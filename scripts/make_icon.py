"""よろずのアプリアイコン（1024x1024）を描く。藍地に青海波、朱の判子に生成りの「万」。

使い方: python scripts/make_icon.py
出力: Yorozu/Assets.xcassets/AppIcon.appiconset/icon-1024.png
"""
import math
import random
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

S = 1024
SS = 2  # 2 倍で描いて縮小し、線をなめらかにする
W = S * SS
out = Path(__file__).resolve().parent.parent / "Yorozu/Assets.xcassets/AppIcon.appiconset/icon-1024.png"

AI = (22, 42, 78)        # 藍
AI_DEEP = (12, 24, 48)
WAVE = (64, 92, 138)
SHU = (200, 52, 38)      # 朱
KINARI = (247, 241, 228) # 生成り

# 背景: 上から下へ深くなる藍
bg = Image.new("RGB", (W, W), AI)
d = ImageDraw.Draw(bg)
for y in range(W):
    t = y / W
    c = tuple(round(AI[i] * (1 - t) + AI_DEEP[i] * t) for i in range(3))
    d.line([(0, y), (W, y)], fill=c)

# 青海波（下半分ほど、薄く）
waves = Image.new("L", (W, W), 0)
wd = ImageDraw.Draw(waves)
r = 150 * SS
step_x, step_y = r * 2, r // 2
for row in range(-1, W // step_y + 3):
    y = row * step_y
    off = 0 if row % 2 == 0 else r
    for col in range(-1, W // step_x + 2):
        x = col * step_x + off
        for k in range(4):
            rr = r - k * (r // 4)
            lw = 5 * SS
            wd.ellipse([x - rr, y - rr, x + rr, y + rr], fill=0)
            wd.ellipse([x - rr, y - rr, x + rr, y + rr], outline=255, width=lw)
# 上に行くほど消える
fade = Image.linear_gradient("L").resize((W, W))
fade = fade.point(lambda v: max(0, min(255, int((v - 90) * 1.6))))
waves = ImageChops.multiply(waves, fade).point(lambda v: v * 0.55)
bg.paste(Image.new("RGB", (W, W), WAVE), mask=waves)

# 朱の判子（少し回して、手押しの揺らぎ）
seal_size = 560 * SS
seal = Image.new("L", (seal_size, seal_size), 0)
sd = ImageDraw.Draw(seal)
sd.rounded_rectangle([0, 0, seal_size - 1, seal_size - 1], radius=70 * SS, fill=255)

# 白抜きの「万」と内枠
font = ImageFont.truetype("C:/Windows/Fonts/yumindb.ttf", int(430 * SS))
glyph = Image.new("L", (seal_size, seal_size), 0)
gd = ImageDraw.Draw(glyph)
inset = 34 * SS
gd.rounded_rectangle([inset, inset, seal_size - inset, seal_size - inset], radius=44 * SS, outline=255, width=12 * SS)
bbox = gd.textbbox((0, 0), "万", font=font)
tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
gd.text(((seal_size - tw) / 2 - bbox[0], (seal_size - th) / 2 - bbox[1] + 6 * SS), "万", font=font, fill=255)
seal = ImageChops.subtract(seal, glyph)

# 朱肉のかすれ: 細かい点で少しだけ欠けさせる
rng = random.Random(7)
grain = Image.new("L", (seal_size, seal_size), 255)
gr = ImageDraw.Draw(grain)
for _ in range(900):
    x, y = rng.randrange(seal_size), rng.randrange(seal_size)
    rad = rng.choice([1, 1, 2, 3]) * SS
    gr.ellipse([x - rad, y - rad, x + rad, y + rad], fill=rng.randrange(120, 220))
# 縁の方を強めにかすれさせる
edge = Image.new("L", (seal_size, seal_size), 0)
ed = ImageDraw.Draw(edge)
ed.rounded_rectangle([0, 0, seal_size - 1, seal_size - 1], radius=70 * SS, outline=255, width=18 * SS)
edge = edge.filter(ImageFilter.GaussianBlur(10 * SS))
grain = ImageChops.subtract(grain, edge.point(lambda v: v * 0.35))
seal = ImageChops.multiply(seal, grain)
glyph = ImageChops.multiply(glyph, grain)

seal = seal.rotate(-4, resample=Image.BICUBIC, expand=True)
glyph = glyph.rotate(-4, resample=Image.BICUBIC, expand=True)
sx = (W - seal.width) // 2
sy = (W - seal.height) // 2

# 影
shadow = Image.new("L", (W, W), 0)
shadow.paste(seal, (sx + 6 * SS, sy + 16 * SS))
shadow = shadow.filter(ImageFilter.GaussianBlur(26 * SS)).point(lambda v: v * 0.45)
bg.paste(Image.new("RGB", (W, W), (4, 8, 18)), mask=shadow)

bg.paste(Image.new("RGB", seal.size, SHU), (sx, sy), mask=seal)
bg.paste(Image.new("RGB", glyph.size, KINARI), (sx, sy), mask=glyph)

icon = bg.resize((S, S), Image.LANCZOS)
out.parent.mkdir(parents=True, exist_ok=True)
icon.save(out)
print(out)
