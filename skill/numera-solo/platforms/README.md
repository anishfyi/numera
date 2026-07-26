# Platform notes

One file per accounting platform, each following `_template.md`.

These are **working notes built from public vendor documentation**, written so a
later session starts from knowledge rather than a search. They are not a
substitute for the vendor's own reference, and they carry a status line saying
what was verified and when.

## How a file gets here

Follow `../PLATFORM-PLAYBOOK.md`. Copy `_template.md`, fill the five sections in
order (auth and limits, entities, queries, writes and sharp edges, double-entry
reconciliation), and mark anything the docs did not answer as UNKNOWN rather
than filling it with something plausible.

## Scope

Numera Solo prepares entries and import files against these platforms. It does
not authenticate to them and does not post. A file here describes how a platform
works; it does not give Solo a write path.

Deep integration, live write-back, per-platform failure handling and a
tamper-evident audit chain across those writes are Numera Pro (https://numera.velofy.co).

## Two things that generalise

Written here because they cause the most damage and apply almost everywhere:

1. **Update usually means full replace.** Many accounting APIs overwrite the
   stored record with exactly what you send, clearing every field you omitted.
   Round-trip the whole object, or use the platform's explicit partial-update
   mechanism after confirming it exists.
2. **Refresh tokens often rotate on every use.** Two concurrent refreshes race
   and orphan the grant, which presents later as a mysterious auth failure.
   Serialise refresh.

## Current files

Nothing yet beyond the template. The first real platform file should be written
the next time a user brings books on a platform the trove does not already
cover.

For QuickBooks Online and Sage Intacct, richer notes already exist in
`../trove/entries/`.
