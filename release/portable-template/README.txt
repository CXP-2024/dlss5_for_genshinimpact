原神 DLSS5 v1.2 前置神经渲染超分一键包（RTX 50 测试版）

发布压缩包为文件名加密的 7z，解压密码：yuanshenqidong

1. 将整个文件夹放在任意英文路径。
2. 只双击“启动_DLSS5.bat”。
3. 第一次在文件选择框中选择 YuanShen.exe，之后再次双击即可。

不要打开 payload\\_internal 里的文件。

脚本会自动修复所有插件路径并通过 FPS Unlocker 启动游戏。不要直接启动游戏 exe，也不需要改名 dxgi.dll 或 d3d12.dll。

本包默认启用 HDR；请同时在 Windows 和显示器设置中开启 HDR。

画面链路：原神 DX11 低分辨率帧 -> DLSS5 Neural Rendering -> 原 DLSS Super Resolution -> ReShade/UI。
本版不需要 GIMI，也不要和 GIMI 版或旧 v1.1 的插件目录混用。

关键说明：
- 游戏内抗锯齿必须选 FSR2；渲染精度决定 NR 和 DLSS 的输入分辨率。
- Insert 打开 OptiScaler，Home 打开 ReShade，F6 切换前置 NR。
- 随包的 DLSS NR 测试运行时面向 RTX 50；驱动和系统要求见 ATTRIBUTION.txt。
- HDR 下插件截图可能出现灰色/色彩偏差；验证画面时优先使用系统截图工具。

来源和修改说明请看 ATTRIBUTION.txt。日志位于 payload 下对应组件目录。
