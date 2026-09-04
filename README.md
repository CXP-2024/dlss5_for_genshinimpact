# 原神 DLSS5 一键包（无 GIMI）

当前版本为 **v1.2 前置神经渲染超分版（RTX 50 测试版）**。它把 DLSS5 Neural Rendering 放在低分辨率阶段运行，再交给原始 DLSS Super Resolution 放大；不需要 GIMI。

> 本项目是第三方实验性整合，不是 NVIDIA、HoYoverse、ReShade 或各上游项目的官方产品。游戏、驱动和预览运行时更新后可能失效，请自行评估使用风险。

## v1.2 下载

完整一键包正在等待维护者上传。新的 Google Drive 与百度网盘链接会在上传完成后补到这里；**不要把下方 v1.1 链接误当成 v1.2**。

- Google Drive：待补充
- 百度网盘：待补充
- 文件名：`DLSS5_GI_Ready_v1.2_PreNR_RTX50_20260904.7z`
- 文件大小：`166,978,690 bytes`（约 159.2 MiB）
- SHA-256：`BB0EF3E89BF37BC018DC6CA872590913AECE8FF37A672B84B76DC72EB4014F1F`
- 解压密码：`yuanshenqidong`
- 格式：7z AES 加密，并启用文件名加密；密码错误时无法查看目录结构

GitHub 仓库只含源码、补丁、配置和可提交的小文件。由于体积与分发边界，直接下载仓库不能代替完整一键包；`nvngx_dlssnr.dll`、`nvngx_dlss.dll`、ReShade 和构建后的 OptiScaler 等运行文件不会提交到 GitHub。

## 使用方法

1. 用密码 `yuanshenqidong` 解压完整 v1.2 7z 到固定目录，建议使用英文路径。
2. 双击 `启动_DLSS5.bat`。
3. 第一次选择 `YuanShen.exe` 或 `GenshinImpact.exe`；路径会保存，之后直接双击即可。
4. 游戏内抗锯齿选择 **FSR2**，关闭垂直同步；渲染精度就是 NR 与 DLSS 的输入倍率。
5. `Home` 打开 ReShade，`Insert` 打开 OptiScaler，`F6` 切换前置 NR。

不需要提前安装 GIMI、ReShade、OptiScaler、DLSS DLL 或 FPS Unlocker，完整一键包已经包含本配置所需组件。不要把它和 GIMI 版、v1.1 旧插件目录、其他 ReShade/RHI 注入包混在一起，也不要直接启动游戏 EXE。

当前完整包按 RTX 50、Windows 11 24H2 和较新 NVIDIA 驱动准备。前置插件原说明建议 RTX 50 使用 615+ 驱动；RTX 40 所需运行时与本包不同，v1.2 尚未验证 RTX 40 替换方案。

## v1.2 实际链路

```text
原神 DX11 低分辨率颜色 / 深度 / 运动向量
  -> Dx11FsrBridge 捕获 FSR2 输入
  -> OptiScaler dlss_12 创建私有 DX12 NGX 会话
  -> 前置 NR 插件以 Feature 18 在渲染分辨率执行 DLSS5 Neural Rendering
  -> 原始 DLSS Feature 1 从渲染分辨率放大到输出分辨率
  -> 结果复制回 DX11
  -> ReShade / UI 在最终游戏输出上继续处理
```

这不是“原分辨率跑完 DLSS5 后再缩放”。测试记录确认输入为 `960x540`、NR Feature 18 输出仍为 `960x540`，随后原始 DLSS 输出 `1920x1080`；连续 5400 个 NR 帧成功，测试段帧率约 160 FPS。

v1.2 不再加载 v1.1 的 `dlss5-dx11-bridge` 与 RenoDX 后置 NR add-on，也把 OptiScaler 内置 `[DlssNr]` 设为关闭，确保一帧只执行一次前置 NR。

## 本版解决的问题

- ReShade 会包装私有 D3D12 创建设备调用，旧路径会在 `ReShade64.dll` 中崩溃。兼容构建只在创建私有 DLSS-on-DX12 设备期间解包 ReShade adapter 并临时绕过其 `D3D12CreateDevice` detour，完成后立即恢复；不修改系统 DLL。
- 无 GIMI 路径原先会先初始化原生 D3D11 NGX，得到只能按严格类型读取的参数表，前置插件因此看不到私有 D3D12 颜色、深度和运动向量。v1.2 在 `dlss_12` 路径延迟 D3D11 NGX 初始化，使用 OptiScaler 自有参数表完成 D3D12 资源交接，再由 D3D12 Feature 自行初始化原生 NGX。

