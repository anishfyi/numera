# Accounting from a phone

Claude Code runs in the terminal, in a desktop app, and as a web app at
claude.ai/code. The web app works from a phone browser, which means a Numera
Solo session can be driven from a phone: the agent and the ledger stay where the
session runs, and the phone is only the control surface.

This file is about what changes when the approver is on a small screen. The
short version: the propose-then-write rule gets **stricter**, not looser.

## What actually moves

Nothing about the ledger changes. The CSV lives where the session runs. The
phone sends instructions and receives proposals. If the session ends, the
ledger is exactly where it was, because every accepted entry was appended at
the time it was approved rather than buffered.

## The small-screen problem

A journal entry approved on a phone is approved by someone who can see about
four lines at once. That is a real control weakness, and it is the reason
finance teams historically required a desk. Compensate:

**1. One entry per proposal.** Never batch several entries into a single yes on
mobile. On a desktop a five-entry batch is reviewable. On a phone it is a
rubber stamp.

**2. Lead with what changes.** Put the account names and the amounts first, and
the memo last. The approver should be able to reject from the first line
without scrolling.

**3. State the running effect.** After the table, one line: which balances move
and to what. "Bank 42,180 to 40,980, Rent expense 0 to 1,200." That single line
is what makes a phone approval safe, because it is checkable at a glance.

**4. Refuse ambiguity harder.** On desktop, asking a clarifying question costs a
few seconds. On mobile the temptation is to guess to save the user typing. Do
not. An unclear coding decision waits.

**5. Never propose a period-affecting change on mobile without saying so.**
Anything touching a closed or closing period, a reversal, or a prior year gets
an explicit warning line before the table, so the approver knows this is not a
routine posting.

## What to refuse on mobile

Decline these and offer to queue them for a desktop session:

- Bulk recategorisation across many transactions.
- Anything that rewrites or reverses history in bulk.
- First-time setup of a chart of accounts.
- Any write against a live remote ledger through Numera Pro, unless the user
  explicitly confirms they understand they are approving a real posting.

Say which ones you are deferring and why. "Queued for desktop: 43 transactions
to recategorise" is a useful answer. Silently doing it is not.

## A good mobile exchange

> **User:** paid the office rent, 1200, from the current account
>
> **Numera:**
> ```
> 2026-07-26   Rent expense    Dr 1,200.00
> 2026-07-26   Bank                Cr 1,200.00
> ```
> Bank 42,180.00 to 40,980.00. Rent expense 0.00 to 1,200.00.
> Memo: Office rent, July. Post it?
>
> **User:** yes
>
> **Numera:** Posted as txn 118. Bank is now 40,980.00.

Two lines, the balance effect, one question. That is the whole shape.

## What this does not make safe

Being able to approve from a phone does not make it wise to approve a month-end
close from one. Solo should say so when it sees a close being attempted on
mobile: the close is a review process, and review needs a screen where the
trial balance fits.
