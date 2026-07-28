# US Tax & Accounting Knowledgebase (keyed by postcode / ZIP)

A structured reference an AI accountant can use to reason about US business tax and
accounting obligations, organized the way the US tax system actually works: federal rules
on top, state rules below, and local (county / city / special-district) rules resolved by
location. **ZIP code is the lookup key into those jurisdictions, not a jurisdiction itself.**

Built 2026-06 from authoritative primary sources (irs.gov, state Departments of Revenue,
Streamlined Sales Tax, US Census) via a multi-agent web-research pass, then assembled and
fact-checked here. Tax figures are labeled with the year they apply to.

## What "for each postcode" really means

A US business does not have one "tax rate for a ZIP." Its obligations are a stack:

1. **Federal** - the same for every ZIP (income tax on the entity, payroll taxes, federal
   forms and deadlines). See [federal.md](federal.md).
2. **State** - set by the state the ZIP is in (income tax, sales tax base rate, franchise /
   gross-receipts taxes, filing requirements). 50 states + DC. See [states.md](states.md).
3. **Local (resolved by location within the state)** - county + city + special-district
   sales/use tax that **stacks into a combined rate**. This is the only layer that varies
   *within* a state, and it is what people mean by "the rate for a ZIP."

The critical correctness point: **a 5-digit ZIP can span multiple cities, counties, and
special tax districts**, because ZIPs are USPS delivery routes, not tax boundaries. The
accurate lookup is `address -> rooftop geocode -> jurisdictions -> combined rate`; a 5-digit
ZIP gives an approximate rate, ZIP+4 a closer one. The mechanics, the post-Wayfair economic
nexus rules, and a seeded sample are in [sales-tax-and-zip.md](sales-tax-and-zip.md).

## Files

| File | Contents |
|------|----------|
| [federal.md](federal.md) | Federal business tax & accounting: entity types, forms & deadlines, corporate rate, payroll/FICA, depreciation (179/bonus/MACRS), R&D credit, accounting methods, GAAP basics |
| [states.md](states.md) | All 50 states + DC: individual & corporate income tax, sales tax base rate, franchise / gross-receipts taxes, economic-nexus thresholds, key filings, notable rules |
| [sales-tax-and-zip.md](sales-tax-and-zip.md) | How ZIP maps to combined sales-tax jurisdictions, origin vs destination sourcing, Wayfair economic nexus, use tax, authoritative per-ZIP datasets, and a worked sample |
| [zip_sales_tax_seed.json](zip_sales_tax_seed.json) | Machine-readable seed: representative ZIPs -> {city, county, state, state_rate, local_rate, combined_rate} |

## Scaling to all ~42,000 ZIPs (without hand-research)

Per-ZIP combined rates are a maintained dataset, not something to research one ZIP at a time.
The seed here is illustrative; production coverage of every ZIP comes from one of:

- **State-published rate/boundary files** - many DORs publish downloadable ZIP or
  address-level rate tables (and Streamlined Sales Tax member states publish standardized
  rate + boundary files).
- **US Census ZCTA <-> county relationship file** - maps ZIP areas to counties for the
  state/county layer.
- **Commercial rate APIs** (Avalara, TaxJar, Vertex) for rooftop-accurate combined rates.

`sales-tax-and-zip.md` lists the specific sources and URLs. The intended pattern is: keep
this KB for the *rules and structure*, and join it to a refreshed rate dataset for the
*per-ZIP numbers*.

## How this plugs into NumeraAI (optional)

NumeraAI already loads reference chunks for the agent via the `apicontext` app. These docs
are written as standalone chunks (clear headings, tables) so they can be indexed there to
give the chat agent grounded US tax context. Not wired in yet - flagged as a follow-up.

## Caveats

- **Not tax advice.** This is a reference for an automation layer; every figure must be
  verified against the primary source before it drives a filing or a posted entry.
- **Rates and thresholds change yearly** (often at year-end / mid-year). Each figure is
  dated; re-verify against the cited DOR/IRS source on use.
- Combined local rates are approximate at the 5-digit ZIP level by nature (see above).
