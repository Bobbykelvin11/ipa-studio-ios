#!/usr/bin/env python3
"""Generates the IPA Studio app icon (1024x1024, opaque)."""
import math
import os
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "IPAStudio", "Assets.xcassets", "AppIcon.appiconset", "AppIcon-1024.png")
S = 2048  # supersample

img = Image.new("RGB", (S, S))
px = img.load()
top = (99, 102, 241)     # indigo
bottom = (217, 70, 239)  # fuchsia
for y in range(S):
    for x in range(S):
        t = (x * 0.35 + y * 0.65) / S
        px[x, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))

overlay = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(overlay)

# soft glow
glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
gd.ellipse([S * 0.18, S * 0.12, S * 0.82, S * 0.76], fill=(255, 255, 255, 70))
glow = glow.filter(ImageFilter.GaussianBlur(120))
img.paste(glow, (0, 0), glow)

# isometric package box
cx, cy = S * 0.5, S * 0.55
w, h = S * 0.30, S * 0.17
depth = S * 0.26
topf = [(cx, cy - h - depth * 0.5), (cx + w, cy - depth * 0.5), (cx, cy + h - depth * 0.5), (cx - w, cy - depth * 0.5)]
left = [topf[3], topf[2], (topf[2][0], topf[2][1] + depth), (topf[3][0], topf[3][1] + depth)]
right = [topf[2], topf[1], (topf[1][0], topf[1][1] + depth), (topf[2][0], topf[2][1] + depth)]
d.polygon(left, fill=(255, 255, 255, 235))
d.polygon(right, fill=(226, 232, 255, 235))
d.polygon(topf, fill=(255, 255, 255, 255))
# tape stripe on top
d.line([((topf[0][0] + topf[3][0]) / 2, (topf[0][1] + topf[3][1]) / 2), ((topf[1][0] + topf[2][0]) / 2, (topf[1][1] + topf[2][1]) / 2)], fill=(129, 140, 248, 255), width=int(S * 0.035))

# "IPA" chevrons on the left face: </>
lx, ly = (left[0][0] + left[2][0]) / 2, (left[0][1] + left[2][1]) / 2
col = (124, 58, 237, 255)
lw = int(S * 0.028)
d.line([(lx - S * 0.06, ly - S * 0.05), (lx - S * 0.11, ly), (lx - S * 0.06, ly + S * 0.05)], fill=col, width=lw, joint="curve")
d.line([(lx + S * 0.03, ly - S * 0.03), (lx + S * 0.08, ly + S * 0.02), (lx + S * 0.03, ly + S * 0.07)], fill=col, width=lw, joint="curve")

# sparkle (AI) top-right
def sparkle(x, y, r, a=255):
    pts = []
    for i in range(8):
        ang = math.pi / 4 * i - math.pi / 2
        rr = r if i % 2 == 0 else r * 0.28
        pts.append((x + rr * math.cos(ang), y + rr * math.sin(ang)))
    d.polygon(pts, fill=(255, 255, 255, a))

sparkle(S * 0.77, S * 0.22, S * 0.11)
sparkle(S * 0.63, S * 0.13, S * 0.045, 220)

img = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
img = img.resize((1024, 1024), Image.LANCZOS)
os.makedirs(os.path.dirname(OUT), exist_ok=True)
img.save(OUT, "PNG")
print("wrote", OUT)
