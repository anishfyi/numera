# UI self-healing loop - REPORT (pass 2)

**Target:** the whole static site, `docs/index.html` + `docs/pro/index.html`
(live at numera.velofy.co and numera.velofy.co/pro).
**Run:** 2026-07-28, helium (Selenium) headless Chrome driven from Python,
scroll-stitched full-page captures at 1440 / 1024 / 768 / 390, light + dark,
24 captures. Fixes verified against a local copy served from `docs/`.

## Coverage
| screen | 1440 | 1024 | 768 | 390 |
|--------|------|------|-----|-----|
| landing - light | pass | pass | pass | pass |
| landing - dark  | pass | pass | pass | pass |
| pro - light | pass | pass | pass (fixed) | pass (fixed) |
| pro - dark  | pass | pass | pass (fixed) | pass (fixed) |

All 13 entries in `screens.json` are **pass**. None flagged `needs-human`.

## Issues fixed (4, all on the pro page)
1. **Zero content gutter below 1380px** - `.section`/`.lede` padding shorthands
   overrode the `.wrap` gutter; every section sat flush at the screen edge at
   1024/768/390. Restored `padding-left/right:var(--gutter)` via a trailing rule.
2. **Header overflow at 761-1099px** - 5 nav links + toggle + 2 CTAs did not fit;
   173px past the viewport at 768, links wrapping. Nav now hides at
   `max-width:1099px`, links are `nowrap`.
3. **Header clipped at phone width** - wordmark + toggle + 2 buttons exceeded
   390px and cut off the primary CTA. "Investor Access" hides at <=760px;
   still reachable from the footer Console link.
4. **Run-together links in the pricing note** - "Book a call Numera Solo is
   free..." now separated by a period.

## Verified clean
- Landing page: no changes needed at any width or theme; the pass-1 fixes hold.
- Pro page after fixes: zero horizontal overflow everywhere (checked both
  `scrollWidth` and fixed-element rects, since fixed overflow is invisible to
  the former), comparison table reflows, footer stacks correctly.

## Gaps noticed in design-rules.md / the design system itself
- The dark-theme `--text-3` contrast note from pass 1 still stands (flagged,
  not fixed, design-system level).
- New rule worth adding: **padding shorthands on `.wrap`ped sections must not
  re-zero the horizontal gutter** - both pages hit this independently. The
  pattern to enforce is `padding: X var(--gutter) Y` or a trailing gutter rule.
- New rule worth adding: **fixed headers need element-rect overflow checks**;
  `document.scrollWidth` cannot see them.

## Process note
Pass 1's caveats about giant-canvas captures producing blanks were confirmed
and worked around with scroll-stitching. Two more headless traps documented in
`issues.md` (500px minimum window width, ~143px chrome in window height).
The loop remains resumable from `.ui-audit/`.
