# Release files

`release/` contains the small, repository-safe parts used by the v1.2 package builder:

- `configs/`: the verified DX11 FSR2 bridge binary and configuration reused from v1.1.
- `fps-unlocker/`: FPS Unlocker files.
- `pre-nr/`: the two unmodified pre-NR plug-in binaries supplied in “B站野生的装机宅 DLSS5-AI渲染超分版-RTX50.zip”, its Mode 2 configuration, checksums and notice.
- `portable-template/`: the no-GIMI v1.2 launcher, user instructions and attribution copied into the final encrypted 7z.
- `custom-bridge/`: legacy v1.1 post-NR bridge files; not loaded by the v1.2 pre-NR profile.

The NVIDIA runtimes, ReShade runtime and compiled OptiScaler compatibility binary are intentionally excluded from Git. See `docs/REDISTRIBUTION.md` and use `tools/Build-PortablePackage.ps1` to assemble a complete local package.
