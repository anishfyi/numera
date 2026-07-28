# The period close and roll-forward

How the ledger turns over from one period to the next: the close sequence, closing
the P&L to retained earnings, and what carries forward. Cross-cutting domain
knowledge.

## The close sequence
A close runs in a dependable order, each step feeding the next: post the subledgers
(AP, AR, payroll), book the period-end adjustments (accruals, prepayment and
deferred-revenue releases, depreciation from the asset register, FX revaluation),
reconcile the bank and the control accounts, clear the uncategorised/suspense pile,
tie out material balance-sheet variances with an explanation each, prepare the tax
/ VAT return, then sign off and lock the period. Adjustments before reconciliations
before tie-out before sign-off - running them out of order means re-doing work when
a late entry moves a reconciled figure.

## Closing the P&L to retained earnings
At year end (and conceptually at each period boundary) the profit-and-loss accounts
are temporary: they measure ONE period and must start the next at zero. The closing
entry sweeps them to equity - debit every income account to nil, credit every
expense and COGS account to nil, and carry the net (income - expenses) to retained
earnings: a net profit credits retained earnings, a net loss debits it. The entry
balances by construction because total income = total expense + net. Only P&L
accounts are closed; balance-sheet accounts are permanent and are never zeroed.

## Opening balances carry forward
After the close, the balance sheet IS the opening position of the next period:
cash, receivables, payables, fixed assets at NBV, and the accumulated retained
earnings all carry forward unchanged as opening balances, while the P&L reopens at
zero. Retained earnings accumulates across periods - this year's net profit adds to
the prior balance; it is not a fresh figure each year. Comparatives (prior-period
columns) come from these carried-forward balances, which is why two consecutive
closes must tie: the closing position of period N is the opening position of N+1.

## Common mistakes
- **Posting into a closed or signed-off period** - it changes numbers already
  reported/filed; post a dated adjustment in the current open period instead, or
  formally reopen with sign-off.
- **Zeroing balance-sheet accounts at close** - only the P&L is temporary; cash and
  retained earnings persist.
- **Forgetting to accumulate retained earnings** - each year's profit ADDS to the
  prior retained-earnings balance, it does not replace it.
- **Closing before the adjustments and reconciliations are done** - a late accrual
  or unreconciled item lands after the sweep and the comparatives no longer tie.
- **A suspense/uncategorised balance left non-zero at close** - it must be cleared
  or explained before sign-off, never carried as a silent plug.
