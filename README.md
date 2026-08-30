# 原神 DLSS5 一键包

1. 下载完整文件夹包，放到任意英文路径。
2. 只双击 `启动_DLSS5.bat`。
3. 第一次选择 `YuanShen.exe`，以后再次双击即可。

压缩包已包含运行所需组件：ReShade、OptiScaler、FSR Bridge、DLSS5 bridge、RenoDX、FPS Unlocker，以及 `nvngx_dlss.dll` 和 `nvngx_dlssnr.dll`。只需运行批处理文件，不需要打开 `.ps1`，也不需要改名 `dxgi.dll`/`d3d12.dll`。

HDR 也已包含并默认启用：启动器会设置原神的 HDR 开关，包内带有 RenoDX 和 HDR shader。要看到真实 HDR 输出，还需要在 Windows 和显示器上开启 HDR；ReShade shader 只是随包提供，不会自动启用每一个效果。

完整文件夹包（含大模型）：[Google Drive 文件夹](https://drive.google.com/drive/folders/1VH2Vg4oAvD_12HBBRnA4xcjmpQUANo50?usp=sharing)

## 工作原理

原神本身是 DX11，DLSS5 插件需要 DX12 的 NGX 调用。启动器按固定顺序注入 ReShade、`Dx11FsrBridge.dll` 和 `OptiScaler.dll`：

1. Bridge 从 DX11 游戏帧中取得颜色、深度和运动向量，并建立一个内部 DX12 会话。
2. OptiScaler 提供 DLSS4 兼容入口；DLSS5 bridge 将这次 DX12 NGX 调用交给 `nvngx_dlssnr.dll` 和 RenoDX DLSS5 插件。
3. 神经渲染完成后，结果同步并复制回原神的 DX11 输出。

脚本每次启动都会把 ReShade 的 `AddonPath`、Shader 路径和 OptiScaler 路径改为压缩包当前位置，并由 Unlocker 统一启动游戏，因此不会继续读取旧的 H 盘配置。

桥接插件还修复了启动崩溃：ReShade 可能会二次包装 Bridge 自建的 DX12 设备，造成虚表冲突。修复版在创建内部设备时临时绕过 ReShade 的设备 hook，并先还原原生 adapter，再恢复 hook；不修改系统 DLL。

GitHub 只保存源码和小型 release 文件；组件授权与重新分发注意事项见 `docs/REDISTRIBUTION.md`。
