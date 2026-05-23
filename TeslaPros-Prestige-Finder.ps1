[CmdletBinding()]
param(
    [switch]$SkipRuntimeScan,
    [switch]$Quiet
)

Set-StrictMode -Version 3
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "TeslaPro's Prestige Finder"

$script:Results = New-Object System.Collections.Generic.List[object]

$script:Config = @{
    Version = "4.1.0"

    PrestigeFileNameNeedles = @(
        "prestige",
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
        "assets/prestige/icons/categories/mace",
        "assets/prestige/icons/hud/potion",
        "assets/prestige/icons/hud/latency",
        "assets/prestige/icons/hud/clock",
        "prestigeclient.vip",
        ".prestigeclient.vip0",
        "prestige_4.properties",
        ".psaclient",
        "prestige injector",
        "prestigeinjector",
        "prestige-injector",
        "prestige_injector"
    )

    RuntimeInjectionPatterns = @(
        [pscustomobject]@{ Label = "Java agent injection"; Pattern = "(?i)-javaagent:"; Risk = 5 },
        [pscustomobject]@{ Label = "Native agent injection"; Pattern = "(?i)-agentpath:"; Risk = 5 },
        [pscustomobject]@{ Label = "Agent library injection"; Pattern = "(?i)-agentlib:"; Risk = 5 },
        [pscustomobject]@{ Label = "Boot classpath injection"; Pattern = "(?i)-Xbootclasspath"; Risk = 5 },
        [pscustomobject]@{ Label = "Fabric addMods injection"; Pattern = "(?i)-Dfabric\.addMods="; Risk = 5 },
        [pscustomobject]@{ Label = "Fabric loadMods injection"; Pattern = "(?i)-Dfabric\.loadMods="; Risk = 5 },
        [pscustomobject]@{ Label = "Fabric custom mod list"; Pattern = "(?i)-Dfabric\.customModList="; Risk = 4 },
        [pscustomobject]@{ Label = "Forge addMods injection"; Pattern = "(?i)-Dforge\.addMods="; Risk = 5 },
        [pscustomobject]@{ Label = "Forge coremod load"; Pattern = "(?i)-Dfml\.coreMods\.load="; Risk = 5 },
        [pscustomobject]@{ Label = "System classloader override"; Pattern = "(?i)-Djava\.system\.class\.loader="; Risk = 5 }
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
}

function Spinner {
    param([string]$Text, [int]$Loops = 10)

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
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "  TESLAPRO'S PRESTIGE FINDER v$($script:Config.Version)" -ForegroundColor Cyan
    Write-Host "  Active PID Scan  •  Prestige File Finder  •  Fast JAR Signature Scanner" -ForegroundColor White
    Write-Host "══════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host ""

    Spinner "Loading scanner modules" 12
    Spinner "Preparing Prestige signatures" 12
    Spinner "Starting scan engine" 12
}

function Section {
    param([string]$Title)

    if ($Quiet) { return }

    Write-Host ""
    Write-Host "[ $Title ]" -ForegroundColor Cyan
}

function Info {
    param([string]$Text)
    if ($Quiet) { return }
    Write-Host "  $Text" -ForegroundColor Gray
}

function Warn {
    param([string]$Text)
    if ($Quiet) { return }
    Write-Host "  [WARN] $Text" -ForegroundColor Yellow
}

function Good {
    param([string]$Text)
    if ($Quiet) { return }
    Write-Host "  [OK] $Text" -ForegroundColor Green
}

function Found {
    param(
        [string]$Type,
        [string]$Match,
        [string]$Location,
        [int]$Risk,
        [string]$Details = ""
    )

    $script:Results.Add([pscustomobject]@{
        Type = $Type
        Match = $Match
        Risk = $Risk
        Location = $Location
        Details = $Details
    })

    if ($Quiet) { return }

    Write-Host "  [FOUND] " -NoNewline -ForegroundColor Red
    Write-Host "$Type " -NoNewline -ForegroundColor Yellow
    Write-Host "-> " -NoNewline -ForegroundColor DarkGray
    Write-Host $Match -ForegroundColor Magenta
    Write-Host "          $Location" -ForegroundColor Gray

    if ($Details) {
        Write-Host "          Strings: $Details" -ForegroundColor DarkCyan
    }
}

function Is-MinecraftRuntimeProcess {
    param($Proc)

    $name = [string]$Proc.Name
    $cmd = [string]$Proc.CommandLine

    return (
        $name -match "java|javaw|minecraft|lunar|badlion|feather|prismlauncher|multimc|modrinth" -or
        $cmd -match "\.minecraft|fabric|forge|lunarclient|feather|badlion|minecraft"
    )
}

function RuntimeScan {
    if ($SkipRuntimeScan) { return }

    Section "ACTIVE MINECRAFT PID / RUNTIME SCAN"
    Spinner "Scanning active Minecraft processes" 10

    $procs = @(Get-CimInstance Win32_Process | Where-Object { Is-MinecraftRuntimeProcess $_ })

    if ($procs.Count -eq 0) {
        Warn "No active Minecraft Java PID found."
        return
    }

    foreach ($proc in $procs) {
        $cmd = [string]$proc.CommandLine

        Info "PID $($proc.ProcessId) | $($proc.Name)"

        foreach ($s in $script:Config.PrestigeExactStrings) {
            if ($cmd.IndexOf($s, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
                Found "Runtime Prestige String" $s "PID $($proc.ProcessId) | $($proc.Name)" 5 $s
            }
        }

        foreach ($rule in $script:Config.RuntimeInjectionPatterns) {
            if ($cmd -match $rule.Pattern) {
                Found "Runtime Injection" $rule.Label "PID $($proc.ProcessId) | $($proc.Name)" $rule.Risk
            }
        }
    }
}

function PrestigeFileNameScan {
    Section "PRESTIGE FILE / FOLDER NAME SCAN"

    foreach ($root in $script:Config.FileScanRoots) {
        if (-not (Test-Path $root)) { continue }

        Spinner "Checking $root" 8

        Get-ChildItem -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            $item = $_
            $name = $item.Name.ToLowerInvariant()
            $full = $item.FullName

            foreach ($needle in $script:Config.PrestigeFileNameNeedles) {
                if ($name.Contains($needle.ToLowerInvariant())) {
                    Found "Prestige Name" $needle $full 3 $needle
                }
            }
        }
    }
}

function PrestigeJarScan {
    Section "PRESTIGE JAR INTERNAL STRING SCAN"

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    foreach ($root in $script:Config.JarScanRoots) {
        if (-not (Test-Path $root)) { continue }

        Spinner "Scanning JARs in $root" 8

        Get-ChildItem -LiteralPath $root -Recurse -Force -File -Filter "*.jar" -ErrorAction SilentlyContinue |
        ForEach-Object {
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
                    Found "JAR Prestige String" "$($unique.Count) string(s)" $jar 5 ($unique -join ", ")
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
        Good "Result      : No Prestige artifacts found."
    } else {
        $risk = ($script:Results | Measure-Object Risk -Sum).Sum

        Write-Host "  Status     : " -NoNewline -ForegroundColor Gray
        Write-Host "REVIEW REQUIRED" -ForegroundColor Red

        Write-Host "  Matches    : " -NoNewline -ForegroundColor Gray
        Write-Host $script:Results.Count -ForegroundColor Yellow

        Write-Host "  Risk Score : " -NoNewline -ForegroundColor Gray
        Write-Host $risk -ForegroundColor Yellow

        Write-Host ""
        $script:Results |
            Sort-Object Risk -Descending |
            Format-Table Type, Match, Risk, Location, Details -AutoSize
    }

    $report = "$env:USERPROFILE\Desktop\TeslaPros-Prestige-Finder-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    $script:Results | Out-File -FilePath $report -Encoding UTF8

    Write-Host ""
    Write-Host "  Report saved: " -NoNewline -ForegroundColor Green
    Write-Host $report -ForegroundColor Gray
}

Banner
RuntimeScan
PrestigeFileNameScan
PrestigeJarScan
Summary

Write-Host ""
Read-Host "Press ENTER to exit"