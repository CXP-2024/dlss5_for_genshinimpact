# v1.2 安装与启动

## 普通用户

1. 从 README 的 Google Drive 或百度网盘链接下载完整 `DLSS5_GI_Ready_v1.2_PreNR_RTX50_20260904.7z`。
2. 使用密码 `yuanshenqidong` 解压到固定目录，建议使用英文路径。压缩包已加密文件名，未输入正确密码不能查看目录结构。
3. 双击 `启动_DLSS5.bat`，第一次选择 `YuanShen.exe` 或 `GenshinImpact.exe`。
4. 游戏内选择 FSR2 抗锯齿；渲染倍率决定 NR/DLSS 输入分辨率。

完整 7z 已含 ReShade、OptiScaler 兼容构建、DX11 FSR Bridge、前置 NR 插件、DLSS/DLSSNR runtime 和 FPS Unlocker。无需提前安装 GIMI 或任一上述组件。

GitHub 仓库不是可直接运行的一键包：大文件和受限 runtime 不在 Git 历史中。

## 启动脚本做什么

脚本每次运行都会：

- 根据包当前位置重写 ReShade 的 Addon/Shader/Texture/Cache/Screenshot 路径；
- 固定 `Dx11Upscaler=dlss_12` 与 FSR2 DX11 输入；
- 固定前置插件 `Mode=2`；
- 关闭 OptiScaler 内置 `[DlssNr]`，避免双重 NR；
- 以 `ReShade64.dll -> Dx11FsrBridge.dll -> OptiScaler.dll` 顺序写入 FPS Unlocker 注入列表并启动游戏。

## 要求与冲突

- v1.2 完整包面向 RTX 50 测试；前置插件原说明建议 NVIDIA 615+ 驱动。
- 建议 Windows 11 24H2 或更新版本，并在 Windows/显示器内开启 HDR 才能看到 HDR 输出。
- 不要与 GIMI 版、旧 v1.1 Add-ons、其他 ReShade/RHI 注入包混用。
- 不要启用 NVIDIA App 帧生成。

## 回退

退出游戏和系统托盘 `unlockfps_nc` 后，直接改用独立的 v1.1 文件夹或干净游戏启动方式。不要从 v1.2 目录中任意删除单个 DLL 后继续启动；先保留日志用于诊断。
