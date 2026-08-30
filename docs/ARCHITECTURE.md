# 工作原理

原神使用 DX11，而 DLSS5 add-on 监听的是 DX12 NGX 调用。`Dx11FsrBridge.dll` 接管原神的 FSR2/TAAU 路径，`OptiScaler.dll` 提供 DLSS4 兼容入口；DLSS5 DX11 bridge 再为 DLSS5 建立独立的 DX12 NGX session。

每帧大致经过：

1. 从游戏资源复制颜色、运动向量和深度。
2. 将深度转换为共享的 `R32_FLOAT` 纹理。
3. 通过共享 fence 在 DX11 与 DX12 队列间同步。
4. 调用 DX12 NGX evaluate，由 DLSS5 add-on 插入神经渲染。
5. 将结果复制回游戏输出纹理。

当前自定义桥接还处理了 ReShade 包装 D3D12 设备导致的虚表冲突：创建内部设备时临时恢复原始 `D3D12CreateDevice` 字节，并将 ReShade 的 DXGI adapter proxy 解包为原生 adapter。修改只作用于进程内 hook，不改写磁盘上的系统 DLL。

这条路径会同时保留 DX11 游戏会话和桥接的 DX12 NGX 会话，因此不是“绕过 DLSS4、直接在原画上跑 DLSS5”。选择 `0.999` 可以让输入接近原生/DLAA，但桥接仍然需要存在。
