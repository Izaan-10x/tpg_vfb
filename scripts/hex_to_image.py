import os
from PIL import Image

WIDTH  = 64
HEIGHT = 64

def hex_to_png(hex_file, out_file):
    if not os.path.exists(hex_file):
        print(f"SKIPPING: {hex_file} not found ? run simulation first")
        return

    pixels = []
    last_valid = (0, 0, 0)

    with open(hex_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if 'x' in line.lower() or 'z' in line.lower():
                pixels.append(last_valid)
                continue
            val = int(line, 16)
            r = (val >> 16) & 0xFF
            g = (val >>  8) & 0xFF
            b = (val >>  0) & 0xFF
            pix = (r, g, b)
            last_valid = pix
            pixels.append(pix)

    total = WIDTH * HEIGHT
    if len(pixels) < total:
        print(f"WARNING: only {len(pixels)} pixels in {hex_file}, expected {total}")
        pixels += [(0, 0, 0)] * (total - len(pixels))
    else:
        pixels = pixels[:total]

    img = Image.new("RGB", (WIDTH, HEIGHT))
    img.putdata(pixels)
    img.save(out_file)
    print(f"Saved: {out_file}")

hex_to_png(
    "/home/izaan/tpg_vfb/sim/tpg_output.hex",
    "/home/izaan/tpg_vfb/sim/tpg_output.png"
)

hex_to_png(
    "/home/izaan/tpg_vfb/sim/output_frame.hex",
    "/home/izaan/tpg_vfb/sim/output_frame.png"
)

print("")
print("Compare:")
print("  TPG raw : sim/tpg_output.png")
print("  VFB out : sim/output_frame.png")
