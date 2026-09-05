# v1.3 配置

一键脚本会固定桥接所需配置，普通用户不需要手改；它不会覆盖外部 add-on 保存的 `Enabled` 或 `Mode`。

## OptiScaler

```ini
[Upscalers]
Dx11Upscaler=dlss_12

[Inputs]
EnableFsr2Inputs=true
UseFsr2Dx11Inputs=true
UseFsr2Inputs=true

[Plugins]
LoadReShade=false

[Hooks]
SkipD3D11DeviceVTableHooks=false

[DlssNr]
Enabled=false
```

`LoadReShade=false` 是因为普通 ReShade 已由 FPS Unlocker 独立注入；`[DlssNr] Enabled=false` 只关闭 OptiScaler 自带的 NR，外部双模式插件仍按自己的 Mode 运行。

## 外部双模式 NR

```ini
[NRBeforeSR]
Enabled=1
Mode=2
```

`Mode=2` 表示在渲染分辨率 NR 后交给原始 DLSS 超分，是新解压包的默认值。取消插件中的“使用渲染分辨率 NR -> SR”会保存 `Mode=1`，执行原始 DLSS SR 后再做输出分辨率 NR；启动器不会在下次启动时改回 Mode 2。

主 `nr-before-sr.zh-CN.addon64` 二进制未修改。RTX 30 与 RTX 50 使用不同的 `nrchain_nvngx.dll` 和 `nvngx_dlssnr.dll`，主入口自动选择对应目录；不能跨目录混用。

## 热键与日志

- `F6`：外部 NR 总开关。
- `Home`：ReShade Overlay。
- `Insert`：OptiScaler Overlay。

日志位于 `payload/Bridge`、`payload/OptiScaler`、活动的 `payload/ReShade/.../pre-nr*` 与游戏目录。Mode 2 成功判断以持续增长的 `NR-before-SR evaluate succeeded` 为准；Mode 1 应看到持续增长的 `NR-after-SR evaluate succeeded`，两者都必须伴随 Feature 18 成功。

HDR 下插件截图可能因色彩空间处理显示为灰色/偏色，优先使用 Windows 系统截图工具。
