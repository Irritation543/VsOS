import struct, os, sys, re

def bmp_to_c(name, path):
    with open(path, 'rb') as f:
        data = f.read()
    w = struct.unpack_from('<I', data, 18)[0]
    h = struct.unpack_from('<I', data, 22)[0]
    bpp = struct.unpack_from('<H', data, 28)[0]
    row_size = ((w * bpp + 31) // 32) * 4
    pixels = []
    for y in range(h):
        row_start = 54 + (h - 1 - y) * row_size
        for x in range(w):
            off = row_start + x * (bpp // 8)
            b = data[off]; g = data[off+1]; r = data[off+2]
            pixels.append((r << 16) | (g << 8) | b)
    arr_name = f"wp_{name}"
    lines = [f"const uint32_t {arr_name}[{w}*{h}] = {{"]
    for i, p in enumerate(pixels):
        if i % 8 == 0:
            lines.append("")
        lines[-1] += f" 0x{p:06X},"
    lines.append("\n};")
    return "\n".join(lines), arr_name

if __name__ == "__main__":
    files = [("Bliss", "wallpapers/Bliss.bmp"), ("Green Horizon", "wallpapers/Green Horizon.bmp")]
    arrays = []
    names = []
    labels = []
    for label, fname in files:
        if not os.path.exists(fname):
            print(f"Warning: {fname} not found, skipping")
            continue
        arr, arr_name = bmp_to_c(label.replace(" ", "_").lower(), fname)
        arrays.append(arr)
        names.append(arr_name)
        labels.append(label)

    n = len(labels)

    out_h = f'#ifndef WALLPAPER_H\n#define WALLPAPER_H\n\n#include <stdint.h>\n\n#define WP_COUNT {n}\n'
    out_h += 'extern const char *wp_names[WP_COUNT];\n'
    out_h += 'extern const uint32_t *wp_data[WP_COUNT];\n'
    for arr_name in names:
        out_h += f'extern const uint32_t {arr_name}[800*600];\n'
    out_h += '#endif\n'

    with open("kernel/wallpaper.h", "w") as f:
        f.write(out_h)

    out_c = '#include "wallpaper.h"\n\n'
    out_c += 'const char *wp_names[WP_COUNT] = {\n'
    for lbl in labels:
        out_c += f'    "{lbl}",\n'
    out_c += '};\n\n'
    out_c += 'const uint32_t *wp_data[WP_COUNT] = {\n'
    for n in names:
        out_c += f'    {n},\n'
    out_c += '};\n\n'
    for arr in arrays:
        out_c += arr + "\n\n"

    with open("kernel/wallpaper.c", "w") as f:
        f.write(out_c)

    print(f"Generated kernel/wallpaper.h and kernel/wallpaper.c ({n} wallpapers)")
