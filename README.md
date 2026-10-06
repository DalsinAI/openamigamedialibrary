# openamigamedialibrary

Media codec libraries for AmigaOS 3.x on 68k, built as static link libraries
for GCC programs and datatypes: libwebp (WebP pictures) and libvpx (VP8 and
VP9 video). openamigaimage's webp.datatype and webm.datatype are built on them. Part of the [OpenAmiga](https://github.com/DalsinAI/openamiga)
ports, made for [OpenBrowser](https://github.com/DalsinAI/openamigabrowser),
the WebKit browser for AmigaOS 3.2.

**Status:** Working: builds, and both libraries decode on the bench exactly as on a PC.

This repository holds the Amiga build, not libwebp, libvpx itself: a build script,
patches, a smoke test and the upstream licences.

## Upstream

| Library | Version | Licence | Home |
| --- | --- | --- | --- |
| libwebp | 1.6.0 | BSD-3-Clause with a patent grant (upstream/libwebp/) | https://developers.google.com/speed/webp |
| libvpx | 1.17.0 | BSD-3-Clause with a patent grant (upstream/libvpx/) | https://chromium.googlesource.com/webm/libvpx |

The exact files and their SHA-256 sums are in [SOURCES](SOURCES). All credit
for the library goes to its authors; see `upstream/` for their notices.

## What the Amiga port changes

- **libwebp: no floating point** (`patches/libwebp-1.6.0-no-float.patch`). The decoder's dithering setup (`VP8InitRandom`) is the one place it uses a float; the patch does it in integers, so the library needs no FPU and no floating-point emulation. Pictures decode the same.
- **libvpx: 8-byte alignment** (`patches/libvpx-1.17.0-amiga-align.patch`). AmigaOS hunk files align data to at most 8 bytes, and the assembler rejects libvpx's 16- and 32-byte `DECLARE_ALIGNED`. With the generic C code there is no SIMD that needs more, so the patch caps it at 8.
- Decoders only: libwebp's decoder and demuxer (upstream's `libwebpdecoder` and `libwebpdemux`), and libvpx's VP8 and VP9 decoders with no threads, post-processing or encoders.

## Building

You need the os32-gcc16 compiler (bebbo's amiga-gcc on GCC 16.2 with libnix
and libpthread; see DalsinAI/openamigabrowser `stove/`) and the upstream
tarballs from [SOURCES](SOURCES) in `tarballs/`. Then:

```
./build.sh
```

The libraries and headers land in `out/` (set `PREFIX` to change that). The
script prints which other settings it needs, if any. Target: 68020 or better, with or without an FPU (`-m68020`), libnix
(`-mcrt=nix20`): the code is integer only, so datatypes can use it too.

Link with: `-lwebpdemux -lwebpdecoder -lvpx`

## Tested

`tests/webptest.c`, run on AmigaOS 3.2.3 on AmigaChrome's AC090 emulation (68040 with FPU, 256 MB), Instance-24, 4 October 2026, as `webptest DH1:OB/webp/lossy.webp DH1:OB/webp/lossless-alpha.webp DH1:OB/webp/lossy-alpha.webp DH1:OB/webp/anim.webp`:

```
DH1:OB/webp/lossy.webp 64 48 alpha=0 24b3d77f
DH1:OB/webp/lossless-alpha.webp 40 30 alpha=1 65a9a948
DH1:OB/webp/lossy-alpha.webp 50 20 alpha=1 ca376736
DH1:OB/webp/anim.webp 32 32 alpha=0 02bb8100
```

The checksums are the same as on a PC: the WebP sums equal libwebp 1.6.0's on Linux, and all 60 video frames (30 VP8, 30 VP9, 160x120) equal libvpx 1.17.0's on Linux, frame for frame. The test files are openamigaimage's (`Datatypes/tests/make-media.sh`), with the WebM clips' frames copied into IVF files; the full output is in `tests/bench-output.txt`.

`tests/vpxtest.c`, as `vpxtest DH1:OB/vpx/vp8.ivf DH1:OB/vpx/vp9.ivf`:

```
DH1:OB/vpx/vp8.ivf VP80 160x120
frame 0 bytes=2084 shown=1 sum=c9b717f4
frame 1 bytes=1165 shown=1 sum=29795d4f
frame 2 bytes=1145 shown=1 sum=c5733365
...
DH1:OB/vpx/vp9.ivf VP90 160x120
frame 0 bytes=349 shown=1 sum=7d766a87
frame 1 bytes=112 shown=1 sum=3dbec590
frame 2 bytes=100 shown=1 sum=2e6748d2
...
VPX_DONE
```

It has not yet been run on real Amiga hardware.

## Known issues

- No encoders yet (WebP or VP8/VP9).

## Licence

Dalsin Limited's Amiga changes (the build script, patches, configuration
headers and tests) are MIT, Copyright (c) 2026 Dalsin Limited: see
[LICENSE](LICENSE). libwebp, libvpx keep their own licences, in
[upstream/](upstream/); a patch to their source stays under that licence.

## Contributors

openamigamedialibrary is created and maintained by [SacredTrees](https://github.com/SacredTrees) with the AmigaChrome agent team, copyright Dalsin Limited. Everyone whose work it includes is credited in [`CONTRIBUTORS.md`](CONTRIBUTORS.md).
