# UI Self-Healing Loop

You are running a fully autonomous visual QA loop on an Alpine.js app. Goal: find UI gaps by actually looking at the rendered app in a browser, fix them, re-check, repeat until clean.

## Setup (do this once)
1. Confirm a browser tool is available (Playwright MCP). If not, run:
   `claude mcp add playwright npx @playwright/mcp@latest`
2. Read the routes/pages of the app and build a full list of screens. Write it to `.ui-audit/screens.json` as an array of `{name, url, viewport, status}`. Include at minimum desktop (1440x900) and mobile (390x844) per screen. `status` starts as `"pending"`.
3. If a design system doc exists (tokens, palette, type scale, spacing scale), read it and summarize the rules into `.ui-audit/design-rules.md`. If none exists, infer rules from the most polished existing screen and write them down, so checks stay consistent across iterations instead of drifting each run.

## Loop (one screen x viewport per pass, pick the next "pending" one)
1. Navigate to it, wait for Alpine to finish hydrating (`window.Alpine` present, no `[x-cloak]` visible), screenshot it.
2. Compare against `.ui-audit/design-rules.md` and these checks:
   - spacing/alignment: inconsistent gaps, misaligned grids, elements touching edges
   - typography: wrong font/weight, inconsistent sizes, bad line-height, orphaned text
   - color/contrast: off-palette colors, low contrast text, broken hover/focus/active states
   - responsiveness: overflow, squished elements, broken stacking at mobile width
   - interactive states: missing hover/focus-visible/loading/empty/error states
   - Alpine-specific: x-cloak flashes, x-show popping instead of transitioning, x-for lists missing `:key` causing flicker on reorder
3. Log every gap found to `.ui-audit/issues.md` (screen, viewport, what's wrong, fix applied). Don't skip anything you'd be embarrassed to ship.
4. Fix issues directly in source (HTML/Alpine directives/CSS/Tailwind classes). Keep diffs scoped to the screen at fault, don't refactor unrelated code.
5. Re-screenshot. If clean, set status to `"pass"` in `screens.json`. If not, repeat steps 2-4 on the same screen, max 4 attempts, then mark `"needs-human"` with the reason and move on.

## Stopping condition
Stop when every entry in `.ui-audit/screens.json` is `"pass"` or `"needs-human"`. Write `.ui-audit/REPORT.md`: screens fixed, total issues fixed, anything flagged `needs-human`, and any gaps you noticed in `design-rules.md` itself.

When fully done, print exactly: `UI_LOOP_DONE`