对应 OptiScaler 源码补丁见 [`src/patches/OptiScaler-DLSSOn12-pre-NR.patch`](src/patches/OptiScaler-DLSSOn12-pre-NR.patch)。

## 来源与修改说明

前置 NR 文件来自用户提供的 `B站野生的装机宅 DLSS5-AI渲染超分版-RTX50.zip`，压缩包及插件界面署名为 Bilibili UP 主 **“野生的装机宅”**。

以下文件保持原二进制不变：

- `nr-before-sr.zh-CN.addon64`
- `nrchain_nvngx.dll`
- RTX 50 测试版 `nvngx_dlssnr.dll`

本项目做过的改动：

- 把 `nr_before_sr.ini` 默认 `Mode` 从 1 改为 2，即由“SR 后 NR”改为“低分辨率 NR 后原 DLSS 超分”；
- 修改 OptiScaler 源码，加入上述无 GIMI 参数交接与 ReShade 私有 D3D12 兼容修复；
- 修改 ReShade Add-on 搜索/早期加载配置、OptiScaler 固定配置和一键启动脚本；
- 沿用 v1.1 已验证的 `Dx11FsrBridge.dll`、FPS Unlocker 与普通 ReShade runtime，v1.2 没有进一步改写这三者的二进制。

原插件声明其 HDR 合成方法派生自 clshortfuse 的 RenoDX DLSS 5 Neural Rendering add-on（MIT）。完整说明、哈希和第三方声明见 [`ATTRIBUTION.txt`](release/portable-template/ATTRIBUTION.txt)、[`THIRD_PARTY_NOTICES.txt`](release/pre-nr/THIRD_PARTY_NOTICES.txt) 与 [`docs/REDISTRIBUTION.md`](docs/REDISTRIBUTION.md)。

## 如何确认真的生效

打开 ReShade Overlay 查看前置插件，正常状态应同时满足：

- `signed feature 18 create ... Success`
- `NR-before-SR evaluate succeeded` 持续增长
- 输入/NR 分辨率小于输出分辨率，例如 `960x540 -> 960x540`，随后 DLSS 输出 `1920x1080`

只看到 Feature 1 evaluate 次数增长、不出现 Feature 18 成功帧，不代表 DLSS5 已生效。日志位置：

- `payload\ReShade\reshade-shaders\Addons\pre-nr\nr-before-sr.log`
- `payload\OptiScaler\OptiScaler.log`
- `payload\Bridge\Dx11FsrBridge.log`
- 游戏目录下 `ReShade.log`

## 常见问题

- 先退出游戏和系统托盘中的 `unlockfps_nc`，再重新双击启动；若解帧状态异常，重启系统后再试。
- Windows 安全中心可能隔离 `UnlockerStub.dll`。只使用你确认来源和哈希的一键包，并自行决定是否允许。
- NVIDIA App 插帧不要和本包同时启用。
- HDR 下插件内置截图可能呈灰色或颜色偏差，这是截图路径的色彩空间问题；验证画面请优先使用系统截图工具。
- 刚进入游戏时短暂闪烁通常与时序历史初始化有关；若持续闪烁，保留四份日志再反馈。

## v1.1 旧版

v1.1 是“原始 DLSS 输出后再执行 NR”的旧链路，保留用于回退，不是本页推荐的前置超分版。

- [Google Drive v1.1](https://drive.google.com/file/d/17LIscmrEGhJrlWnOdZNlRBFJotdHaOLf/view?usp=sharing)
- [百度网盘 v1.1](https://pan.baidu.com/s/1tlxdX8iLNN9gCvEd5j2soQ?pwd=y95x)（提取码 `y95x`，7z 密码 `yuanshenqidong`）

## 上游项目

- [Genshin FSR Bridge](https://github.com/AizawaHikaru233/genshin_fsr_brigde)
- [OptiScaler DLSSNR fork](https://github.com/Dagherbou/OptiScaler_DLSSNR)
- [OptiScaler](https://github.com/optiscaler/OptiScaler)
- [ReShade](https://reshade.me/)
- [Genshin FPS Unlock](https://github.com/34736384/genshin-fps-unlock)
- [RenoDX](https://github.com/clshortfuse/renodx)

源码许可证与快照说明见 `src/`、`licenses/` 和根目录 `NOTICE`。
