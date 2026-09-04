# 重新分发与来源边界

本仓库提交源码、补丁、说明、许可证和小型 release 文件，不提交完整运行包中的大型/受限组件。

| 组件 | GitHub 状态 | 说明 |
| --- | --- | --- |
| `nvngx_dlssnr.dll` | 不提交 | RTX 50 NVIDIA 签名预览运行时（165,840,496 bytes）或 RTX 30 RankFTW 310.8.SF-v2 无签名运行时（165,830,144 bytes） |
| `nvngx_dlss.dll` | 不提交 | NVIDIA NGX runtime，58,956,400 bytes |
| `ReShade64.dll` | 不提交 | 应从 ReShade 官方 Add-on 分发获取 |
| `OptiScaler.dll` | 不提交 | 本项目补丁构建产物约 25 MiB；源码差异以 patch 提交 |
| XeSS/FFX runtime | 不提交 | 来自各上游发行包，遵循各自许可 |
| `nr-before-sr.zh-CN.addon64` | 提交 | 用户提供的装机宅压缩包内小型插件，二进制未修改；保留声明和哈希 |
| `nrchain_nvngx.dll` | 提交 | RTX 50 版同上；RTX 30 sidecar 来自署名“华晓熊”的修复包，分别保留哈希与说明 |

前置 NR 插件来源文件为 `B站野生的装机宅 DLSS5-AI渲染超分版-RTX50.zip`，署名 Bilibili UP 主“野生的装机宅”。本项目不主张其著作权，也没有对两个插件二进制进行反编译后重编译或二进制修改。

本项目把 `nr_before_sr.ini` 的初始默认值从 Mode 1 改为 Mode 2，但兼容更新已经恢复两种模式，且启动器不再覆盖用户选择。RTX 30 源码增量和 Profile 来自 `DLSS5_GI_Ready_v1.2_PreNR_fixRTX30.zip`（文档署名“华晓熊”）；本项目对其完成差异审核、重建与一键入口整合。原插件声明其 HDR 合成方法派生自 clshortfuse/RenoDX（MIT），声明副本在 `release/pre-nr/THIRD_PARTY_NOTICES.txt`。

`tools/Build-PortablePackage.ps1` 要求分别提供 RTX 30/RTX 50 runtime，并按固定 SHA-256 生成 AES 加密且隐藏文件名的完整 7z。7z 本身不进入 Git 历史。上传网盘前应再次核对各组件许可、作者授权、来源和哈希；尤其应向用户明确 RTX 30 runtime 没有数字签名。
