# Sage 300 CRE

> On premise, construction. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Writes and sharp edges

How writing works on Sage 300 CRE (Construction & Real Estate, formerly Timberline
Office), and the traps. This is a construction ERP over a Pervasive PSQL (Btrieve)
data store, not a cloud API. Exact table names, import layouts and app versions
below should be verified against the Sage 300 CRE integration/import documentation.

### The integration model (read by ODBC, write by import)
- **Reads**: the Sage 300 CRE ODBC driver is the standard, supported read path -
  read-mostly, and slow on large tables. Treat it as reporting-grade.
- **Writes are NOT a live REST/SDK transaction API in the cloud sense.** The
  supported write paths are, in order of how integrations actually do it:
  1. **Import files** - the canonical path. You produce a strictly-formatted text
     file to the spec of the target application (AP invoice import, JC cost import,
     GL journal/transaction import, etc.) and the app imports it, usually as a
     batch a human reviews and posts. Column order / headers are exact.
  2. The Sage 300 CRE API / SDK where a given module exposes one.
- It is **batch-oriented, not real-time** - there is no webhook and no synchronous
  "post and get the id back" round trip the way QBO or Xero give you.
- **Never write directly to the Btrieve/Pervasive files.** Direct file writes are
  unsupported, bypass application validation, and corrupt the data set.

### Construction-specific shape
- Transactions carry **job / cost-code / category** dimensions (Job Cost). AP
  invoices tie to **commitments** (POs and subcontracts); GL postings typically
  ORIGINATE in the subledger apps (AP, JC, PR) and post to GL in batches, rather
  than being keyed straight into GL.
- Period and close locking is **per application** (AP, JC, GL each lock), not one
  global switch - confirm every relevant app's period is open before importing.

### Sharp edges
- **Import layout is strict and version-specific** - a column out of place silently
  mis-maps or rejects the whole batch; validate against the app's current import
  spec.
- **ODBC is read-oriented and can be slow / connection-limited** - pull what you
  need, do not stream the whole ledger.
- **No idempotency** on imports - re-importing the same file double-posts; track
  which files/batches you have already submitted and use unique batch references.
- **VAT is light / US-centric** - Sage 300 CRE is a US construction product; UK VAT
  and CIS (construction industry scheme) are handled through specific setups, not a
  general tax-code-on-the-line model. Verify the CIS/VAT configuration before
  relying on tax behaviour.
(Verify exact import file layouts, ODBC table names, and per-app behaviour against
the Sage 300 CRE integration documentation for the installed version.)

## Field notes

Sage 300 CRE (formerly Timberline) is a US construction ERP on an Actian Zen
data store (the engine formerly called Pervasive PSQL, descended from Btrieve;
older CRE releases ship Pervasive PSQL v11 or Actian PSQL 12, newer ones Actian
Zen 15 - verify the engine for your installed CRE version). You read it over
ODBC; the supported way to post transactions is import files the apps batch up
for a human to post. Operational scars below; names, versions and error/status
codes flagged "(verify against the SDK/driver docs)" as they drift by release.

### ODBC connection fails or sees no tables
A connection that times out or opens with no tables is environment, not your
query. The Sage 300 CRE ODBC driver must be installed AND a DSN configured to the
correct Timberline data folder, with matching bitness. The Sage CRE ODBC drivers
are 32-bit only - there is no 64-bit Sage CRE driver - so a 64-bit host process
cannot load the driver and will fail in a way that can look like bad credentials.
Register the DSN with the 32-bit ODBC Administrator and connect from a 32-bit
process. Confirm driver install, DSN target and 32-bit host (verify against the
driver docs for your release). ODBC is primarily a read/reporting channel; see
below before treating it as a write path.

### Big-table reads hang or choke the system
Queries that crawl or stall, sometimes degrading the desktop for everyone, come
from ODBC over the Actian/Pervasive (Btrieve-lineage) engine being slow and
connection-limited; whole-ledger scans of large JC/GL tables are costly and
sessions scarce. Pull only the columns and date ranges you need, filter at
source, page extracts, run heavy reads off-hours, and reuse one connection over
many.

