/*
 * openamigamedialibrary check for libvpx: decode every frame of IVF files
 * (VP8 or VP9) and print a checksum of each picture's Y, U and V planes, so
 * an Amiga's results can be compared with a PC's.
 * MIT, Copyright (c) 2026 Dalsin Limited.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpx/vpx_decoder.h"
#include "vpx/vp8dx.h"

static unsigned long le32(const unsigned char *p)
{
    return p[0] | (unsigned long)p[1] << 8 | (unsigned long)p[2] << 16 | (unsigned long)p[3] << 24;
}

int main(int argc, char **argv)
{
    int a;
    for (a = 1; a < argc; a++) {
        FILE *f = fopen(argv[a], "rb");
        unsigned char header[32], frameHeader[12];
        vpx_codec_ctx_t codec;
        unsigned frame = 0;
        if (!f || fread(header, 1, 32, f) != 32 || memcmp(header, "DKIF", 4)) {
            printf("%s: not an IVF file\n", argv[a]);
            continue;
        }
        printf("%s %.4s %ux%u\n", argv[a], (const char *)header + 8, header[12] | header[13] << 8, header[14] | header[15] << 8);
        if (vpx_codec_dec_init(&codec, !memcmp(header + 8, "VP80", 4) ? vpx_codec_vp8_dx() : vpx_codec_vp9_dx(), NULL, 0)) {
            printf("VPX_INIT_FAIL\n");
            return 20;
        }
        while (fread(frameHeader, 1, 12, f) == 12) {
            unsigned long size = le32(frameHeader), sum = 0;
            unsigned char *data = malloc(size);
            vpx_codec_iter_t iter = NULL;
            vpx_image_t *img;
            int shown = 0;
            if (!data || fread(data, 1, size, f) != size) {
                printf("READ_FAIL %u\n", frame);
                return 20;
            }
            if (vpx_codec_decode(&codec, data, size, NULL, 0))
                printf("frame %u DECODE_FAIL %s\n", frame, vpx_codec_error(&codec));
            while ((img = vpx_codec_get_frame(&codec, &iter))) {
                int plane, y, x;
                for (plane = 0; plane < 3; plane++) {
                    int w = plane ? (img->d_w + 1) / 2 : img->d_w, h = plane ? (img->d_h + 1) / 2 : img->d_h;
                    for (y = 0; y < h; y++) {
                        const unsigned char *row = img->planes[plane] + y * img->stride[plane];
                        for (x = 0; x < w; x++)
                            sum = (sum * 31 + row[x]) & 0xffffffffUL;
                    }
                }
                shown++;
            }
            printf("frame %u bytes=%lu shown=%d sum=%08lx\n", frame, size, shown, sum);
            free(data);
            frame++;
        }
        vpx_codec_destroy(&codec);
        fclose(f);
    }
    printf("VPX_DONE\n");
    return 0;
}
