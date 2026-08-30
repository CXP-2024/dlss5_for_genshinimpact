# 安装与启动

## 目录原则

建议把本仓库克隆到一个固定目录，例如 `D:\GenshinDLSS5Tutorial`。游戏目录只放 ReShade 的 `dxgi.dll`、ReShade 配置及其 Add-ons；教程仓库本身不需要放进游戏目录。

## 组件

必须组件：

1. ReShade Add-on 构建（官方安装器的 Add-on 版本）。
2. `release/custom-bridge/dlss5-dx11-bridge.addon64` 与 `.cfg`。
3. `release/configs/Dx11FsrBridge.dll` 与同目录的 `.ini`。
4. OptiScaler 的 `OptiScaler.dll`。
5. DLSS5 add-on 的 `renodx-dlss5.addon64`。
6. `nvngx_dlssnr.dll` 与 OptiScaler 所需的 `nvngx_dlss.dll`。
7. `release/fps-unlocker/unlockfps_nc.exe` 与 `UnlockerStub.dll`。

将 2、5 放进 ReShade Add-ons 目录。将 3 中的 DLL 与 `.ini` 放在同一目录，只把 DLL 加到 FPS Unlocker 的 DLL 注入列表。模型 DLL 按对应项目的说明放置，不能用同名旧版本覆盖后不核对哈希。

## 启动顺序

1. 用 FPS Unlocker 的设置选择 `YuanShen.exe`。
2. 确认 AddonPath 和 DLL 列表全部来自当前目录，不含旧磁盘或其他机器的绝对路径。
3. 只通过 `unlockfps_nc.exe` 启动。
4. 在 ReShade Overlay 中确认桥接和 DLSS5 add-on 均为加载状态。
5. 首次测试选择渲染倍率 `0.999`，再逐步尝试其他倍率。

## 失败回退

删除或重命名 `dlss5-dx11-bridge.addon64` 即可回到没有 DLSS5 桥接的路径。不要删除游戏文件；先保留日志供定位。