### A re-run import double-posts everything
Imports have no idempotency: no upsert key dedupes, so the same file imported
twice creates a second batch. The fix is yours - stamp each file with a unique
batch reference, ledger what you have submitted, and never resubmit a "maybe it
failed" file before confirming the prior batch in the app.

### A batch rejects or columns mis-map
Import files are strict and version-specific: column order, headers, widths and
date formats must match the target application's current import spec exactly, and
a single shifted column silently mis-maps or kills the batch. Validate every file
against the installed version's layout (verify the layout against the app's import
documentation), and re-verify after any Sage upgrade.

### Import accepted but numbers never appear
Writes are not synchronous: an import lands as a BATCH a person reviews and posts
inside the app; until posted it is not in JC/GL and on no report, and there is no
webhook or post-and-get-id round trip. Treat import-then-post as two steps,
report the batch reference, and say posting is a human action.

### "Locked period" on only some files
Period and close locks are PER application - AP, JC and GL lock independently,
with no single global switch. Confirm the period is open in every application a
file touches before importing, and read the rejection as one app's lock, not a
system-wide close. Note the usual close/lock ordering (subsidiary and operational
apps first, General Ledger last), so a GL-period rejection can be a downstream
symptom of where you are in the close.

### Missing-field error on cost transactions
Cost transactions carry mandatory job / cost-code / category dimensions (Job
Cost); omit any and the app refuses the line, often citing a field you thought
optional. Populate all three on every cost line and validate against the live job
setup before importing (verify the exact required field names against the app's
import spec for your release).

### "Can we write the data files directly?"
Editing the Actian/Pervasive (Btrieve-format) files to skip slow ODBC and finicky
imports corrupts the data set: direct writes bypass all application validation and
indexing. Never write the data files directly. The supported write path for
transactions is import files.

### "Can't we just write back over ODBC?"
ODBC write is technically possible, not impossible - CRE security exposes separate
"ODBC read" and "ODBC write" role permissions, and commercial tools do write
through the ODBC layer. But treat it as the exception, not the channel: only a
limited set of fields is writable, you cannot create most records this way, and
ODBC writes bypass the application's validation and posting logic just as direct
file edits do. It is not a substitute for import-then-post for transactions. A
partner-program SDK/API exists for some modules, but the CRE SDK is gated behind
the Sage Developer Partner Program and is sparse/elusive even to enrolled
partners, so do not assume one is available for your module (verify with Sage
before relying on it). Default to import files; reserve ODBC writes for the
narrow, supported field-update cases a vendor tool documents.

## Overview

On-prem construction/real-estate accounting suite, job-cost-centric. NOT Sage 300 ERP (Accpac) and NOT Sage Intacct - same vendor, different product, different data store, different access model. No general-purpose cloud REST API. Treat it as a desktop application whose data you read over ODBC and into which you write mostly via file-based imports. Everything below assumes an on-prem or partner-hosted install you have direct or VPN access to.

### Identity: what this is and is not
Sage 300 CRE = the product formerly sold as Sage Timberline Office. Modules are job-cost-first: General Ledger (GL), Job Cost (JC), Accounts Payable (AP), Accounts Receivable / Billing (AR/Billing), Payroll (PR), Cash Management (CM), Property Management (PM), Equipment Cost (EQ), Contracts, Purchasing, Inventory. It is a separate product from Sage 300 ERP / Accpac (those use SQL Server and an OData Web API) and from Sage Intacct (cloud, XML/REST). Advice, drivers, field names, and journal conventions do NOT transfer between them. If a user says "Sage 300" alone, disambiguate: CRE vs ERP. Companion product Sage Estimating (formerly Timberline Estimating) often sits alongside it.

### Data store: Pervasive / Btrieve flat files
Application data lives in Pervasive PSQL (Btrieve) database files on a file server, organized as a data folder per company, with the GL/JC/AP/etc. files inside (named with module prefixes and a version-specific naming scheme). This is NOT SQL Server; there is no T-SQL engine to query directly. Records are ISAM rows in fixed-format files. Pervasive PSQL provides the SQL/ODBC layer on top of Btrieve. Because the engine is file-locking based, heavy concurrent ODBC reads can contend with users running desktop tasks (period close, posting); schedule big extracts off-hours. Back up the data folder, never just individual files, since cross-file referential integrity is maintained by the app, not the engine. (verify against live docs)

