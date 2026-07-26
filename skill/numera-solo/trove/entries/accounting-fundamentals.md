---
title: Accounting fundamentals (double-entry, the GL, accrual vs cash)
slug: accounting-fundamentals
type: reference
created: 2026-06-29
tags: [accounting, double-entry, debits-credits, general-ledger, chart-of-accounts]
---

The non-negotiable core. Get this right and the rest follows.

## The accounting equation
**Assets = Liabilities + Equity.** It always balances. Income and expenses flow
into equity through retained earnings, so the working form is:

`Assets = Liabilities + Equity + (Income - Expenses)`

## Double-entry
Every transaction touches at least two accounts, and **total debits == total
credits**. A journal entry that does not balance is not a journal entry; fix it.

| Account type | Increases with | Decreases with | Normal balance |
|---|---|---|---|
| Asset (Bank, AR, Equipment) | Debit | Credit | Debit |
| Expense (Rent, Software, Travel) | Debit | Credit | Debit |
| Liability (AP, Loans, Tax payable) | Credit | Debit | Credit |
| Equity (Capital, Retained earnings) | Credit | Debit | Credit |
| Income / Revenue (Sales, Interest) | Credit | Debit | Credit |

Mnemonic **DEAD CLIC**: Debits increase Expenses, Assets, Dividends; Credits
increase Liabilities, Income, Capital.

## Worked entries
- Paid 1,200 rent from the bank -> Dr Rent expense 1,200 / Cr Bank 1,200
- Invoiced a customer 5,000 (unpaid) -> Dr Accounts receivable 5,000 / Cr Sales 5,000
- Customer pays the 5,000 -> Dr Bank 5,000 / Cr Accounts receivable 5,000
- Bought a 900 laptop on the card -> Dr Equipment 900 / Cr Accounts payable 900
- Bank fee 15 -> Dr Bank charges 15 / Cr Bank 15
- Recorded 300 monthly depreciation -> Dr Depreciation expense 300 / Cr Accumulated depreciation 300

## The books, layer by layer
1. **Source document** (invoice, receipt, bank line) ->
2. **Journal entry** (the balanced debit/credit) ->
3. **General ledger (GL)** (all entries, grouped by account) ->
4. **Trial balance** (every account's balance; total debits must equal total credits) ->
5. **Financial statements** (see the financial-statements entry).

The **general ledger** is the system of record. A **sub-ledger** (AR, AP, fixed
assets) holds the detail behind a single GL control account (e.g. the AR
sub-ledger lists each customer invoice; the AR control account in the GL is their sum).

## Accrual vs cash
- **Cash basis:** record when money moves. Simple; fine for very small businesses.
- **Accrual basis:** record when **earned/incurred** (revenue when invoiced,
  expense when the bill arrives), regardless of payment. Required past a certain
  size, and the only basis that shows a true P&L. The matching principle: recognize
  expenses in the period they helped earn the revenue.

Key accrual constructs:
- **Accounts receivable / payable** - earned/owed but not yet paid.
- **Deferred (unearned) revenue** - cash received before earning it -> a *liability*.
- **Accrued expense** - incurred before billing -> a *liability*.
- **Prepaid expense** - paid in advance for future benefit -> an *asset*, released over time.

## Chart of accounts (COA)
The list of accounts the books use, grouped Asset / Liability / Equity / Income /
Expense, often numbered (1000s assets, 2000s liabilities, 3000s equity, 4000s
income, 5000s+ expenses). Keep it stable month to month; add accounts deliberately.
A small service/SaaS starting chart: Bank, Accounts receivable, Prepayments,
Equipment, Accumulated depreciation, VAT/sales-tax control; Accounts payable,
Credit card, Accruals, Loans; Owner capital, Retained earnings; Sales, Interest
income; COGS, Rent, Hosting + software, Marketing, Travel, Payroll, Bank charges,
Professional fees, Depreciation.

## Corrections stay auditable
Never edit a posted entry. To fix a mistake, post a **reversing entry** (swap the
original debits and credits) citing the original, then post the correct entry. The
trail stays intact. This is the discipline NumeraAI (and Solo) enforces on every write.
