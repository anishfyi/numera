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
