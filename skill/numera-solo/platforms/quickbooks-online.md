# QuickBooks Online

> Cloud, REST v3. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Auth and limits

### OAuth 2.0 flow
Authorization code flow. Authorize at https://appcenter.intuit.com/connect/oauth2 with scope com.intuit.quickbooks.accounting; Intuit appends realmId to the callback. Exchange the code at https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer with HTTP Basic (client_id:client_secret).

### Token lifetimes and refresh
Access tokens last 60 minutes. Refresh tokens last 100 days but ROTATE: every refresh response may contain a new refresh_token; always persist the latest one or the chain dies. Refresh proactively on 401. A revoked or 100-day-stale refresh token requires full re-consent.

### Rate limits
~500 requests/minute per realm, 10 concurrent requests per realm per app. Batch endpoint counts as one request but max 30 operations. On 429 back off and honor Retry-After. Sandbox limits are lower.

### Hosts
Production https://quickbooks.api.intuit.com, sandbox https://sandbox-quickbooks.api.intuit.com. All entity URLs are /v3/company/{realmId}/... Always send minorversion (75 is current); some fields only exist in later minor versions.

## Entities

### Account
Fields: Id, Name (unique), AcctNum, AccountType (e.g. Expense, Cost of Goods Sold, Income, Bank, Accounts Receivable), AccountSubType, Classification (Asset/Liability/Equity/Revenue/Expense), CurrencyRef, Active. Create requires Name + AccountType (or AccountSubType). You cannot delete accounts, only Active=false via sparse update.

### JournalEntry
Line[] each with Amount, DetailType="JournalEntryLineDetail", JournalEntryLineDetail{PostingType: "Debit"|"Credit", AccountRef{value}, ClassRef, DepartmentRef, Entity{Type, EntityRef} for AR/AP lines}. Debits must equal credits. TxnDate, DocNumber, PrivateNote. AR (Accounts Receivable) lines need Entity=Customer; AP lines need Entity=Vendor. Multicurrency JEs need CurrencyRef + ExchangeRate.

### Invoice
CustomerRef required, Line[] with SalesItemLineDetail (ItemRef, Qty, UnitPrice, TaxCodeRef) or DescriptionOnly. Balance is read-only (unpaid amount). DueDate, TxnDate, DocNumber (unique unless custom txn numbers off), EmailStatus, BillEmail. Voiding: POST /invoice?operation=void with Id+SyncToken.

### Bill
VendorRef required, Line[] with AccountBasedExpenseLineDetail{AccountRef} or ItemBasedExpenseLineDetail{ItemRef}. APAccountRef optional, defaults to the AP account. Pay with BillPayment (CheckPayment or CreditCardPayment, Line linking each Bill by TxnId).

### Payment
CustomerRef + TotalAmt; Line[] each linking to an Invoice via LinkedTxn{TxnId, TxnType:"Invoice"}. Unapplied payments have no Line. DepositToAccountRef or UndepositedFunds.

### Customer / Vendor
DisplayName must be unique across customers+vendors+employees. Balance read-only. Email = PrimaryEmailAddr.Address. Soft-delete via Active=false.

### Item
Type: Inventory | NonInventory | Service | Category. Inventory items require IncomeAccountRef, ExpenseAccountRef (COGS), AssetAccountRef, TrackQtyOnHand=true, QtyOnHand + InvStartDate.

### TaxCode / TaxRate
TaxCode bundles TaxRateRefs (SalesTaxRateList / PurchaseTaxRateList). On invoices set TxnTaxDetail.TxnTaxCodeRef or per-line TaxCodeRef ("TAX"/"NON" in US; real codes elsewhere). Global tax model (non-US) differs from US automated sales tax.

### Class / Department
ClassRef and DepartmentRef are the two dimensions. Enable in company settings first; otherwise refs are silently dropped.

## Queries

### Syntax
GET /v3/company/{realm}/query?query=<urlencoded>. SQL-ish over one entity at a time: SELECT * FROM Invoice WHERE Balance > '0' ORDERBY TxnDate DESC STARTPOSITION 1 MAXRESULTS 100. No JOINs, no GROUP BY, no aggregate except COUNT(*). String literals in single quotes; dates 'YYYY-MM-DD'.

### Operators
=, !=, <, >, <=, >=, LIKE (with %), IN. Filterable fields only (most refs filterable as e.g. CustomerRef = '123'). MetaData.LastUpdatedTime filters power incremental sync.

### Pagination
STARTPOSITION is 1-based; MAXRESULTS caps at 1000. Loop: STARTPOSITION 1, 1001, 2001... until fewer than MAXRESULTS rows return. SELECT COUNT(*) FROM Invoice gives totalCount.

