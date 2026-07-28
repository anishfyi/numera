# Setup: from tagged to closing books

What happens the first time someone brings you real books. Four steps, and none
of them should take a question the user has already answered.

## 1. Bring the toolchain up

```bash
./scripts/setup.sh
```

Creates `~/.numera/`, builds an isolated virtualenv there, and installs:

| Tool | Package | What it buys |
| --- | --- | --- |
| curl_reap | `curl-reap` | fetches vendor API docs that block ordinary HTTP clients |
| terbium | `terbium-parse` | parses statements and invoices out of PDF, XLSX, CSV |
| trove | (git clone) | remembers the chart of accounts and coding rules between sessions |

Two things worth knowing about that script rather than rediscovering them:

- **It uses a venv on purpose.** Homebrew and most distro Pythons are marked
  externally managed (PEP 668), so a plain `pip install` is refused. The common
  workaround, `--break-system-packages`, can genuinely break a Homebrew install.
  Everything lives under `~/.numera/venv` and touches nothing else.
- **The package names are not the import names.** `terbium-parse` imports as
  `terbium`. Installing `terbium` gets you a different, unrelated project.

It installs without prompting, but prints what it is installing and why. If
something fails it says so and keeps going: Numera degrades, it does not stop.

## 2. Find out where the books are

Ask, in one short list rather than one question at a time, and skip anything a
`NUMERA.md` or a trove memory already answers:

1. Whose books, and what period?
2. Where do they live: a local CSV ledger, or a platform?
3. If a platform, **which product and which edition?** "QuickBooks" is not an
   answer. Online and Desktop share a name and almost nothing else. "Sage" is
   five different products.
4. One currency or several?

## 3. Pull that platform's own documentation

```bash
./scripts/fetch-docs.sh xero
./scripts/fetch-docs.sh --list      # what has known sources
```

Cached to `~/.numera/docs/<platform>/`, never committed. That directory belongs
to the user, and this repo redistributes nothing a vendor owns.

**Three kinds of source, because they are genuinely different:**

- **`spec`** A static OpenAPI file, fetched verbatim. By far the best input:
  machine-readable, complete, versioned by the vendor. Xero publishes one and it
  is ~900KB of exact request and response contracts. Read this over any prose.
- **`md`** A server-rendered doc page converted to markdown. Microsoft Learn
  works this way.
- **`browser`** A client-rendered page that **cannot be scraped**. Intuit's and
  Xero's developer portals are Gatsby apps: the HTML is over a megabyte of
  JavaScript shell and the prose is not in it. The script says so and prints the
  URL rather than caching an empty file. Open it yourself and paste what matters.

If a fetch returns under 400 bytes it is treated as a failure, because an empty
SPA shell is not a document. Never report a doc as fetched on file existence
alone.

## 4. Read before you write

Order matters:

1. `platforms/<name>.md` in this repo, for the shape and the known traps.
2. The cached vendor source, for the current contract. **The vendor wins.**
3. `PLATFORM-PLAYBOOK.md` if the platform has no file yet.

Then tell the user which documents you are working from, before you act rather
than after. If the platform has no notes here, write them into `platforms/`
using `platforms/_template.md` as you learn, so the next session starts from knowledge.

## When a platform has no known doc source

Do not guess and do not scrape blindly. Follow `PLATFORM-PLAYBOOK.md`, find the
vendor's own reference, and add the URL to `SOURCES` in `scripts/fetch-docs.sh`
with the right mode. That way the search happens once, ever.
