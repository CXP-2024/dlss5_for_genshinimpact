# v1.2 配置

一键脚本会固定关键配置，普通用户不需要手改。

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

`LoadReShade=false` 是因为普通 ReShade 已由 FPS Unlocker 独立注入；`[DlssNr] Enabled=false` 只关闭 OptiScaler 自带的后置 NR，外部前置插件仍在运行。

## 前置 NR

```ini
[NRBeforeSR]
Enabled=1
Mode=2
```

`Mode=2` 表示渲染分辨率 NR 后交给原始 DLSS 超分。它是本项目对装机宅包内默认配置的唯一修改；两个插件二进制未修改。

## 热键与日志

- `F6`：前置 NR 总开关。
- `Home`：ReShade Overlay。
- `Insert`：OptiScaler Overlay。

日志位于 `payload/Bridge`、`payload/OptiScaler`、`payload/ReShade/.../pre-nr` 与游戏目录。成功判断以 `signed feature 18 create ... Success` 和持续增长的 `NR-before-SR evaluate succeeded` 为准。

HDR 下插件截图可能因色彩空间处理显示为灰色/偏色，优先使用 Windows 系统截图工具。
