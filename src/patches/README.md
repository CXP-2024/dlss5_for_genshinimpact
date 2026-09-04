# OptiScaler v1.2 build patch

`OptiScaler-DLSSOn12-pre-NR.patch` is the source patch used to produce the
`OptiScaler.dll` in the v1.2 portable package.

Patch base:

- Repository: <https://github.com/Dagherbou/OptiScaler_DLSSNR>
- Commit: `973761621353b99bee3dc7d4bb27b117fef2644f`

The patch contains the DLSS-on-DX12 path used for Genshin's DX11 FSR2 inputs,
Neural Rendering diagnostics, and integration fixes needed by the external
`nr-before-sr` add-on. In particular, it prevents `nrchain_nvngx.dll` from being
mistaken for the NVIDIA NGX core DLL. For the no-GIMI `dlss_12` profile it also:

- defers native D3D11 NGX initialisation so OptiScaler's cross-pointer-compatible
  parameter table carries the private D3D12 resources to both the pre-NR observer
  and native DLSS;
- unwraps ReShade's DXGI adapter proxy and temporarily bypasses ReShade's
  `D3D12CreateDevice` detour while creating the private DLSS-on-DX12 device;
- keeps ReShade on the game's final DX11 swapchain and restores the detour after
  private device creation.

It also contains an optional `SkipD3D11DeviceVTableHooks` switch for GIMI
coexistence; the no-GIMI v1.2 profile explicitly sets that switch to `false`, so
the normal D3D11 path remains active.

The release package does not use OptiScaler's built-in post-upscale `[DlssNr]`
pass. The launcher pins `[DlssNr] Enabled=false`; the external add-on owns the
single pre-upscale NR pass in Mode 2.

The patch can be checked from a clean upstream checkout with:

```powershell
git checkout 973761621353b99bee3dc7d4bb27b117fef2644f
git apply --check path\to\OptiScaler-DLSSOn12-pre-NR.patch
```
