# Accruals, prepayments and depreciation · Period-end adjusting entries

Adjusting entries align the ledger to the accrual basis at period close: recognise economic events in the period they occur, not when cash moves. Every adjusting entry touches exactly one P&L account and one balance-sheet account, and never touches cash. Post-dated to the last day of the period being closed.

## Accrual basis vs cash basis
Accrual basis: recognise revenue when earned and expense when incurred, regardless of cash timing. This is what GAAP/IFRS require; most ledgers keep the GL on accrual, but many (e.g. QBO, Xero) can also REPORT on a cash basis - confirm the entity's basis before posting accruals. Cash basis: recognise only when cash is received/paid; used by some small entities and some tax filings (e.g. UK cash-basis traders, US cash-basis under the gross-receipts threshold). The whole point of adjusting entries (accruals, prepayments, deferrals, depreciation) is to convert raw cash/invoice activity into accrual-basis numbers at period end. If the books are kept on cash basis, you do NOT post accruals/prepayments - flag any request to do so as a basis mismatch.

## Accrued expense (expense incurred, not yet invoiced)
Cost relates to this period but no supplier invoice received yet (e.g. December electricity, unbilled professional fees, wages for days worked before payday). Recognise it now.
- Period end: DR Expense (P&L) / CR Accruals (current liability).
- Worked: £2,400/yr audit fee, 3 months fall in this period before the invoice arrives → accrue £600. DR Audit fees 600 / CR Accruals 600.
The accrual is an estimate; book your best estimate net of recoverable VAT (no VAT on an accrual - VAT is only recognised on a valid tax invoice). When the actual invoice lands, the difference between estimate and actual hits the P&L in the later period.

## Reversing the accrual next period
Accruals are typically reversed on day 1 of the next period so the incoming real invoice posts cleanly to the expense account without double-counting.
- Reversal (next period, day 1): DR Accruals / CR Expense (the mirror of the original).
- Then the actual invoice posts normally: DR Expense / CR Trade payables (+ VAT).
- Net effect: the reversal credit and the invoice debit offset in the new period; only any estimate variance remains in the expense account. Worked: accrued £600; actual invoice £640 net. Reversal credits expense £600, invoice debits expense £640 → £40 net expense in the new period (the under-accrual). This is the cleanest pattern - it avoids manually splitting each invoice between the accrual and the new period.

## Accrued / unbilled revenue
Revenue earned this period but not yet invoiced to the customer (e.g. work delivered, milestone met, time worked under a contract). Recognise it now.
- Period end: DR Accrued income / unbilled receivables (current asset) / CR Revenue (P&L).
- Worked: consultancy delivered £5,000 of work in March, invoice goes out in April → DR Accrued income 5,000 / CR Revenue 5,000.
- Reverse next period (DR Revenue / CR Accrued income), then raise the real invoice (DR Trade receivables / CR Revenue + output VAT). Output VAT is NOT accrued - it crystallises only on the actual tax invoice (tax point). Under IFRS 15 this asset is a "contract asset" if it's conditional on more than the passage of time; otherwise it's a receivable.

## Prepayment (expense paid in advance)
Cash paid now for benefit spanning future periods (e.g. annual insurance, rent paid quarterly in advance, software subscriptions, prepaid business rates). Do not expense it all at payment.
- At payment: DR Prepayments (current asset) / CR Cash/bank (VAT goes to the VAT account at payment per the invoice, not spread).
- Each period, amortise the portion consumed: DR Expense (P&L) / CR Prepayments.
- Worked: £1,200 annual insurance paid 1 Oct, year-end 31 Dec. At pay: DR Prepayments 1,200 / CR Bank 1,200. At 31 Dec, 3 months consumed → DR Insurance 300 / CR Prepayments 300. Prepayment asset carries 900 into next year and amortises 100/month. Prepayments AMORTISE - they are not reversed in full; the asset is drawn down period by period until exhausted.

## Deferred / unearned revenue (cash received in advance)
Customer pays before you've earned it (e.g. annual subscription billed up front, deposits, retainers, prepaid maintenance). It is a liability until earned, not revenue.
- On receipt: DR Cash/bank / CR Deferred revenue (current liability). If a VAT invoice was raised, output VAT is due at that tax point regardless of when revenue is recognised - VAT timing and revenue recognition diverge here.
- Each period as earned: DR Deferred revenue / CR Revenue (P&L).
- Worked: £1,200 annual SaaS billed 1 Jan, recognised monthly. On receipt: DR Bank 1,200 / CR Deferred revenue 1,200. Each month: DR Deferred revenue 100 / CR Revenue 100. Liability runs down to nil over 12 months. Like prepayments, deferred revenue is released over time, not reversed in one go.

