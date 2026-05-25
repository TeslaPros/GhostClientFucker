[CmdletBinding()]
param(
    [switch]$SkipRuntimeScan,
    [switch]$SkipBrowserScan,
    [switch]$Quiet
)

Set-StrictMode -Version 3
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "TeslaPro's Prestige Finder (Optimized)"

$script:Results = New-Object System.Collections.Generic.List[object]

$script:Config = @{
    Version = "4.2.0-Optimized"

    # Strict file matching needles to avoid matching basic words
    PrestigeFileNameNeedles = @(
        "prestigeclient",
        "prestige injector",
        "prestigeinjector",
        "prestige-injector",
        "prestige_injector",
        ".psaclient"
    )

    PrestigeExactStrings = @(
        "dev/zprestige/prestige",
        "dev/zprestige/prestige/client/Prestige",
        "dev.zprestige.prestige",
        "assets/prestige/sounds/pop2.wav",
        "assets/prestige/sounds/pop3.wav",
        "assets/prestige/font/inter/json",
        "prestigeclient.vip"
    )

    RuntimeInjectionPatterns = @(
        [pscustomobject]@{ Label = "Java agent injection"; Pattern = "(?i)-javaagent:"; Risk = 5 },
        [pscustomobject]@{ Label = "Native agent injection"; Pattern = "(?i)-agentpath:"; Risk = 5 },
        [pscustomobject]@{ Label = "Boot classpath injection"; Pattern = "(?i)-Xbootclasspath"; Risk = 5 },
        [pscustomobject]@{ Label = "Fabric addMods injection"; Pattern = "(?i)-Dfabric\.addMods="; Risk = 5 },
        [pscustomobject]@{ Label = "Forge addMods injection"; Pattern = "(?i)-Dforge\.addMods="; Risk = 5 }
    )

    FileScanRoots = @(
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents",
        "$env:APPDATA",
        "$env:LOCALAPPDATA",
        "$env:TEMP"
    )

    JarScanRoots = @(
        "$env:APPDATA\.minecraft\mods",
        "$env:APPDATA\.minecraft\versions",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop"
    )

    # Browser History Paths (Chrome & Edge)
    BrowserHistoryPaths = @(
        @{ Name = "Google Chrome"; Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History" },
        @{ Name = "Microsoft Edge"; Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History" }
    )
}

function Spinner {
    param([string]$Text, [int]$Loops = 6)
    if ($Quiet) { return }
    $frames = @("⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏")
    for ($i = 0; $i -lt $Loops; $i++) {
        Write-Host "`r  $($frames[$i % $frames.Count]) $Text" -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 35
    }
    Write-Host "`r  ✓ $Text" -ForegroundColor Green
}

function Banner {
    if ($Quiet) { return }
    Clear-Host
    Write-Host "`n══════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "  TESLAPRO'S PRESTIGE FINDER v$($script:Config.Version)" -ForegroundColor Cyan
    Write-Host "  PID Scan  •  File Signatures  •  JAR Scanner  •  Browser History Analyzer" -ForegroundColor White
    Write-Host "══════════════════════════════════════════════════════════════════════════════`n"
    Spinner "Loading engine profiles" 6
}

function Section { param([string]$Title) if ($Quiet) { return }; Write-Host "`n[ $Title ]" -ForegroundColor Cyan }
function Info { param([string]$Text) if ($Quiet) { return }; Write-Host "  $Text" -ForegroundColor Gray }
function Warn { param([string]$Text) if ($Quiet) { return }; Write-Host "  [WARN] $Text" -ForegroundColor Yellow }
function Good { param([string]$Text) if ($Quiet) { return }; Write-Host "  [OK] $Text" -ForegroundColor Green }

function Found {
    param([string]$Type, [string]$Match, [string]$Location, [int]$Risk, [string]$Details = "")
    $script:Results.Add([pscustomobject]@{ Type = $Type; Match = $Match; Risk = $Risk; Location = $Location; Details = $Details })
    if ($Quiet) { return }
    Write-Host "  [FOUND] " -NoNewline -ForegroundColor Red
    Write-Host "$Type -> " -NoNewline -ForegroundColor Yellow
    Write-Host $Match -ForegroundColor Magenta
    Write-Host "          $Location" -ForegroundColor Gray
    if ($Details) { Write-Host "          Details: $Details" -ForegroundColor DarkCyan }
}

function Is-MinecraftRuntimeProcess {
    param($Proc)
    $name = [string]$Proc.Name
    $cmd = [string]$Proc.CommandLine
    return ($name -match "java|javaw|minecraft|lunar|badlion|feather|prismlauncher" -or $cmd -match "\.minecraft|fabric|forge|lunarclient")
}

function RuntimeScan {
    if ($SkipRuntimeScan) { return }
    Section "ACTIVE MINECRAFT PROCESS SCAN"
    $procs = @(Get-CimInstance Win32_Process | Where-Object { Is-MinecraftRuntimeProcess $_ })
    if ($procs.Count -eq 0) { Warn "No active Minecraft Java processes found."; return }

    foreach ($proc in $procs) {
        $cmd = [string]$proc.CommandLine
        foreach ($s in $script:Config.PrestigeExactStrings) {
            if ($cmd.IndexOf($s, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
                Found "Runtime Cheat String" $s "PID $($proc.ProcessId)" 5 $s
            }
        }
        foreach ($rule in $script:Config.RuntimeInjectionPatterns) {
            if ($cmd -match $rule.Pattern) {
                Found "Suspicious Arguments" $rule.Label "PID $($proc.ProcessId)" $rule.Risk
            }
        }
    }
}

function BrowserHistoryScan {
    if ($SkipBrowserScan) { return }
    Section "BROWSER HISTORY & DOWNLOADS SCAN"

    foreach ($browser in $script:Config.BrowserHistoryPaths) {
        $dbPath = $browser.Path
        if (-not (Test-Path $dbPath)) { continue }
        
        Spinner "Analyzing $($browser.Name) History Records" 8
        $tempDb = "$env:TEMP\br_hist_tmp.db"
        
        try {
            # Copy file locally because the browser database locks up if open
            Copy-Item -LiteralPath $dbPath -Destination $tempDb -Force -ErrorAction SilentlyContinue
            
            # Use basic Regex reading directly over the DB binary data streams instead of requiring heavy SQL modules
            $fileContent = [System.IO.File]::ReadAllText($tempDb, [System.Text.Encoding]::GetEncoding("ISO-8859-1"))
            
            if ($fileContent -match "prestigeclient\.vip") {
                Found "Web Footprint" "Visited/Downloaded from prestigeclient.vip" $browser.Name 4 "Browser Cache/History Entry Found"
            }
        } catch {}
        finally {
            if (Test-Path $tempDb) { Remove-Item -Path $tempDb -Force -ErrorAction SilentlyContinue }
        }
    }
}

function PrestigeFileNameScan {
    Section "FILTERED FILE & FOLDER NAME SCAN"

    foreach ($root in $script:Config.FileScanRoots) {
        if (-not (Test-Path $root)) { continue }
        Spinner "Checking $root" 6

        Get-ChildItem -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            $item = $_
            $full = $item.FullName
            
            # Skip massive native Windows/Microsoft subfolders to decrease false flags dramatically
            if ($full -match "AppData\\Local\\Microsoft" -or $full -match "PackageAware") { return }

            $name = $item.Name.ToLowerInvariant()
            foreach ($needle in $script:Config.PrestigeFileNameNeedles) {
                if ($name.Contains($needle)) {
                    Found "Prestige Named Artifact" $needle $full 3 "Matched exact signature keyword: $needle"
                }
            }
        }
    }
}

function PrestigeJarScan {
    Section "JAR CONTAINER INTERNALS SCAN"
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    foreach ($root in $script:Config.JarScanRoots) {
        if (-not (Test-Path $root)) { continue }
        Spinner "Parsing compiled JAR archives in $root" 6

        Get-ChildItem -LiteralPath $root -Recurse -Force -File -Filter "*.jar" -ErrorAction SilentlyContinue | ForEach-Object {
            $jar = $_.FullName
            try {
                $zip = [System.IO.Compression.ZipFile]::OpenRead($jar)
                $foundStrings = New-Object System.Collections.Generic.List[string]

                foreach ($entry in $zip.Entries) {
                    $entryName = $entry.FullName
                    foreach ($s in $script:Config.PrestigeExactStrings) {
                        if ($entryName.IndexOf($s, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
                            $foundStrings.Add($s)
                        }
                    }
                }
                $zip.Dispose()
                $unique = @($foundStrings | Select-Object -Unique)
                if ($unique.Count -gt 0) {
                    Found "Malicious Mod Internals" "$($unique.Count) signature path(s)" $jar 5 ($unique -join ", ")
                }
            } catch {}
        }
    }
}

function Summary {
    Section "SCAN SUMMARY"
    if ($script:Results.Count -eq 0) {
        Good "Status      : CLEAN"
        Good "Detections  : 0"
        Good "Result      : No verified Prestige Client trace found."
    } else {
        $risk = ($script:Results | Measure-Object Risk -Sum).Sum
        Write-Host "  Status     : " -NoNewline -ForegroundColor Gray
        Write-Host "ATTENTION REQUIRED" -ForegroundColor Red
        Write-Host "  Matches    : " -NoNewline -ForegroundColor Gray; Write-Host $script:Results.Count -ForegroundColor Yellow
        Write-Host "  Total Risk : " -NoNewline -ForegroundColor Gray; Write-Host $risk -ForegroundColor Yellow
        Write-Host ""
        $script:Results | Sort-Object Risk -Descending | Format-Table Type, Match, Risk, Location -AutoSize
    }

    $report = "$env:USERPROFILE\Desktop\Prestige-Scanner-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    $script:Results | Out-File -FilePath $report -Encoding UTF8
    Write-Host "`n  Report stored safely to: " -NoNewline -ForegroundColor Green
    Write-Host $report -ForegroundColor Gray
}

Banner
RuntimeScan
BrowserHistoryScan
PrestigeFileNameScan
PrestigeJarScan
Summary

Write-Host ""
Read-Host "Press ENTER to complete execution"