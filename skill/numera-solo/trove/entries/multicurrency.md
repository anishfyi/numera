# Multi-Currency Accounting

## Three currencies, three roles
Every multi-currency entry sits in up to three currency frames. (1) Transaction currency: the currency the document is denominated in (the invoice says EUR). (2) Functional currency: the currency of the entity's primary economic environment, the one the books are kept in (e.g. GBP for a UK ledger). (3) Presentation/reporting currency: the currency the financial statements are shown in, often the same as functional but can differ for group consolidation. The ledger ALWAYS records and balances in functional currency; transaction currency is carried as a memo/foreign amount on the line. Never confuse "the invoice is in EUR" with "the ledger entry is in EUR", the entry is functional with a foreign-amount tag.

## Spot rate vs closing rate
Spot (transaction) rate: the exchange rate on the date the transaction is initially recognised, used to translate a foreign invoice, bill, or payment into functional currency at booking. Closing (period-end) rate: the rate at the balance-sheet date, used to re-translate (revalue) monetary balances still outstanding. A single foreign invoice that is raised and later settled touches at least two rates: spot at raising, spot at settlement, and possibly a closing rate at any period-end in between. Each rate produces a different functional amount for the same foreign amount; the differences are FX gain/loss.

## Monetary vs non-monetary items
Only monetary items get revalued at the closing rate. Monetary = balances settled in a fixed number of currency units: AR, AP, foreign cash/bank, loans, accrued interest. Non-monetary items are NOT revalued, they stay at the historical (spot-at-acquisition) rate: inventory, fixed assets, prepayments, deferred revenue, equity contributions. (Deferred revenue is treated as non-monetary because it is settled by DELIVERING goods/services, not cash; a refundable cash advance is the monetary exception - judgement under IAS 21.) So a foreign-currency fixed asset sits frozen at its purchase-date rate forever; a foreign-currency receivable moves every period-end. Misclassifying a prepayment as monetary and revaluing it is a common error.

## Realized vs unrealized FX
Realized FX gain/loss: arises on settlement, the cash actually moves and the rate difference between booking and payment is locked in. Unrealized FX gain/loss: arises on revaluation of an open monetary balance at period-end, no cash has moved, the position is still open, the gain/loss can reverse next period. Both hit P&L (typically a "Foreign exchange gain/(loss)" line). The distinction matters for tax (some regimes tax only realized FX) and for reversing logic: unrealized revaluations are usually reversed/re-based at the next measurement so you don't double-count when settlement finally occurs.

## A journal must balance WITHIN each currency before any FX
Hard rule: in functional currency the journal's debits must equal credits to the penny. FX gain/loss is NOT a fudge to make a single-currency entry balance, it is its own recognised line with its own account. When an entry spans rates (e.g. clearing a foreign AR against a foreign cash receipt translated at a different rate), the functional debits and credits will not naturally tie out; the residual is posted explicitly to the FX gain/loss account, and THAT is what makes it balance. The foreign-currency (transaction) amounts also balance independently within their own currency: a EUR invoice and its EUR payment net to zero in EUR. If the foreign amounts don't net, the discrepancy is a real EUR difference (short-pay, bank charge), not FX.

