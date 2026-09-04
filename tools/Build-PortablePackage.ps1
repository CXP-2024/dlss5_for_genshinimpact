param(
    [Parameter(Mandatory = $true)][string]$RuntimeRoot,
    [Parameter(Mandatory = $true)][string]$OptiScalerRoot,
    [Parameter(Mandatory = $true)][string]$DlssNrRuntimePath,
    [Parameter(Mandatory = $true)][string]$OutputDirectory,
    [string]$ArchivePassword = 'yuanshenqidong',
    [string]$SevenZipPath = 'C:\Program Files\7-Zip\7z.exe'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$runtime = [IO.Path]::GetFullPath($RuntimeRoot)
$optiSource = [IO.Path]::GetFullPath($OptiScalerRoot)
$dlssNrRuntime = [IO.Path]::GetFullPath($DlssNrRuntimePath)
$sevenZip = [IO.Path]::GetFullPath($SevenZipPath)
$out = [IO.Path]::GetFullPath($OutputDirectory)
$staging = Join-Path $out 'DLSS5_GI_Ready'
$archive = Join-Path $out 'DLSS5_GI_Ready_v1.2_PreNR_RTX50_20260904.7z'

$expectedHashes = @{
    Bridge = '1AB7FBD90B69D8F57851FDFC039AA3890AEE46AEA2DCB4DB72C8049282140310'
    PreNrAddon = '522D979CBFF335710F362B9FC2F330988673D7F8C7A1A2D93DA9980EC8DDA695'
    NrChain = 'DB26E486592B252072BA5734FC2B27412863B8526826225640C837D4B4D11B60'
    DlssNrRuntime = 'E16BCF15E16E13F527491CDF7845B2FE6521A738D8F7C9C721866A8496E1FC8E'
    OptiScaler = '38FA288ABC16EE8E4FE1A1992E731ED7FAAB167FE09C41C93D0D8F01D8D110CF'
    ReShade = '0CEE63F9C9F13F3AC909C5B4903F4DBB4B719A7AB3B4F13B0DEAF83C814B94F7'
}

function Require-File {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "缺少文件：$Path" }
}

function Require-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw "缺少目录：$Path" }
}

