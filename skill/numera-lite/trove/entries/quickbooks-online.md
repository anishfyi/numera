---
title: QuickBooks Online (QBO) - data model, concepts, working with it
slug: quickbooks-online
type: reference
created: 2026-06-29
tags: [software, quickbooks, qbo, smb, accounting-platform]
---

QuickBooks Online (QBO) by Intuit is the most common cloud accounting system for
small businesses. (QuickBooks Desktop is the older on-prem product - similar
concepts, different access.) This is what a bookkeeping agent needs to reason about it.

## What it is
Cloud, double-entry accounting for SMBs. Editions: Simple Start, Essentials, Plus,
Advanced (more users, classes/locations, projects, budgets as you go up). It runs
the full small-business cycle: invoicing, bills, banking, payroll (add-on), sales
tax, and reporting.

## Core data model (the objects)
- **Chart of Accounts** - the GL accounts (each has a Type and Detail Type, e.g.
  Type "Expense" / Detail "Office/General Administrative"). Account types drive
  where things land on the statements.
- **Customers** and **Vendors** (suppliers) - the names you transact with; Customers
  can have **sub-customers/Projects**.
- **Products and Services (Items)** - what you sell/buy; each maps to an income (and
  optionally expense/COGS) account. Item types: Service, Inventory, Non-inventory, Bundle.
- **Transactions**: Invoice, Sales Receipt, Payment received, Credit Memo (AR side);
  Bill, Bill Payment, Expense, Check, Vendor Credit (AP side); Journal Entry (manual
  double-entry); Transfer; Deposit.
- **Classes** and **Locations** (Plus/Advanced) - tags for segment reporting without
  bloating the COA (e.g. Class = product line, Location = office).
- **Attachments**, **Audit Log** (who changed what), **Tax codes/rates**.

## Concepts that trip people up
- **Cash vs accrual** is a report toggle - the same ledger reports either way; know
  which the client uses before quoting a number.
- **Undeposited Funds** - a holding account for received payments not yet deposited
  to the bank; clear it when the bank deposit lands (or reconciliation breaks).
- **Bank feeds** - QBO pulls bank/card transactions; you categorize/match them.
  "Banking" review is where most coding happens. Matching to existing transactions
  avoids duplicates.
- **Reconciliation** - the dedicated Reconcile screen matches QBO to the statement;
  a reconciled transaction is marked "R".
- **Accounts Receivable / Accounts Payable** are special accounts QBO manages via
  Invoices/Bills - avoid posting manual journal entries straight to AR/AP without a name.
- **Sales tax** - QBO's Automated Sales Tax computes rates by address; tracked in a
  sales-tax liability/agency, filed from the Sales Tax Center.

## Key reports
Profit and Loss, Balance Sheet, Statement of Cash Flows, A/R Aging Summary/Detail,
A/P Aging, General Ledger, Trial Balance, Transaction Detail by Account, Sales by
Customer/Product. Reports can be run cash/accrual and by Class/Location/Project.

## Working with QBO as an agent
- **UI** - the day-to-day surface for a human operator.
- **Exports** - any report exports to CSV/Excel/PDF; the General Ledger or
  Transaction Detail export is the cleanest way to pull the books into a local file
  that Numera Lite can read and reason over.
- **API** - the Intuit QuickBooks Online Accounting API (OAuth 2.0, REST/JSON) is
  how the full NumeraAI writes back: objects like Account, Customer, Vendor, Item,
  Invoice, Bill, JournalEntry, Payment. A posted JournalEntry needs balanced Line
  items each with a `JournalEntryLineDetail` (PostingType Debit/Credit, AccountRef).
  Updates use the object Id + **SyncToken** (optimistic locking - stale token fails).
- **Sandbox** - Intuit provides a developer sandbox company for safe testing.

## Gotchas
- Editing/voiding a reconciled or prior-period transaction can break a past
  reconciliation - prefer reversing entries.
- Names matter: AR/AP transactions must carry a Customer/Vendor or aging breaks.
- The same item appearing twice on a document is two lines, not a bug.
- "Categorize" in bank feed posts a transaction; "Match" links to an existing one -
  picking wrong creates duplicates.

For how NumeraAI writes safely (propose -> confirm -> read-back -> seal), see the
month-end-close entry. Numera Lite works against an exported ledger locally and
never writes to QBO.
