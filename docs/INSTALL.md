# v1.3 安装与启动

## 普通用户

1. 从 README 的 v1.3 正式版区域下载 RTX 30/RTX 50 双 Profile 完整包；v1.2、v1.0 链接仅用于历史回退。
2. 使用密码 `yuanshenqidong` 解压到固定目录，建议使用英文路径。压缩包已加密文件名，未输入正确密码不能查看目录结构。
3. 双击 `启动_DLSS5.bat`，脚本自动识别 RTX 30/RTX 50；第一次选择 `YuanShen.exe` 或 `GenshinImpact.exe`。识别失败或检测到未验证显卡时，脚本会提示选择 Profile。
4. 游戏内选择 FSR2 抗锯齿；渲染倍率决定 NR/DLSS 输入分辨率。

完整 7z 已含 ReShade、OptiScaler 兼容构建、DX11 FSR Bridge、前置 NR 插件、DLSS/DLSSNR runtime 和 FPS Unlocker。无需提前安装 GIMI 或任一上述组件。

GitHub 仓库不是可直接运行的一键包：大文件和受限 runtime 不在 Git 历史中。

## 启动脚本做什么

脚本每次运行都会：

- 根据显卡自动选择成套 Profile，并按包当前位置重写 ReShade 的 Addon/Shader/Texture/Cache/Screenshot 路径；
- 固定 `Dx11Upscaler=dlss_12` 与 FSR2 DX11 输入；
- 首次默认 `Mode=2`，但不再覆盖插件保存的 `Enabled`/`Mode`；取消“使用渲染分辨率 NR -> SR”即可使用输出分辨率后置 NR；
- 关闭 OptiScaler 内置 `[DlssNr]`，避免双重 NR；
- 以 `ReShade64.dll -> Dx11FsrBridge.dll -> OptiScaler.dll` 顺序写入 FPS Unlocker 注入列表并启动游戏。

## 要求与冲突

- v1.3 双 Profile 包用于 RTX 30/RTX 50；RTX 40 尚无经过实机验证的一键 Profile。
- RTX 30 使用 RankFTW 310.8.SF-v2 无签名 runtime，RTX 50 使用 NVIDIA 签名 runtime；两套文件不能交叉混用。
- 建议 Windows 11 24H2 或更新版本，并在 Windows/显示器内开启 HDR 才能看到 HDR 输出。
- 不要与 GIMI 版、旧 v1.1 Add-ons、其他 ReShade/RHI 注入包混用。
- 不要启用 NVIDIA App 帧生成。

## 回退

退出游戏和系统托盘 `unlockfps_nc` 后，直接改用独立的 v1.1 文件夹或干净游戏启动方式。不要从 v1.3 目录中任意删除单个 DLL 后继续启动；先保留日志用于诊断。
