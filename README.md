# 原神 DLSS5 一键包

## 目录

- [最新版本 v1.1](#最新版本v11)
- [RTX 40 系列专用 DLSS NR 模型](#rtx-40-系列专用-dlss-nr-模型)
- [旧版本 v1.0](#旧版本v10)
- [失败排查！！！一定要看！一定要看！一定要看！！！](#报错闪退-进不去原神-进去了画面未生效可能原因)
- [屏幕闪烁说明](#dlss5刚进入时可能会有屏幕闪烁)
- [调参示例](#调参示例源于b站up主ZHFred)
- [解压后的目录](#解压后的目录)
- [工作原理](#工作原理)
- [引用的开源项目](#引用的开源项目)

1. 务必下载完整文件夹包，并将其放到任意 **英文路径下。不要放在带有中文路径或者空格的路径下** 
2. 只双击 `启动_DLSS5.bat`。
3. 第一次选择 `YuanShen.exe`，以后再次双击即可。
4. 如果不成功，请看[失败排查！！！一定要看！一定要看！一定要看！！！](#报错闪退-进不去原神-进去了画面未生效可能原因)

压缩包已包含运行所需组件：ReShade、OptiScaler、FSR Bridge、DLSS5 bridge、RenoDX、FPS Unlocker，以及 `nvngx_dlss.dll` 和 `nvngx_dlssnr.dll`。只需运行批处理文件，不需要打开 `.ps1`，也不需要改名 `dxgi.dll`/`d3d12.dll`。

HDR 也已包含并默认启用：启动器会设置原神的 HDR 开关，包内带有 RenoDX 和 HDR shader。要看到真实 HDR 输出，还需要在 Windows 和显示器上开启 HDR；ReShade shader 只是随包提供，不会自动启用每一个效果。

## 最新版本：v1.1 有问题进q 1107530312 联系

推荐下载 v1.1：已修复此前 RenoDX DLSS5 插件的显存泄漏问题，并更新 DLSS5/NR 模型组件。支持50系显卡。

[失败排查！！！一定要看！一定要看！一定要看！！！](#报错闪退-进不去原神-进去了画面未生效可能原因)

- [Google Drive 下载](https://drive.google.com/file/d/17LIscmrEGhJrlWnOdZNlRBFJotdHaOLf/view?usp=sharing)（不限速）
- [百度网盘下载](https://pan.baidu.com/s/1tlxdX8iLNN9gCvEd5j2soQ?pwd=y95x)（国内访问方便，建议使用 SVIP 下载）

百度网盘提取码：`y95x`；7z 解压密码：`yuanshenqidong`。

### RTX 40 系列专用 DLSS NR 模型

如果显卡是 RTX 40 系列，请额外下载 RHI 提供的 RTX40 专用 `nvngx_dlssnr.dll`，不要直接使用完整包内的默认 NR 模型：

- [Google Drive 下载](https://drive.google.com/file/d/1Ztmm0oSlFRQfNvbNN8aav11w-WriCWCA/view?usp=sharing)
- [百度网盘下载](https://pan.baidu.com/s/176qWSQ4eiyXjtHdyQb_iCw?pwd=jhfk)（提取码：`jhfk`）

解压后，用其中的 `nvngx_dlssnr.dll` 替换：

```text
DLSS5_GI_Ready\payload\ReShade\reshade-shaders\Addons\nvngx_dlssnr.dll
```

只替换这个文件，其余插件均保持不变。

## 报错闪退-进不去原神-进去了画面未生效可能原因

1. 请确保自己的系统是window11 24H及以上系统， 如不是请更新系统至最新（win10请升级至win11）。请确保你的显卡是Nvidia显卡的40系或者50系。请确保你使用的压缩包来源与此处的Google云盘或者百度网盘链接一致。请确保解压后放到任意 **英文路径下**，不要放在带有中文或者空格或者特殊字符的路径下*
2. 请在第一次启动前删除或卸载除当前压缩包以外的所有你安装过的第三方内容（如第三方游戏目录注入式启动器，Reshade组件，RHI组件等等），保证游戏目录文件夹处于干净状态，防止与DLSS5启动冲突。
3. 首先关闭你的所有杀毒软件，包括但不限于毒枭360，毒王电脑管家，毒霸金山... 其次检查是否插件被windows拦截了，具体按在win键，搜索安全，进入到windows安全中心，找到如下页面是否把UnlockerStub.dll给拦截了，需要允许其使用这个程序
![alt text](docs/images/fix_stub.dll.png)
4. 检查驱动是否为新版，目前已验证版本610.88可以正常启动使用，更高的版本兼容性更强，所以推荐更新到最新
5. 检查帧率限制是否已经被解除，如果没有，请务必在系统托盘中退出unlockfps_nc这个程序，然后重新双击启动DLSS5
6. 尽量不要把原神安装在系统盘的Program Files 目录，启动可能会有权限问题，可尝试使用管理员权限启动DLSS5, 或者将原神本体安装在根盘或者其它数据盘内。
7. 不要开启nvidai app里面的插帧功能！！！且原神内部的抗锯齿选项请使用FSR2！！！因为我们通过这个接口转成DLSS算法抗锯齿。进入游戏后可以试着调一下渲染倍率，其中倍率0.999相当于DLAA，0.2 就是超级性能档的DLSS. 关闭垂直同步，关闭动态模糊，关闭角色动态高精度。
8. 最后，请尝试重启游戏，重启系统看看是否解决。
![](docs/images/nv.png)

## DLSS5刚进入时可能会有屏幕闪烁

这是正常的，大概率是参数没有调好，可以自行配一下
![alt text](docs/images/canshu.jpg)

## 调参示例源于b站up主ZHFred
![](docs/images/example.jpg)
![](docs/images/dlss5exp.png)

## 解压后的目录

解压完成后，根目录应类似下图：

![解压后的文件结构](docs/images/dlss5-package-layout.png)

## 工作原理

原神本身是 DX11，DLSS5 插件需要 DX12 的 NGX 调用。启动器按固定顺序注入 ReShade、`Dx11FsrBridge.dll` 和 `OptiScaler.dll`：

1. Bridge 从 DX11 游戏帧中取得颜色、深度和运动向量，并建立一个内部 DX12 会话。
2. OptiScaler 提供 DLSS4 兼容入口；DLSS5 bridge 将这次 DX12 NGX 调用交给 `nvngx_dlssnr.dll` 和 RenoDX DLSS5 插件。
3. 神经渲染完成后，结果同步并复制回原神的 DX11 输出。

脚本每次启动都会把 ReShade 的 `AddonPath`、Shader 路径和 OptiScaler 路径改为压缩包当前位置。

桥接插件还修复了启动崩溃：ReShade 可能会二次包装 Bridge 自建的 DX12 设备，造成虚表冲突。修复版在创建内部设备时临时绕过 ReShade 的设备 hook，并先还原原生 adapter，再恢复 hook；不修改系统 DLL。

GitHub 只保存源码和小型 release 文件；组件授权与重新分发注意事项见 `docs/REDISTRIBUTION.md`。

### 旧版本：v1.0

如需兼容旧配置，可使用 v1.0。普通用户建议优先使用上面的 v1.1。

- [Google Drive 文件夹（v1.0）](https://drive.google.com/drive/folders/1VH2Vg4oAvD_12HBBRnA4xcjmpQUANo50?usp=sharing)
- [百度网盘：GI.7z（v1.0）](https://pan.baidu.com/s/1T9EqgpNZ2kmBWLzr1P4ETQ?pwd=ysqd)（建议使用 SVIP 下载）

百度网盘提取码：`ysqd`；7z 解压密码：`yuanshenqidong`。

如果解压后缺少 `UnlockerStub.dll`，请从 [GitHub 单独下载](https://github.com/CXP-2024/dlss5_for_genshinimpact/raw/refs/heads/main/release/fps-unlocker/UnlockerStub.dll)，放到解压包根目录，与 `启动_DLSS5.bat`、`unlockfps_nc.exe` 同级。只需补放这个文件，不要改名。


## 引用的开源项目

- [Genshin FSR Bridge](https://github.com/AizawaHikaru233/genshin_fsr_brigde)：拦截原神 DX11 的 FSR2 调用，准备颜色、深度和运动向量，并把超分请求转交给 OptiScaler。这里使用它的 `Dx11FsrBridge.dll` 作为 DX11 输入桥接；本项目没有改写其核心 FSR 算法，只调整了组件目录和加载顺序。
- [DLSS5 DX11 Bridge](https://github.com/NIGos/dlss5-dx11-bridge)：把 DX11 的 NGX 请求复制到自建 DX12 会话，使 DLSS5 Neural Rendering 插件能够接收到调用，再将结果复制回游戏输出。本项目基于其源码编译，并增加 ReShade 二次包装 D3D12 设备的兼容处理：创建内部设备时临时绕过 `D3D12CreateDevice` hook、还原原生 adapter，随后恢复 hook；具体见 [`LOCAL-CHANGES.md`](src/dlss5-dx11-bridge/LOCAL-CHANGES.md)。
- [Genshin FPS Unlock](https://github.com/34736384/genshin-fps-unlock)：通过外部进程写入游戏帧率参数并启动游戏。本项目未改动其解锁算法，只将 `unlockfps_nc.exe`、`UnlockerStub.dll` 和配置写入流程整合进一键包。

三个项目的组合关系是：FSR Bridge 提供 DX11 的输入资源，OptiScaler 提供 DLSS4 兼容入口，DLSS5 DX11 Bridge 将请求转入 DLSS5，FPS Unlocker 负责按配置启动并解锁帧率。