## Reverse vs amortise - the decision rule
- REVERSE (full mirror entry next period): one-off estimates that a real transaction will replace - accrued expenses and accrued/unbilled revenue. You reverse so the incoming invoice can post normally without you hand-splitting it.
- AMORTISE (partial draw-down each period over the asset/liability life): balances representing a pool consumed gradually - prepayments and deferred revenue. You never reverse the whole prepayment; you release the slice consumed.
- Depreciation is neither reversed nor a one-off - it accumulates (see below).
Tell: if a single future invoice/cash event will land and clear the balance, reverse. If the balance is a multi-period pool, amortise.

## Depreciation - concept and the journal
Spread a tangible fixed asset's cost (less residual/salvage value) over its useful life. The journal is identical across all methods; only the periodic amount differs.
- Each period: DR Depreciation expense (P&L) / CR Accumulated depreciation (contra-asset on the balance sheet).
- Accumulated depreciation is a separate contra account - never credit the asset cost account directly. Net book value (NBV) = cost − accumulated depreciation. Depreciation is NOT reversed and NOT reclassed at year-end; it accrues until the asset is fully depreciated or disposed. On disposal, remove cost and accumulated depreciation and book gain/loss vs proceeds.

## Straight-line depreciation
Equal charge each period over the life.
- Formula: (Cost − Residual value) / Useful life in periods.
- Worked: asset £10,000, residual £1,000, 5-year life. Annual = (10,000 − 1,000)/5 = £1,800/yr. DR Depreciation expense 1,800 / CR Accumulated depreciation 1,800, each year for 5 years. After year 5, accumulated dep = 9,000, NBV = 1,000 (= residual; stop here). Monthly version = 1,800/12 = £150. Pro-rate the first period if acquired mid-period (policy-dependent: full-month, mid-month, or actual days).

## Reducing-balance / declining-balance depreciation
Higher charge early, falling over time; applied to NBV (carrying amount), NOT to cost, and residual is NOT subtracted from the base.
- Formula: NBV at start of period × fixed rate %. Each year the base shrinks.
- Worked: asset £10,000, 25% reducing balance. Y1: 10,000 × 25% = 2,500 → NBV 7,500. Y2: 7,500 × 25% = 1,875 → NBV 5,625. Y3: 5,625 × 25% = 1,406 → NBV 4,219. The asset never reaches zero mathematically; stop at residual value or write off the remainder in the final year per policy. Double-declining balance is a variant: rate = 2 × (1/useful life) (e.g. 5-year life → 40%); same NBV-base mechanics. The journal is the same DR expense / CR accumulated depreciation.

## Units-of-production depreciation
Charge tracks actual usage, not time - for assets whose wear is output-driven (machinery, vehicles by mileage).
- Formula: ((Cost − Residual) / Total estimated lifetime units) × units used this period. The first part is the per-unit rate.
- Worked: machine £50,000, residual £5,000, expected 90,000 units. Rate = (50,000 − 5,000)/90,000 = £0.50/unit. Period producing 12,000 units → 12,000 × 0.50 = £6,000. DR Depreciation expense 6,000 / CR Accumulated depreciation 6,000. Total depreciation over life can never exceed (cost − residual); cap the final period so accumulated dep doesn't overshoot.

## Recurring-journal patterns
Most adjusting entries repeat on a schedule - automate as recurring/memorised journals rather than re-keying.
- Straight-line depreciation: fixed-amount recurring journal, same DR/CR each period; tie to the fixed-asset register so additions/disposals adjust the run.
- Prepayment amortisation: schedule the draw-down (e.g. 12 monthly DR Expense / CR Prepayments of equal slices) at the time of the initial payment.
- Deferred revenue release: schedule monthly DR Deferred revenue / CR Revenue over the contract term.
- Accruals with auto-reversal: book the accrual flagged "reversing" so the system posts the mirror entry automatically on the first day of the next period - most GLs (Xero, QBO, NetSuite, Intacct, BC) support a reversing-journal flag; use it instead of a manual reversal to avoid forgotten reversals double-counting cost. Reducing-balance and units-of-production are NOT fixed-amount, so they can't be a flat recurring journal - recompute each period from NBV or actual units.

## Period-end checklist and common errors
- All adjusting entries dated the last day of the period; reversals dated day 1 of the next.
- No VAT on accruals/prepayment amortisation/deferred-revenue release - VAT is handled once on the actual tax invoice/payment.
- Don't expense a prepayment in full, don't recognise deferred revenue in full, don't depreciate against the asset cost account.
- Reversing an accrual but then also coding the real invoice to the accruals account = the accrual never clears; code the real invoice to the expense account.
- Depreciation base error: straight-line and units-of-production subtract residual; reducing-balance does not.
- Closed/locked period: adjusting entries posted into a locked period reject at post time - post to the next open period or have the period reopened.