### Auth and access model (overview)
There is no token, OAuth, or web login for data access. Three practical paths: (1) ODBC reads via the Sage 300 CRE ODBC driver (read access controlled by a Sage ODBC user/password layered over Windows/network access to the data folder); (2) the Sage 300 CRE SDK / API for programmatic interaction; (3) the desktop application's own import tools and Sage Intelligence (Excel-based) reporting. "Authentication" in practice means: a Windows account with network rights to the company data folder, plus the Sage ODBC driver's own credential prompt (driver-level user/password configured in the Sage system). Application-level module security (which user can post/edit which module) is enforced by the desktop app, NOT by the ODBC layer - ODBC can read tables the in-app user would be barred from, so do not treat ODBC visibility as authorization. (verify against live docs)

### The ODBC driver is read-mostly
The Sage 300 CRE ODBC driver is designed and supported for READS (reporting, extracts, BI). Treat it as read-only in practice: do not attempt to INSERT/UPDATE Btrieve files through ODBC to post accounting transactions - it bypasses the application's posting logic, audit trail, and cross-file integrity, and can corrupt the data set. All financial writes go through the application: desktop entry, file-based import (Import templates / Tools > Import), or the SDK where supported. The mental model: ODBC = SELECT; postings = import or SDK. (verify against live docs)

### Connecting over ODBC
Create a DSN using the "Sage 300 Construction and Real Estate" / "Timberline Data" ODBC driver pointing at a company data folder; the driver exposes tables by module. Use the driver's own configuration to enable "real-time" vs cached reads and to map the data folder. Table and column names follow the desktop field structure and are version-specific; enumerate them from ODBC catalog metadata (DatabaseMetaData / driver table list) rather than hardcoding - names differ across versions and even across modules' file layouts. The driver speaks a restricted SQL subset: expect limited JOIN support, no/limited subqueries, and quirks around date and amount columns. Test every query; do not assume full ANSI SQL. (verify against live docs)

### Entities: GL is small, Job Cost is the point
The friendly journal-shape entities still exist (Accounts, journal entries, AP invoices, AR invoices/billings, payments, receipts), but the center of gravity is Job Cost. Core dimensions: Job, then within a job Cost Code (the WBS line, e.g. "03-300 concrete") and Cost Type / Category (Labor, Material, Subcontract, Equipment, Other). Every cost transaction is tagged Job + Cost Code + Cost Type. Commitments (subcontracts and purchase orders) and Change Orders modify a job's committed and revised budget. Estimating populates the original budget. So a JC record carries far more analytic structure than a GL line: budget, committed, actual cost, cost to complete, and billing/revenue all roll up by Job and Cost Code. The GL is the financial summary; JC is the operational truth, and the two must reconcile.

### Entities: GL accounts and the chart
GL accounts use a structured account number (prefix/base/suffix style segments configurable per install) and carry account type (asset/liability/equity/revenue/expense) and period balances by fiscal year/period. The chart is typically smaller than a vanilla GL because cost detail lives in Job Cost, not in dozens of expense accounts - one "Construction Costs - WIP" or "Cost of Construction" account can absorb thousands of JC transactions whose detail is held by Job/Cost Code/Cost Type. When reconciling, do not expect GL account granularity to match JC analytic granularity; the bridge is the JC-to-GL interface and the WIP/cost accounts. (verify against live docs)

### How job-cost postings map to the friendly journal shape
A cost hitting a job posts in two ledgers at once: Job Cost (Job + Cost Code + Cost Type, increasing actual cost) and GL (the double entry). Typical mappings:
- AP subcontract/material invoice on a job: DR Job Cost / WIP (Construction-in-progress) expense account, CR Accounts Payable. JC actual cost increases for that Job/Cost Code/Cost Type.
- Payroll labor to a job: DR Job Cost (Labor) WIP, CR wages payable / cash; burden (taxes, fringes) posts as additional JC cost via configured burden rates.
- Equipment cost charged to a job: DR Job Cost (Equipment), CR equipment cost recovery/clearing.
- Owner billing (AR/Billing): DR Accounts Receivable, CR Contract Revenue (or CR Billings in Excess on percentage-of-completion). Retainage on a billing posts DR Retainage Receivable instead of AR for the held portion.
Present any proposed entry in this DR/CR form, but state the Job, Cost Code, and Cost Type it carries, because in CRE those are part of the posting, not a memo.

