param(
    [Parameter(Mandatory = $true)][string]$RuntimeRoot,
    [Parameter(Mandatory = $true)][string]$Dlss5Root,
    [Parameter(Mandatory = $true)][string]$RenoDxRoot,
    [Parameter(Mandatory = $true)][string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$runtime = [IO.Path]::GetFullPath($RuntimeRoot)
$dlss5 = [IO.Path]::GetFullPath($Dlss5Root)
$renodx = [IO.Path]::GetFullPath($RenoDxRoot)
$out = [IO.Path]::GetFullPath($OutputDirectory)
$staging = Join-Path $out 'DLSS5_Genshin_Ready'
$zip = Join-Path $out 'DLSS5_Genshin_Ready.zip'

function Require-File {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "缺少文件：$Path" }
}

function Require-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw "缺少目录：$Path" }
}

function Copy-File {
    param([string]$Source, [string]$RelativeDestination)
    Require-File $Source
    $destination = Join-Path $staging $RelativeDestination
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $destination -Force
}

function Copy-RelativeTree {
    param([string]$SourceRoot, [string]$DestinationRoot, [scriptblock]$Filter = { $true })
    Require-Directory $SourceRoot
    foreach ($file in Get-ChildItem -LiteralPath $SourceRoot -Recurse -File) {
        if (-not (& $Filter $file)) { continue }
        $relative = $file.FullName.Substring($SourceRoot.TrimEnd('\').Length + 1)
        Copy-File $file.FullName (Join-Path $DestinationRoot $relative)
    }
}

New-Item -ItemType Directory -Force -Path $out | Out-Null
if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
New-Item -ItemType Directory -Force -Path $staging | Out-Null

Copy-File (Join-Path $repo 'release\portable-template\启动_DLSS5.bat') '启动_DLSS5.bat'
Copy-File (Join-Path $repo 'release\portable-template\配置并启动.ps1') '配置并启动.ps1'
Copy-File (Join-Path $repo 'release\portable-template\README.txt') 'README.txt'
Copy-File (Join-Path $runtime 'unlockfps_nc.exe') 'unlockfps_nc.exe'
Copy-File (Join-Path $runtime 'UnlockerStub.dll') 'UnlockerStub.dll'

Copy-File (Join-Path $runtime 'payload\Bridge\Dx11FsrBridge.dll') 'payload\Bridge\Dx11FsrBridge.dll'
Copy-File (Join-Path $runtime 'payload\Bridge\Dx11FsrBridge.ini') 'payload\Bridge\Dx11FsrBridge.ini'
Copy-File (Join-Path $runtime 'payload\ReShade\ReShade64.dll') 'payload\ReShade\ReShade64.dll'

$shaderRoot = Join-Path $runtime 'payload\ReShade\reshade-shaders'
Copy-RelativeTree $shaderRoot 'payload\ReShade\reshade-shaders' {
    param($file)
    $relative = $file.FullName.Substring($shaderRoot.TrimEnd('\').Length + 1)
    return ($file.Name -notmatch '\.log($|\.)' -and $relative -notmatch '(^|\\)Addons\\_disabled_legacy(\\|$)')
}

$optiFiles = @(
    'amd_fidelityfx_dx12.dll',
    'amd_fidelityfx_upscaler_dx12.dll',
    'libxell.dll',
    'libxess_dx11.dll',
    'libxess.dll',
    'nvngx_dlss.dll',
    'nvngx_dlss.license.txt',
    'OptiScaler.dll',
    'OptiScaler.default.ini',
    'OptiScaler.ini'
)
foreach ($name in $optiFiles) {
    Copy-File (Join-Path $runtime "payload\OptiScaler\$name") "payload\OptiScaler\$name"
}
# The source package may contain the maintainer's absolute OptiScaler path.
# Portable users must resolve this path from the extracted package instead.
$portableOptiIni = Join-Path $staging 'payload\OptiScaler\OptiScaler.ini'
$portableOptiText = Get-Content -LiteralPath $portableOptiIni -Raw -Encoding UTF8
$portableOptiText = [regex]::Replace($portableOptiText, '(?im)^\s*OptiDllPath\s*=.*$', 'OptiDllPath = auto')
[IO.File]::WriteAllText($portableOptiIni, $portableOptiText, [Text.UTF8Encoding]::new($false))
Copy-RelativeTree (Join-Path $runtime 'payload\OptiScaler\D3D12_Optiscaler') 'payload\OptiScaler\D3D12_Optiscaler'
Copy-RelativeTree (Join-Path $runtime 'payload\OptiScaler\Licenses') 'payload\OptiScaler\Licenses'

# Keep the DLSS and DLSS-NR pair from the same DLSS5 test bundle (both 310.8).
Copy-File (Join-Path $dlss5 'dlss5\nvngx_dlss.dll') 'payload\OptiScaler\nvngx_dlss.dll'
Copy-File (Join-Path $dlss5 'dlss5\nvngx_dlssnr.dll') 'payload\ReShade\reshade-shaders\Addons\nvngx_dlssnr.dll'
Copy-File (Join-Path $renodx 'renodx-dlss5.addon64') 'payload\ReShade\reshade-shaders\Addons\renodx-dlss5.addon64'

$manifest = [ordered]@{
    ReShade = '6.8.0 Add-on'
    OptiScaler = '0.9.4'
    Dx11FsrBridge = '1.2.3'
    Dlss5Bridge = '1.0.20 local compatibility build'
    Dlss = '310.8.0'
    DlssNr = '310.8.0 preview'
    Notes = 'Built for private/test distribution; verify component permissions before public redistribution.'
}
$manifest | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $staging 'VERSION.json') -Encoding UTF8

$hashLines = foreach ($file in Get-ChildItem -LiteralPath $staging -Recurse -File | Sort-Object FullName) {
    $relative = $file.FullName.Substring($staging.TrimEnd('\').Length + 1).Replace('\', '/')
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    "$hash  $relative"
}
$hashLines | Set-Content -LiteralPath (Join-Path $staging 'SHA256SUMS.txt') -Encoding ASCII
Compress-Archive -LiteralPath $staging -DestinationPath $zip -CompressionLevel Optimal
Write-Host "已生成：$zip"
