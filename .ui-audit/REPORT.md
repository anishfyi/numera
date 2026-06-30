# UI self-healing loop - REPORT

**Target:** Numera landing page (`docs/index.html`), the only web UI in this repo.
**Run:** executed inline (Claude Code drove a real Chromium via Playwright and
screenshotted every screen x viewport x theme).

## Coverage
| screen | desktop 1440x900 | mobile 390x844 |
|--------|------------------|----------------|
| landing - light | pass | pass |
| landing - dark  | pass | pass |

All 4 entries in `screens.json` are **pass**. None flagged `needs-human`.

## Issues fixed (1)
1. **Full-agent feature list ran full-width (1380px) on desktop** - lines too long,
   loose, inconsistent with the capped prose. Capped `#full .feat` to `max-width:64ch`
   (now ~661px). See `issues.md`.

The page was already in good shape (it was hand-tuned earlier this session: hero
fold, megamark-to-base, mobile overflow fix, mobile header). This pass confirmed
those held and caught the one remaining readability gap.

## Verified clean
- **Zero horizontal overflow** at 1440 / 390 / 360 in both themes.
- Hero + megamark fold (full NUM∑RA visible with a gap above the base, no clip).
- Card/pricing rhythm; 2-up/3-up collapse to 1 col on mobile.
- Light/dark parity; seal-terracotta used only on the seal mark; no theme flash.
- Hover/focus states present (from numera.css); cards non-interactive.

## Gaps noticed in design-rules.md / the design system itself
- **Dark-theme `--text-3` is borderline for small text.** Eyebrows, fineprint, and
  card sub-text use `--text-3` (#767163), which computes ~3.6:1 against the dark
  surfaces - passes WCAG AA-large but is **below AA (4.5:1)** for normal-size text.
  This is a shared token in `numera.css` used across the whole product, so I did
  **not** override it per-page. Recommend lightening `--text-3` in the dark theme
  (e.g. toward #8a857a) at the design-system level. Flagged, not fixed.
- The static page has no Alpine; the loop's Alpine-specific checks (x-cloak/x-show/
  x-for) don't apply here. If a future screen is Alpine-driven, those re-activate.

## Process note
The provided `run-ui-loop.sh` driver was **not** runnable here: it invokes
`claude --dangerously-skip-permissions`, which the Claude Code safety classifier
hard-blocks (auto-mode bypass). The loop was executed inline instead (same outcome,
safer). `ui-fix-loop.md` and this `.ui-audit/` state are saved and resumable.