### Reports
GET /v3/company/{realm}/reports/{ReportName}: ProfitAndLoss, BalanceSheet, AgedReceivables, AgedPayables, GeneralLedger, TrialBalance, CashFlow. Params: start_date, end_date, accounting_method, summarize_column_by, customer, vendor, account. Response is a Rows/Columns tree, not entities; walk Rows.Row[].ColData.

### Change data capture
GET /cdc?entities=Invoice,Customer&changedSince=ISO8601 returns changes incl. deletes (status="Deleted") for the last 30 days max.

## Writes and sharp edges

### Create / full update / sparse update
POST /v3/company/{realm}/{entity}. Updates also POST (no PUT): include Id + SyncToken. Full update replaces the entity, omitted fields are CLEARED. Sparse update: include "sparse": true and only changed fields, plus Id + SyncToken.

### SyncToken (optimistic locking)
Every write must carry the CURRENT SyncToken; it increments on each change. A stale token returns error 5010 "Stale object". Recovery: GET the entity, take the new SyncToken, re-apply the change.

### Void vs delete
Transactions: ?operation=void keeps an audit-friendly zeroed txn (Invoice, Payment, etc.); ?operation=delete hard-deletes (Bill, JournalEntry...). Names (Customer/Vendor/Account/Item) cannot be deleted, only Active=false.

### Batch
POST /batch with up to 30 BatchItemRequests (mixed creates/updates/queries). Each item succeeds/fails independently; map results by bId. Good for bulk JE posting; still costs rate limit as one call.

### Idempotency
No idempotency keys. Guard duplicate creates with a pre-query on DocNumber/PrivateNote, and write the platform ref into the audit log immediately.

### Sharp edges
- Error body: Fault.Error[] with code, Message, Detail. 6240 = duplicate DocNumber; 6210 = account type mismatch on a line; 2010 = missing required field.
- Amounts are decimals; do not send more precision than 2dp for GBP/USD.
- DocNumber maxes at 21 chars; duplicates rejected only if "Custom transaction numbers" is off.
- TxnDate defaults to today if omitted; period-end work must always set it explicitly.
- Closing date: writes into closed periods fail or require so the books-closed password; error mentions "books closed".
- Multicurrency cannot be switched off once on; home-currency-only realms reject CurrencyRef.

## Field notes

Scar tissue for an agent posting JournalEntries against QBO. Each section is the symptom, the cause, the fix.

### "Stale Object Error" 5010 on update = you sent an old SyncToken
QBO uses optimistic locking. Every entity carries a SyncToken that increments on EVERY change (including changes made by the QBO UI, bank feeds, or another integration). An update POST with a SyncToken that is not the current one fails with error 5010 "Stale Object Error". You cannot blindly cache the token. Fix: do the read-then-write dance every time. GET the entity (or query it), read its current SyncToken, apply your change to that fresh copy, POST. On 5010, re-GET and retry once; if it 5010s again something else is writing concurrently.

### Updates POST to the same URL as creates, not PUT, and require Id + SyncToken
There is no PUT/PATCH. To update you POST to /v3/company/{realm}/{entity} with the body carrying both "Id" and the current "SyncToken". Omit either and QBO treats it as a create (or rejects it). This is the #1 "why did my update create a duplicate" cause.

### Full update SILENTLY WIPES every field you omit
A normal (non-sparse) update is a full replace: QBO overwrites the stored entity with exactly what you send. Any field you leave out is cleared/reset to default, not preserved. Post a JournalEntry update with only the lines you touched and you blow away DocNumber, PrivateNote, and every other line. Fix: either round-trip the FULL entity (GET, mutate, POST all fields back) or use a sparse update.

### Sparse update: set "sparse": true or omitted fields vanish
Add "sparse": true to the request body to patch only the fields you send; everything omitted is left untouched. Still requires Id + current SyncToken. Caveat for JournalEntry/Invoice: the Line array is generally NOT sparse-mergeable per-line. Sending Line[] replaces the whole line set, so to edit one line you must send the complete intended Line array. Treat sparse as field-level, not line-level.

### minorversion is a query param and pinning it is mandatory
Append ?minorversion=N to every call. It controls the request/response contract; new fields and behaviours only appear at or above the minor version that introduced them, and Intuit deprecates old minor versions over time. If you do not pin it, Intuit's default can shift under you and silently change payload shape. Pin a known-good value and bump deliberately. Current is around minorversion 75 (verify against live docs). Some fields simply do not exist below the minor version that added them, so a "missing field" can mean "minorversion too low," not a bug.

