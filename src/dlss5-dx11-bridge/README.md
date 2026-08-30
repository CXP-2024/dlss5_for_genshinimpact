# DLSS 5 DX11 Bridge

A ReShade add-on that lets a DLSS 5 Neural Rendering add-on — which only hooks
DirectX 12 — run inside a game that renders with DirectX 11.

Tested on Baldur's Gate 3 (DX11 build), with DLAA and with every DLSS quality
preset. Nothing here is specific to that game.

## What it does

A DLSS 5 add-on works by detouring `NVSDK_NGX_D3D12_CreateFeature` and
`NVSDK_NGX_D3D12_EvaluateFeature` and inserting its neural-rendering pass into
them. A D3D11 game never calls those functions, so the add-on sits idle forever
showing "waiting for game DLSS".

This bridge intercepts the game's own `NVSDK_NGX_D3D11_EvaluateFeature_C`,
forwards it untouched, and then reproduces the same DLSS contract on a second
NGX session running on its own D3D12 device. That D3D12 evaluate is a genuine
NGX call, so the DLSS 5 add-on detours it and does its work. The result is
copied back into the game's own output texture.

The DLSS 5 add-on is not modified or patched in any way. It simply starts
receiving the calls it was always waiting for.

Per frame:

1. copy the game's Color and MotionVectors into shared textures
2. convert the game's depth into a shared `R32_FLOAT` texture with a compute
   shader — `CopyResource` cannot, the formats are in different typeless
   families. Which view format is legal depends on the game's depth format, so
   it is read from the texture rather than assumed
3. signal a fence shared between the D3D11 and D3D12 queues
4. run the D3D12 evaluate, which is where the DLSS 5 add-on inserts itself
5. signal back, and copy the result into the game's output

Every size, offset and scalar is read from the game's own NGX parameter block
and forwarded verbatim, so upscaling presets work as well as DLAA.

## Requirements

In the game folder, alongside the game executable:

| File | Where from |
| --- | --- |
| `dxgi.dll` — ReShade 6.8+ **with add-on support** | reshade.me, full version |
| a DLSS 5 Neural Rendering ReShade add-on | its own author |
| `nvngx_dlssnr.dll` | shipped with that add-on |
| `dlss5-dx11-bridge.addon64` | this package |

The DLSS 5 add-on's own neural-rendering toggle has to be enabled, either in
its ReShade overlay panel or in `ReShade.ini`.

The bridge itself needs a D3D11 game with native DLSS, a GPU and driver that
support D3D12, and `ID3D11Device5` for cross-API shared fences.

## Install

Drop `dlss5-dx11-bridge.addon64` next to ReShade. On first run it writes
`dlss5-dx11-bridge.cfg` with working defaults; nothing needs configuring.

To remove it, delete the file.

Nothing on disk is patched. The only writes to foreign code are 14 bytes at
three function entry points, in memory, restored around every call.

## Configuration

`dlss5-dx11-bridge.cfg` is re-read while the game runs, so values can be
changed without restarting. Changes that only take effect on a new NGX feature
trigger a rebuild automatically.

| Key | Default | Meaning |
| --- | --- | --- |
| `stage` | 3 | How much of the bridge runs. `0` fully inert, `1` the input copies only, `2` also the depth conversion, `3` everything. Useful for isolating a problem: if `stage=0` still misbehaves, the bridge is not the cause. |
| `mode` | 2 | `0` never writes to the game, `1` transport only with no DLSS, `2` the full path. |
| `skip_game` | 1 | Do not forward the game's own DLSS evaluate. Its result is overwritten anyway, so running it is wasted work. Suppressed only while the bridge is healthy and already delivering. |
| `flags` | 107 | `DLSS.Feature.Create.Flags` for the bridge's feature. |
| `subrects` | 1 | Fallback for `DLSS.Enable.Output.Subrects`, used only when the game does not set one of its own. |
| `reset_every` | 0 | `1` forces the NGX Reset flag every frame, discarding temporal history. Diagnostic only. |
| `pixels` | 0 | `1` reads pixels back to the CPU for debugging. Stalls the GPU hard. |

## Log

`dlss5-dx11-bridge.log` records the contract read from the game, which
resource-sharing direction the driver accepted, the result of every NGX call,
and a timing line every 600 frames:

```
[bridge] 600 frames: bridge CPU 0.84 ms/frame | frame interval 16.00 ms (62.5 fps) | spread 5.74-29.93 ms | bridge is 5% of the frame | d3d12 43200/43202 (2 behind)
```

- **bridge CPU** is time spent inside this add-on, mostly waiting on the GPU
  rather than working. Read it next to the frame interval, not on its own.
- **spread** is the widest and narrowest gap between consecutive frames in the
  window. The average hides it, and it is what a driver-side frame generator
  responds to.
- **d3d12 N/M** is how far the D3D12 side is running behind. One to a few is
  ordinary pipelining. A gap that grows while the log then stops is the
  transport stalling; a small gap before a log stops dead means it is not.

## Performance

