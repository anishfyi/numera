# Numera design rules (inferred from numera.css tokens + the page)

The site reuses the NumeraAI design system (`docs/numera.css`). These are the rules
UI checks are held to, so passes stay consistent across iterations.

## Type
- **Display / headings / wordmark:** Archivo (`--f-display`), heavy weights, tight
  tracking (-.02 to -.035em).
- **Body / prose:** Instrument Sans (`--f-body`), line-height ~1.6.
- **Labels / eyebrows / data / code:** Spline Sans Mono (`--f-data`).
- **Eyebrows:** mono, UPPERCASE, letter-spacing ~.2em, color `--text-3`.
- Hero headline currently clamp(24,3.2vw,40); section headings clamp(27,3.6vw,44).
  No orphaned single words on their own line where avoidable.

## Color (token-driven; never hardcode hex in markup)
- Light: bg `#F6F4EE`, raised `#FDFCFA`, inset `#EDEAE2`; text `#181712`,
  text-2 `#56524A`, text-3 `#837E72`; lines rgba(24,23,19,.16/.08).
- Dark (`[data-theme=dark]`): bg `#0F0E0C`, text `#ECEAE3`, text-2 `#A9A599`.
- Accent green `--ok` (#2A701B light / #8FD460 dark) for confirmations/checks.
- **Seal terracotta `--seal` is used ONLY on the cryptographic seal mark.** Nowhere else.
- Body text must clear WCAG AA on its surface (text-2 on bg is the floor).

## Spacing & shape
- Spacing scale only: --s1 4 / s2 8 / s3 12 / s4 16 / s5 24 / s6 32 / s7 48 / s8 64 / s9 96.
- Page gutter: `--gutter` clamp(20,4vw,56). Content max-width 1380 (`.wrap`), centered.
- Radii: s 7 / m 11 / l 16 / full 999.
- No element should touch the viewport edge except intentional full-bleed bands
  (the megamark). Cards sit on `--bg-raised` with `--line-2` borders + shadow-1.

## Elevation & state
- Light theme uses shadows (`--shadow-1/2/3`); dark uses borders.
- Interactive cards/buttons lift on hover: `translateY(-2px)` + `--shadow-2`.
- **focus-visible must mirror hover** (keyboard == mouse affordance), never a bare outline only.
- Buttons: `.btn-primary` (inverse block), `.btn-secondary` (outline), `.btn-ghost`.

## Layout / responsive
- Two-col grids (`.cards2`, `.prices`, `.hero-grid`) collapse to 1 col on small screens.
- Grid/flex children that hold wide content (code blocks) must set `min-width:0`
  so the page never gains horizontal scroll. **Zero horizontal overflow at any width.**
- Hero + megamark fill the first screen on desktop; the full NUM∑RA wordmark must
  be visible with a small gap above the base, never clipped.
- Header on mobile: wordmark + theme toggle + Get started (inline nav hidden, no hamburger here).

## Not applicable
- This is a static page (no Alpine.js): x-cloak / x-show / x-for checks are N/A.
  The only JS is the theme toggle; verify no flash-of-wrong-theme on load.
