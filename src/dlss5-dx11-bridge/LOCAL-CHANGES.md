# Local compatibility changes

The binary in `release/custom-bridge/` is a local rebuild of the upstream
`dlss5-dx11-bridge` source. The changes are deliberately limited to the
DX12-device creation path and hot-reload detection:

1. The `dred` setting participates in the changed-configuration check.
2. Before the bridge creates its private D3D12 device, it temporarily restores
   the original bytes of `D3D12CreateDevice`, then restores the hook afterward.
3. A ReShade DXGI adapter proxy is unwrapped before calling the native entry
   point, so ReShade does not wrap the bridge's private device a second time.
4. The native call helper is used by `BridgeInitSession`.

This addresses the observed ReShade D3D12 device-wrapper/vtable conflict. It is
an in-process workaround, not a patch to ReShade or Windows system DLLs. Rebuild
and retest after every ReShade or game update.
