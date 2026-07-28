# Doc map

Where to look, by task and by platform. Internal notes first, because they tell
you what to look for; the vendor's own reference second, because it is the only
authority on the current contract.

## By task

| Task | Read first |
| --- | --- |
| Any journal entry | `trove/entries/accounting-fundamentals.md` |
| Correcting something already posted | `trove/entries/reclasses-and-corrections.md` |
| P&L, balance sheet, cash flow | `trove/entries/financial-statements.md` |
| Closing a period | `trove/entries/month-end-close.md` |
| Bank reconciliation | `trove/entries/bank-reconciliation.md` |
| Accruals, prepayments, depreciation | `trove/entries/accruals-prepayments-depreciation.md` |
| Revenue recognition | `trove/entries/revenue-recognition.md` |
| Inventory and COGS | `trove/entries/inventory-and-cogs-valuation.md` |
| Fixed assets and disposals | `trove/entries/fixed-assets-and-disposals.md` |
| Leases | `trove/entries/lease-accounting.md` |
| Payroll journals | `trove/entries/payroll-journals.md` |
| Bad debt / expected credit loss | `trove/entries/bad-debt-and-expected-credit-loss.md` |
| Provisions and contingencies | `trove/entries/provisions-and-contingencies.md` |
| More than one currency | `trove/entries/multicurrency.md` |
| Foreign subsidiaries | `trove/entries/foreign-operations-and-translation.md` |
| Intercompany, consolidation | `trove/entries/intercompany-and-consolidation.md` |
| Control accounts vs subledgers | `trove/entries/control-accounts-and-subledgers.md` |
| **Before automating anything** | `trove/entries/automation-pitfalls.md` |

## Tax

| Need | Read |
| --- | --- |
| US federal: entities, forms, deadlines, payroll, depreciation | `us-tax/federal.md` |
| A specific state, all 50 plus DC | `us-tax/states.md` |
| US sales tax, nexus, and why a ZIP is not a rate | `us-tax/sales-tax-and-zip.md` |
| VAT, GST, reverse charge | `trove/entries/vat-gst-and-reverse-charge.md` |
| UK/EU VAT alongside US sales tax | `trove/entries/sales-tax-and-vat.md` |
| Entity types, filings, payroll tax overview | `trove/entries/us-taxation.md` |

Every figure carries the tax year it applies to. Rates and thresholds change
annually: verify anything year-dependent against the primary source before a
user relies on it for a filing.

## By platform

Read the platform file, then pull the vendor's own reference with
`scripts/fetch-docs.sh <platform>` and read that too. The vendor wins on any
conflict; these notes are a map, not the territory.

| Platform | Notes | Vendor source |
| --- | --- | --- |
| QuickBooks Online | `platforms/quickbooks-online.md` | browser only, portal is client-rendered |
| QuickBooks Desktop | `platforms/quickbooks-desktop.md` | SDK / QBXML, on premise |
| Xero | `platforms/xero.md` | **OpenAPI spec**, fetches cleanly |
| Oracle NetSuite | `platforms/netsuite.md` | browser only |
| Sage Intacct | `platforms/sage-intacct.md` | browser only |
| Sage 300 | `platforms/sage-300.md` | no known public source |
| Sage 300 CRE | `platforms/sage-300-cre.md` | no known public source |
| Sage 50 | `platforms/sage-50.md` | no known public source |
| Dynamics 365 BC | `platforms/dynamics-365-bc.md` | Microsoft Learn, fetches cleanly |

Anything else: `PLATFORM-PLAYBOOK.md`. Add what you learn to `platforms/` using
`platforms/_template.md`, and add the doc URL to `SOURCES` in
`scripts/fetch-docs.sh` so the search happens once.

## The two that cause most damage

Repeated here because they are platform independent and destroy data:

1. **Assume an update is a full replace** until the docs prove otherwise. Many
   accounting APIs overwrite the stored record with exactly what you send,
   silently clearing every field you omitted.
2. **Never invent an identifier.** Account codes, tax codes and entity ids come
   from a read against the live system, never from a plausible guess.

## Working from a phone

`REMOTE.md`. The propose-then-write rule gets stricter on a small screen, not
looser.
