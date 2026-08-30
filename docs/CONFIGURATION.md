# 配置建议

## 桥接配置

以 `examples/dlss5-dx11-bridge.cfg` 为起点：

- `stage=3`、`mode=2`：完整桥接路径。
- `skip_game=1`：跳过会被覆盖的原生 DLSS evaluate，避免重复计算。
- `reset_every=0`：保留时间性历史；只有诊断伪影时临时设为 `1`。
- `pixels=0`：不要开启 CPU 回读，它会强制 GPU 同步并显著拖慢帧率。
- `dred=0`：正常使用保持关闭；只在 D3D12 崩溃诊断时打开。

配置文件热加载，但地址/RVA 只对已验证的游戏版本有效。升级游戏后若菜单或渲染异常，应先禁用桥接并重新确认版本适配。

## ReShade / DLSS5

使用带 Add-on 支持的 ReShade。DLSS5 add-on 的 Neural Rendering 开关由它自己的面板控制；桥接只负责把 DX11 的 NGX 调用送到 DX12 会话。

`0.999` 是渲染倍率菜单中的原生档位，用于 DLAA/原生输入测试；它不是“99.9% 的 DLSS 质量”。

## 伪影排查

先保持同一场景：

1. `stage=0`，确认原始画面。
2. `stage=3`，保持 DLSS5 参数不变。
3. 若只在桥接开启时出现问题，检查深度约定、运动向量缩放和历史重置。
4. 若两者都正常但 DLSS5 开启后异常，优先检查 `nvngx_dlssnr.dll`、RenoDX add-on 和 ReShade 版本是否成套。
