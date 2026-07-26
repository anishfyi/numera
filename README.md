# Numera Solo

**A small, open-source accounting AI you run locally with the Claude Code CLI.**

Numera Solo is a careful, local-first bookkeeper. It keeps one plain-text ledger
on your machine, reasons in real double-entry, and never writes to your books
without showing you the entry and getting a yes. No cloud, no account, no data
leaving your laptop. Free forever.

It is the open-source little sibling of [NumeraAI](https://anishfyi.github.io/numera)
- the full AI accountant that does the whole month-end close and writes back to
QuickBooks, Xero, Sage and NetSuite with a tamper-evident audit chain.

> **Solo does the everyday bookkeeping on a local file. The full NumeraAI does the
> close on your real ledgers.** See the difference: https://anishfyi.github.io/numera

## What it does

- **Record** double-entry journal entries from plain English ("paid 1,200 rent").
- **Categorize** bank transactions to the right accounts, and learn your coding.
- **Reconcile** a bank statement CSV against the ledger and surface the exact gap.
- **Report** a simple P&L and balance sheet, with every total tied back to the rows.
- **Remember** your chart of accounts and vendor coding rules across sessions.

Every change is **proposed first** - shown as a balanced entry - and only written
to the ledger after you say yes.

## Install (about 2 minutes)

1. **Install the Claude Code CLI** (if you have not already):
   https://docs.claude.com/claude-code - then run `claude` once to sign in.

2. **Get the skill into Claude Code.** Clone this repo and copy the skill into your
   Claude skills folder:

   ```bash
   git clone https://github.com/anishfyi/numera.git
   mkdir -p ~/.claude/skills
   cp -r numera/skill/numera-solo ~/.claude/skills/
   ```

3. **(Recommended) Add the trove layer for memory** so it keeps your chart of
   accounts and coding rules between sessions:
   https://github.com/anishfyi/trove

4. **Run it in your books folder:**

   ```bash
   cp numera/examples/ledger.csv ./        # or start your own
   claude
   ```

   Then just talk to it:

   ```
   > record: paid 90 to Vercel from the bank for hosting
   > reconcile ledger.csv against this statement: bank-may.csv
   > show me the P&L for May
   ```

   It will propose each entry, wait for your yes, then append it to `ledger.csv`.

## How it works

Numera Solo is a [Claude Code skill](https://docs.claude.com/claude-code) -
a folder of instructions plus a bundled knowledge **trove** (`skill/numera-solo/`).
Claude Code loads it when you ask for bookkeeping and acts as your bookkeeper
against a local `ledger.csv`.

The skill ships a knowledge trove at `skill/numera-solo/trove/` (built in the
[trove](https://github.com/anishfyi/trove) format: an `INDEX.md` plus one markdown
file per topic in `entries/`) covering accounting fundamentals, the financial
statements, the month-end close, US taxation, sales tax / VAT, and two accounting
platforms - **QuickBooks Online** and **Sage Intacct**. Solo reads the relevant
entry before reasoning about a topic. Separately, the optional **trove plugin**
gives it durable memory of *your* chart of accounts and vendor coding rules across
sessions.

There is no server and no database. Your ledger is a CSV you own.

## Honest limits

Solo is a bookkeeper's assistant, not a filing service or a licensed accountant.
It does not file taxes, does not write to live accounting platforms, and does not
replace professional sign-off. For the full close, multi-platform write-back, and
an audit-sealed trust layer, that is the paid
[NumeraAI](https://anishfyi.github.io/numera).

## License

MIT - see [LICENSE](LICENSE). Use it, fork it, ship it.
