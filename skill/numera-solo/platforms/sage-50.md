# Sage 50

> On premise. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Writes and sharp edges

How writing works on Sage 50, and the traps. Exact object names, tax-code numbers
and version pairings below should be verified against the Sage 50 SDK docs for the
installed edition and version - they differ by product and release.

### First, which Sage 50? They are two different products
"Sage 50" is a brand over TWO unrelated codebases with different data models and
SDKs. Always confirm which before integrating:
- **Sage 50 Accounts (UK)** - formerly Sage Line 50. Nominal codes, T-codes for VAT.
- **Sage 50 US** - formerly Peachtree. Different schema, different SDK.
Code written for one does not work on the other.

### The integration model (local, file-based)
Sage 50 is desktop software over a shared company-data folder, not a cloud tenant:
- **UK Sage 50 Accounts**: write through the Sage Data Objects (SDO) COM/.NET
  engine (the "Sg50SdoEngine" object family) against the data path; you log in with
  a Sage username/password and the company must have third-party integration
  ENABLED and the SDK licensed/activated (a serial/activation key). ODBC exists but
  is the read path.
- **Sage 50 US**: the Sage 50 US SDK (.NET) / COM, or transaction import files.
- Either way the data lives in a shared folder with a **single logical writer** -
  concurrent writers contend on the data lock. Post during low activity and expect
  to retry on lock contention.

### Posting an entry
- Reference accounts by **nominal code** (UK) / account ID (US); resolve against the
  chart of accounts first.
- VAT is driven by **tax codes** (UK Sage uses T0 zero, T1 standard, T2 exempt, plus
  codes for reverse charge / EC); the code on the transaction drives the VAT return
  boxes - do not journal the VAT control directly.
- A posted transaction is effectively immutable by policy in many setups; correct by
  reversing, not by editing history.

### Sharp edges
- **SDK version must match the data version.** Upgrading Sage 50 can change the data
  format and break an older SDK binding; pin and test the SDK against the exact
  installed version.
- **Activation/serial required** - the SDO engine refuses to connect without the
  integration enabled and a valid serial; this is a common first-run failure.
- **No cloud webhooks.** There is no push; poll the data for changes.
- **Foreign currency is a module** that may not be enabled - multi-currency calls
  can fail on a single-currency company.
- **Login + exclusive-access quirks**: some operations need exclusive access; a user
  in the company can block them.
(Verify exact SDO object names, T-code numbers, and SDK/data version pairings
against the Sage 50 SDK documentation for the installed edition.)

## Field notes

Operational scar tissue for the two desktop products that share the "Sage 50" badge. These are the connection, versioning and locking traps that bite at runtime - they sit alongside the writes_and_sharp_edges doc (the actual posting model), they don't repeat it. Where an exact object name, error string or version pairing is given, treat it as illustrative and verify against the SDK/SDO docs for the installed edition because they drift between releases. British/practitioner English throughout.

### "Sage 50" is two products with two SDKs - target the wrong one and nothing connects
The symptom: code that connected fine at one client throws "class not registered" or just finds no engine at the next. The cause: UK Sage 50 Accounts (formerly Line 50) and US Sage 50 (formerly Peachtree) are unrelated codebases. UK has two distinct integration routes: Sage Data Objects (SDO) - a COM/ActiveX component (a set of ActiveX DLLs, driven from .NET via COM interop) with full read/write and access via the developer programme, whose ProgID is version-suffixed as SDOEngine.<n> (for example SDOEngine.27 for a given release, instantiated as CreateObject("SDOEngine.<n>")) - and SData, a separate, free, REST-based API that exposes only a limited subset of functionality and cannot write at the depth SDO can. They are not the same thing; pick the one that matches your read/write needs and verify the exact ProgID/assembly against the SDK docs. US uses its own Sage 50 US SDK (verify the exact assembly/ProgID against the SDK docs). The fix: detect the product first (installed path, registry, version banner), pick the matching SDK and integration route, and never assume the connection recipe ports across the pond.

