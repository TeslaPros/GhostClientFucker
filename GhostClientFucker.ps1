[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
Clear-Host

$currentFont = (Get-ItemProperty "HKCU:\Console" -ErrorAction SilentlyContinue).FaceName
if ($currentFont -notmatch "NSimSun|Gothic|Noto") {
    Write-Host "  [!] Tip: Set your terminal font to 'NSimSun' to display all elements correctly." -ForegroundColor DarkYellow
    Write-Host
}

$Banner = @"
  ████████╗███████╗███████╗██╗      █████╗ ██████╗ ██████╗  ██████╗ 
  ╚══██╔══╝██╔════╝██╔════╝██║     ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗
     ██║   █████╗  ███████╗██║     ███████║██████╔╝██████╔╝██║   ██║
     ██║   ██╔══╝  ╚════██║██║     ██╔══██║██╔═══╝ ██╔══██╗██║   ██║
     ██║   ███████╗███████║███████╗██║  ██║██║     ██║  ██║╚██████╔╝
     ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ 
                                                                    
   ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗  ██████╗██╗     ██╗███████╗███╗   ██╗████████╗
  ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝ ██╔════╝██║     ██║██╔════╝████╗  ██║╚══██╔══╝
  ██║  ███╗███████║██║   ██║███████╗   ██║    ██║     ██║     ██║█████╗  ██╔██╗ ██║   ██║   
  ██║   ██║██╔══██║██║   ██║╚════██║   ██║    ██║     ██║     ██║██╔══╝  ██║╚██╗██║   ██║   
  ╚██████╔╝██║  ██║╚██████╔╝███████║   ██║    ╚██████╗███████╗██║███████╗██║ ╚████║   ██║   
   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝     ╚═════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   
                                                                                            
  -> FUCKER EDITION <-
"@

function Write-Row {
    param([string]$char, [int]$count, [System.ConsoleColor]$color)
    Write-Host ($char * $count) -ForegroundColor $color
}

Write-Host $Banner -ForegroundColor Cyan
Write-Host ""
Write-Host "  ⚡ Powered by " -ForegroundColor Gray -NoNewline
Write-Host "TeslaPro " -ForegroundColor Cyan -NoNewline
Write-Host "|| " -ForegroundColor DarkGray -NoNewline
Write-Host "Discord: " -ForegroundColor Gray -NoNewline
Write-Host "teamwsf " -ForegroundColor White -NoNewline
Write-Host "|| " -ForegroundColor DarkGray -NoNewline
Write-Host "Credits to: " -ForegroundColor DarkGray -NoNewline
Write-Host "MeowTonynoh" -ForegroundColor DarkGray
Write-Host ""
Write-Row "─" 85 DarkGray
Write-Host

Write-Host "  [>] Enter the path to the mods folder: " -NoNewline -ForegroundColor White
Write-Host "(Press Enter for default)" -ForegroundColor DarkGray
$modsPath = Read-Host "  "
Write-Host

if ([string]::IsNullOrWhiteSpace($modsPath)) {
    $modsPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"
    Write-Host "  [+] Starting with default location: " -NoNewline -ForegroundColor Gray
    Write-Host $modsPath -ForegroundColor White
    Write-Host
}

if (-not (Test-Path $modsPath -PathType Container)) {
    Write-Host "  [X] ERROR: Invalid Path!" -ForegroundColor Red
    Write-Host "  [-] The specified directory does not exist or is inaccessible." -ForegroundColor Yellow
    Write-Host
    Write-Host "  [-] Attempted directory: $modsPath" -ForegroundColor Gray
    Write-Host
    Write-Host "  [i] Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Row "═" 85 DarkCyan
Write-Host "  [►] SCAN MODE ACTIVATED ON: $modsPath" -ForegroundColor Green
Write-Row "═" 85 DarkCyan
Write-Host

$mcProcess = Get-Process javaw -ErrorAction SilentlyContinue
if (-not $mcProcess) {
    $mcProcess = Get-Process java -ErrorAction SilentlyContinue
}

if ($mcProcess) {
    try {
        $startTime = $mcProcess.StartTime
        $uptime = (Get-Date) - $startTime
        Write-Host "  ┌── { Minecraft Runtime Status }" -ForegroundColor Cyan
        Write-Host "  ├── Process: $($mcProcess.Name) (PID $($mcProcess.Id))" -ForegroundColor Gray
        Write-Host "  ├── Started on: $startTime" -ForegroundColor Gray
        Write-Host "  └── Uptime:     $($uptime.Hours)h $($uptime.Minutes)m $($uptime.Seconds)s" -ForegroundColor Gray
        Write-Host ""
    } catch { }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$suspiciousPatterns = @(
    "AimAssist", "AnchorTweaks", "AutoAnchor", "AutoCrystal", "AutoDoubleHand",
    "AutoHitCrystal", "AutoPot", "AutoTotem", "AutoArmor", "InventoryTotem",
    "JumpReset", "LegitTotem", "PingSpoof", "SelfDestruct",
    "ShieldBreaker", "TriggerBot", "AxeSpam", "WebMacro",
    "FastPlace", "WalskyOptimizer", "WalksyOptimizer", "walsky.optimizer",
    "WalksyCrystalOptimizerMod", "Donut", "Replace Mod",
    "ShieldDisabler", "SilentAim", "Totem Hit", "Wtap", "FakeLag",
    "BlockESP", "dev.krypton", "Virgin", "AntiMissClick",
    "LagReach", "PopSwitch", "SprintReset", "ChestSteal", "AntiBot",
    "ElytraSwap", "FastXP", "FastExp", "Refill",  "AirAnchor",
    "jnativehook", "FakeInv", "HoverTotem", "AutoClicker", "AutoFirework",
    "PackSpoof", "Antiknockback", "catlean", "Argon",
    "AuthBypass", "Asteria", "Prestige", "AutoEat", "AutoMine",
    "MaceSwap", "DoubleAnchor", "AutoTPA", "BaseFinder", "Xenon", "gypsy",
    "Grim", "grim",
    "org.chainlibs.module.impl.modules.Crystal.Y",
    "org.chainlibs.module.impl.modules.Crystal.bF",
    "org.chainlibs.module.impl.modules.Crystal.bM",
    "org.chainlibs.module.impl.modules.Crystal.bY",
    "org.chainlibs.module.impl.modules.Crystal.bq",
    "org.chainlibs.module.impl.modules.Crystal.cv",
    "org.chainlibs.module.impl.modules.Crystal.o",
    "org.chainlibs.module.impl.modules.Blatant.I",
    "org.chainlibs.module.impl.modules.Blatant.bR",
    "org.chainlibs.module.impl.modules.Blatant.bx",
    "org.chainlibs.module.impl.modules.Blatant.cj",
    "org.chainlibs.module.impl.modules.Blatant.dk",
    "imgui.gl3", "imgui.glfw",
    "BowAim", "Criticals", "Fakenick", "FakeItem",
    "invsee", "ItemExploit", "Hellion", "hellion",
    "LicenseCheckMixin", "ClientPlayerInteractionManagerAccessor",
    "ClientPlayerEntityMixim", "dev.gambleclient", "obfuscatedAuth",
    "phantom-refmap.json", "xyz.greaj",
    "じ.class", "ふ.class", "ぶ.class", "ぷ.class", "た.class",
    "ね.class", "そ.class", "な.class", "ど.class", "ぐ.class",
    "ず.class", "で.class", "つ.class", "べ.class", "せ.class",
    "と.class", "み.class", "び.class", "す.class", "の.class"
)

$cheatStrings = @(
    "AutoCrystal", "autocrystal", "auto crystal", "cw crystal",
    "dontPlaceCrystal", "dontBreakCrystal",
    "AutoHitCrystal", "autohitcrystal", "canPlaceCrystalServer", "healPotSlot",
    "ＡｕｔｏＣｒｙｓｔａｌ", "Ａｕｔｏ Ｃｒｙｓｔａｌ",
    "ＡｕｔｏＨｉｔＣｒｙｓｔａｌ",
    "AutoAnchor", "autoanchor", "auto anchor", "DoubleAnchor",
     "HasAnchor", "anchortweaks", "anchor macro", "safe anchor", "safeanchor",
    "SafeAnchor", "AirAnchor",
    "ＡｕｔｏＡｎｃｈｏｒ", "Ａｕｔｏ Ａｎｃｈｏｒ",
    "ＤｏｕｂｌｅＡｎｃｈｏｒ", "Ｄｏｕｂｌｅ Ａｎｃｈｏ r",
    "ＳａｆｅＡｎｃｈｏｒ", "Ｓａｆｅ Ａｎｃｈｏ r",
    "Ａｎｃｈｏｒ Ｍａｃｒｏ", "anchorMacro",
    "AutoTotem", "autototem", "auto totem", "InventoryTotem",
    "inventorytotem", "HoverTotem", "hover totem", "legittotem",
    "ＡｕｔｏＴｏｔｅｍ", "Ａｕｔｏ Ｔｏｔｅｍ",
    "ＨｏｖｅｒＴｏｔｅｍ", "Ｈｏｖｅｒ Ｔｏｔｅｍ",
    "ＩｎｖｅｎｔｏｒｙＴｏｔｅｍ", "Ａｕｔｏ Ｉｎｖｅｎｔｏｒｙ Ｔｏｔｅｍ",
    "Ａｕｔｏ Ｔｏｔｅｍ Ｈｉｔ",
    "AutoPot", "autopot", "auto pot", "speedPotSlot", "strengthPotSlot",
    "AutoArmor", "autoarmor", "auto armor",
    "ＡｕｔｏＰｏｔ", "Ａｕｔｏ Ｐｏｔ",
    "Ａｕｔｏ Ｐｏｔ Ｒｅｆｉｌｌ", "AutoPotRefill",
    "ＡｕｔｏＡｒｍｏｒ", "Ａｕｔｏ Ａｒｍｏ r",
    "preventSwordBlockBreaking", "preventSwordBlockAttack",
    "ShieldDisabler", "ShieldBreaker",
    "ＳｈｉｅｌｄＤｉｓａｂｌｅｒ", "Ｓｈｉｅｌｄ Ｄｉｓａｂｌｅｒ",
    "Breaking shield with axe...",
    "AutoDoubleHand", "autodoublehand", "auto double hand",
    "ＡｕｔｏＤｏｕｂｌｅＨａｎｄ", "Ａｕｔｏ Ｄｏｕｂｌｅ Ｈａｎｄ",
    "AutoClicker",
    "ＡｕｔｏＣｌｉｃｋｅｒ",
    "Failed to switch to mace after axe!",
    "AutoMace", "MaceSwap", "SpearSwap",
    "ＡｕｔｏＭａｃｅ", "Ａｕｔｏ Ｍａｃｅ",
    "ＭａｃｅＳｗａｐ", "Ｍａｃｅ Ｓｗａｐ",
    "Ｓｐｅａｒ Ｓｗａｐ", "Ａｕｔｏｍａｔｉｃａｌｌｙ ａｘｅ ａｎ d ｍａｃｅ ｓｈｉｅｌｄｅｄ ｐｌａｙｅｒｓ",
    "Ｓｔｕｎ Ｓｌａｍ", "StunSlam",
    "Donut", "JumpReset", "axespam", "axe spam",
    "EndCrystalItemMixin",
    "findKnockbackSword", "attackRegisteredThisClick",
    "AimAssist", "aimassist", "aim assist",
    "triggerbot", "trigger bot",
    "ＡｉｍＡｓｓｉｓｔ", "Ａｉｍ Ａｓｓｉｓｔ",
    "ＴrｉｇｇｅｒＢｏｔ", "Ｔｒｉｇｇｅｒ Ｂｏｔ",
    "Silent Rotations", "SilentRotations",
    "Ｓｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ",
    "FakeInv", "swapBackToOriginalSlot",
    "FakeLag", "pingspoof", "ping spoof",
    "ＦａｋｅＬａｇ", "Ｆａｋｅ Ｌａｇ",
    "fakePunch", "Fake Punch",
    "Ｆａｋｅ Ｐｕｎｃｈ",
    "webmacro", "web macro",
    "AntiWeb", "AutoWeb",
    "Ａｎｔｉ Ｗｅｂ", "ＡｕｔｏＷｅｂ",
    "Ｐｌａｃｅｓ Ｗｅｂｓ Ｏｎ Ｅｎｅｍｉｅｓ",
    "lvstrng", "dqrkis", "selfdestruct", "self destruct",
    "WalksyCrystalOptimizerMod", "WalksyOptimizer", "WalskyOptimizer",
    "Ｗａｌｋｓｙ Ｏｐｔｉｍｉｚｅｒ",
    "autoCrystalPlaceClock",
    "AutoFirework", "ElytraSwap", "FastXP", "FastExp", "NoJumpDelay",
    "ＥｌｙｔｒａＳｗａｐ", "Ｅｌｙｔｒａ Ｓｗａｐ",
    "PackSpoof", "Antiknockback", "catlean",
    "AuthBypass", "obfuscatedAuth", "LicenseCheckMixin",
    "BaseFinder", "invsee", "ItemExploit",
    "FreezePlayer",
    "Ｆrｅｅｃａｍ", "Ｍｏｖｅ ｆrｅｅｌｙ ｔｈｒｏｕｇｈ ｗａｌｌｓ",
    "Ｎｏ Ｃｌｉｐ", "Ｆrｅｅｚｅ Ｐｌａｙｅｒ",
    "LWFH Crystal",
    "ＬＷＦＨ Ｃｒyｓｔａｌ",
    "KeyPearl", "LootYeeter",
    "ＫｅｙＰｅａｒl", "Ｋｅｙ Ｐｅａｒｌ",
    "Ｌｏｏｔ Ｙｅｅｔｅｒ",
    "FastPlace",
    "Ｆａｓｔ Ｐｌａｃｅ", "Ｐｌａｃｅ ｂｌｏｃｋｓ ｆａｓｔｅ r",
    "AutoBreach",
    "Ａｕｔｏ Ｂｒｅａｃｈ",
    "setBlockBreakingCooldown", "getBlockBreakingCooldown", "blockBreakingCooldown",
    "onBlockBreaking", "setItemUseCooldown",
    "setSelectedSlot", "invokeDoAttack", "invokeDoItemUse", "invokeOnMouseButton",
    "onPushOutOfBlocks", "onIsGlowing",
    "Automatically switches to sword when hitting with totem",
    "arrayOfString", "POT_CHEATS",
    "Dqrkis Client", "Entity.isGlowing",
    "Activate Key", "Ａｃｔｉｖａｔｅ Ｋｅｙ",
    "Click Simulation", "Ｃｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ",
    "On RMB", "Ｏｎ ＲＭＢ",
    "No Count Glitch", "Ｎｏ Ｃｏｕｎｔ Ｇｌｉｔｃｈ",
    "No Bounce", "NoBounce", "Ｎｏ Ｂｏｕｎｃｅ", "ＮｏＢｏｕｎｃｅ",
    "Ｒｅｍｏｖｅｓ ｔｈｅ ｃｒyｓｔａｌ ｂｏｕｎｃｅ ａｎｉｍａｔｉｏｎ",
    "Place Delay", "Ｐｌａｃｅ Ｄｅｌａｙ",
    "Break Delay", "Ｂrｅａｋ Ｄｅｌａｙ",
    "Fast Mode", "Ｆａｓｔ Ｍｏｄｅ",
    "Place Chance", "Ｐｌａｃｅ Ｃhandling",
    "Break Chance", "Ｂｒｅａｋ Ｃhandling",
    "Stop On Kill", "Ｓｔｏｐ Ｏｎ Ｋｉｌｌ",
    "Ｄａｍａｇｅ Ｔｉｃｋ", "damagetick",
    "Anti Weakness", "Ａｎｔｉ Ｗｅａｋｎｅｓｓ",
    "Particle Chance", "Ｐａｒｔｉｃｌｅ Ｃhandling",
    "Trigger Key", "Ｔｒｉｇｇｅｒ Ｋｅy",
    "Switch Delay", "Ｓｗｉｔｃｈ Ｄｅｌａｙ",
    "Totem Slot", "Ｔｏｔｅｍ Ｓｌｏｔ",
    "Silent Rotations", "Ｓｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ",
    "Smooth Rotations", "Ｓｍｏｏｔｈ Ｒｏｔａｔｉｏｎｓ",
    "Rotation Speed", "Ｒｏｔａｔｉｏｎ Ｓｐｅｅｄ",
    "Use Easing", "Ｕｓｅ Ｅａｓｉｎｇ",
    "Easing Strength", "Ｅａｓｉｎｇ Ｓｔｒｅｎｇｔｈ",
    "While Use", "Ｗｈｉｌｅ Ｕｓｅ",
    "Stop on Kill", "Ｓｔｏｐ ｏｎ Ｋｉｌ l",
    "Click Simulation", "Ｃｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ",
    "Glowstone Delay", "Ｇｌｏ wｓｔｏｎｅ Ｄｅｌａｙ",
    "Glowstone Chance", "Ｇｌｏ wｓｔｏｎｅ Ｃhandling",
    "Explode Delay", "Ｅｘｐｌｏｄｅ Ｄｅｌａｙ",
    "Explode Chance", "Ｅｘｐｌｏｄｅ Ｃhandling",
    "Explode Slot", "Ｅｘｐｌｏｄｅ Ｓｌｏｔ",
    "Only Charge", "Ｏｎｌy Ｃｈａｒｇｅ",
    "Anchor Macro", "Ａｎｃｈｏｒ Ｍａｃｒｏ",
    "Reach Distance", "Ｒｅａｃｈ Ｄｉｓｔａｎｃｅ",
    "Min Height", "Ｍｉｎ Ｈｅｉｇｈｔ",
    "Min Fall Speed", "Ｍｉｎ Ｆａｌｌ Ｓｐｅｅｄ",
    "Attack Delay", "Ａｔｔａｃｋ Ｄｅｌａｙ",
    "Breach Delay", "Ｂｒｅａｃｈ Ｄｅｌａy",
    "Require Elytra", "Ｒｅｑｕiｒｅ Ｅｌyｔｒａ",
    "Auto Switch Back", "Ａｕｔｏ Ｓ wｉｔｃｈ Ｂａｃｋ",
    "Check Line of Sight", "Ｃ... Check Line of Sight",
    "Only When Falling", "Ｏｎｌy Ｗｈｅｎ Ｆａｌｌｉｎｇ",
    "Require Crit", "Ｒｅｑｕｉｒｅ Ｃｒiｔ",
    "Show Status Display", "Ｓｈｏ w Ｓｔａｔｕｓ Ｄｉｓｐｌａｙ",
    "Stop On Crystal", "Ｓｔｏｐ Ｏｎ Ｃｒyｓｔａｌ",
    "Check Shield", "Ｃhｅｃk Ｓ... Shield",
    "On Pop", "Ｏｎ Ｐｏｐ",
    "Predict Damage", "Ｐｒｅｄｉｃｔ Ｄａｍａｇｅ",
    "On Ground", "Ｏｎ Ｇｒｏｕｎｄ",
    "Check Players", "Ｃｈｅｃｋ Ｐｌａyｅｒｓ",
    "Predict Crystals", "Ｐrｅｄｉｃｔ Ｃｒyｓｔａｌｓ",
    "Check Aim", "Ｃhｅｃｋ Ａｉｍ",
    "Check Items", "Ｃｈｅｃｋ Ｉｔｅｍｓ",
    "Activates Above", "Ａｃｔｉｖａｔｅｓ Ａｂｏｖｅ",
    "Blatant", "Ｂｌａｔａｎｔ",
    "Force Totem", "... Force Totem",
    "Stay Open For", "Ｓｔａy Ｏｐｅｎ Ｆｏｒ",
    "Auto Inventory Totem", "Ａｕｔｏ Ｉｎｖｅｎｔｏｒy Ｔｏｔｅｍ",
    "Only On Pop", "Ｏｎｌy Ｏｎ Ｐｏｐ",
    "Vertical Speed", "Ｖｅｒｔｉｃａｌ Ｓｐｅｅｄ",
    "Hover Totem", "Ｈｏｖｅ r Ｔｏｔｅｍ",
    "Swap Speed", "Ｓ wａｐ Ｓｐｅｅｄ",
    "Strict One-Tick", "Ｓｔｒｉｃｔ Ｏｎｅ－Ｔｉｃｋ",
    "Mace Priority", "Ｍａｃｅ Ｐｒｉｏｒｉｔy",
    "Min Totems", "Ｍｉｎ Ｔｏｔｅｍｓ",
    "Min Pearls", "Ｍｉｎ Ｐｅａｒｌｓ",
    "Totem First", "Ｔｏｔｅｍ Ｆｉｒｓｔ",
    "Drop Interval", "Ｄｒｏｐ Ｉｎｔｅｒｖａｌ",
    "Random Pattern", "Ｒａｎｄｏｍ Ｐａｔｔｅｒｎ",
    "Loot Yeeter", "Ｌｏｏｔ Ｙｅｅｔｅｒ",
    "Horizontal Aim Speed", "Ｈｏｒｉｚｏｎｔａｌ Ａｉｍ Ｓｐｅｅｄ",
    "Vertical Aim Speed", "Ｖｅｒｔｉｃａｌ Ａｉｍ Ｓｐｅｅｄ",
    "Include Head", "Ｉ... Include Head",
    "Web Delay", "Ｗｅｂ Ｄｅｌａｙ",
    "Holding Web", "Ｈｏｌｄｉｎｇ Ｗｅｂ",
    "Not When Affects Player", "Ｎｏｔ Ｗｈｅｎ Ａｆｆｅｃｔｓ Ｐｌａｙｅ r",
    "Hit Delay", "Ｈｉｔ Ｄｅｌａy",
    "Ｓ wｉｔｃｈ Ｂａｃｋ",
    "Require Hold Axe", "Ｒｅｑｕｉｒｅ Ｈｏｌｄ Ａｘｅ",
    "Fake Punch", "Ｆａｋｅ Ｐｕｎｃｈ",
    "placeInterval", "breakInterval", "stopOnKill",
    "activateOnRightClick", "holdCrystal",
    "ｐｌａｃｅＩｎｔｅｒｖａｌ", "ｂrｅａｋＩｎｔｅｒｖａｌ",
    "ｓｔｏｐＯｎＫｉｌｌ", "ａｃｔｉｖａｔｅＯｎＲｉｇｈｔＣｌｉｃｋ",
    "ｄａｍａｇｅｔｉｃｋ", "ｈｏｌｄＣrｙｓｔａｌ",
    "ｆａｋｅＰｕｎｃｈ",
    "Ｒｅｆｉｌｌｓ ｙｏｕr ｈｏｔｂａｒ ｗｉｔｈ ｐｏｔｉｏｎｓ",
    "Ｋｅｐｓ ｙｏｕ ｓｐｒｉｎｔｉｎｇ ａｔ ａｌｌ ｔｉｍｅｓ",
    "Ｐｌａｃｅｓ ａｎｃｈｏｒ， ｃｈａｒｇｅｓ ｉｔ， ｐrｏｔｅｃｔｓ ｙｏｕ， ａｎｄ ｅｘｐｌｏｄｅｓ",
    "Ａｕｔｏ ｓ wａｐ ｔｏ ｓｐｅａｒ ｏｎ ａｔｔａｃｋ",
    "Macro Key", "Ａｕｔｏ Ｐｏｔ", "Ｍａｃｒｏ Ｋｅy",
    "KillAura", "ClickAura", "MultiAura", "ForceField", "LegitAura",
    "AimBot", "AutoAim", "SilentAim", "AimLock", "HeadSnap",
    "CrystalAura",
    "AnchorAura", "AnchorFill", "AnchorPlace",
    "BedAura", "AutoBed", "BedBomb", "BedPlace",
    "BowAimbot", "BowSpam", "AutoBow",
    "AutoCrit", "CritBypass", "AlwaysCrit", "CriticalHit",
    "ReachHack", "ExtendReach", "LongReach", "HitboxExpand",
    "AntiKB", "NoKnockback", "GrimVelocity", "GrimDisabler", "VelocitySpoof", "KBReduce",
    "OffhandTotem", "TotemSwitch",
    "AutoWeapon", "AutoSword", "AutoCity", "Burrow", "SelfTrap",
    "HoleFiller", "AntiSurround", "AntiBurrow",
    "WTap", "TargetStrafe", "AutoGap", "AutoPearl",
    "FlyHack", "CreativeFlight", "BoatFly", "PacketFly", "AirJump",
    "SpeedHack", "BHop", "BunnyHop",
    "AntiFall", "NoFallDamage", "SafeFall",
    "StepHack", "FastClimb", "AutoStep", "HighStep",
    "WaterWalk", "LiquidWalk", "LavaWalk",
    "NoSlow", "NoSlowdown", "NoWeb", "NoSoulSand",
    "WallHack",
    "ElytraSpeed", "InstantElytra",
    "ScaffoldWalk", "FastBridge", "BuildHelper", "AutoBridge",
    "Nuker", "NukerLegit", "InstantBreak",
    "GhostHand", "NoSwing",
    "PlaceAssist", "AirPlace", "AutoPlace", "InstantPlace",
    "PlayerESP", "MobESP", "ItemESP", "StorageESP", "ChestESP",
    "Tracers", "NameTagsHack",
    "XRayHack", "OreFinder", "CaveFinder", "OreESP",
    "NewChunks", "ChunkBorders", "TunnelFinder",
    "TargetHUD", "ReachDisplay",
    "DoubleClicker", "JitterClick", "ButterflyClick", "CPSBoost",
    "ChestStealer", "InvManager", "InvMovebypass",
    "AutoSprint", "AntiAFK", "AutoRespawn",
    "FakeNick", "PopSwitch",
    "FakeLatency", "FakePing", "SpoofRotation", "PositionSpoof",
    "GameSpeed", "SpeedTimer",
    "GrimBypass", "VulcanBypass", "MatrixBypass",
    "AACBypass", "VerusDisabler", "IntaveBypass", "WatchdogBypass",
    "PacketMine", "PacketWalk", "PacketSneak", "PacketCancel", "PacketDupe", "PacketSpam",
    "SelfDestruct", "HideClient",
    "SessionStealer", "TokenLogger", "TokenGrabber", "DiscordToken",
    "RemoteAccess", "ReverseShell", "C2Server", "Backdoor", "KeyLogger",
    "StashFinder", "TrailFinder",
    "imgui.binding",
    "JNativeHook", "GlobalScreen", "NativeKeyListener",
    "client-refmap.json", "cheat-refmap.json",
    "aHR0cDovL2FwaS5ub3ZhY2xpZW50LmxvbC93ZWJob29rLnR4dA==",
    "meteordevelopment", "cc/novoline",
    "com/alan/clients", "club/maxstats", "wtf/moonlight",
    "me/zeroeightsix/kami", "net/ccbluex", "today/opai",
    "net/minecraft/injection", "org/chainlibs/module/impl/modules",
    "xyz/greaj", "com/cheatbreaker", "com/moonsworth",
    "doomsdayclient", "DoomsdayClient", "doomsday.jar",
    "novaclient", "api.novaclient.lol",
    "WalksyOptimizer", "LWFH Crystal",
    "vape.gg", "vapeclient", "VapeClient", "VapeLite",
    "intent.store", "IntentClient",
    "rise.today", "riseclient.com",
    "meteor-client", "meteorclient", "meteordevelopment.meteorclient",
    "liquidbounce", "fdp-client", "net.ccbluex",
    "novoware", "novoclient",
    "aristois", "impactclient", "azura",
    "pandaware", "skilled", "moonClient", "astolfo",
    "futureClient", "konas", "rusherhack", "inertia", "exhibition"
)

$patternRegex = [regex]::new(
    '(?<![A-Za-z])(' + ($suspiciousPatterns -join '|') + ')(?![A-Za-z])',
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

$cheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $cheatStrings) { [void]$cheatStringSet.Add($s) }

function Get-FileSHA1 {
    param([string]$Path)
    return (Get-FileHash -Path $Path -Algorithm SHA1).Hash
}

function Get-DownloadSource {
    param([string]$Path)
    $zoneData = Get-Content -Raw -Stream Zone.Identifier $Path -ErrorAction SilentlyContinue
    if ($zoneData -match "HostUrl=(.+)") {
        $url = $matches[1].Trim()
        if ($url -match "mediafire\.com")                         { return "MediaFire" }
        elseif ($url -match "discord\.com|discordapp\.com|cdn\.discordapp\.com") { return "Discord" }
        elseif ($url -match "dropbox\.com")                                      { return "Dropbox" }
        elseif ($url -match "drive\.google\.com")                                { return "Google Drive" }
        elseif ($url -match "mega\.nz|mega\.co\.nz")                             { return "MEGA" }
        elseif ($url -match "github\.com")                                       { return "GitHub" }
        elseif ($url -match "modrinth\.com")                                     { return "Modrinth" }
        elseif ($url -match "curseforge\.com")                                   { return "CurseForge" }
        elseif ($url -match "anydesk\.com")                                      { return "AnyDesk" }
        elseif ($url -match "doomsdayclient\.com")                               { return "DoomsdayClient" }
        elseif ($url -match "prestigeclient\.vip")                               { return "PrestigeClient" }
        elseif ($url -match "198macros\.com")                                    { return "198Macros" }
        elseif ($url -match "dqrkis\.xyz")                                       { return "Dqrkis" }
        else {
            if ($url -match "https?://(?:www\.)?([^/]+)") { return $matches[1] }
            return $url
        }
    }
    return $null
}

function Query-Modrinth {
    param([string]$Hash)
    try {
        $versionInfo = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version_file/$Hash" -Method Get -UseBasicParsing -ErrorAction Stop
        if ($versionInfo.project_id) {
            $projectInfo = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/project/$($versionInfo.project_id)" -Method Get -UseBasicParsing -ErrorAction Stop
            return @{ Name = $projectInfo.title; Slug = $projectInfo.slug }
        }
    } catch { }
    return @{ Name = ""; Slug = "" }
}

function Query-Megabase {
    param([string]$Hash)
    try {
        $result = Invoke-RestMethod -Uri "https://megabase.vercel.app/api/query?hash=$Hash" -Method Get -UseBasicParsing -ErrorAction Stop
        if (-not $result.error) { return $result.data }
    } catch { }
    return $null
}

$fullwidthRegex = [regex]::new(
    "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}",
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

function Invoke-ModScan {
    param([string]$FilePath)

    $foundPatterns  = [System.Collections.Generic.HashSet[string]]::new()
    $foundStrings   = [System.Collections.Generic.HashSet[string]]::new()
    $foundFullwidth = [System.Collections.Generic.HashSet[string]]::new()

    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($FilePath)

        foreach ($entry in $archive.Entries) {
            foreach ($m in $patternRegex.Matches($entry.FullName)) {
                [void]$foundPatterns.Add($m.Value)
            }
        }

        $allEntries    = [System.Collections.Generic.List[object]]::new()
        $innerArchives = [System.Collections.Generic.List[object]]::new()

        foreach ($e in $archive.Entries) { $allEntries.Add($e) }

        foreach ($nj in ($archive.Entries | Where-Object { $_.FullName -match "^META-INF/jars/.+\.jar$" })) {
            try {
                $ns = $nj.Open()
                $ms = New-Object System.IO.MemoryStream
                $ns.CopyTo($ms); $ns.Close()
                $ms.Position = 0
                $iz = [System.IO.Compression.ZipArchive]::new($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                $innerArchives.Add($iz)
                foreach ($ie in $iz.Entries) { $allEntries.Add($ie) }
            } catch { }
        }

        foreach ($entry in $allEntries) {
            $name = $entry.FullName

            if ($name -match '\.(class|json)$' -or $name -match 'MANIFEST\.MF') {
                try {
                    $st = $entry.Open()
                    $ms2 = New-Object System.IO.MemoryStream
                    $st.CopyTo($ms2); $st.Close()
                    $bytes = $ms2.ToArray(); $ms2.Dispose()

                    $ascii = [System.Text.Encoding]::ASCII.GetString($bytes)
                    $utf8  = [System.Text.Encoding]::UTF8.GetString($bytes)

                    foreach ($m in $patternRegex.Matches($ascii)) { [void]$foundPatterns.Add($m.Value) }

                    foreach ($s in $cheatStringSet) {
                        if ($ascii.Contains($s)) { [void]$foundStrings.Add($s); continue }
                        if ($utf8.Contains($s))  { [void]$foundStrings.Add($s) }
                    }

                    foreach ($m in $fullwidthRegex.Matches($utf8)) {
                        [void]$foundFullwidth.Add($m.Value)
                    }
                } catch { }
            }
        }

        foreach ($ia in $innerArchives) { try { $ia.Dispose() } catch { } }
        $archive.Dispose()
    } catch { }

    $fwCheatPool = @($script:cheatStrings | Where-Object {
        $_ -cmatch "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]"
    })
    $resolvedFullwidth = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($fw in @($foundFullwidth)) {
        if ($fw.Length -lt 3) { continue }
        $bestMatch = $null
        foreach ($cs in $fwCheatPool) {
            if ($cs.Contains($fw)) {
                if ($null -eq $bestMatch -or $cs.Length -lt $bestMatch.Length) {
                    $bestMatch = $cs
                }
            }
        }
        if ($null -ne $bestMatch) {
            [void]$resolvedFullwidth.Add($bestMatch)
        } elseif ($fw.Length -ge 6) {
            [void]$resolvedFullwidth.Add($fw)
        }
    }
    $resolved = @($resolvedFullwidth)
    $finalFullwidth = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($fw in $resolved) {
        $isRedundant = $false
        foreach ($other in $resolved) {
            if ($fw.Length -lt $other.Length -and $other.Contains($fw)) {
                $isRedundant = $true; break
            }
        }
        if (-not $isRedundant) { [void]$finalFullwidth.Add($fw) }
    }

    return @{ Patterns = $foundPatterns; Strings = $foundStrings; Fullwidth = $finalFullwidth }
}

function Invoke-ObfuscationScan {
    param([string]$FilePath)

    $flags = [System.Collections.Generic.List[string]]::new()

    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($FilePath)

        $totalClass    = 0
        $numericCount  = 0
        $unicodeCount  = 0
        $fullwidthCount= 0
        $japaneseCount = 0
        $singleLetterCount = 0
        $twoLetterCount    = 0
        $gibberishCount    = 0
        $noVowelCount      = 0
        $confusionCount    = 0
        $singleCharPkg     = 0
        $contentSample     = [System.Text.StringBuilder]::new()
        $sampleSize        = 0

        $cheatObfuscators = @{
            "Skidfuscator"   = @("dev/skidfuscator", "Skidfuscator", "skidfuscator.dev")
            "Paramorphism"   = @("Paramorphism", "paramorphism-", "dev/paramorphism")
            "Radon"          = @("ItzSomebody/Radon", "me/itzsomebody/radon", "Radon Obfuscator")
            "Caesium"        = @("sim0n/Caesium", "Caesium Obfuscator", "dev/sim0n/caesium")
            "Bozar"          = @("vimasig/Bozar", "Bozar Obfuscator", "com/bozar")
            "Branchlock"     = @("Branchlock", "branchlock.dev")
            "Binscure"       = @("Binscure", "com/binscure")
            "SuperBlaubeere" = @("superblaubeere", "superblaubeere27")
            "Qprotect"       = @("Qprotect", "QProtect", "mdma.dev/qprotect")
            "Zelix"          = @("ZKMFLOW", "ZKM", "ZelixKlassMaster", "com/zelix")
            "Stringer"       = @("StringerJavaObfuscator", "com/licel/stringer")
            "JNIC"           = @("JNIC", "jnic.obf", "jnic-obfuscator")
            "Scuti"          = @("ScutiObf", "scuti.obf")
            "Smoke"          = @("SmokeObf", "smoke.obf")
        }

        foreach ($entry in $archive.Entries) {
            $name = $entry.FullName

            if ($name -match "\.class$") {
                $totalClass++
                $className = [System.IO.Path]::GetFileNameWithoutExtension(($name -split "/")[-1])

                if ($className -match "^\d+$")                          { $numericCount++ }
                if ($className -match "[^\x00-\x7F]")                   { $unicodeCount++ }
                if ($className -match "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]") { $fullwidthCount++ }
                if ($className -match "[\u3040-\u309F\u30A0-\u30FF]")    { $japaneseCount++ }
                if ($className -match "^[a-zA-Z]$")                     { $singleLetterCount++ }
                if ($className -match "^[a-zA-Z]{2}$")                  { $twoLetterCount++ }
                if ($className -match "^[Il1O0]+$" -or $className -match "^[_]+$") { $confusionCount++ }

                if ($className.Length -ge 3 -and $className.Length -le 8 -and $className -match "^[a-zA-Z]+$") {
                    $vowels = ($className.ToCharArray() | Where-Object { $_ -match "[aeiouAEIOU]" }).Count
                    if ($vowels -eq 0) { $noVowelCount++ }
                    $hasCluster = $className -match "[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]{3,}"
                    if ($hasCluster -and ($vowels / $className.Length) -lt 0.3) { $gibberishCount++ }
                }

                $segs = ($name -replace "\.class$", "") -split "/"
                foreach ($seg in $segs[0..($segs.Count - 2)]) {
                    if ($seg.Length -eq 1) { $singleCharPkg++ }
                }

                if ($sampleSize -lt 150000 -and $entry.Length -lt 100000 -and $entry.Length -gt 100) {
                    try {
                        $st = $entry.Open()
                        $ms = New-Object System.IO.MemoryStream
                        $st.CopyTo($ms); $st.Close()
                        $ascii = [System.Text.Encoding]::ASCII.GetString($ms.ToArray())
                        $ms.Dispose()
                        [void]$contentSample.Append($ascii)
                        $sampleSize += $ascii.Length
                    } catch { }
                }
            }
        }
        $archive.Dispose()

        if ($totalClass -lt 5) { return $flags }

        $pct = { param($n) [math]::Round(($n / $totalClass) * 100) }
        $numPct = & $pct $numericCount
        $uniPct = & $pct $unicodeCount
        $fwPct  = & $pct $fullwidthCount
        $jpPct  = & $pct $japaneseCount
        $s1Pct  = & $pct $singleLetterCount
        $s2Pct  = & $pct $twoLetterCount
        $gibPct = & $pct $gibberishCount
        $novPct = & $pct $noVowelCount
        $confPct= & $pct $confusionCount

        if ($numPct -ge 20)  { $flags.Add("Numeric class names — $numPct% of classes have numeric-only names") }
        if ($uniPct -ge 10)  { $flags.Add("Unicode class names — $uniPct% of classes use non-ASCII characters") }
        if ($fwPct -gt 0)    { $flags.Add("Fullwidth Unicode class names — $fwPct% use ａｂｃ/ＡＢＣ/０１２ chars ($fullwidthCount classes)") }
        if ($jpPct -gt 0)    { $flags.Add("Japanese obfuscation — $jpPct% use hiragana/katakana class names ($japaneseCount classes)") }
        if ($s1Pct -ge 15)   { $flags.Add("Single-letter class names — $s1Pct% ($singleLetterCount classes)") }
        if ($s2Pct -ge 20)   { $flags.Add("Two-letter class names — $s2Pct% ($twoLetterCount classes)") }
        if ($gibPct -ge 5)   { $flags.Add("Gibberish class names — $gibPct% have no vowels / consonant clusters ($gibberishCount classes)") }
        if ($novPct -ge 8)   { $flags.Add("No-vowel class names — $novPct% ($noVowelCount classes)") }
        if ($confPct -ge 3)  { $flags.Add("Confusion-char names (Il1O0/_) — $confPct% ($confusionCount classes)") }
        if ($singleCharPkg -ge 6) { $flags.Add("Single-char package paths — $singleCharPkg path segments like a/b/c") }

        $fwStringMatches = [regex]::Matches($contentSample.ToString(), "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}")
        if ($fwStringMatches.Count -gt 0) {
            $examples = ($fwStringMatches | Select-Object -First 3 | ForEach-Object { $_.Value }) -join ", "
            $flags.Add("Fullwidth strings in class content — $($fwStringMatches.Count) occurrences (e.g. $examples)")
        }

        $sampleStr = $contentSample.ToString()
        foreach ($obfName in $cheatObfuscators.Keys) {
            foreach ($pat in $cheatObfuscators[$obfName]) {
                if ($sampleStr.Contains($pat)) {
                    $flags.Add("Known cheat obfuscator detected — $obfName (matched: $pat)")
                    break
                }
            }
        }
    } catch { }

    return $flags
}

function Invoke-BypassScan {
    param([string]$FilePath)

    $flags = [System.Collections.Generic.List[string]]::new()
    $mavenPrefixes = @(
        "com_","org_","net_","io_","dev_","gs_","xyz_",
        "app_","me_","tv_","uk_","be_","fr_","de_"
    )

    function Test-SuspiciousJarName {
        param([string]$JarName)
        $base = [System.IO.Path]::GetFileNameWithoutExtension($JarName)
        if ($base -match '\d') { return $false }
        foreach ($pfx in $mavenPrefixes) {
            if ($base.ToLower().StartsWith($pfx)) { return $false }
        }
        if ($base.Length -gt 20) { return $false }
        return $true
    }

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath)
        $nestedJars = @($zip.Entries | Where-Object { $_.FullName -match "^META-INF/jars/.+\.jar$" })
        $outerClasses = @($zip.Entries | Where-Object { $_.FullName -match "\.class$" })

        $suspiciousNestedJars = @()
        foreach ($nj in $nestedJars) {
            $njBase = [System.IO.Path]::GetFileName($nj.FullName)
            if (Test-SuspiciousJarName -JarName $njBase) {
                $suspiciousNestedJars += $njBase
            }
        }

        foreach ($sj in $suspiciousNestedJars) {
            $flags.Add("Suspicious nested JAR — no version, unknown dependency: $sj")
        }

        if ($nestedJars.Count -eq 1 -and $outerClasses.Count -lt 3) {
            $njName = [System.IO.Path]::GetFileName(($nestedJars | Select-Object -First 1).FullName)
            $flags.Add("Hollow shell — only $($outerClasses.Count) own class(es), wraps: $njName")
        }

        $outerModId = ""
        $fmje = $zip.Entries | Where-Object { $_.FullName -eq "fabric.mod.json" } | Select-Object -First 1
        if ($fmje) {
            try {
                $s = $fmje.Open()
                $r = New-Object System.IO.StreamReader($s)
                $t = $r.ReadToEnd(); $r.Close(); $s.Close()
                if ($t -match '"id"\s*:\s*"([^"]+)"') { $outerModId = $matches[1] }
            } catch { }
        }

        $allEntries = [System.Collections.Generic.List[object]]::new()
        foreach ($e in $zip.Entries) { $allEntries.Add($e) }

        $innerZips = [System.Collections.Generic.List[object]]::new()
        foreach ($nj in $nestedJars) {
            try {
                $ns = $nj.Open()
                $ms = New-Object System.IO.MemoryStream
                $ns.CopyTo($ms); $ns.Close()
                $ms.Position = 0
                $iz = [System.IO.Compression.ZipArchive]::new($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                $innerZips.Add($iz)
                foreach ($ie in $iz.Entries) { $allEntries.Add($ie) }
            } catch { }
        }

        $runtimeExecFound = $false
        $httpDownloadFound = $false
        $httpExfilFound    = $false
        $obfuscatedAuth    = $false
        $jnativehookFound  = $false

        foreach ($entry in $allEntries) {
            $name = $entry.FullName

            if ($name -match "fabric\.mod\.json$") {
                if ($outerModId -and $name -match "META-INF/jars/") {
                    try {
                        $s = $entry.Open(); $r = New-Object System.IO.StreamReader($s); $t = $r.ReadToEnd(); $r.Close(); $s.Close()
                        if ($t -match '"id"\s*:\s*"([^"]+)"') {
                            $innerId = $matches[1]
                            if ($innerId -ne $outerModId) {
                                $flags.Add("Mod ID Mismatch — Outer: '$outerModId' vs Inner: '$innerId'")
                            }
                        }
                    } catch { }
                }
            }

            if ($name -match "\.class$") {
                try {
                    $st = $entry.Open(); $ms = New-Object System.IO.MemoryStream; $st.CopyTo($ms); $st.Close()
                    $bytes = $ms.ToArray(); $ms.Dispose()

                    $ascii = [System.Text.Encoding]::ASCII.GetString($bytes)
                    $utf8  = [System.Text.Encoding]::UTF8.GetString($bytes)

                    if (-not $runtimeExecFound -and ($ascii.Contains("java/lang/Runtime") -and $ascii.Contains("exec"))) {
                        $runtimeExecFound = $true
                        $flags.Add("Process Execution — Calls Runtime.getRuntime().exec() (potential RCE/backdoor)")
                    }

                    if (-not $httpDownloadFound -and ($ascii.Contains("java/net/URL") -and $ascii.Contains("openStream"))) {
                        $httpDownloadFound = $true
                        $flags.Add("Network Download — Class initiates stream-based download via URL.openStream()")
                    }

                    if (-not $httpExfilFound -and ($ascii.Contains("HttpURLConnection") -and ($ascii.Contains("POST") -or $ascii.Contains("getOutputStream")))) {
                        $httpExfilFound = $true
                        $flags.Add("Data Exfiltration — HTTP connection sending POST data (possible logger/webhook)")
                    }

                    if (-not $obfuscatedAuth -and ($ascii.Contains("YUhSMGNEb3ZMM0Z3YVM1dWIzWmhiRzV6YVdsdWJuUXVkSGg0") -or $ascii.Contains("api.novaclient.lol"))) {
                        $obfuscatedAuth = $true
                        $flags.Add("Hardcoded Malicious URI — Obfuscated endpoint references detected")
                    }

                    if (-not $jnativehookFound -and $ascii.Contains("org/jnativehook")) {
                        $jnativehookFound = $true
                        $flags.Add("Native Keylogger Framework — Contains JNativeHook classes (captures global keystrokes)")
                    }
                } catch { }
            }
        }

        foreach ($iz in $innerZips) { try { $iz.Dispose() } catch { } }
        $zip.Dispose()
    } catch { }

    return $flags
}

$files = Get-ChildItem -Path $modsPath -Filter *.jar -File -ErrorAction SilentlyContinue

if ($files.Count -eq 0) {
    Write-Host "  [i] No .jar files found in the folder." -ForegroundColor Yellow
    Write-Host
    Write-Host "  [+] Scan complete." -ForegroundColor Green
    Write-Host "  [i] Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

$flaggedMods     = [System.Collections.Generic.List[object]]::new()
$bypassMods      = [System.Collections.Generic.List[object]]::new()
$obfuscatedMods  = [System.Collections.Generic.List[object]]::new()
$cleanMods       = [System.Collections.Generic.List[object]]::new()
$jvmFlags        = [System.Collections.Generic.List[string]]::new()

$totalFiles = $files.Count
$currentIndex = 0

Write-Host "  [>] Starting analysis of $totalFiles files..." -ForegroundColor Cyan
Write-Host

foreach ($file in $files) {
    $currentIndex++
    $percent = [math]::Round(($currentIndex / $totalFiles) * 100)
    Write-Progress -Activity "TeslaPro Ghost Scan" -Status "Processing: $($file.Name) ($percent%)" -PercentComplete $percent

    $sha1 = Get-FileSHA1 -Path $file.FullName
    $downloadSource = Get-DownloadSource -Path $file.FullName

    $megabaseResult = Query-Megabase -Hash $sha1
    if ($megabaseResult) {
        if ($megabaseResult.status -eq "clean") {
            $cleanMods.Add(@{ File = $file; Reason = "Verified via Megabase API" })
            continue
        } elseif ($megabaseResult.status -eq "flagged") {
            $flaggedMods.Add(@{ File = $file; Detections = @("Megabase API: " + $megabaseResult.reason); Source = $downloadSource })
            continue
        }
    }

    $modrinthResult = Query-Modrinth -Hash $sha1
    if ($modrinthResult.Name) {
        $cleanMods.Add(@{ File = $file; Reason = "Legitimate Modrinth release ($($modrinthResult.Name))" })
        continue
    }

    $scanResults     = Invoke-ModScan -FilePath $file.FullName
    $obfuscationFlags= Invoke-ObfuscationScan -FilePath $file.FullName
    $bypassFlags     = Invoke-BypassScan -FilePath $file.FullName

    $detections = [System.Collections.Generic.List[string]]::new()
    foreach ($p in $scanResults.Patterns)  { $detections.Add("Suspicious file pattern: $p") }
    foreach ($s in $scanResults.Strings)   { $detections.Add("Found cheat string: $s") }
    foreach ($fw in $scanResults.Fullwidth){ $detections.Add("Wide unicode string (obf): $fw") }

    if ($detections.Count -gt 0) {
        $flaggedMods.Add(@{ File = $file; Detections = @($detections); Source = $downloadSource })
        continue
    }

    if ($bypassFlags.Count -gt 0) {
        $bypassMods.Add(@{ File = $file; Flags = $bypassFlags; Source = $downloadSource })
        continue
    }

    if ($obfuscationFlags.Count -gt 0) {
        $obfuscatedMods.Add(@{ File = $file; Flags = $obfuscationFlags; Source = $downloadSource })
        continue
    }

    $cleanMods.Add(@{ File = $file; Reason = "No anomalies or suspicious code found" })
}

Write-Host "  [+] ANALYSIS COMPLETE RECONNAISSANCE REPORT:" -ForegroundColor Green
Write-Host

if ($flaggedMods.Count -gt 0) {
    Write-Row "─" 85 Red
    Write-Host "  [☠] MALICIOUS / CHEAT MODS DEACTIVATED ($($flaggedMods.Count))" -ForegroundColor Red
    Write-Row "─" 85 Red
    foreach ($m in $flaggedMods) {
        Write-Host "  [-] CRISIS: $($m.File.Name)" -ForegroundColor Red
        if ($m.Source) { Write-Host "      ↳ Download Source: $($m.Source)" -ForegroundColor DarkYellow }
        foreach ($det in $m.Detections) {
            Write-Host "      ⚠️ $det" -ForegroundColor Yellow
        }
        Write-Host
    }
}

if ($bypassMods.Count -gt 0) {
    Write-Row "─" 85 Magenta
    Write-Host "  [!] SUSPECTED BYPASS / BACKDOOR CODES ($($bypassMods.Count))" -ForegroundColor Magenta
    Write-Row "─" 85 Magenta
    foreach ($m in $bypassMods) {
        Write-Host "  [?] RISK: $($m.File.Name)" -ForegroundColor Magenta
        if ($m.Source) { Write-Host "      ↳ Download Source: $($m.Source)" -ForegroundColor DarkYellow }
        foreach ($flg in $m.Flags) {
            Write-Host "      ⚡ $flg" -ForegroundColor Gray
        }
        Write-Host
    }
}

if ($obfuscatedMods.Count -gt 0) {
    Write-Row "─" 85 Yellow
    Write-Host "  [#] HEAVILY OBFUSCATED / UNREADABLE FILES ($($obfuscatedMods.Count))" -ForegroundColor Yellow
    Write-Row "─" 85 Yellow
    foreach ($m in $obfuscatedMods) {
        Write-Host "  [*] UNKNOWN: $($m.File.Name)" -ForegroundColor Yellow
        if ($m.Source) { Write-Host "      ↳ Download Source: $($m.Source)" -ForegroundColor DarkYellow }
        foreach ($flg in $m.Flags) {
            Write-Host "      • $flg" -ForegroundColor Gray
        }
        Write-Host
    }
}

$mcArgs = Get-CimInstance Win32_Process -Filter "Name='javaw.exe' OR Name='java.exe'" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CommandLine -ErrorAction SilentlyContinue
if ($mcArgs) {
    if ($mcArgs -match "-Xbootclasspath" -or $mcArgs -match "-javaagent" -or $mcArgs -match "-agentpath") {
        $jvmFlags.Add("Injected JVM Agent / Bootclasspath manipulation detected in active Minecraft instance.")
    }
}

if ($jvmFlags.Count -gt 0) {
    Write-Row "─" 85 Orange
    Write-Host "  [⚡] RUNTIME JVM COMPROMISE ALERTS" -ForegroundColor Red
    Write-Row "─" 85 Orange
    foreach ($jf in $jvmFlags) {
        Write-Host "  [CRITICAL] $jf" -ForegroundColor Red
    }
    Write-Host
}

if ($cleanMods.Count -gt 0) {
    Write-Row "─" 85 DarkCyan
    Write-Host "  [✓] SAFE / VERIFIED MODS ($($cleanMods.Count))" -ForegroundColor Green
    Write-Row "─" 85 DarkCyan
    foreach ($m in $cleanMods) {
        Write-Host "  [+] SAFE: $($m.File.Name)" -ForegroundColor Gray
        Write-Host "      ↳ Reason: $($m.Reason)" -ForegroundColor DarkGreen
    }
    Write-Host
}

Write-Row "─" 85 DarkCyan
Write-Host "  📊 METRICS SUMMARY:" -ForegroundColor White
Write-Host "  ──────────────────"
Write-Host "  Total scanned files:     " -ForegroundColor Gray -NoNewline; Write-Host "$totalFiles"                     -ForegroundColor White
Write-Host "  Malicious / Cheats:      " -ForegroundColor Gray -NoNewline; Write-Host "$($flaggedMods.Count)"           -ForegroundColor Red
Write-Host "  Bypass / Anomalies:      " -ForegroundColor Gray -NoNewline; Write-Host "$($bypassMods.Count)"            -ForegroundColor Magenta
Write-Host "  Obfuscated / Suspect:    " -ForegroundColor Gray -NoNewline; Write-Host "$($obfuscatedMods.Count)"        -ForegroundColor Yellow
Write-Host "  JVM Runtime Warnings:    " -ForegroundColor Gray -NoNewline; Write-Host "$($jvmFlags.Count)"               -ForegroundColor Red
Write-Host
Write-Row "━" 85 Cyan
Write-Host ""
Write-Host "  ✨ System Analysis Complete. Thanks for using TeslaPro's Ghost client fucker!" -ForegroundColor Cyan
Write-Host ""
Write-Host "  👤 Creator   : " -ForegroundColor White -NoNewline
Write-Host "TeslaPro" -ForegroundColor Cyan
Write-Host "  📱 Discord   : " -ForegroundColor White -NoNewline
Write-Host "teamwsf" -ForegroundColor White
Write-Host "  📝 Credits to: " -ForegroundColor DarkGray -NoNewline
Write-Host "MeowTonynoh" -ForegroundColor DarkGray
Write-Host ""
Write-Row "━" 85 Cyan
Write-Host ""

Write-Host "  [i] Press any key to close the scanner window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")