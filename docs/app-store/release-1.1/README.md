# Musica 1.1 release package

Authorized September 6, 2026 to improve discovery, downloads, and conversion.

`metadata.json` is the source for this release's App Store text. The release retains the existing name, adds a note-reading subtitle and relevant keywords, and explains the real-piano requirement and free/Premium features.

The six portrait screenshots use actual app captures with readable benefit headlines, ordered as follows:

1. Play the note on your piano — core practice experience.
2. A little help when they need it — note-name and keyboard hints.
3. Small goals. Big smiles. — completed daily goal and 20 free notes.
4. See their practice add up — progress calendar, explicitly marked Premium.
5. Ready for the next staff — grand staff, explicitly marked Premium.
6. Their own space to learn — multiple profiles, explicitly marked Premium.

Store screenshots are rendered with `render_screens.swift` from the original simulator captures in `raw/`. The accompanying HTML files are editable layout references, not a deployed website. Upload the six numbered JPEGs in `screenshots/`; each is an opaque 1320 × 2868 image. Run `swift docs/app-store/release-1.1/render_screens.swift "$PWD/docs/app-store/release-1.1"` from the repository root to reproduce them. Original screenshots from version 1.0 are retained elsewhere in this folder's parent directory.

Prices, available territories, and privacy practices remain unchanged in this release. A fresh-customer native App Store search check and real-piano user sessions remain external validation tasks; simulator checks do not establish acoustic detection quality or search ranking.
