#!/bin/sh
# openamigamedialibrary: libwebp and libvpx, built for AmigaOS 3.x (68020 + FPU) with the
# os32-gcc16 compiler (bebbo's amiga-gcc, GCC 16.2, libnix, libpthread).
# MIT, Copyright (c) 2026 Dalsin Limited. The library keeps its own licence.
#
#   OS32_GCC16   compiler root holding prefix/ and compat/
#                (default ~/AmigaChrome/stoves/os32-gcc16)
#   PREFIX       where include/ and lib/ go (default ./out)
#   TARBALLS     folder holding the upstream tarballs listed in SOURCES
#                (default ./tarballs); the script checks their SHA-256
#   JOBS         parallel jobs for CMake/make builds (default 2)
#
# usage: ./build.sh
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
S=${OS32_GCC16:-"$HOME/AmigaChrome/stoves/os32-gcc16"}
P=$S/prefix
OUT=${PREFIX:-"$HERE/out"}
TARBALLS=${TARBALLS:-"$HERE/tarballs"}
JOBS=${JOBS:-2}
WORK="$HERE/work"
CC="$P/bin/m68k-amigaos-gcc"
CXX="$P/bin/m68k-amigaos-g++"
AR="$P/bin/m68k-amigaos-ar"
CPU=${OS32_CPU_FLAGS:-"-m68020 -m68881 -mcrt=nix20"}
CFLAGS="-O2 $CPU -D_DEFAULT_SOURCE=1 -D_POSIX_TIMERS=1 -D_POSIX_REALTIME_SIGNALS=1 -fno-common"
mkdir -p "$OUT/include" "$OUT/lib" "$WORK"

# unpack NAME TARBALL SHA256: check the tarball and unpack it into $WORK
unpack() {
    t="$TARBALLS/$2"
    [ -f "$t" ] || { echo "missing $t (see SOURCES)"; exit 2; }
    echo "$3  $t" | sha256sum -c - >/dev/null || { echo "SHA-256 mismatch: $t"; exit 2; }
    rm -rf "$WORK/$1"; mkdir -p "$WORK/$1"
    case "$2" in
        *.zip) (cd "$WORK/$1" && unzip -q "$t") ;;
        *) tar xf "$t" -C "$WORK/$1" ;;
    esac
}

# archive NAME FILE...: compile into $OUT/lib/libNAME.a ($XFLAGS added)
archive() {
    name=$1; shift
    obj="$WORK/obj-$name"
    rm -rf "$obj"; mkdir -p "$obj"
    for f in "$@"; do
        o="$obj/$(echo "$f" | tr '/' '_' | sed 's/\.[a-z]*$//').o"
        case "$f" in
            *.cc|*.cpp) $CXX $CFLAGS ${XFLAGS:-} -c "$f" -o "$o" ;;
            *) $CC $CFLAGS ${XFLAGS:-} -c "$f" -o "$o" ;;
        esac
    done
    rm -f "$OUT/lib/lib$name.a"
    $AR rcs "$OUT/lib/lib$name.a" "$obj"/*.o
    echo "lib$name.a: $(wc -c < "$OUT/lib/lib$name.a") bytes"
}

# Integer code only, built without FPU instructions: the same libraries serve
# programs and datatypes on any 68020 or better.
CFLAGS="-O2 -m68020 -mcrt=nix20 -fomit-frame-pointer -DNDEBUG -DWORDS_BIGENDIAN"

unpack libwebp libwebp-1.6.0.tar.gz e4ab7009bf0629fd11982d4c2aa83964cf244cffba7347ecd39019a9e38c4564
cd "$WORK/libwebp/libwebp-1.6.0"
patch -p1 -s < "$HERE/patches/libwebp-1.6.0-no-float.patch"
# The decoder (upstream's libwebpdecoder) and the demuxer, for animated and
# extended files. The SSE, NEON and MIPS files compile to nothing on 68k.
XFLAGS="-I. -Isrc" archive webpdecoder \
    src/dec/alpha_dec.c src/dec/buffer_dec.c src/dec/frame_dec.c src/dec/idec_dec.c src/dec/io_dec.c \
    src/dec/quant_dec.c src/dec/tree_dec.c src/dec/vp8_dec.c src/dec/vp8l_dec.c src/dec/webp_dec.c \
    src/dsp/alpha_processing.c src/dsp/cpu.c src/dsp/dec.c src/dsp/dec_clip_tables.c src/dsp/filters.c \
    src/dsp/lossless.c src/dsp/rescaler.c src/dsp/upsampling.c src/dsp/yuv.c \
    src/utils/bit_reader_utils.c src/utils/color_cache_utils.c src/utils/filters_utils.c \
    src/utils/huffman_utils.c src/utils/palette.c src/utils/quant_levels_dec_utils.c \
    src/utils/random_utils.c src/utils/rescaler_utils.c src/utils/thread_utils.c src/utils/utils.c
XFLAGS="-I. -Isrc" archive webpdemux src/demux/demux.c
mkdir -p "$OUT/include/webp"
cp src/webp/decode.h src/webp/demux.h src/webp/mux_types.h src/webp/types.h "$OUT/include/webp/"

unpack libvpx libvpx-1.17.0.tar.gz 1020f184046187baa2985dbde38e0691f49c44088bca7a1842b0236c6081dc0a
cd "$WORK/libvpx/libvpx-1.17.0"
patch -p1 -s < "$HERE/patches/libvpx-1.17.0-amiga-align.patch"
# The VP8 and VP9 decoders in plain C: no encoders, threads or tools.
mkdir -p "$WORK/libvpx-build" && cd "$WORK/libvpx-build"
CROSS="$P/bin/m68k-amigaos-" CFLAGS="$CFLAGS" "$WORK/libvpx/libvpx-1.17.0/configure" --target=generic-gnu \
    --prefix="$OUT" --disable-vp8-encoder --disable-vp9-encoder --enable-vp8-decoder --enable-vp9-decoder \
    --disable-examples --disable-tools --disable-docs --disable-unit-tests --disable-multithread \
    --disable-runtime-cpu-detect --disable-install-docs --disable-install-bins --disable-webm-io \
    --disable-libyuv --enable-static --disable-shared --disable-postproc --disable-vp9-postproc \
    --disable-internal-stats --disable-pic --size-limit=8192x8192 > configure.log
make -j"$JOBS" > build.log
make install > install.log
echo "libvpx.a: $(wc -c < "$OUT/lib/libvpx.a") bytes"
