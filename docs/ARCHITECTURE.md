# v1.2 工作原理

v1.2 是无 GIMI 的“前置 NR 后超分”链路：

```text
Genshin DX11 FSR2 inputs (low resolution)
  -> Dx11FsrBridge
  -> OptiScaler DLSS-on-DX12 interop
  -> DLSS5 Neural Rendering Feature 18 at render resolution
  -> native DLSS Super Sampling Feature 1
  -> copy back to DX11
  -> ReShade and UI on the final swapchain
```

每帧的关键步骤：

1. `Dx11FsrBridge.dll` 识别原神 FSR2 路径的颜色、深度、运动向量和目标纹理。
2. OptiScaler 建立共享纹理、fence、私有 D3D12 device/queue/list，把 D3D11 输入转成 D3D12 资源。
3. `nr-before-sr.zh-CN.addon64` 观察原始 DLSS Feature 1 evaluate，Mode 2 先以同输入/输出尺寸创建 Feature 18，并把 NR 结果作为 Feature 1 的 Color。
4. 原始 `nvngx_dlss.dll` 把 NR 后的低分辨率颜色放大到游戏输出尺寸。
5. 输出同步并复制回 DX11；ReShade 和 UI 仍在最终游戏交换链下游。

## 无 GIMI 参数交接修复

旧的无 GIMI 路径先初始化原生 D3D11 NGX，`GetCapabilityParameters` 因而返回 NVIDIA 的类型严格参数表。随后 DX11-on-12 桥虽然写入了 D3D12 资源，但前置插件无法按 D3D12 resource 槽读取，表现为 Feature 1 调用增加而 Feature 18 始终为 0。

兼容构建在选择 `Dx11Upscaler=dlss_12` 时延迟原生 D3D11 NGX 初始化，让 FSR2 DX11 输入使用 OptiScaler 自有、支持资源指针交叉读取的参数表。原始 DLSS Feature 在 D3D12 侧独立初始化 native NGX，不损失 DLSS 超分。

## ReShade 私有 D3D12 修复

普通 ReShade 会 detour `D3D12CreateDevice` 并包装 DXGI adapter；私有 DLSS-on-DX12 device 若再次进入这层包装，会在 ReShade 中访问冲突。兼容构建只在创建私有 device 的短窗口内：

1. 通过 ReShade 内部 QueryInterface 标记取回原生 adapter；
2. 暂时恢复系统 `d3d12.dll` 入口原始字节；
3. 创建 device 后立刻恢复 ReShade detour。

修改只发生在当前游戏进程，不写入或替换系统 DLL。

## 已验证记录

本机实测链路为 `960x540 NR -> 960x540 -> DLSS -> 1920x1080`，Feature 18 连续成功 5400 帧，稳定段约 160 FPS。只有 Feature 1 evaluate 而没有 Feature 18 成功帧，不算 DLSS5 生效。
