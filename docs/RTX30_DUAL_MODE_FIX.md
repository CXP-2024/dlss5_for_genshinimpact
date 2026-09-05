# v1.3 RTX 30 后端兼容与双模式恢复说明

## 审核结论

v1.3 使用的外部修复来源包 `DLSS5_GI_Ready_v1.2_PreNR_fixRTX30.zip` 不是只替换了 NR 模型。
相对本仓库原 v1.2 实验补丁，它只继续修改三个 OptiScaler 源文件，但解决了两个不同问题：

1. RTX 30 的 NGX 驱动路径不能安全使用原 v1.2 的“延迟 D3D11 初始化 + 自定义参数表”。
2. 原神不同路径出现的 R8/R10/R11 packed/typeless 输出不能直接承担两种 NR/SR 排列所需的 FP16 中间结果。

修复包中的主插件 `nr-before-sr.zh-CN.addon64` 与原“野生的装机宅”包完全相同，
SHA-256 均为 `522D979CBFF335710F362B9FC2F330988673D7F8C7A1A2D93DA9980EC8DDA695`。
原包配置默认 `Mode=1`，因此后置 NR 本来就是插件功能；先前失效的部分位于桥接和启动配置。

## RTX 30 为什么恢复

`inputs/NVNGX_DLSS_Dx11.cpp` 将两个决策拆开：

- 无 GIMI 的 `dlss_12` 路径提前完成原生 D3D11 NGX 初始化，以满足 RTX 30/40 驱动的顺序要求；
- D3D11 的 Get/Capability/Allocate 接口返回由原生 D3D12 NGX 创建的参数对象，
  使私有驱动字段与桥接中的 `ID3D12Resource*` 同时有效；
- 销毁参数时使用与创建端匹配的 D3D12 NGX API。

桥接还给每条 D3D12 command list 写入稳定的 queue-affinity 标记，并在 Reset 后重新写入。
这让 RTX 30 运行时能够确认 Feature 18 命令确实属于同一图形队列。

## 两种画面链路

Mode 2 是默认的低分辨率 NR 超分链路：

```text
原神 DX11 渲染分辨率输入
  -> Feature 18 Neural Rendering
  -> 原始 Feature 1 DLSS Super Resolution
  -> ReShade / UI
```

Mode 1 是恢复的原插件后置链路：

```text
原神 DX11 渲染分辨率输入
  -> 原始 Feature 1 DLSS Super Resolution
  -> 输出分辨率 Feature 18 Neural Rendering
  -> ReShade / UI
```

桥接检测到游戏输出属于 R8/R10/R11 packed/typeless 格式时，会创建输出尺寸的
`R16G16B16A16_FLOAT` 载体。DLSS 和插件按选定顺序完成后，再把最终结果编码回游戏
输出并复制回 DX11。这个载体同时解决 Mode 1 后置 NR 和 RTX 30 对格式契约更严格的问题。

外部修复包只在 `R8G8B8A8_TYPELESS` 时启用该载体。实际国服/RTX 50 日志显示输出为
`R10G10B10A2_UNORM`（枚举 24），插件因而拒绝 Mode 1 并回退原始 DLSS。本仓库把判断
扩展到实际出现的 R8/R10/R11 packed/typeless 家族；这是在外部修复之上的本地补充。

## 一键启动的额外修正

外部修复包的两个 BAT 能选择不同 Profile，但它的 PowerShell 脚本每次启动都会强制写：

```ini
Enabled=1
Mode=2
```

因此其底层虽然支持 Mode 1，玩家的后置 NR 选择仍会在下一次启动时丢失。本仓库的启动器
不再修改这两个值：第一次使用 Mode 2 默认值，之后完整保留插件界面的选择。

主入口会自动识别 RTX 30/RTX 50 并选择成套的 AddonPath、`nrchain_nvngx.dll` 和
`nvngx_dlssnr.dll`。识别失败或检测到未验证显卡时，同一个 `启动_DLSS5.bat`
会提示选择 Profile；RTX 40 尚未建立经过实机验证的一键 Profile，不在自动选择范围内。

## RTX30 生命周期门禁与稳定 Add-on

修复实验中使用过的新版 Add-on 除了检查 Feature 18 是否成功，还要求通过 ReShade
观察私有 queue 的 `ExecuteCommandLists`、Signal 和 fence retirement。由于私有
D3D12 device 为避免 ReShade 二次包装而绕过其创建 detour，这些提交事件不会完整进入
ReShade 的观察路径。新版 Add-on 因而持续 fail-closed，日志表现为
`transfer-submitted=0` / `lifecycle-bypass` 增长，画面在前置 NR 与原始 SR
之间长期闪烁。

v1.3 的 RTX30 Profile 改用此前验证过的稳定旧版
`nr-before-sr.zh-CN.addon64`，SHA-256 为
`522D979CBFF335710F362B9FC2F330988673D7F8C7A1A2D93DA9980EC8DDA695`。
它仍创建并连续执行 Feature 18，只是不采用上述与私有 queue 观察路径不兼容的门禁。
因此这不是关闭 NR、退回普通 DLSS 或改回 v1.1 后置链路。

## 源码与归属

- OptiScaler 基线：`Dagherbou/OptiScaler_DLSSNR` 提交
  `973761621353b99bee3dc7d4bb27b117fef2644f`。
- 先应用 `src/patches/OptiScaler-DLSSOn12-pre-NR.patch`。
- 再应用 `src/patches/OptiScaler-RTX30-dual-mode.delta.patch`。
- RTX 30 增量和 Profile 来自用户提供的修复包，其文档署名“华晓熊”。
- RTX 30 NR runtime 为 RankFTW 310.8.SF-v2，文件无数字签名，不提交到 GitHub。
- 主 NR add-on 来自署名 Bilibili UP 主“野生的装机宅”的原包，二进制未修改。

本仓库只记录小型 Profile 文件、补丁、哈希和说明。大型 NVIDIA/RankFTW 运行时及完整
加密包不进入 Git 历史。

## 本地运行验收

在 RTX 5080 / 国服 `YuanShen.exe` 上使用最终构建和自动 Profile 选择：

- Mode 1：`post-SR signed feature 18 create 1920x1080 guides=960x540` 成功，
  `NR-after-SR evaluate succeeded` 持续到 600 帧；
- Mode 2：`signed feature 18 create 960x540 -> 960x540` 成功，
  `NR-before-SR evaluate succeeded` 持续到 1200 帧；
- 两次均记录 `output redirected from format 24 to R16G16B16A16_FLOAT`，未出现回写失败。
