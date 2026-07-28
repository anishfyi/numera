# UI audit issues log

One row per gap found, with the fix applied. Newest passes appended.

| # | screen | viewport / theme | what's wrong | fix applied |
|---|--------|------------------|--------------|-------------|
| 1 | landing (#full section) | 1440x900 · light + dark | The full-agent feature list (`#full .feat`) spanned the entire 1380px container (`max-width:none`); lines were far too long and loose compared to the capped prose elsewhere - a line-length / readability gap and inconsistent rhythm. | Capped the list to `max-width:64ch` (now ~661px), so each bold label sits tight with its description, matching the ~60ch prose above. Mobile unaffected (64ch > viewport, still full-width). |

## Checked and clean (no fix needed)
- **Horizontal overflow:** 0px at 1440 and 390 (and 360) in both themes - the earlier mobile grid `min-width:0` fix holds.
- **Hero / megamark fold:** full NUM∑RA visible with a gap above the base; no clipping; balanced left-aligned hero.
- **Cards / pricing:** consistent spacing, borders, radii, shadow; 2-up/3-up collapse to 1 col on mobile; middle pricing card correctly accented.
- **Light/dark parity:** palette, accents (`--ok` green), and the seal-only terracotta render correctly in both; no off-palette colors; no theme flash on load.
- **Interactive states:** buttons get hover (lift) from numera.css + a focus outline; nav links get hover; the cards are non-interactive (no focus needed).
- **Alpine checks:** N/A - static page, no Alpine directives; only JS is the theme toggle.

## Pass 2 (2026-07-28, helium headless Chrome, live numera.velofy.co + local verify)

| # | screen | viewport / theme | what's wrong | fix applied |
|---|--------|------------------|--------------|-------------|
| 2 | pro (all sections) | 1024, 768, 390 · both themes | `.section` and `.lede` `padding: X 0 Y` shorthands (equal specificity, later in source) zeroed the horizontal gutter from `.wrap`, so below 1380px every section sat flush at the screen edge (left=0, text touching the right edge on phones). Same defect the landing page already had a media-query patch for. | Trailing rule `.wrap, .section, .lede{ padding-left/right:var(--gutter) }` restores the design-system gutter at all widths; desktop now matches the landing page's rhythm. |
| 3 | pro header | 768 (761-1099) · both themes | Full header (wordmark + 5 nav links + toggle + 2 CTA buttons) overflowed by 173px at 768: nav links wrapped ("How it works" on two lines), "Get Numera Pro" pushed off-screen. Fixed-position overflow is invisible to scrollWidth checks. | Hide `nav.primary` at `max-width:1099px` (was 760px) and add `white-space:nowrap` on nav links. Footer keeps all destinations reachable. |
| 4 | pro header | 390 · both themes | Wordmark + toggle + "Investor Access" + "Get Numera Pro" cannot fit a phone; the primary CTA was clipped at the right edge. | At `max-width:760px` hide `.header-cta .btn-secondary` (Investor Access). Phone header is now wordmark + toggle + one CTA, same as the landing page. Investor entry remains in the footer (Console) and the badge on wider screens. |
| 5 | pro pricing note | all | "Book a call" and "Numera Solo" links ran together with no separator: "...writing? Book a call Numera Solo is free..." | Added a period: "Book a call</a>. <a>Numera Solo</a> is free...". |

## Checked and clean (pass 2)
- **Landing page:** zero issues at 1440 / 768 / 390, light + dark. Gutters, hero fold, megamark, card rhythm, stacked pricing, centered mobile footer all hold.
- **Pro page after fixes:** zero horizontal overflow at 1440/1024/768/390 (scrollWidth and fixed-header rect checks); header clean at 1200/1100 (full nav) and 1099/1024/768/390 (compact); comparison table reflows at 390; footer link list and meta stack correctly.
- **Capture caveats discovered (not site bugs):** headless Chrome clamps window width to >=500 (use CDP `Emulation.setDeviceMetricsOverride` for true 390px), window height includes ~143px of chrome (measure `window.innerHeight`, do not trust set size), and giant single-canvas screenshots render blanks (scroll-stitch instead).
