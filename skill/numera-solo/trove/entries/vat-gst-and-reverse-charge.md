# VAT, GST and the Reverse Charge

UK VAT mechanics for an AI preparing returns. This is the area most models get wrong: the difference is recovery rights and where amounts land in the boxes, not just the rate. Treat every supply as having two questions: (1) what rate/treatment applies, and (2) does it give a right to reclaim input VAT.

## Output VAT vs input VAT
Output VAT = VAT you charge customers on your sales. It is a liability you owe HMRC.
Input VAT = VAT you are charged by suppliers on your purchases. It is recoverable from HMRC if the cost relates to taxable (standard/reduced/zero-rated) supplies you make.
Net VAT payable = output VAT minus recoverable input VAT. Positive = you pay HMRC; negative = HMRC repays you (a repayment return).
Journal on a standard sale: DR Debtors (gross) / CR Sales (net) / CR VAT control (output). On a purchase: DR Expense or Asset (net) / DR VAT control (input) / CR Creditors (gross). The VAT control account nets to the period liability.

## The 9 boxes of the UK VAT return
Exactly what each box holds. Boxes 1, 2, 4, 6, 7, 8, 9 are entered; Boxes 3 and 5 are calculated.
- Box 1: VAT due on sales and other outputs (output VAT, including reverse-charge output and the VAT element of EU acquisitions).
- Box 2: VAT due on acquisitions of goods made in Northern Ireland from EU member states (acquisition tax). Post-Brexit this is NI-only; nil for GB-only traders.
- Box 3: total VAT due = Box 1 + Box 2. Calculated.
- Box 4: VAT reclaimed on purchases and other inputs (input VAT, including reverse-charge input, acquisition VAT, and postponed import VAT).
- Box 5: net VAT = Box 3 minus Box 4, reported as a POSITIVE figure; the direction is set by which is larger (Box 3 > Box 4 -> pay HMRC; Box 4 > Box 3 -> reclaim). Calculated.
- Box 6: total value of sales and all other outputs excluding VAT (net sales). Include zero-rated, exempt, and reverse-charge sales values here.
- Box 7: total value of purchases and all other inputs excluding VAT (net purchases). Include reverse-charge and imported goods values.
- Box 8: total value of goods (excluding VAT) supplied to EU member states from Northern Ireland. NI-only.
- Box 9: total value of goods (excluding VAT) acquired from EU member states into Northern Ireland. NI-only.
Boxes 8 and 9 are goods only, never services. Boxes 6 and 7 are values (net), not VAT amounts; a common AI error is putting VAT amounts in 6/7.

## Domestic reverse charge (buyer self-accounts)
On a reverse-charge supply the supplier does NOT charge VAT; the customer accounts for both sides. Used for UK construction services (CIS reverse charge), and for cross-border services received under the general place-of-supply rule.
The buyer posts the same VAT amount as both output and input:
- Box 1: + the output VAT the buyer self-charges.
- Box 4: + the same VAT as input (if fully recoverable).
- Box 6: include the value (for general/cross-border reverse charge on services; do NOT include in Box 6 for the UK domestic construction reverse charge - the customer leaves the value out of Box 6).
- Box 7: + the net value of the purchase.
Cash effect is nil when the buyer can fully recover (Box 1 and Box 4 cancel). If the buyer is partially exempt, Box 4 is restricted and real VAT becomes payable. Supplier's invoice must state reverse charge applies and show no VAT. Supplier shows the net value in Box 6 but nothing in Box 1.

## EU acquisitions and postponed import VAT
EU acquisitions (NI only, goods): account for acquisition VAT in Box 2, reclaim the same in Box 4 (if recoverable), value in Boxes 7 and 9. Self-accounting, nil net if fully recoverable.
Imports of goods into GB from anywhere (post-Brexit): use Postponed VAT Accounting (PVA). Instead of paying import VAT at the border, declare it on the return:
- Box 1: + import VAT due (from the monthly PVA statement).
- Box 4: + the same import VAT reclaimed (if recoverable).
- Box 7: + net value of the imported goods.
PVA is nil-cash when fully recoverable and replaces the old C79-and-pay-at-border flow. Figures come from the HMRC online monthly postponed import VAT statement, not the supplier invoice. If PVA is not used, import VAT paid at the border is reclaimed in Box 4 using the C79 certificate as evidence.

## Zero-rated vs exempt vs outside-scope (and why it matters)
Three distinct things; the difference is the right to reclaim input VAT, not the customer-facing 0%.
- Zero-rated: a taxable supply at 0% (e.g. most food, children's clothes, books, exports of goods). No output VAT charged, BUT input VAT on related costs is fully recoverable. Counts toward the registration threshold. Goes in Box 6.
- Exempt: not a taxable supply (e.g. most insurance, finance, postage, certain education/health, some property). No output VAT, AND input VAT on related costs is NOT recoverable. Does not count toward the registration threshold. Value still reported in Box 6.
- Outside the scope of UK VAT: not a UK supply at all (e.g. wages, dividends, TOMS-adjacent items, supplies made outside the UK, statutory fees). No VAT, generally excluded from the boxes entirely.
The trap an AI must not make: treating exempt as zero-rated. Both show 0% to the customer, but exempt blocks input recovery and triggers partial exemption; zero-rated does not.

## Partial exemption basics
A business making both taxable and exempt supplies can recover only the input VAT attributable to its taxable supplies.
Three-step standard method:
1. Directly attributable to taxable supplies: fully recoverable.
2. Directly attributable to exempt supplies: not recoverable.
3. Residual/overhead input VAT (relates to both): recover the taxable proportion, by default = taxable turnover / total turnover, rounded up to the next whole percent.
De minimis: there are SEVERAL tests; passing ANY ONE makes all input VAT (including the exempt-related portion) recoverable. The common simplified test is broadly: exempt input VAT under GBP 625/month on average AND under 50% of total input VAT (other tests exist). (verify current de minimis tests + thresholds against live HMRC guidance.)
An annual adjustment recalculates recovery over the full VAT year and corrects the quarterly provisional figures. Getting taxable-vs-exempt classification wrong cascades into wrong Box 4.

## Making Tax Digital (MTD) and the filing deadline
MTD for VAT: VAT-registered businesses must keep digital records and file returns via MTD-compatible software using HMRC's API; manual entry through the old portal is closed. There must be a digital link (no manual copy-paste) between the source record and the submitted figures.
Deadline rule: the return and the payment are due one calendar month plus 7 days after the end of the VAT period. Example: quarter ending 31 March -> due 7 May. Most businesses file quarterly; some monthly or annually (Annual Accounting Scheme). Payment timing follows the same one-month-plus-7-days rule (direct debit may collect a few working days later). Records must be retained (generally 6 years).

## GST analog (one line)
GST (Australia, New Zealand, Canada, India, etc.) works on the same input/output credit mechanism as VAT - you charge GST on sales (output), claim input tax credits on purchases, and remit the net - but rates, registration thresholds, return forms (e.g. Australian BAS, Indian GSTR), box layout, and filing cadence differ by country, so never reuse UK box numbers or the GBP 625 de minimis outside the UK.