function Assert-Sha256 {
    param([string]$Path, [string]$Expected, [string]$Label)
    Require-File $Path
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if ($actual -ne $Expected) { throw "$Label SHA-256 不匹配：$actual" }
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

Require-Directory $runtime
Require-Directory $optiSource
Require-File $dlssNrRuntime
Require-File $sevenZip
if ([string]::IsNullOrWhiteSpace($ArchivePassword)) { throw '7z 密码不能为空' }
New-Item -ItemType Directory -Force -Path $out | Out-Null

$resolvedOut = (Resolve-Path -LiteralPath $out).Path.TrimEnd('\')
$resolvedStaging = [IO.Path]::GetFullPath($staging)
if (-not $resolvedStaging.StartsWith($resolvedOut + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw "拒绝清理输出目录外的路径：$resolvedStaging"
}

if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }
New-Item -ItemType Directory -Force -Path $staging | Out-Null

$bridgeDll = Join-Path $repo 'release\configs\Dx11FsrBridge.dll'
$preNrSource = Join-Path $repo 'release\pre-nr'
$preNrAddon = Join-Path $preNrSource 'nr-before-sr.zh-CN.addon64'
$nrChain = Join-Path $preNrSource 'nrchain_nvngx.dll'
$optiDll = Join-Path $optiSource 'OptiScaler.dll'
$reshadeDll = Join-Path $runtime 'payload\ReShade\ReShade64.dll'

Assert-Sha256 $bridgeDll $expectedHashes.Bridge 'Dx11FsrBridge.dll'
Assert-Sha256 $preNrAddon $expectedHashes.PreNrAddon 'nr-before-sr.zh-CN.addon64'
Assert-Sha256 $nrChain $expectedHashes.NrChain 'nrchain_nvngx.dll'
Assert-Sha256 $dlssNrRuntime $expectedHashes.DlssNrRuntime 'nvngx_dlssnr.dll'
Assert-Sha256 $optiDll $expectedHashes.OptiScaler 'OptiScaler.dll'
Assert-Sha256 $reshadeDll $expectedHashes.ReShade 'ReShade64.dll'

Copy-File (Join-Path $repo 'release\portable-template\启动_DLSS5.bat') '启动_DLSS5.bat'
Copy-File (Join-Path $repo 'release\portable-template\README.txt') 'README.txt'
Copy-File (Join-Path $repo 'release\portable-template\ATTRIBUTION.txt') 'ATTRIBUTION.txt'
Copy-File (Join-Path $repo 'release\portable-template\configure_and_start.ps1') 'payload\_internal\configure_and_start.ps1'
Copy-File (Join-Path $runtime 'unlockfps_nc.exe') 'unlockfps_nc.exe'
Copy-File (Join-Path $runtime 'UnlockerStub.dll') 'UnlockerStub.dll'

Copy-File $bridgeDll 'payload\Bridge\Dx11FsrBridge.dll'
Copy-File (Join-Path $repo 'release\configs\Dx11FsrBridge.ini') 'payload\Bridge\Dx11FsrBridge.ini'
Copy-File $reshadeDll 'payload\ReShade\ReShade64.dll'

$shaderRoot = Join-Path $runtime 'payload\ReShade\reshade-shaders'
Copy-RelativeTree $shaderRoot 'payload\ReShade\reshade-shaders' {
    param($file)
    $relative = $file.FullName.Substring($shaderRoot.TrimEnd('\').Length + 1)
    return ($file.Name -notmatch '\.log($|\.)' -and $relative -notmatch '(^|\\)Addons(\\|$)')
}

foreach ($name in @('nr-before-sr.zh-CN.addon64', 'nrchain_nvngx.dll', 'nr_before_sr.ini', 'THIRD_PARTY_NOTICES.txt')) {
    Copy-File (Join-Path $preNrSource $name) "payload\ReShade\reshade-shaders\Addons\pre-nr\$name"
}
Copy-File $dlssNrRuntime 'payload\ReShade\reshade-shaders\Addons\pre-nr\nvngx_dlssnr.dll'

$optiFiles = @(
    'amd_fidelityfx_dx12.dll',
    'amd_fidelityfx_upscaler_dx12.dll',
    'libxell.dll',
    'libxess_dx11.dll',
    'libxess.dll',
    'nvngx_dlss.dll',
    'nvngx_dlss.license.txt',
    'OptiScaler.dll'
)
foreach ($name in $optiFiles) {
    Copy-File (Join-Path $optiSource $name) "payload\OptiScaler\$name"
}
Copy-File (Join-Path $optiSource 'OptiScaler.default.ini') 'payload\OptiScaler\OptiScaler.default.ini'
Copy-File (Join-Path $optiSource 'OptiScaler.default.ini') 'payload\OptiScaler\OptiScaler.ini'
Copy-RelativeTree (Join-Path $optiSource 'D3D12_Optiscaler') 'payload\OptiScaler\D3D12_Optiscaler'
Copy-RelativeTree (Join-Path $optiSource 'Licenses') 'payload\OptiScaler\Licenses'

$manifest = [ordered]@{
    Package = 'v1.2'
    Profile = 'RTX 50 pre-NR then original DLSS Super Resolution'
    GIMI = 'not required and not included'
    ReShade = '6.8.0 Add-on; unmodified v1.1 runtime'
    OptiScaler = 'DLSS-on-DX12/pre-NR compatibility build; ReShade private-DX12 bypass and custom NGX parameter hand-off'
    Dx11FsrBridge = '1.2.3'
    PreNrAddon = 'Bilibili 野生的装机宅; binaries unmodified; config Mode 1 -> Mode 2'
    Dlss = '310.8.0'
    DlssNr = '310.8.0 RTX 50 preview'
    Notes = 'Old dlss5-dx11-bridge and RenoDX post-NR add-ons are intentionally not included.'
}
$manifest | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $staging 'VERSION.json') -Encoding UTF8

$hashLines = foreach ($file in Get-ChildItem -LiteralPath $staging -Recurse -File | Sort-Object FullName) {
    $relative = $file.FullName.Substring($staging.TrimEnd('\').Length + 1).Replace('\', '/')
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    "$hash  $relative"
}
$hashLines | Set-Content -LiteralPath (Join-Path $staging 'SHA256SUMS.txt') -Encoding UTF8

$passwordArgument = "-p$ArchivePassword"
Push-Location -LiteralPath $out
try {
    & $sevenZip a -t7z $archive '.\DLSS5_GI_Ready' $passwordArgument -mhe=on -mx=9 -mmt=on
    if ($LASTEXITCODE -ne 0) { throw "7z 创建失败，退出码：$LASTEXITCODE" }
} finally {
    Pop-Location
}

Write-Host "已生成目录：$staging"
Write-Host "已生成 AES 加密且隐藏文件名的 7z：$archive"
