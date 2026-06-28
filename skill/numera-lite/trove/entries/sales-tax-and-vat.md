---
title: Sales tax (US) and VAT (UK/EU) - the transaction taxes
slug: sales-tax-and-vat
type: reference
created: 2026-06-29
tags: [taxation, sales-tax, vat, nexus, wayfair]
---

The two big consumption taxes a bookkeeping agent meets: US sales tax and UK/EU
VAT. Rates and thresholds change - verify against the state DOR / HMRC before relying
on a number. Not tax advice.

## US sales tax
A **destination-or-origin**, jurisdiction-stacked tax collected by the seller from
the buyer and remitted to the state (and often county/city/special districts).

- **The rate stack**: state + county + city + special-district rates sum to the
  **combined rate** at a location. There is no single national rate.
- **ZIP codes do not map cleanly to a rate** - a ZIP can span multiple cities,
  counties, and districts. Accurate calculation is by full address (rooftop
  geocode); a 5-digit ZIP is only an approximation, ZIP+4 closer.
- **NOMAD states have no statewide sales tax**: New Hampshire, Oregon, Montana,
  Alaska (local only), Delaware.
- **Origin vs destination sourcing**: most states are destination-based for
  interstate sales (the buyer's ship-to rate applies); some are origin-based for
  in-state sales (the seller's location rate). California is mixed (state/county/city
  origin, district destination).
- **Economic nexus (post-Wayfair, 2018)**: a seller must register and collect once it
  crosses a state's threshold - commonly **$100,000 in sales or 200 transactions**
  in a year (many states have dropped the 200-transaction prong; some use $500k).
  Physical presence also creates nexus.
- **Marketplace facilitator laws**: marketplaces (Amazon, etc.) collect and remit on
  behalf of their third-party sellers.
- **Use tax**: the buyer self-assesses the equivalent tax when a seller did not
  collect (e.g. an out-of-state purchase).
- **In the books**: sales tax collected is a **liability** (Sales tax payable), not
  income; it is owed to the state until filed and paid. Track by jurisdiction.
- **Scaling rates**: per-ZIP/address rates come from maintained datasets (Streamlined
  Sales Tax rate/boundary files, state DOR tables) or commercial APIs (Avalara,
  TaxJar, Vertex) - not hand-research.

## UK/EU VAT (Value Added Tax)
A multi-stage tax on value added; the business is a collector, the final consumer
bears it.

- **Output VAT** - VAT you charge customers on sales. **Input VAT** - VAT you pay on
  purchases. You remit **output minus input** to the tax authority (reclaim if input
  exceeds output).
- **UK standard rate 20%**, reduced 5%, zero-rate 0% (e.g. most food, children's
  clothing), plus exempt (e.g. some financial services - no VAT and input not
  reclaimable). Know the difference between zero-rated (reclaim input) and exempt (cannot).
- **Registration**: required once taxable turnover passes the VAT threshold (a
  rolling 12-month figure set by HMRC); voluntary registration is allowed below it.
- **VAT return**: usually quarterly in the UK; the 9-box return reports output VAT,
  input VAT, net due/reclaim, and totals. The UK files via **Making Tax Digital (MTD)**
  (digital records + API submission).
- **Reverse charge**: for many cross-border B2B services and UK construction (CIS
  domestic reverse charge), the **buyer** accounts for both the output and input VAT
  instead of the supplier - net zero if fully reclaimable, but it must appear on the
  return. NumeraAI handles this when prepping VAT.
- **EU VAT** - each member state sets its own standard rate (typically ~17-27%);
  intra-EU and import rules (OSS/IOSS) apply for cross-border sales.
- **In the books**: Output VAT (liability) and Input VAT (asset) net into a VAT
  control / VAT payable account that clears when the return is filed and paid.

## What an agent should do
Record the tax to the right control account (never as income/expense), keep it by
jurisdiction/rate, track filing deadlines, and prep the return for human review and
filing - never file on the user's behalf.
