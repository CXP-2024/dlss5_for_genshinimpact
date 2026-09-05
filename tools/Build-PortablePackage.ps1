param(
    [Parameter(Mandatory = $true)][string]$RuntimeRoot,
    [Parameter(Mandatory = $true)][string]$OptiScalerRoot,
    [Parameter(Mandatory = $true)][Alias('DlssNrRuntimePath')][string]$DlssNrRuntime50Path,
    [Parameter(Mandatory = $true)][string]$DlssNrRuntime30Path,
    [Parameter(Mandatory = $true)][string]$OutputDirectory,
    [string]$ArchiveName = 'DLSS5_GI_Ready_v1.2_PreNR_RTX30_RTX50_20260905.7z',
    [string]$ArchivePassword = 'yuanshenqidong',
    [string]$SevenZipPath = 'C:\Program Files\7-Zip\7z.exe'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$runtime = [IO.Path]::GetFullPath($RuntimeRoot)
$optiSource = [IO.Path]::GetFullPath($OptiScalerRoot)
$dlssNrRuntime50 = [IO.Path]::GetFullPath($DlssNrRuntime50Path)
$dlssNrRuntime30 = [IO.Path]::GetFullPath($DlssNrRuntime30Path)
$sevenZip = [IO.Path]::GetFullPath($SevenZipPath)
$out = [IO.Path]::GetFullPath($OutputDirectory)
$staging = Join-Path $out 'DLSS5_GI_Ready'
$archive = Join-Path $out $ArchiveName

$expectedHashes = @{
    Bridge = '1AB7FBD90B69D8F57851FDFC039AA3890AEE46AEA2DCB4DB72C8049282140310'
    PreNrAddon = '522D979CBFF335710F362B9FC2F330988673D7F8C7A1A2D93DA9980EC8DDA695'
    NrChain50 = 'DB26E486592B252072BA5734FC2B27412863B8526826225640C837D4B4D11B60'
    NrChain30 = '46041A5FF91AE2FD907E310D132AABC3C4A1ECD48DACE511B8672909D5D9C2FB'
    DlssNrRuntime50 = 'E16BCF15E16E13F527491CDF7845B2FE6521A738D8F7C9C721866A8496E1FC8E'
    DlssNrRuntime30 = '6EB209E764F39872625DEBD6ABAF45E2BB6322F6F270F781F70C059AE30B3927'
    OptiScaler = @(
        '3211054BDA7FCF648569155304B2AFF2B1D0F9D050CBB64AB0AB9FBA7F58DC9A',
        'BBD9AC5E676C39354783362F8E05E4FE2A8D0314CA97F3AAF817EBD0F5DE211D',
        '917A401B69519DA7C994A4CA10482A1FC27FEA6AA50D1B5ABA3FCA11C0219B16'
    )
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

function Assert-Sha256Any {
    param([string]$Path, [string[]]$Expected, [string]$Label)
    Require-File $Path
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if ($actual -notin $Expected) { throw "$Label SHA-256 不匹配：$actual" }
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
Require-File $dlssNrRuntime50
Require-File $dlssNrRuntime30
Require-File $sevenZip
if ([string]::IsNullOrWhiteSpace($ArchivePassword)) { throw '7z 密码不能为空' }
if ([IO.Path]::GetFileName($ArchiveName) -ne $ArchiveName -or -not $ArchiveName.EndsWith('.7z')) {
    throw 'ArchiveName 必须是单独的 .7z 文件名，不能包含目录。'
}
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
$preNr30Source = Join-Path $repo 'release\pre-nr-rtx30'
$preNrAddon = Join-Path $preNrSource 'nr-before-sr.zh-CN.addon64'
$nrChain50 = Join-Path $preNrSource 'nrchain_nvngx.dll'
$nrChain30 = Join-Path $preNr30Source 'nrchain_nvngx.dll'
$optiDll = Join-Path $optiSource 'OptiScaler.dll'
$reshadeDll = Join-Path $runtime 'payload\ReShade\ReShade64.dll'

Assert-Sha256 $bridgeDll $expectedHashes.Bridge 'Dx11FsrBridge.dll'
Assert-Sha256 $preNrAddon $expectedHashes.PreNrAddon 'nr-before-sr.zh-CN.addon64'
Assert-Sha256 $nrChain50 $expectedHashes.NrChain50 'RTX 50 nrchain_nvngx.dll'
Assert-Sha256 $nrChain30 $expectedHashes.NrChain30 'RTX 30 nrchain_nvngx.dll'
Assert-Sha256 $dlssNrRuntime50 $expectedHashes.DlssNrRuntime50 'RTX 50 nvngx_dlssnr.dll'
Assert-Sha256 $dlssNrRuntime30 $expectedHashes.DlssNrRuntime30 'RTX 30 nvngx_dlssnr.dll'
Assert-Sha256Any $optiDll $expectedHashes.OptiScaler 'OptiScaler.dll'
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
Copy-File $dlssNrRuntime50 'payload\ReShade\reshade-shaders\Addons\pre-nr\nvngx_dlssnr.dll'

Copy-File $preNrAddon 'payload\ReShade\reshade-shaders\Addons\pre-nr-rtx30\nr-before-sr.zh-CN.addon64'
Copy-File $nrChain30 'payload\ReShade\reshade-shaders\Addons\pre-nr-rtx30\nrchain_nvngx.dll'
Copy-File (Join-Path $preNr30Source 'nr_before_sr.ini') 'payload\ReShade\reshade-shaders\Addons\pre-nr-rtx30\nr_before_sr.ini'
Copy-File (Join-Path $preNrSource 'THIRD_PARTY_NOTICES.txt') 'payload\ReShade\reshade-shaders\Addons\pre-nr-rtx30\THIRD_PARTY_NOTICES.txt'
Copy-File (Join-Path $preNr30Source 'RTX30_PROFILE_NOTICE.txt') 'payload\ReShade\reshade-shaders\Addons\pre-nr-rtx30\RTX30_PROFILE_NOTICE.txt'
Copy-File $dlssNrRuntime30 'payload\ReShade\reshade-shaders\Addons\pre-nr-rtx30\nvngx_dlssnr.dll'

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
    Profiles = @('RTX 30 RankFTW SF compatibility runtime', 'RTX 50 NVIDIA signed preview runtime')
    GIMI = 'not required and not included'
    ReShade = '6.8.0 Add-on; unmodified v1.1 runtime'
    OptiScaler = 'DLSS-on-DX12 dual-mode build; native D3D12 NGX parameters, queue affinity and FP16 output carrier'
    Dx11FsrBridge = '1.2.3'
    PreNrAddon = 'Bilibili 野生的装机宅; main binary unmodified; Mode 2 default and Mode 1 restored/preserved'
    Dlss = '310.8.0'
    DlssNr = 'RTX 30: RankFTW 310.8.SF-v2 unsigned; RTX 50: NVIDIA 310.8.0 signed'
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
