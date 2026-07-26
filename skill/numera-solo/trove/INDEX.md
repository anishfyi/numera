# Numera Solo Trove

> **Numera Solo - a Solo AI Agent by anishfyi.** https://github.com/anishfyi/numera
>
> A bundled knowledge trove for the Numera Solo accounting skill: decent working
> knowledge of two accounting platforms (Sage Intacct, QuickBooks Online) and of
> accounting and taxation, as plain markdown for easy reference by Claude Code.
> One file per topic in `entries/`. Built in the [trove](https://github.com/anishfyi/trove)
> format (INDEX.md + entries/). Read the relevant entry before reasoning about that topic.

<!-- entries below -->

## Accounting and taxation
- [Accounting fundamentals](entries/accounting-fundamentals.md) - double-entry, debits/credits, the accounting equation, the GL/sub-ledger/trial balance, accrual vs cash, the chart of accounts, auditable corrections
- [The financial statements](entries/financial-statements.md) - P&L, balance sheet, cash flow, the equity bridge, how they tie out (net profit -> retained earnings, closing cash -> bank, balance sheet must balance)
- [The month-end close](entries/month-end-close.md) - the 15-step close checklist Numera runs (reconcile, accruals, prepayments, depreciation, deferred revenue, review, lock) plus the controls that make it trustworthy
- [US business taxation](entries/us-taxation.md) - entity types (sole prop / LLC / S-corp / C-corp), federal forms and deadlines (1120, 1120-S, 1065, Sch C), payroll taxes (FICA/FUTA, 941/940, W-2/1099), accounting method and tax year
- [Sales tax (US) and VAT (UK/EU)](entries/sales-tax-and-vat.md) - the rate stack and why ZIP != rate, NOMAD states, Wayfair economic nexus, use tax; VAT output/input, registration, the return, reverse charge, MTD

## Accounting software
- [QuickBooks Online (QBO)](entries/quickbooks-online.md) - the SMB cloud standard: data model (COA, customers/vendors, items, invoices/bills, journal entries, classes/locations), cash-vs-accrual toggle, undeposited funds, bank feeds, reconciliation, reports, the Intuit API, and gotchas
- [Sage Intacct](entries/sage-intacct.md) - the mid-market cloud GL: dimensions over a lean COA (the defining idea), multi-entity and consolidation, GL batches, the XML web-services API, imports, and gotchas

---

_How Numera Solo uses this: read the entry that matches the task before acting -
e.g. `accounting-fundamentals` before posting any entry, `quickbooks-online` or
`sage-intacct` when the user's books live there, `month-end-close` when closing a
period, and the taxation entries when sales tax / VAT / filings come up. Verify any
figure that changes yearly against the primary source. Solo is a bookkeeper's
assistant, not a licensed accountant or a filing service._