### The SDO/SDK version must match the installed data version, or the binding breaks
The symptom: an integration that ran for months suddenly fails to open the company after the user accepts a Sage update, often with a data-version or "could not load" error. The cause: SDO is version-locked to the data format - the ProgID itself carries the version (SDOEngine.<n>), and a Sage 50 upgrade rewrites the company data so an older SDO component can no longer bind to it. The fix: pin the SDO/SDK version to the exact installed Sage version (including matching the SDOEngine.<n> you instantiate), treat any Sage upgrade as a breaking event, and probe the installed version at connect time so you fail loudly with a clear message rather than mid-write.

### The engine refuses to connect unless third-party integration is enabled (and, on older versions, activated)
The symptom: valid credentials, correct data path, yet the engine will not open - a generic activation/serial or "third-party access not enabled" failure on the very first call. The cause: SDO needs third-party integration switched on inside Sage (Tools > Activation > Enable 3rd Party Integration). On older releases that step also demanded a free SDO serial number and activation key obtained from Sage: this was required on Sage 50 Accounts v24.0 and below, but from v24.1 onwards the serial/activation key is no longer needed - enabling integration is enough. Either way, without the integration step the engine simply declines. The fix: confirm third-party integration is enabled (and, if on v24.0 or earlier, that the SDK is activated with its key) as a one-off setup step, and surface this as a configuration error, not a transient retry.

### Login plus exclusive-access locks - a logged-in user can block your writes
The symptom: reads work but a write or a maintenance operation throws "in use" / access-denied intermittently. The cause: Sage 50 is a shared-folder, single-logical-writer model; some operations need exclusive access and any human (or another integration) inside the company contends on the data lock. The fix: log in with a real Sage user, serialise writes, run during low activity, and treat lock errors as retry-after-backoff rather than hard failures.

### SDO reads and writes itself; the Sage ODBC driver is a separate, optional, read-only path
The symptom: queries return empty or the DSN test fails despite the company existing. The cause: SDO does full read and write directly through the engine - you do not need ODBC to read. Sage also ships a separate ODBC driver (read-only by design) that some integrations use as a reporting/extract path via a DSN pointing at the shared data folder; if you go that route and the UNC path is unreachable, the mapping is wrong, or the file is locked, you get silence not a clear error. The fix: prefer SDO for reads when you are already using it to write; if you do use the ODBC driver, treat it as an optional read-only path distinct from the SDO engine, and verify the data path is reachable and the DSN resolves before blaming the schema.

### No webhooks - you must poll, and validate T-codes per company
The symptom: changes made in Sage never reach you, or a VAT posting lands in the wrong return box at one client. The cause: Sage 50 is local with no push/webhooks, and tax T-codes (T0, T1, etc.) and foreign-currency are configured per company - the multi-currency module may be off entirely. The fix: poll on a schedule for change detection, resolve and validate T-codes against the live company before posting, and feature-detect multi-currency rather than assuming it exists.

## Overview

### Two different products under one name
"Sage 50" is two unrelated codebases sharing a brand. UK/IE "Sage 50 Accounts" (formerly Sage Line 50 / Sage Instant) and US/Canada "Sage 50" (formerly Peachtree; "Sage 50cloud Accounting" in the US) are different applications with different data files, different schemas, different terminology, and different integration paths. Identify the country/edition FIRST - a method that works for UK does not exist on US and vice versa. UK uses "nominal codes / nominal ledger" and VAT; US uses "accounts / chart of accounts" and sales tax. Neither is the cloud-native Sage Business Cloud Accounting (Sage Accounting / formerly Sage One), which is a separate REST product.

### Desktop/on-prem, no general cloud REST
Both editions are Windows desktop apps with a local data store; the company file lives on a workstation or a Windows file share, not in a Sage-hosted cloud. There is NO general public cloud REST API for the ledger like Xero/QuickBooks Online. All programmatic access is local: an SDK/data layer running on a machine that can see the data files, or ODBC against those files. "Sage 50cloud" is a connected desktop edition (Microsoft 365/OneDrive sync, remote data access add-on, bank feeds), not a re-platform - the system of record is still the desktop file. Treat any integration as on-prem with file/SDK access, never assume an internet endpoint.