### WIP, billings, and percentage-of-completion
Construction GL is governed by revenue recognition over time. Key balance-sheet pairs: Costs and Estimated Earnings in Excess of Billings (underbilling, an asset) vs Billings in Excess of Costs and Estimated Earnings (overbilling, a liability). Percent complete is usually cost-to-cost: actual cost to date / total estimated cost. Earned revenue = percent complete x total contract value; the over/under-billing adjustment = earned revenue - amount billed to date. These adjustments are period-end GL entries derived from JC data (the WIP schedule / WIP report), not automatic line postings. Retainage (commonly ~5-10%, contract-specific) is withheld on both AP (retainage payable to subs) and AR (retainage receivable from owner) and released later; it sits in dedicated retainage accounts, not in normal AP/AR. When proposing close entries, drive over/under-billing and retainage from the WIP schedule, and verify percent-complete method per contract (cost-to-cost vs units vs effort) before assuming. (verify against live docs)

### Queries: reading data the right way
For reporting and reconciliation, read over ODBC or use Sage Intelligence (Excel add-in that ships with curated report layouts over the same data). For ad hoc, ODBC SELECT against the module tables: GL transactions/accounts, JC cost transactions/cost detail, AP/AR documents. Because the SQL subset is limited, prefer single-table scans filtered by job/period and join/aggregate in your own code rather than in one big SQL statement. Period and fiscal-year fields, not just dates, drive accounting reporting - filter on the accounting period, since transaction date and posting period can differ (a March-dated invoice posted in the April period reports in April). Amounts in JC may be stored separately for budget/committed/actual; sum the correct measure. Always reconcile a JC roll-up back to its GL control account before trusting it. (verify against live docs)

### Writes: file-based imports and the SDK
Postings into CRE are made by the application, via: (1) Import templates - module import tools (Tools > Import / module-specific import) accept text/CSV/fixed-width files matching a defined import layout, used to load AP invoices, GL entries, JC transactions, timecards, etc.; the import runs the same validation and posting logic as manual entry. (2) The Sage 300 CRE SDK / API for programmatic entry where exposed. (3) Manual desktop entry. Imports are the standard automation path: build the file to the template, the user runs the import in the app, the app validates and posts, an audit/error report comes back. Never post by writing Btrieve directly. (verify against live docs)

### Sharp edges
- ODBC is read-mostly: SELECT yes, posting via direct table writes no - it skips validation, audit, and integrity and risks corruption. Route all postings through import or the SDK.
- Distinct product: this is NOT Sage 300 ERP (Accpac) and NOT Intacct. Drivers, field names, OData/REST, and journal conventions from those do not apply here.
- Version + driver pinning: data file layouts, table/column names, and the ODBC driver are version-specific. Pin the driver to the install's version, enumerate schema from catalog metadata each time, never hardcode names across versions. (verify against live docs)
- Import layouts are version- and module-specific and brittle: column order, fixed widths, and required fields must match the template exactly or the import fails or posts wrong. Always confirm the layout against the live install before generating a file. (verify against live docs)
- Period vs date: postings are governed by accounting period, which can differ from the transaction date; filter and post by period or you will misstate the month.
- Job/Cost Code/Cost Type are required posting dimensions for job costs, not optional tags; an entry missing them is incomplete in CRE.
- Retainage and over/under-billing live in dedicated accounts and are period-end WIP-driven entries, not ordinary AP/AR/revenue lines - do not net them into normal control accounts.
- GL granularity != JC granularity: reconcile JC roll-ups to GL control/WIP accounts; do not assume one matches the other line for line.
- Concurrency: heavy ODBC reads can contend with Btrieve file locks during posting/close; run large extracts off-hours.
- Authorization gap: ODBC read visibility ignores in-app module security; do not infer a user is permitted to act on data just because ODBC returned it.
- SDK availability and capabilities vary by module and version; confirm what the SDK actually supports for the target module before assuming a write path exists. (verify against live docs)