- The transport costs nothing measurable. With the D3D12 device, queue and
  allocators created but the evaluate disabled (`stage=2`), frame time matches
  the add-on being fully inert (`stage=0`).
- CPU time inside the add-on is well under a millisecond per frame. The rest is
  the neural pass on the GPU.
- How much that costs depends on scene, resolution, GPU and the DLSS 5 add-on's
  own settings, and varies enough between areas of one game that a single figure
  would mislead.

To measure it where you play: set `stage=0`, stand still, read a timing line;
set `stage=3`, do not move, read another. The file is re-read while the game
runs, so both come from one spot in one session.

## Related

[dlss5-d3d12-fix](https://github.com/NIGos/dlss5-d3d12-fix) fixes a different
failure of the same add-on: a DirectX 12 game whose DLSS output carries a mip
chain, which that add-on requires to be single-mip and silently refuses. If the
panel says STANDBY/FAILED rather than waiting for the game's DLSS, that is the
one to use.

## Building

Windows SDK and MSVC. No external dependencies; the ReShade add-on API is
reached through `GetProcAddress` and the NGX interfaces are declared inline.

From the `src` folder. `bridge.h` and `bridge.inc` are pulled in by the `.cpp`
and are not compiled separately.

```
rc /nologo version.rc
cl /nologo /LD /EHsc /O2 /MT dlss5-dx11-bridge.cpp ^
   /link /OUT:dlss5-dx11-bridge.addon64 version.res kernel32.lib user32.lib
```

The version lives in two places that have to stay in step: `BRIDGE_VERSION` in
the `.cpp`, and the numbers in `version.rc`. The first is what the log prints,
the second is what ReShade's overlay shows.

## Reporting a problem

Post `dlss5-dx11-bridge.log`. It is written to answer the usual questions
without a conversation:

- the exact build, with its compile date
- the host executable and Windows version
- **which of NVIDIA's model files are present next to the add-on**, and every
  `*.addon*` in the folder — the most common cause of "it does nothing" is a
  missing `nvngx_dlssnr.dll` or no DLSS 5 add-on at all
- **which `d3d11.dll` the process is using** — a wrapper in the game folder
  (ENB, a proxy) rather than the one in System32
- every other ReShade add-on in the folder, so conflicts are visible
- the GPU and driver
- the NGX capabilities this GPU will agree to. `SuperSamplingDenoising.Available`
  is reported among them, but it describes Ray Reconstruction rather than
  neural rendering, so a `0` there does not by itself mean the feature is
  unavailable
- **every module exporting the NGX D3D11 API, and which of them were hooked** —
  one line per layer, with the entry-point addresses
- if none were found, every loaded module exposing NGX or Streamline
- if they were hooked but nobody called them within 60 seconds, an explicit
  note saying so — that is a different problem from failing to hook, and the
  log distinguishes them
- whether `sl.interposer.dll` is in the process. Streamline does reach this
  add-on — it links NVIDIA's NGX D3D11 client and calls the same entry points on
  the feature snippet — but the calls then come from Streamline rather than from
  the game, which is worth knowing when reading the parameter block

## Confirmed working

Reported by users, across seven unrelated engines:

| Title | Engine | DLSS from |
| --- | --- | --- |
| **Baldur's Gate 3** | Divinity 4.0 | the game — tested in depth here, DLAA and every quality preset |
| **Final Fantasy XIV Online** | in-house | the game |
| **The Legend of Heroes: Trails beyond the Horizon** | Falcom | the game — needed both fixes in 1.0.4 and 1.0.5, and is the reason they exist |
| **Tainted Grail: Fall of Avalon** | Unity | the game |
| **7 Days to Die** | Unity | the game |
| **Skyrim Special Edition** | Creation | a DLSS injector mod |
| **Fallout 4** | Creation | a DLSS injector mod |
| **S.T.A.L.K.E.R. Anomaly** | X-Ray | an upscaler injector mod (SSS24) |
| **Assetto Corsa** | kunOS | Custom Shaders Patch (Preview 338 or later) |

The last three matter for a second reason: they show the bridge picks up DLSS
that another mod provides, not only DLSS built into the game. Those setups reach
NGX by a different route — the mod links NGX statically and calls the feature
snippet directly, rather than through the driver's loader — which is why every
module exporting the API is hooked rather than one chosen by guesswork.

Nothing here targets a particular game. Every module exporting the NGX D3D11
API is hooked, and every size, format and offset is read from the parameter
block the caller passes. Where it has failed so far
it has been because something was hardcoded from the one game it was written
against — see 1.0.4 — so reports from new titles are useful even when they work.

## Known limits

- The game's DLSS runs once and the bridge's runs once; with `skip_game=1` only
  the bridge's does. There is no path that avoids a second NGX session.
- Only tested on one game and one GPU.
- Resolution changes and DLSS preset changes are handled by rebuilding, but
  alt-tab and exclusive-fullscreen transitions are not specifically handled.
- Verbose logging is always on.

If anything goes wrong the bridge disables itself and the game renders on its
own; it never leaves a broken frame on screen deliberately.
