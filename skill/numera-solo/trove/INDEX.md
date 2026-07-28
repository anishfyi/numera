# Numera Solo Trove

> Accounting knowledge for the Numera Solo skill, one file per topic in
> `entries/`. Built in the [trove](https://github.com/anishfyi/trove) format.
> **Read the entry that matches the task before acting.** Working from memory
> is how a plausible, balanced, completely wrong entry gets posted.

Deeper references live alongside this trove:

- `../us-tax/` federal, all 50 states and DC, and the sales-tax stack
- `../platforms/` per-platform notes for 9 accounting systems
- `../SETUP.md` pull a vendor's own API reference before writing to it

<!-- entries below -->

## Core doctrine, read before posting anything
- [Accounting fundamentals](entries/accounting-fundamentals.md) - The non-negotiable core. Get this right and the rest follows.
- [Financial statements](entries/financial-statements.md) - Three core statements plus the equity bridge. They are different views of the
- [Control accounts and subledgers](entries/control-accounts-and-subledgers.md) - Control accounts summarise a subledger in the general ledger. The subledger holds the per-entity / per-document detail; the control account holds...
- [Reclasses and corrections](entries/reclasses-and-corrections.md) - Reclass: right amount, right period, WRONG account. Move balance between accounts; net P&L and net cash unchanged. Correction: WRONG amount (typo,...

## The close
- [Month end close](entries/month-end-close.md) - The month-end close is the repeatable process that turns a month of raw activity
- [Bank reconciliation](entries/bank-reconciliation.md) - Reconciling the GL cash account (book balance) to the bank statement balance for a period. The goal is not to make the two numbers equal by force;...
- [Accruals, prepayments and depreciation](entries/accruals-prepayments-depreciation.md) - Adjusting entries align the ledger to the accrual basis at period close: recognise economic events in the period they occur, not when cash moves....
- [The period close and roll-forward](entries/period-close-and-roll-forward.md) - How the ledger turns over from one period to the next: the close sequence, closing
- [The cash flow statement](entries/cash-flow-statement.md) - The cash flow statement explains the period's movement in cash, not profit. It reclassifies every cash event into three sections - operating,...

## Recognition and valuation
- [Revenue recognition and deferred revenue](entries/revenue-recognition.md) - When to recognise revenue, and how deferred revenue unwinds. Cross-cutting domain
- [Inventory valuation and cost of goods sold](entries/inventory-and-cogs-valuation.md) - How to value stock and move its cost into the P&L on any ledger: inventory is an asset carried at cost, and cost of goods sold (COGS) is the cost...
- [Fixed assets, depreciation and disposals](entries/fixed-assets-and-disposals.md) - How to reason about capital assets across any ledger: the register IS the
- [Lease accounting (IFRS 16 / ASC 842)](entries/lease-accounting.md) - How a lessee gets a lease onto the balance sheet and unwinds it across any ledger:
- [Provisions and contingencies (IAS 37)](entries/provisions-and-contingencies.md) - When a liability of uncertain timing or amount goes on the balance sheet versus when it is merely disclosed in the notes. Cross-cutting domain...
- [Bad debt and expected credit loss](entries/bad-debt-and-expected-credit-loss.md) - Bad debt is the cost of customers who will not, or might not, pay. The discipline is to recognise that cost against profit BEFORE the specific...
- [Payroll journals: gross-to-net](entries/payroll-journals.md) - How a pay run lands on the ledger from the employer's side: gross pay is the

## Multi-entity and currency
- [Multi-Currency Accounting](entries/multicurrency.md) - Every multi-currency entry sits in up to three currency frames. (1) Transaction currency: the currency the document is denominated in (the invoice...
- [Foreign operations and translation](entries/foreign-operations-and-translation.md) - How to bring a foreign OPERATION (a subsidiary, branch or division that keeps its
- [Intercompany transactions and consolidation](entries/intercompany-and-consolidation.md) - How transactions between members of the same group are recorded, reconciled, and removed when the group reports as one. The elimination mechanics...

## Tax
- [Us taxation](entries/us-taxation.md) - Decent working knowledge of US business tax for a bookkeeping agent. Figures change
- [Sales tax and vat](entries/sales-tax-and-vat.md) - The two big consumption taxes a bookkeeping agent meets: US sales tax and UK/EU
- [VAT, GST and the Reverse Charge](entries/vat-gst-and-reverse-charge.md) - UK VAT mechanics for an AI preparing returns. This is the area most models get wrong: the difference is recovery rights and where amounts land in...

## Working with a platform
- [Quickbooks online](entries/quickbooks-online.md) - QuickBooks Online (QBO) by Intuit is the most common cloud accounting system for
- [Sage intacct](entries/sage-intacct.md) - Sage Intacct is a cloud financial management / accounting system for mid-market

## What goes wrong
- [Automation pitfalls](entries/automation-pitfalls.md) - Cross-platform scar tissue: the mistakes an AI makes automating accounting REGARDLESS of which ledger (Xero, QBO, Intacct, NetSuite, Dynamics BC,...

---

_Numera Solo is a bookkeeper's assistant, not a licensed accountant and not a
filing service. Verify anything year-dependent against the primary source._
