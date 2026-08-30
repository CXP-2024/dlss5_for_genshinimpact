# 重新分发边界

本仓库只提交源码、许可证和可确认可分发的小型组件。以下文件不提交：

| 组件 | 原因 | 当前本机大小 |
| --- | --- | ---: |
| `nvngx_dlssnr.dll` | NVIDIA 预览模型/运行时，来源和许可受限 | 158.16 MiB |
| `nvngx_dlss.dll` | NVIDIA NGX runtime，随 OptiScaler/NVIDIA SDK 许可分发 | 56.23 MiB |
| `libxess.dll` | XeSS runtime，本 DLSS-only 路径不需要 | 74.19 MiB |
| `ReShade64.dll` | ReShade runtime，应从官方 Add-on 安装器获取 | 5.33 MiB |
| `OptiScaler.dll` | 第三方项目发行文件，建议从其 release 获取 | 约 25 MiB |
| `renodx-dlss5.addon64` | 未确认本项目具有再分发授权 | 约 0.37 MiB |

`tools/Build-PortablePackage.ps1` 会从本机已取得的文件生成一个独立 ZIP，供维护者自行上传到 Google Drive。这个 ZIP 不属于 GitHub 仓库，且包含受限运行时；上传前请确认每个组件的再分发权限。不要把它或其中的大文件提交到 Git 历史。

源码目录保留各上游项目的许可证和 NOTICE。发布前请再次核对上游许可证、作者授权和下载来源。