### JournalEntry line: AccountRef + Amount + PostingType are all required
Each Line needs DetailType "JournalEntryLineDetail" and a JournalEntryLineDetail with PostingType ("Debit" or "Credit"), AccountRef.value, plus a positive Amount on the line. Amount is always positive; the side is carried by PostingType, NOT by a signed number. Send a negative Amount and you get a validation error, not a credit. Total Debits must equal total Credits or the post is rejected. AR lines need Entity{Type:"Customer"}; AP lines need Entity{Type:"Vendor"} or QBO rejects the line against those account types.

### Sandbox vs production: different base URL AND a different realm
Sandbox host is https://sandbox-quickbooks.api.intuit.com; production host is https://quickbooks.api.intuit.com. The realmId (company id) from a sandbox connection only works against the sandbox host, and a production realmId only against production. Mixing them returns auth/realm errors, not a clear "wrong environment" message. OAuth tokens are also environment-scoped. The single most common deploy bug: prod credentials pointed at the sandbox URL (or vice versa). Make host + realm + token come from one config block.

### Query returns at most ~1000 rows even without MAXRESULTS; page with STARTPOSITION
The /query endpoint caps a single response. If you omit MAXRESULTS the default page is small (around 100), and MAXRESULTS itself is capped at 1000 (verify against live docs). There is no cursor. Page manually: STARTPOSITION is 1-based, so loop STARTPOSITION 1, 1001, 2001... with MAXRESULTS 1000 until a page returns fewer rows than MAXRESULTS. SELECT COUNT(*) FROM Entity gives the total to size the loop. Assuming one query returns "everything" silently truncates large ledgers.

### 429 / "ThrottleExceeded": back off, honour Retry-After, cap concurrency
QBO throttles per realm. Limits are roughly 500 requests/minute per realm and about 10 concurrent requests per realm per app (verify against live docs). Over either and you get HTTP 429. Respect the Retry-After header if present, otherwise exponential backoff with jitter. The /batch endpoint helps: it counts as one request but carries up to 30 operations, so bulk JE posting through /batch is far cheaper on the rate limit than 30 individual calls. Sandbox limits are lower than production.

### Entity names in the query are case-sensitive PascalCase
The SQL-ish query is NOT SQL-lax about identifiers. FROM JournalEntry works; FROM journalentry or FROM JOURNALENTRY does not. Field names in WHERE/ORDERBY are likewise the exact PascalCase from the entity schema (TxnDate, not txndate). Keywords (SELECT/FROM/WHERE/ORDERBY) are tolerant, but entity and field names are not. A "could not parse"/empty result often traces to casing.

### Writes into a closed period or against reconciled lines are blocked
If the company has a closing/books-closed date set, posting or editing a transaction dated on or before it fails (or demands the closing-date password) and the error mentions books being closed. Separately, lines that have been bank-reconciled cannot be freely edited; changing the account/amount on a reconciled JE line is restricted and warns about breaking the reconciliation. For period-end work, ALWAYS set TxnDate explicitly (it defaults to today if omitted) so a JE does not silently land in the current open period instead of the period you are closing.

### Multicurrency: send transaction-currency Amounts + ExchangeRate, not home amounts
On a multicurrency-enabled realm, a foreign JournalEntry needs CurrencyRef plus ExchangeRate, and the line Amounts are in the TRANSACTION currency, not the home currency. QBO derives the home-currency value from Amount x ExchangeRate (the home figure surfaces in fields like HomeTotalAmt). Send home-currency amounts by mistake and the books post at the wrong value. Conversely, a home-currency-only realm rejects CurrencyRef entirely, and multicurrency cannot be turned off once enabled. Debits must equal credits in the transaction currency.

### No idempotency keys: pre-query before you create
QBO offers no idempotency token. A retried create after a network blip makes a duplicate JE. Guard creates with a pre-query on a unique-ish marker (DocNumber or a tag in PrivateNote) and write the returned QBO Id into your audit log immediately so a retry can detect the prior success. Note DocNumber duplicates are only rejected when "Custom transaction numbers" is off, so DocNumber alone is not a hard uniqueness guarantee.

### Error shape: read Fault.Error[].code, not just the HTTP status
QBO returns a Fault object with an Error array; each entry has a numeric code, a Message, and a Detail. The HTTP status alone (often 400) does not tell you what failed. Branch on the code: 5010 = stale SyncToken (re-read and retry); 6240 = duplicate DocNumber; 6210 = account-type mismatch on a line; 2010 = missing required field; 610 = object not found (verify exact codes against live docs). Log code + Detail, not just "400 Bad Request."

