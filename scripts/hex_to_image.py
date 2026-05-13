from PIL import Image

HEX_FILE  = "/home/izaan/tpg_vfb/sim/output_frame.hex"
OUT_IMAGE = "/home/izaan/tpg_vfb/sim/output_frame.png"
WIDTH     = 64
HEIGHT    = 64

pixels = []
last_valid = (0, 0, 0)

with open(HEX_FILE, "r") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        if 'x' in line.lower() or 'z' in line.lower():
            pixels.append(last_valid)  # use previous valid pixel
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
    pixels += [(0,0,0)] * (total - len(pixels))
else:
    pixels = pixels[:total]

print(f"Total pixels: {len(pixels)}")
img = Image.new("RGB", (WIDTH, HEIGHT))
img.putdata(pixels)
img.save(OUT_IMAGE)
print(f"Saved: {OUT_IMAGE}")

