"""Generate reproducible App Store screenshot layouts from actual simulator captures."""
from html import escape
from pathlib import Path

ROOT = Path(__file__).parent
SCENES = [
    ("01-practice", "practice", "REAL PIANO. REAL PRACTICE.", "Play the note<br>on your piano.",
     "Musica listens as your child plays.<br>No cables. No touchscreen keys.", "20 NOTES A DAY · FREE", "mint"),
    ("02-hints", "hints", "FROM THE STAFF TO THE KEYS", "A little help.<br>A lot of progress.",
     "Helpful note names and keyboard hints<br>when they need a nudge.", "LEARN AT THEIR OWN PACE", "lavender"),
    ("03-goal", "goal", "A LITTLE PRACTICE, EVERY DAY", "Small goals.<br>Big smiles.",
     "20 free notes each day.<br>A celebration when the goal is reached.", "BUILD A DAILY HABIT", "peach"),
    ("04-progress", "progress", "MUSICA PREMIUM", "See their<br>practice add up.",
     "Daily scores, gold stars, and a record<br>of the notes they practiced.", "PROGRESS CALENDAR · PREMIUM", "lavender"),
    ("05-grand", "grand", "MUSICA PREMIUM", "Ready for<br>the next staff.",
     "Grow from treble to bass<br>and the full grand staff.", "MORE ROOM TO GROW · PREMIUM", "mint"),
    ("06-profiles", "profiles", "MUSICA PREMIUM", "Their own<br>space to learn.",
     "A profile, pace, and practice history<br>for each child in your family.", "MULTIPLE PROFILES · PREMIUM", "peach"),
]

CSS = """
*{box-sizing:border-box}html,body{margin:0;width:1320px;height:2868px;overflow:hidden}
body{position:relative;font-family:-apple-system,BlinkMacSystemFont,Arial,sans-serif;color:#172a38;background:var(--bg)}
.mint{--bg:#dff5eb;--accent:#247a65;--glow:#b4e4cf}.lavender{--bg:#ede8fc;--accent:#7051b0;--glow:#d5c7f5}
.peach{--bg:#fff0dd;--accent:#9d602c;--glow:#f4d5a6}
.halo{position:absolute;left:calc(50% - 780px);top:1040px;width:1560px;height:1560px;border-radius:50%;background:var(--glow);opacity:.65}
header{position:absolute;left:100px;top:106px;width:1120px;z-index:2}
.brand{display:flex;align-items:center;gap:20px;font-size:42px;font-weight:700;letter-spacing:-1px}
.brand img{width:68px;height:68px;border-radius:16px}
.eyebrow{margin-top:68px;font-size:27px;font-weight:750;letter-spacing:4px;color:var(--accent)}
h1{margin:27px 0 29px;font-size:116px;line-height:1.04;letter-spacing:-6px;font-weight:800}
.detail{font-size:38px;line-height:1.45;font-weight:450;color:#3b4b55}
.phone{position:absolute;z-index:1;top:815px;left:220px;width:880px;padding:13px;border-radius:106px;background:#23313c;box-shadow:0 36px 64px #1c354532;overflow:hidden}
.phone img{display:block;width:854px;height:auto;border-radius:93px}
footer{position:absolute;z-index:3;bottom:80px;left:100px;width:1120px;text-align:center;font-size:26px;letter-spacing:2.5px;font-weight:750;color:var(--accent)}
"""

for slug, screenshot, eyebrow, title, detail, footer, theme in SCENES:
    page = f'''<!doctype html><html lang="en"><meta charset="utf-8"><title>{escape(slug)} — Musica</title>
<style>{CSS}</style><body class="{theme}"><div class="halo"></div>
<header><div class="brand"><img src="../../../Musica/Assets.xcassets/AppIcon.appiconset/AppIcon.png" alt="">Musica</div>
<div class="eyebrow">{eyebrow}</div><h1>{title}</h1><div class="detail">{detail}</div></header>
<div class="phone"><img src="raw/{screenshot}.png" alt="Actual Musica {screenshot} screen"></div>
<footer>{footer}</footer></body></html>'''
    (ROOT / f"{slug}.html").write_text(page)

print(f"Generated {len(SCENES)} screenshot layouts at 1320 × 2868.")
