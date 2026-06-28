---
title: Sage Intacct - dimensions, multi-entity, data model, working with it
slug: sage-intacct
type: reference
created: 2026-06-29
tags: [software, sage-intacct, erp, mid-market, accounting-platform]
---

Sage Intacct is a cloud financial management / accounting system for mid-market
companies and finance teams. It sits above QuickBooks in complexity: strong
multi-entity, dimensions, and automation. This is what a bookkeeping agent needs.

## What it is
Cloud, true multi-entity general ledger and ERP-lite. Core modules: General Ledger,
Accounts Payable, Accounts Receivable, Cash Management, Order Entry, Purchasing,
Fixed Assets, plus add-ons (Projects, Time & Expense, Contracts/revenue recognition,
Multi-entity & Consolidation, Spend Management). AICPA-endorsed; common for SaaS,
nonprofits, healthcare, professional services.

## The defining feature: Dimensions
Intacct's big idea is a **lean chart of accounts plus dimensions**. Instead of
encoding department/location/project into hundreds of GL account numbers, you keep
a small COA and **tag** each transaction with dimensions, then report by any
combination. Standard dimensions:
- **Location** (and entity, in multi-entity), **Department**, **Project**,
  **Customer**, **Vendor**, **Item**, **Class**, **Employee**, plus **custom
  dimensions**.

This is the single biggest mental difference from QuickBooks: reporting power comes
from dimensions, not from a sprawling account list. A journal line carries the
account *and* its dimension tags.

## Multi-entity and consolidation
Intacct natively handles many entities under one company, with shared COA,
inter-entity transactions, automatic due-to/due-from elimination, and currency
consolidation. You can operate at a single entity or at the top (consolidated) view.
"Books close" can run per entity and roll up.

## Core data model (objects)
- **GL Accounts** (lean), **GL Journal / Journal Entries** posted as **GL batches**
  (a batch groups balanced entries).
- **AP Bills, AP Payments; AR Invoices, AR Payments**; **Cash Management** (bank
  accounts, reconciliation).
- **Dimensions** (above) attached to lines.
- **Order Entry / Purchasing** transactions (sales orders, POs) for those modules.
- **Statistical accounts** - track non-financial metrics (headcount, square footage)
  alongside the GL for KPI reporting.
- **Books**: an accrual book by default; supports reporting periods and adjustment journals.

## Working with Intacct as an agent
- **UI** - the operator surface; menus by module.
- **Imports** - Intacct is import-friendly: CSV/template uploads for journal entries,
  bills, invoices, customers, etc. A GL journal import needs balanced debit/credit
  lines with account + dimension columns.
- **API / Web Services** - the XML-based Sage Intacct API (session-based: log in to
  get a session id, then post function calls like `create`/`update`/`read` against
  objects such as `GLBATCH`/`GLENTRY`, `APBILL`, `ARINVOICE`). The full NumeraAI's
  Intacct adapter builds GL batches this way (balanced GLENTRY lines, controlid for
  idempotency, TRX/exchange-rate fields for multi-currency). A posted batch must balance.
- **Exports / reports** - the Financial Report Writer and standard reports export to
  Excel/CSV; export the GL detail to pull the books into a local file Numera Lite can read.

## Concepts and gotchas
- Think **dimensions, not accounts** - if asked "how do we track project costs?",
  the answer is a Project dimension, not new GL accounts.
- A GL batch / journal must balance per entity and per currency.
- Periods can be opened/closed per book; posting to a closed period is blocked.
- Multi-entity: watch which entity context you are in; inter-entity entries auto-create
  the due-to/due-from side.
- Reconciliation lives in Cash Management; match Intacct to the bank statement there.

For the safe write loop (propose -> confirm -> read-back -> seal) the full NumeraAI
uses against Intacct, see the month-end-close entry. Numera Lite reasons over an
exported ledger locally and does not write to Intacct.
