<div align="center">
  <img src="docs/assets/numera-mark.svg" alt="Numera" width="86">

  <h1>Numera Solo</h1>

  <p><strong>An open-source accounting AI you run on your own machine with the Claude Code CLI.</strong></p>

  <p>
    <a href="https://numera.velofy.co"><strong>numera.velofy.co</strong></a>
    ·
    <a href="#install-about-2-minutes">Install</a>
    ·
    <a href="skill/numera-solo/SKILL.md">The skill</a>
    ·
    <a href="skill/numera-solo/DOC-MAP.md">Doc map</a>
    ·
    <a href="https://numera.velofy.co#pricing">Numera Pro</a>
  </p>

  <p>
    <a href="LICENSE"><img alt="MIT" src="https://img.shields.io/badge/license-MIT-0F0E0C.svg"></a>
    <img alt="local first" src="https://img.shields.io/badge/data-never%20leaves%20your%20machine-2A701B.svg">
    <img alt="no server" src="https://img.shields.io/badge/server-none-0F0E0C.svg">
  </p>
</div>

---

Numera Solo is a careful, local-first bookkeeper. It keeps one plain-text ledger
on your machine, reasons in real double-entry, and never writes to your books
without showing you the entry and getting a yes. No cloud, no account, no data
leaving your laptop. Free forever.

> **Solo does the everyday bookkeeping on a local file. [Numera Pro](https://numera.velofy.co#pricing)
> does the close on your real ledgers.** See the difference at
> [numera.velofy.co](https://numera.velofy.co).

## The one rule

Money is not a place to be clever. Every change to the ledger is **proposed
first**, as a balanced entry you can read, and written only after you say yes.

```
> record: paid 1,200 rent from the current account

  2026-07-26   Rent expense    Dr 1,200.00
  2026-07-26   Bank                Cr 1,200.00

  Bank 42,180.00 to 40,980.00. Rent expense 0.00 to 1,200.00.
  Post it?

> yes

  Posted as txn 118. Bank is now 40,980.00.
```

Corrections are new reversing entries that cite the original, never edits to past
rows. That is how real books stay auditable.

## What it does

| | |
| --- | --- |
| **Record** | Double-entry journal entries from plain English |
| **Categorize** | Bank transactions to the right accounts, learning your coding as it goes |
| **Reconcile** | A bank statement CSV against the ledger, surfacing the exact gap |
| **Report** | P&L and balance sheet, every total tied back to its rows |
| **Remember** | Your chart of accounts and vendor rules, across sessions |
| **Work anywhere** | Any accounting platform, by reading that vendor's own docs first |

## Any accounting platform, not just the two it ships

The bundled trove carries working knowledge of QuickBooks Online and Sage
Intacct. When your books live somewhere else, Solo follows
[`PLATFORM-PLAYBOOK.md`](skill/numera-solo/PLATFORM-PLAYBOOK.md): identify the
exact product and edition, find the vendor's own developer reference, and build
the model in a fixed order (auth and limits, entities, queries, writes and sharp
edges, then how it all maps back to double entry). What it learns gets written
into `platforms/` so the next session starts from knowledge.

[`DOC-MAP.md`](skill/numera-solo/DOC-MAP.md) routes a task and a platform
straight to the right documents, internal entry first, then the vendor reference.

Two rules from the playbook are worth repeating, because they are the ones that
destroy data:

- **Assume an update is a full replace** until the docs prove otherwise. Many
  accounting APIs silently wipe every field you omit.
- **Never invent an identifier.** Account codes, tax codes and entity ids come
  from a read against the live system, never from a plausible guess.

## Install (about 2 minutes)

1. **Install the Claude Code CLI** if you have not already:
   https://docs.claude.com/claude-code, then run `claude` once to sign in.

2. **Get the skill into Claude Code:**

   ```bash
   git clone https://github.com/anishfyi/numera.git
   mkdir -p ~/.claude/skills
   cp -r numera/skill/numera-solo ~/.claude/skills/
   ```

3. **Optional but recommended:** add the [trove](https://github.com/anishfyi/trove)
   plugin so it keeps your chart of accounts and coding rules between sessions.

4. **Run it in your books folder:**

   ```bash
   cp numera/examples/ledger.csv ./        # or start your own
   claude
   ```

   Then talk to it:

   ```
   > record: paid 90 to Vercel from the bank for hosting
   > reconcile ledger.csv against this statement: bank-may.csv
   > show me the P&L for May
   ```

## From your phone

Claude Code has a web app, so a Solo session can be driven from a phone with the
ledger staying wherever the session runs. Read
[`REMOTE.md`](skill/numera-solo/REMOTE.md) first. The short version: on a small
screen the propose-then-write rule gets **stricter**, not looser. One entry per
proposal, accounts and amounts first, the resulting balances stated in a single
line, and bulk recategorisation or a month-end close deferred to a desktop rather
than collected as a rubber-stamp yes on a four-line screen.

## How it works

Numera Solo is a [Claude Code skill](https://docs.claude.com/claude-code): a
folder of instructions plus a bundled knowledge trove, at `skill/numera-solo/`.

```
skill/numera-solo/
  SKILL.md               the bookkeeper's instructions
  DOC-MAP.md             task + platform -> the exact docs to read
  PLATFORM-PLAYBOOK.md   how to work against any accounting platform
  REMOTE.md              running from a phone
  platforms/             per-platform notes, built from vendor docs
  trove/                 accounting knowledge, one file per topic
```

The trove covers accounting fundamentals, the financial statements, the
month-end close, US taxation, sales tax and VAT, plus QuickBooks Online and Sage
Intacct. Solo reads the relevant entry before reasoning about a topic rather than
working from memory.

There is no server and no database. Your ledger is a CSV you own.

## Honest limits

Solo is a bookkeeper's assistant, not a filing service and not a licensed
accountant. It does not file taxes, it does not hold credentials for your cloud
ledger, and it does not replace professional sign-off.

For the full month-end close, live write-back with per-platform failure handling,
and a tamper-evident audit chain over every write, that is
[Numera Pro](https://numera.velofy.co#pricing).

## License

MIT, see [LICENSE](LICENSE). Use it, fork it, ship it.

<div align="center">
  <br>
  <a href="https://numera.velofy.co"><strong>numera.velofy.co</strong></a>
</div>