## Booking a foreign-currency sales invoice
Foreign AR sales invoice for EUR 10,000, spot 0.8500 (GBP per EUR) on raise date. Functional value = 10,000 x 0.8500 = GBP 8,500.
DR Accounts Receivable GBP 8,500 (foreign amt EUR 10,000)
CR Revenue GBP 8,500
The AR line carries the EUR 10,000 as its foreign/original amount. Revenue is recognised once at the spot rate and never re-translated (it's a P&L event, fixed at transaction date). Only the open AR (monetary) will later move.

## Period-end revaluation of monetary balances
At period-end, re-translate each open foreign monetary balance at the closing rate; the change in functional value vs its current carrying value is the unrealized FX. For a receivable whose functional value RISES (foreign currency strengthened against functional): DR Accounts Receivable / CR FX gain. For a receivable whose functional value FALLS: CR Accounts Receivable / DR FX loss. For a payable it is mirrored: payable functional value rising = DR FX loss / CR Accounts Payable; falling = DR Accounts Payable / CR FX gain. The contra is ALWAYS the FX gain/loss P&L account, never revenue/expense or the original account's income side. Revalue the carrying amount, not the original, i.e. move from the last-known functional value to the closing-rate value.

## Reversing the revaluation
Two acceptable mechanics. (1) Reverse the period-end revaluation entry on day one of the next period, returning the balance to its historical functional value, so settlement FX is computed cleanly against original cost. (2) Leave the revaluation in place and treat the revalued functional amount as the new carrying base, so the next movement (next period-end or settlement) is measured from there. Either gives the same cumulative P&L; be consistent and know which the platform/ledger uses before computing settlement FX, or you will double-count the unrealized portion.

## Settling a foreign-currency invoice (realized FX)
Receipt of EUR 10,000 against the AR above, but settlement-date spot is 0.8200. Cash received in functional = 10,000 x 0.8200 = GBP 8,200. AR was carried at GBP 8,500. Realized loss = GBP 300.
DR Bank (functional) GBP 8,200 (foreign EUR 10,000)
DR FX loss GBP 300
CR Accounts Receivable GBP 8,500 (clears foreign EUR 10,000)
Foreign amounts: EUR 10,000 in vs EUR 10,000 cleared = nets to zero in EUR (correct). Functional amounts only balance because the GBP 300 FX loss line is present. If a period-end revaluation already moved AR to, say, GBP 8,400, then only GBP 200 of NEW realized loss is booked at settlement (8,400 - 8,200), the earlier GBP 100 having been recognised as unrealized, unless you reversed the revaluation first, in which case the full GBP 300 is realized now.

## Worked example end to end
EUR 10,000 invoice. Rates (GBP per EUR): raise 0.8500, period-end 0.8300, settlement 0.8200.
1. Raise: DR AR 8,500 / CR Revenue 8,500.
2. Period-end revaluation (AR falls 8,500→8,300): DR FX loss 200 / CR AR 200. AR now 8,300. Unrealized loss 200 in P&L.
3a. If revaluation NOT reversed, settle: DR Bank 8,200 / DR FX loss 100 / CR AR 8,300. Realized loss this period 100. Total P&L impact 200 + 100 = 300.
3b. If revaluation reversed at next period start (DR AR 200 / CR FX gain 200, AR back to 8,500), settle: DR Bank 8,200 / DR FX loss 300 / CR AR 8,500. Net P&L = -200 (P1) +200 (reversal) -300 (settle) = -300.
Both paths land total FX = GBP 300 loss = (0.8500 - 0.8200) x 10,000. The cumulative result is rate-at-raise minus rate-at-settlement on the foreign amount, regardless of period-end mechanics.

## Exchange-rate sourcing and rate dates
Use a defensible, documented rate source and apply it consistently: a central-bank daily reference (ECB, Bank of England), an FX data provider, or a stated corporate/period-average policy. Match the rate DATE to the event: spot on the document/transaction date for initial recognition; the period-end (closing) date rate for revaluation; the settlement date rate for realized FX. Income-statement items may use a period-average rate; balance-sheet monetary items use the closing rate. Define direction explicitly (units of functional per unit of foreign, or the inverse) and divide/multiply accordingly, inverting the rate silently doubles your error. For weekends/holidays the convention is the most recent published rate (rate carries forward), be explicit which day's rate applies. Tax authorities often mandate a specific source/method for VAT and reporting; follow the jurisdiction's required rate where one exists.

## Rounding
Translate then round to the functional currency's minor unit (2 dp for GBP/EUR/USD; 0 dp for JPY) at the line or document level per policy, and be consistent, because rounding at line level vs total level gives different sub-penny results. Compute FX gain/loss as the difference between already-rounded functional amounts so the residual posted to FX equals exactly what makes the entry balance; do not carry unrounded precision into the FX line. Tiny residuals from independent rounding of the cash, clearing, and revaluation legs are absorbed into the FX gain/loss line, never into revenue, expense, or a suspense account. Never round the foreign (transaction) amount, it is the contractual figure and must net to zero in its own currency.

## VAT and multi-currency
VAT is accounted in functional currency using the rate prescribed by the tax authority on the tax point date (often a specified published rate, not the entity's chosen commercial rate). The VAT amount in functional currency is fixed at the tax point and is NOT subsequently revalued, it is a settled tax obligation, not an open FX-exposed monetary balance for revaluation purposes (the residual trade payable/receivable still is). When an invoice is foreign-denominated, show both the foreign and functional VAT amounts; the functional VAT is what flows to the VAT return.

## Common failure modes
Revaluing revenue/expense or non-monetary items (only open monetary balances move). Posting FX differences to the original income/expense account instead of the FX gain/loss line. Double-counting unrealized FX at settlement because the prior revaluation wasn't reversed or wasn't used as the new base. Inverting the rate direction. Forcing a single-currency entry to balance via FX instead of finding the real foreign-amount discrepancy (short-payment, bank charge, write-off). Mixing rate dates (using closing rate to book a new transaction, or spot to revalue). Letting foreign amounts fail to net to zero in their own currency and calling the gap "FX" when it is a real underpayment.
