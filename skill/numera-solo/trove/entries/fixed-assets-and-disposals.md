# Fixed assets, depreciation and disposals

How to reason about capital assets across any ledger: the register IS the
sub-ledger, depreciation runs from it, and disposal derecognizes the asset with a
gain or loss. Cross-cutting domain knowledge; the platform-specific tags live in
each system's docs.

## The asset register is the sub-ledger; depreciation runs from it
A fixed-asset register holds each asset's cost, accumulated depreciation and net
book value (NBV = cost - accumulated depreciation), and rolls those forward period
by period. Depreciation should ORIGINATE from the register, not be keyed as a
standalone journal: the register knows each asset's cost, in-service date, method,
useful life and remaining NBV, so it can compute the period charge and stop at the
right time. A flat recurring "depreciation" journal that is not driven by an asset
sub-ledger drifts from the real carrying value and keeps charging after an asset is
fully depreciated or disposed. The monthly entry is DR depreciation expense, CR
accumulated depreciation (a contra-asset) - never credit the asset cost account
directly; cost stays at historical cost until disposal.

## Straight-line vs reducing-balance
Straight-line spreads (cost - residual) evenly over the useful life: charge =
(cost - residual) / periods, the same every period. Reducing (declining) balance
takes a fixed rate of the CARRYING amount each period, so the charge falls over
time: charge = NBV-at-start-of-period * rate; it never naturally reaches zero, so a
fixed-term schedule writes off the remaining NBV in the final period (or switches
to straight-line for the tail). Either way the schedule must amortize to exactly
the depreciable base - the last period absorbs the rounding so the asset lands at
its residual (often nil), not a few pence off. Match the method to how the asset
delivers value; do not silently switch methods mid-life.

## Disposal: derecognize cost and accumulated depreciation, book the gain or loss
When an asset is sold or scrapped, remove BOTH its cost and its accumulated
depreciation from the books, take the proceeds to cash/receivable, and book the
balancing figure as a gain or loss on disposal. The gain/(loss) = proceeds - NBV
(where NBV = cost - accumulated depreciation at the disposal date). Lines: CR asset
cost (full original cost), DR accumulated depreciation (the full accumulated to
date), DR cash/receivable (proceeds), and the balancing DR loss / CR gain to a
disposal account in the P&L. The entry balances by construction: (accumulated +
proceeds) - cost = the gain (positive) or loss (negative). A part-exchange follows
the same shape with the trade-in allowance standing in for cash.

## Common mistakes
- **Crediting the asset cost account for depreciation** instead of accumulated
  depreciation - this loses the historical cost and breaks the register.
- **Depreciating past full depreciation or after disposal** - stop at residual; a
  disposed asset takes no further depreciation.
- **Forgetting to remove accumulated depreciation on disposal** - leaving it behind
  overstates assets and misstates the gain/loss.
- **Booking the gain/loss to revenue or a cost line** instead of a disposal account
  - it is a separate P&L item, not turnover.
- **Revaluing or impairing by editing cost** - impairment is its own entry (DR
  impairment loss, CR accumulated depreciation/impairment), not a cost rewrite.