### UK access path: Sage 50 SDK (SDO) and SData
UK Sage 50 Accounts exposes the Sage Data Objects (SDO) COM SDK - the supported, read/write programmatic layer that enforces business rules. SData (a REST/Atom-style HTTP interface served locally by Sage 50 Accounts, e.g. via a local SData service) was the modern UK integration surface but is legacy/deprecated for newer integrations; prefer SDO for writes (verify current SDK availability and licensing against live docs). SDO requires a matching SDK version per Sage 50 release and a licensed seat. ODBC is read-mostly and bypasses business rules - use it for reporting, not posting.

### US access path: Sage 50 US SDK (COM/.NET)
US Sage 50 (Peachtree lineage) integrates via the Sage 50 US SDK, a COM/.NET object model the desktop exposes; historically branded as the Peachtree/Sage 50 SDK and consumed from .NET (verify exact assembly/class names and current SDK distribution against live docs). It is the supported write path and applies the same edit/validation rules as the UI. There is also a separate "Sage 50 Accounting Connector"/intermediary-cloud approach used by some partners; do not assume it is present. As in the UK, ODBC against the company data is available for reads.

### ODBC against the data directory
Both editions ship/support an ODBC driver pointed at the company data folder. UK Sage 50 Accounts stores data in a company directory with an .SAJ data subfolder ("Sage Accounts Data"/ACCDATA with a .SAJ store); the Sage 50 ODBC DSN points at that data path. US Sage 50 has its own ODBC DSN against the Peachtree/Sage 50 company directory. ODBC gives SQL SELECT access to tables/views for reporting and reconciliation. ODBC writes are unsupported/dangerous (bypass business logic, balances, and audit) - read only, never INSERT/UPDATE the ledger over ODBC. Exact .SAJ table/column names vary by version (verify against live docs).

### Reads vs writes
Reads: ODBC (SQL, read-only) is the simplest for reporting/extract; SDO (UK) / US SDK can also read with full rule context. Writes/postings: MUST go through SDO (UK) or the US SDK so double-entry, VAT/sales-tax, and audit are enforced; the desktop typically must be installed and, depending on version, running/licensed on the machine doing the write. Never post to the ledger via ODBC. Treat the SDK as the only legitimate write surface; treat ODBC as the read surface.

### How postings map to the friendly journal shape
UK nominal ledger: a journal is a set of nominal entries that must net to zero, each line carrying a nominal code, a debit OR credit amount, date, and reference (tax/T-code on transactional postings; pure nominal journals are usually outside VAT). The friendly journal shape (lines of {account, debit, credit, memo}) maps to nominal-code lines where debit increases assets/expenses and credit increases liabilities/income/equity - standard double-entry. US Sage 50: same double-entry against the chart of accounts (General Journal entries), debits = credits. Customer/supplier (AR/AP) and bank transactions post through their own document types (invoices, receipts, payments) that generate the underlying nominal/GL entries plus VAT/sales-tax and control-account movement automatically - prefer the document type over a raw journal when one exists, so tax and ledger control stay correct.

### Sharp edges
- Data-path access: you must reach the company data folder (.SAJ on UK) on the LAN/host; mapped drives, share permissions, and antivirus locking the data path are common failure causes.
- Exclusive access / locking: Sage 50 (esp. UK) often needs exclusive or controlled multi-user access for SDK writes; SDO writes can fail if users are in the company, and some operations require single-user mode. Coordinate with live users before posting.
- Version coupling: the SDK/SDO version, ODBC driver, and the Sage 50 program version must match the data version; an upgrade of the desktop can break an integration until the SDK is updated. Feature/field availability differs by version - never assume a field exists.
- SData deprecation (UK): SData is legacy and may be absent/disabled on current installs; do not build new write integrations on it - use SDO (verify against live docs).
- 32-bit/COM: SDO/US COM objects are often 32-bit; host process bitness and DCOM/registration matter on the workstation.
- ODBC is read-only in practice: writing via ODBC corrupts balances and audit - it is not a supported posting path.
- Tax codes/periods: UK postings use T-codes (e.g. T0/T1/T9 conventions, configurable per company) and a VAT scheme; posting into a closed/locked period or a wrong T-code misstates the VAT return. Let the document type calculate tax rather than hand-keying tax lines.
- Multi-company: each company is a separate data file/path; there is no single tenant - select the correct company directory explicitly per connection.

