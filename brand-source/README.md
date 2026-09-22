# Brand source material

The originals the templates' artwork is derived from. Nothing here is loaded at
build time: the templates read the prepared files in [`../latex/assets`](../latex/assets),
which the Office builders share. Keep this folder as the record of where those
came from, and regenerate rather than edit the prepared files by hand.

| File | What it is | Prepared as |
| --- | --- | --- |
| `logo.png` | The university crest, full colour, as issued. | `saus-logo.png`, and from it `saus-logo-white.png` and `saus-logo-gray.png` |
| `favicon.ico` | Site icon from saus.edu.pk. | not used by the templates |
| `aerial-campus.jpg` | Aerial view of the campus. | `saus-title-bg.jpg` |
| `entrance-monument.jpg` | The entrance with the name pylon. | `saus-campus-gate.jpg` |
| `teaching-block.jpg` | Teaching block across the lawn. | `saus-campus-courtyard.jpg` |
| `rock-monument.jpg` | The painted rock monument. | `saus-monument.jpg` |

Only the originals behind a prepared file are kept here; photographs the
templates don't use belong in the university's own photo library, not in the
repository. `favicon.ico` stays because it is part of the identity, not a
photograph.

## Regenerating

If the university issues a revised crest, replace `logo.png`, copy it to
`../latex/assets/saus-logo.png` trimmed, and make the white and grey versions
from it:

```bash
magick logo.png -trim +repage ../latex/assets/saus-logo.png
magick ../latex/assets/saus-logo.png -trim +repage -background white -alpha remove \
  -alpha off -colorspace Gray -negate -linear-stretch 2%x2% \( +clone \) \
  -compose CopyOpacity -composite -colorspace sRGB ../latex/assets/saus-logo-white.png
```

Photographs are cover-cropped to the page or slide, so prepare them at 16:9 or
wider; 1920×1080 is ample.

## Signatures

`make-signature-specimen.py` draws `../latex/assets/signature-specimen.png`, the
invented scrawl the letter and certificate demos sign with. It is nobody's
signature, so the demo PDFs in this repository can be shared freely.

**Real signatures stay out of the repository.** Keep the signer's PNG outside it
(or at the repository root, where `.gitignore` excludes `signature-trans.png`),
and point a single document at it with `\saussignimage{...}` or
`\signatory[...]{...}`. Never copy one into `../latex/assets`, into a template,
or into a committed PDF.
