原神 DLSS5 v1.2 双模式一键包（RTX 30 / RTX 50）

发布压缩包为文件名加密的 7z，解压密码：yuanshenqidong

1. 将整个文件夹放在任意英文路径。
2. 通常只双击“启动_DLSS5.bat”，脚本会自动选择 RTX 30 或 RTX 50 Profile。
3. 第一次在文件选择框中选择 YuanShen.exe，之后再次双击即可。
4. 自动识别失败时，可改用“启动_DLSS5_RTX30.bat”或“启动_DLSS5_RTX50.bat”。

不要打开 payload\\_internal 里的文件。

脚本会自动修复所有插件路径并通过 FPS Unlocker 启动游戏。不要直接启动游戏 exe，也不需要改名 dxgi.dll 或 d3d12.dll。

本包默认启用 HDR；请同时在 Windows 和显示器设置中开启 HDR。

默认链路（插件中勾选“使用渲染分辨率 NR -> SR”）：
原神 DX11 低分辨率帧 -> DLSS5 Neural Rendering -> 原 DLSS Super Resolution -> ReShade/UI。

取消该选项后恢复插件原有的后置链路：
原神 DX11 低分辨率帧 -> 原 DLSS Super Resolution -> 输出分辨率 DLSS5 NR -> ReShade/UI。

启动器不会再覆盖 Enabled 或 Mode，插件界面中的选择在下次启动时仍然保留。
本版不需要 GIMI，也不要和 GIMI 版或旧 v1.1 的插件目录混用。

关键说明：
- 游戏内抗锯齿必须选 FSR2；渲染精度决定 NR 和 DLSS 的输入分辨率。
- Insert 打开 OptiScaler，Home 打开 ReShade，F6 切换前置 NR。
- RTX 30 与 RTX 50 使用独立的 nrchain/runtime 组合，不能交叉替换；详情见 ATTRIBUTION.txt。
- RTX 30 Profile 的 RankFTW 310.8.SF-v2 运行时没有数字签名；RTX 50 Profile 使用 NVIDIA 签名运行时。
- HDR 下插件截图可能出现灰色/色彩偏差；验证画面时优先使用系统截图工具。

来源和修改说明请看 ATTRIBUTION.txt。日志位于 payload 下对应组件目录。
