# Accounting basics (the part Lite must never get wrong)

## The accounting equation
**Assets = Liabilities + Equity.** It always balances. Income and expenses flow
into equity (via retained earnings), so an expanded view is:

Assets = Liabilities + Equity + (Income - Expenses)

## Double-entry
Every transaction touches at least two accounts, and total debits == total credits.

| Account type | Increases with | Decreases with |
|--------------|----------------|----------------|
| Asset (Bank, AR, Equipment) | Debit | Credit |
| Expense (Rent, Software, Travel) | Debit | Credit |
| Liability (AP, Loans, Tax payable) | Credit | Debit |
| Equity (Capital, Retained earnings) | Credit | Debit |
| Income (Sales, Interest) | Credit | Debit |

Mnemonic: **DEAD CLIC** - Debits increase Expenses, Assets, Dividends; Credits
increase Liabilities, Income, Capital.

## Worked examples
- **Paid 1,200 rent from the bank:** Debit Rent expense 1,200 / Credit Bank 1,200.
- **Invoiced a customer 5,000 (not yet paid):** Debit Accounts receivable 5,000 /
  Credit Sales 5,000.
- **Customer pays the 5,000:** Debit Bank 5,000 / Credit Accounts receivable 5,000.
- **Bought a 900 laptop on the company card:** Debit Equipment 900 / Credit
  Accounts payable 900 (or Credit Bank 900 if paid from the bank).
- **Bank charged a 15 fee:** Debit Bank charges 15 / Credit Bank 15.

## Cash vs accrual
- **Cash basis:** record when money moves. Simplest for tiny businesses.
- **Accrual basis:** record when earned/incurred (revenue when invoiced, expense
  when the bill arrives), regardless of payment. Required once a business is past a
  certain size and the only basis that shows a true P&L. Ask the user which they use
  and stay consistent.

## Corrections
Never edit a posted row. To fix a mistake, post a **reversing entry** (swap the
debits and credits of the original) with a memo citing the original `txn`, then post
the correct entry. The trail stays intact.

## A simple month-end (what Lite can help with)
1. Code every bank line to an account.
2. Reconcile the ledger's Bank balance to the bank statement; book fees/interest.
3. Post any obvious accruals the user names (e.g. an unpaid bill for the month).
4. Produce the P&L and balance sheet and sanity-check that the balance sheet balances.

The full NumeraAI automates this end to end against live ledgers; Lite walks it with you.
