# Release files

`release/` contains the small, repository-safe parts used by the v1.3 package builder:

- `configs/`: the verified DX11 FSR2 bridge binary and configuration reused from v1.1.
- `fps-unlocker/`: FPS Unlocker files.
- `pre-nr/`: the RTX 50 add-on/sidecar supplied in “B站野生的装机宅 DLSS5-AI渲染超分版-RTX50.zip”, the initial Mode 2 configuration, checksums and notice.
- `pre-nr-rtx30/`: the RTX 30 sidecar/Profile supplied in the repair archive credited to “华晓熊”; the common main add-on is copied from `pre-nr/` by the builder.
- `portable-template/`: the no-GIMI v1.3 launcher, user instructions and attribution copied into the final encrypted 7z.
- `custom-bridge/`: legacy v1.1 post-NR bridge files; not loaded by the v1.3 pre-NR profile.

The NVIDIA/RankFTW runtimes, ReShade runtime and compiled OptiScaler compatibility binary are intentionally excluded from Git. See `docs/REDISTRIBUTION.md` and use `tools/Build-PortablePackage.ps1` to assemble a complete local package.
