#include <stdio.h>
#include <assert.h>
#include <string.h>

#include "b85.h"

void b85_enc_part(uint8_t const *src, size_t srclen,
    uint8_t *dst, size_t *dstlen,
    uint8_t const **rem, size_t *remlen)
{
    size_t i;

    assert(src);
    assert(dst);
    assert(dstlen);
    assert(rem);
    assert(remlen);

    for(i = 0, *dstlen = 0; i + 4 <= srclen; i += 4, *dstlen += 5) {
        // todo: handle special cases: zeros, spaces
        uint32_t v = (src[i] << 24) | (src[i+1] << 16) | (src[i+2] << 8) | src[i+3];
        dst[*dstlen + 4] = v % 85 + 33; v /= 85;
        dst[*dstlen + 3] = v % 85 + 33; v /= 85;
        dst[*dstlen + 2] = v % 85 + 33; v /= 85;
        dst[*dstlen + 1] = v % 85 + 33; v /= 85;
        dst[*dstlen] = v % 85 + 33;
    }
    *rem = src + i;
    *remlen = srclen - i;
}

int b85_enc_final(uint8_t const *src, size_t srclen,
    uint8_t *dst, size_t *dstlen)
{
    switch(srclen) {
        uint32_t v;

    case 0:
        *dstlen = 0;
        return(0);
        break;
    case 1:
        v = (src[0] << 24) | 1;
        v /= 85; v /= 85; v /= 85;
        dst[1] = v % 85 + 33; v /= 85;
        dst[0] = v % 85 + 33;
        *dstlen = 2;
        return(0);
        break;
    case 2:
        v = (src[0] << 24) | (src[1] << 16) | 1;
        v /= 85; v /= 85;
        dst[2] = v % 85 + 33; v /= 85;
        dst[1] = v % 85 + 33; v /= 85;
        dst[0] = v % 85 + 33;
        *dstlen = 3;
        return(0);
        break;
    case 3:
        v = (src[0] << 24) | (src[1] << 16) |(src[2] << 8) | 1;
        v /= 85;
        dst[3] = v % 85 + 33; v /= 85;
        dst[2] = v % 85 + 33; v /= 85;
        dst[1] = v % 85 + 33; v /= 85;
        dst[0] = v % 85 + 33;
        *dstlen = 4;
        return(0);
        break;
    default:
        return(1);
        break;
    }
}

int b85_dec_part(uint8_t const *src, size_t srclen,
    uint8_t *dst, size_t *dstlen,
    uint8_t const **rem, size_t *remlen)
{
    size_t i;

    assert(src);
    assert(dst);
    assert(dstlen);
    assert(rem);
    assert(remlen);

    for(i = 0, *dstlen = 0; i + 5 <= srclen; i += 5, *dstlen += 4) {
        // todo: handle special cases: z, y
        // todo: handle errors!
        uint32_t v = (src[i] - 33) * 52200625; // 85 ** 4
        v += (src[i+1] - 33) * 614125; // 85 ** 3
        v += (src[i+2] - 33) * 7225; // 85 ** 2
        v += (src[i+3] - 33) * 85; // 85 ** 1
        v += src[i+4] - 33; // 85 ** 0
        dst[3] = v & 0xff; v = v >> 8;
        dst[2] = v & 0xff; v = v >> 8;
        dst[1] = v & 0xff; v = v >> 8;
        dst[0] = v & 0xff;
    }
    *rem = src + i;
    *remlen = srclen - i;
    return(0);
}

int b85_dec_final(uint8_t const *src, size_t srclen,
    uint8_t *dst, size_t *dstlen)
{
    assert(src);
    assert(dst);
    assert(dstlen);

    // todo: handle special cases: z, y
    // todo: handle errors!
    switch(srclen) {
        uint32_t v;

    case 0:
        *dstlen = 0;
        return(0);
        break;
    case 2:
        v = (src[0] - 33) * 52200625; // 85 ** 4
        v += (src[1] - 33) * 614125; // 85 ** 3
        v += ('u' - 33) * 7225; // 85 ** 2
        v += ('u' - 33) * 85; // 85 ** 1
        v += 'u' - 33; // 85 ** 0
        v = v >> 24;
        dst[0] = v & 0xff;
        *dstlen = 1;
        return(0);
        break;
    case 3:
        v = (src[0] - 33) * 52200625; // 85 ** 4
        v += (src[1] - 33) * 614125; // 85 ** 3
        v += (src[2] - 33) * 7225; // 85 ** 2
        v += ('u' - 33) * 85; // 85 ** 1
        v += 'u' - 33; // 85 ** 0
        v = v >> 16;
        dst[1] = v & 0xff; v = v >> 8;
        dst[0] = v & 0xff;
        *dstlen = 2;
        return(0);
        break;
    case 4:
        v = (src[0] - 33) * 52200625; // 85 ** 4
        v += (src[1] - 33) * 614125; // 85 ** 3
        v += (src[2] - 33) * 7225; // 85 ** 2
        v += (src[3] - 33) * 85; // 85 ** 1
        v += 'u' - 33; // 85 ** 0
        v = v >> 8;
        dst[2] = v & 0xff; v = v >> 8;
        dst[1] = v & 0xff; v = v >> 8;
        dst[0] = v & 0xff;
        *dstlen = 3;
        return(0);
        break;
    default:
        return(1);
        break;
    }
}
