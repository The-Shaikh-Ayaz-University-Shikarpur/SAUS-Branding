"""Draw assets/signature-specimen.png: the placeholder signature used by the
letter and certificate demos.

It is an invented pen scrawl -- nobody's signature -- so that the demo PDFs in
this repository can be shared. A real signature belongs in the signer's own
copy of a letter, never in a template (see the README).

    python brand-source/make-signature-specimen.py
"""
import os

from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                   "..", "latex", "assets", "signature-specimen.png")

W, H, SS = 1100, 380, 4                      # size, and supersampling for edges
INK = (26, 26, 46)                           # blue-black ink

# Each stroke is a chain of cubic Beziers: p0, c1, c2, p1, c1, c2, p1, ...
# with the pen width at the start and end of the stroke.
STROKES = [
    # capital initial: a tall loop coming down into a belly
    ([(120, 300), (150, 120), (300, 60), (330, 150),
      (355, 225), (190, 250), (205, 310),
      (218, 358), (330, 330), (360, 268)], 6, 13),
    # a small connecting hump into a second letter
    ([(330, 300), (395, 200), (430, 300), (470, 250),
      (505, 205), (470, 130), (520, 128),
      (570, 126), (560, 290), (620, 268)], 5, 11),
    # trailing letters, getting looser
    ([(600, 285), (650, 190), (690, 300), (735, 245),
      (780, 192), (800, 300), (860, 235),
      (915, 172), (930, 250), (980, 205)], 5, 9),
    # the flourish underneath
    ([(170, 340), (330, 395), (700, 372), (900, 318),
      (960, 302), (975, 268), (930, 262)], 4, 9),
]


def bezier(p0, c1, c2, p1, steps):
    for i in range(steps + 1):
        t = i / steps
        u = 1 - t
        yield (u * u * u * p0[0] + 3 * u * u * t * c1[0] + 3 * u * t * t * c2[0] + t * t * t * p1[0],
               u * u * u * p0[1] + 3 * u * u * t * c1[1] + 3 * u * t * t * c2[1] + t * t * t * p1[1])


def points(chain):
    pts = [chain[0]]
    for i in range(0, len(chain) - 3, 3):
        pts += list(bezier(chain[i], chain[i + 1], chain[i + 2], chain[i + 3], 400))[1:]
    return pts


img = Image.new("RGBA", (W * SS, H * SS), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

for chain, w_start, w_end in STROKES:
    pts = points(chain)
    n = len(pts) - 1
    last = None
    for i, (x, y) in enumerate(pts):
        t = i / n
        # taper both ends of the stroke, and let the pen swell in between
        taper = min(1.0, 8 * min(t, 1 - t) + 0.35)
        w = (w_start + (w_end - w_start) * t) * taper
        r = w * SS / 2
        here = (x * SS, y * SS)
        draw.ellipse([here[0] - r, here[1] - r, here[0] + r, here[1] + r], fill=INK)
        if last:                    # keep the line solid where the pen runs thin
            draw.line([last, here], fill=INK, width=max(1, int(round(w * SS))))
        last = here

out = img.resize((W, H), Image.LANCZOS)
box = out.getbbox()                          # trim, as a scanned signature would be,
out = out.crop((box[0] - 8, box[1] - 8,      # but leave room under the flourish so
                box[2] + 8, box[3] + 70))    # it does not strike through the name
out.save(os.path.normpath(OUT))
print("wrote", os.path.normpath(OUT))
