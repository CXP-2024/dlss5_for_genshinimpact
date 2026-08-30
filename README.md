# 原神 DLSS5 DX11 方案

这个仓库整理了一套通过 `unlockfps_nc.exe` 统一启动原神的实验性组件：

```text
原神 DX11 -> Dx11FsrBridge -> OptiScaler/FSR2 -> DLSS4 接口
                                \-> ReShade DLSS5 add-on -> nvngx_dlssnr.dll
```

桥接插件会把 DX11 游戏的 NGX 调用复制到自建的 DX12 会话，供只支持 DX12 的 DLSS5 add-on 执行神经渲染，再把结果复制回游戏。当前自定义桥接版本还包含针对 ReShade D3D12 设备包装冲突的兼容修复。

## 仓库内容

- `release/fps-unlocker/`：FPS Unlocker 启动器及其 stub。
- `release/configs/`：已验证的 `Dx11FsrBridge.dll` 与配置。
- `release/custom-bridge/`：修复过的 `dlss5-dx11-bridge.addon64`。
- `src/`：上游源码快照、许可证和构建资料。
- `examples/`：不含任何本机绝对路径的配置模板。
- `docs/`：安装、配置、原理和重新分发说明。

## 快速安装

1. 从 [ReShade 官方下载页](https://reshade.me/) 获取带 Add-on 支持的 ReShade，安装到包含 `YuanShen.exe` 的游戏目录。建议使用当前稳定的 Add-on 构建。
2. 将 `release/custom-bridge/dlss5-dx11-bridge.addon64` 放到 ReShade 的 Add-ons 目录，并将同目录的 `.cfg` 放在插件实际读取的位置。
3. 将 `release/configs/Dx11FsrBridge.dll` 与同目录的 `.ini` 放在一起，并只把 DLL 加入 FPS Unlocker 的注入列表。
4. 从 [OptiScaler 官方发布页](https://github.com/cdooled/OptiScaler/releases) 获取 `OptiScaler.dll`，按其说明放入注入列表；不要把多个版本混放。
5. 获取 DLSS5 add-on 作者提供的 `renodx-dlss5.addon64`，并按作者说明启用 Neural Rendering。
6. 将 `nvngx_dlssnr.dll` 放在 DLSS5 add-on 要求的位置。当前测试模型可从[用户提供的 Google Drive 文件](https://drive.google.com/file/d/1G__IepUDavy5X5QK-8hcrGbTW_e99ZDV/view?usp=sharing)获取。
7. 另行获取与 OptiScaler 版本匹配的 `nvngx_dlss.dll`，放入 OptiScaler 要求的位置。
8. 首次运行 `release/fps-unlocker/unlockfps_nc.exe`，选择 `YuanShen.exe`，让它统一启动游戏。不要直接双击游戏 exe 绕过注入器。

详细步骤见 [`docs/INSTALL.md`](docs/INSTALL.md)。

## 首次排查

- 想测试 DLSS5 的原生/DLAA 输入时，在游戏渲染倍率菜单选择 `0.999`（显示为“原生”）。这不是 DLSS 超分质量档位。
- 若画面出现伪影，先将 `stage=0` 验证桥接是否为原因，再检查 DLSS5 add-on 的深度约定、运动矢量和历史重置设置。
- ReShade、桥接、OptiScaler、RenoDX 必须来自同一套配置目录；日志中的 `AddonPath` 不应指向旧的 H 盘路径。

## 重要限制

DLSS5 add-on 和 NVIDIA 模型是预览/第三方组件。它们不在本仓库中重新分发；请确认来源、许可证和文件哈希。原神修改可能违反游戏服务条款，使用前请自行评估风险。

许可证与组件边界见 [`docs/REDISTRIBUTION.md`](docs/REDISTRIBUTION.md)。
