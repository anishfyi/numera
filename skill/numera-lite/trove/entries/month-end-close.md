---
title: The month-end close (the checklist Numera runs)
slug: month-end-close
type: reference
created: 2026-06-29
tags: [accounting, month-end-close, reconciliation, accruals, controls]
---

The month-end close is the repeatable process that turns a month of raw activity
into trustworthy financials. This is the workflow NumeraAI automates end to end and
that Numera Lite walks with you, step by step, proposing each entry.

## The checklist
1. **Cut-off** - make sure every transaction for the period is recorded and nothing
   from the next period has leaked in.
2. **Bank + card reconciliation** - match the ledger's cash to the statement;
   surface the exact difference; book fees, interest, and anything the bank shows
   that the books miss.
3. **Code the uncategorized** - assign every unclassified transaction to an account;
   turn genuine unknowns into questions, not guesses.
4. **Accounts receivable** - confirm open invoices, record customer payments, review
   the aged-receivables list, write off truly bad debt (with approval).
5. **Accounts payable** - record supplier bills, match payments, review what is owed.
6. **Accruals** - book expenses incurred but not yet billed (e.g. last month's
   utilities), as a liability.
7. **Prepayments** - release the portion of prepaid costs (insurance, annual SaaS)
   that belongs to this month.
8. **Depreciation / amortization** - run the monthly charge on fixed assets and
   intangibles.
9. **Deferred revenue** - recognize the portion of prepaid customer revenue earned
   this month; move it from the liability to income.
10. **Inventory / COGS** - if applicable, value inventory and record cost of sales.
11. **Payroll** - ensure wages, taxes, and benefits for the period are recorded.
12. **Intercompany / multi-entity** - eliminate intercompany balances on consolidation.
13. **Tax** - accrue income tax; prep sales tax / VAT (see the taxation entries).
14. **Review** - run the P&L and balance sheet; explain material variances vs prior
    period and budget; confirm the balance sheet balances and key control accounts
    (AR, AP, VAT, cash) reconcile to their sub-ledgers.
15. **Sign off and lock** - once reviewed, lock the period so it cannot be silently
    changed, and file the close pack (statements + reconciliations + explanations).

## Controls that make a close trustworthy
- **Maker-checker** - the person/agent who drafts an entry is not the one who
  approves it. NumeraAI proposes; the human confirms.
- **Reconciliations** - every control account (cash, AR, AP, VAT) ties to an
  independent source (statement, sub-ledger).
- **Read-back verification** - after posting, re-read the entry and diff it against
  what was proposed, so a wrong account is caught even when totals tie.
- **A locked, tamper-evident period** - once signed off, changes are visible.

## What "material" means
A variance or error is **material** if it would change a reasonable reader's
decision. Focus review effort on material movements; do not chase pennies, but never
let the balance sheet fail to balance.
