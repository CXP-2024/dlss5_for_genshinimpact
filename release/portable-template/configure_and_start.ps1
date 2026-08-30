param(
    [string]$GamePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $PSCommandPath
$root = [IO.Path]::GetFullPath((Join-Path $scriptDir '..\..'))
$payload = Join-Path $root 'payload'
$fpsConfigPath = Join-Path $root 'fps_config.json'
$unlockerPath = Join-Path $root 'unlockfps_nc.exe'

function Resolve-GameExe {
    param([string]$InputPath)
    if ([string]::IsNullOrWhiteSpace($InputPath)) { return $null }
    $clean = $InputPath.Trim().Trim('"')
    if (-not (Test-Path -LiteralPath $clean)) { return $null }
    $resolved = (Resolve-Path -LiteralPath $clean).Path
    if ((Get-Item -LiteralPath $resolved).PSIsContainer) {
        foreach ($name in @('YuanShen.exe', 'GenshinImpact.exe')) {
            $candidate = Join-Path $resolved $name
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $candidate).Path }
        }
        return $null
    }
    if ([IO.Path]::GetFileName($resolved) -in @('YuanShen.exe', 'GenshinImpact.exe')) { return $resolved }
    return $null
}

function Read-SavedGamePath {
    if (-not (Test-Path -LiteralPath $fpsConfigPath -PathType Leaf)) { return $null }
    try {
        $saved = Get-Content -LiteralPath $fpsConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
        return Resolve-GameExe -InputPath ([string]$saved.GamePath)
    } catch { return $null }
}

function Browse-GameExe {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Title = 'Select YuanShen.exe or GenshinImpact.exe'
        $dialog.Filter = 'Genshin Impact|YuanShen.exe;GenshinImpact.exe|Executable files|*.exe'
        $dialog.CheckFileExists = $true
        $dialog.Multiselect = $false
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            return Resolve-GameExe -InputPath $dialog.FileName
        }
    } catch { }
    return $null
}

function Select-GameExe {
    param([string]$InitialPath)
    $candidate = Resolve-GameExe -InputPath $InitialPath
    if ($null -eq $candidate) { $candidate = Browse-GameExe }
    while ($null -eq $candidate) {
        Write-Host ''
        Write-Host 'Enter the game folder or the full path to YuanShen.exe:' -ForegroundColor Cyan
        $candidate = Resolve-GameExe -InputPath (Read-Host 'Path')
        if ($null -eq $candidate) { Write-Host 'Invalid path. Try again.' -ForegroundColor Red }
    }
    return $candidate
}

function Set-IniValue {
    param([string]$Path, [string]$Section, [string]$Key, [string]$Value)
    $lines = [Collections.Generic.List[string]]::new()
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        foreach ($line in @(Get-Content -LiteralPath $Path -Encoding UTF8)) { $lines.Add([string]$line) }
    }
    $start = -1
    $end = $lines.Count
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -ieq "[$Section]") {
            $start = $i
            for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                if ($lines[$j].Trim() -match '^\[.+\]$') { $end = $j; break }
            }
            break
        }
    }
    if ($start -lt 0) {
        if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim() -ne '') { $lines.Add('') }
        $lines.Add("[$Section]")
        $lines.Add("$Key=$Value")
    } else {
        $found = $false
        for ($i = $start + 1; $i -lt $end; $i++) {
            if ($lines[$i] -match ('^\s*' + [regex]::Escape($Key) + '\s*=')) {
                $lines[$i] = "$Key=$Value"
                $found = $true
                break
            }
        }
        if (-not $found) { $lines.Insert($end, "$Key=$Value") }
    }
    [IO.File]::WriteAllLines($Path, $lines, [Text.UTF8Encoding]::new($false))
}

$gameExe = Select-GameExe -InitialPath $(if ($GamePath) { $GamePath } else { Read-SavedGamePath })
$gameDir = Split-Path -Parent $gameExe
$reshade = Join-Path $payload 'ReShade\ReShade64.dll'
$bridge = Join-Path $payload 'Bridge\Dx11FsrBridge.dll'
$opti = Join-Path $payload 'OptiScaler\OptiScaler.dll'
$addons = Join-Path $payload 'ReShade\reshade-shaders\Addons'
$shaders = Join-Path $payload 'ReShade\reshade-shaders\Shaders'
$textures = Join-Path $payload 'ReShade\reshade-shaders\Textures'
$optiIni = Join-Path $payload 'OptiScaler\OptiScaler.ini'
$reshadeIni = Join-Path $gameDir 'ReShade.ini'

foreach ($required in @($unlockerPath, $reshade, $bridge, $opti, (Join-Path $addons 'dlss5-dx11-bridge.addon64'), (Join-Path $addons 'renodx-dlss5.addon64'), (Join-Path $addons 'nvngx_dlssnr.dll'), (Join-Path $payload 'OptiScaler\nvngx_dlss.dll'))) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Missing file: $required" }
}

if (Test-Path -LiteralPath $reshadeIni -PathType Leaf) {
    $backup = "$reshadeIni.dlss5-backup"
    if (-not (Test-Path -LiteralPath $backup -PathType Leaf)) { Copy-Item -LiteralPath $reshadeIni -Destination $backup }
}
Set-IniValue -Path $reshadeIni -Section 'ADDON' -Key 'AddonPath' -Value ([IO.Path]::GetFullPath($addons))
Set-IniValue -Path $reshadeIni -Section 'GENERAL' -Key 'EffectSearchPaths' -Value ([IO.Path]::GetFullPath($shaders))
Set-IniValue -Path $reshadeIni -Section 'GENERAL' -Key 'TextureSearchPaths' -Value ([IO.Path]::GetFullPath($textures))

if (-not (Test-Path -LiteralPath $optiIni -PathType Leaf)) { throw "Missing OptiScaler.ini: $optiIni" }
Set-IniValue -Path $optiIni -Section 'Libraries' -Key 'OptiDllPath' -Value ([IO.Path]::GetFullPath((Join-Path $payload 'OptiScaler')))

$config = [ordered]@{
    GamePath = $gameExe
    AutoStart = $true
    AutoClose = $true
    PopupWindow = $true
    Fullscreen = $false
    UseCustomRes = $false
    IsExclusiveFullscreen = $false
    StartMinimized = $true
    UsePowerSave = $false
    SuspendLoad = $false
    UseMobileUI = $false
    UseHDR = $true
    FPSTarget = 160
    CustomResX = 1920
    CustomResY = 1080
    MonitorNum = 1
    Priority = 3
    AdditionalCommandLine = ''
    LastVersionNotify = 0
    DllList = @($reshade, $bridge, $opti)
}
$config | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $fpsConfigPath -Encoding UTF8
Write-Host "Configuration complete: $gameExe" -ForegroundColor Green
Start-Process -FilePath $unlockerPath -WorkingDirectory $root
