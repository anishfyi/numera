# Xero

> Cloud, REST. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Auth and limits

### OAuth 2.0 + PKCE
Authorize at https://login.xero.com/identity/connect/authorize, token at https://identity.xero.com/connect/token. PKCE (S256) works without a client secret for native/local apps. Scopes for accounting work: openid profile email accounting.transactions accounting.settings accounting.reports.read offline_access. offline_access is what yields a refresh token.

### Tenants
One token can cover several orgs. After auth, GET https://api.xero.com/connections lists {tenantId, tenantName}; EVERY API call needs header xero-tenant-id. Forgetting it returns 403 with an empty-ish body.

### Token lifetimes
Access token 30 minutes. Refresh token 60 days, ROTATES on every refresh; always store the newest or the grant dies. Refresh = POST grant_type=refresh_token (+client_id, secret only for non-PKCE apps).

### Rate limits
60 calls/min per tenant, 5000/day per tenant, 5 concurrent. 429 returns Retry-After seconds; honor it. The daily cap is the one long syncs hit; batch with page=, If-Modified-Since, and the 'summaryOnly=true' param on list endpoints.

## Entities

### Accounts
Code (unique, <=10 chars), Name, Type (REVENUE, EXPENSE, DIRECTCOSTS, CURRENT, FIXED, BANK, CURRLIAB, EQUITY...), TaxType, Description, Status (ACTIVE/ARCHIVED). Bank accounts need BankAccountNumber + Type=BANK. SystemAccount accounts (AR, AP, retained earnings) cannot be modified.

### ManualJournals
The journal-entry entity. JournalLines[]: {LineAmount (positive=debit, negative=credit), AccountCode, Description, TaxType, Tracking[]}. Lines must sum to zero. Status: DRAFT or POSTED. Date, Narration required. LineAmountTypes usually NoTax for pure GL moves.

### Invoices
Type ACCREC (sales) or ACCPAY (bills - Xero bills ARE Invoices with Type=ACCPAY). Contact required, LineItems[] {Description, Quantity, UnitAmount, AccountCode, TaxType, ItemCode, Tracking}. Status path: DRAFT -> SUBMITTED -> AUTHORISED -> PAID/VOIDED. AmountDue, AmountPaid read-only. InvoiceNumber unique per org for ACCREC.

### Payments
{Invoice:{InvoiceID}, Account:{Code} (must be a bank or enable-payments account), Date, Amount}. Deleting = PUT status DELETED. Overpayments/Prepayments are separate entities linked via Allocations.

### Contacts
Name unique. IsCustomer/IsSupplier are derived flags, not settable. EmailAddress, Addresses[], Phones[], ContactStatus ACTIVE/ARCHIVED.

### Items
Code unique. SalesDetails{UnitPrice, AccountCode, TaxType} and PurchaseDetails{...}. IsTrackedAsInventory needs InventoryAssetAccountCode + COGSAccountCode; tracked items reject negative stock sales.

### TaxRates / TrackingCategories
TaxRates: TaxType code (e.g. OUTPUT2 20% UK VAT, INPUT2, NONE, ZERORATED), EffectiveRate. TrackingCategories: up to 2 active, each with Options[]; attach per line as Tracking:[{Name, Option}]. These are Xero's dimensions.

### BankTransactions
SPEND/RECEIVE with BankAccount{Code}, Contact, LineItems. Used for direct bank spend/receive money; reconciliation matches statement lines to these or to Payments.

## Queries

### where filter
GET /Invoices?where=Status=="AUTHORISED" AND AmountDue>0 AND Date>=DateTime(2026,01,01). Syntax is .NET-ish: ==, !=, >, <, &&/AND, ||/OR, String.Contains("x"), Date guids as Guid("..."). URL-encode the whole where value. Slow on large orgs; prefer dedicated params (Statuses=, ContactIDs=, InvoiceNumbers=) where offered.

### Paging
page=1.. with default 100/page (some endpoints accept pageSize up to 1000 on newer API versions). Responses with paging include pagination metadata only on some endpoints; otherwise loop until an empty page. order=Date DESC for sorting.

### If-Modified-Since
Header for incremental sync on list endpoints; returns records modified after the timestamp. Combine with page=.

### Reports endpoint
GET /Reports/{Name}: ProfitAndLoss, BalanceSheet, TrialBalance, AgedReceivablesByContact (needs contactID... actually use AgedReceivables summary per contact loops), BankSummary, BudgetSummary. Params: fromDate, toDate, date, periods, timeframe, trackingCategoryID. Response is a Rows tree (RowType Header/Section/Row/SummaryRow) with Cells[].Value; walk it, do not assume column order.

### History
GET /{Entity}/{id}/history shows the change trail; PUT adds a note. Useful for audit answers.

## Writes and sharp edges

### Create vs update
PUT /Entity = create only; POST /Entity = create-or-update (include EntityID to update). POST with a batch array {"Invoices": [...]} writes many; add ?SummarizeErrors=false to get per-element validation results (each element gets StatusAttributeString + ValidationErrors instead of the whole batch failing).

### Updates are full-ish
POST update merges at the top level but REPLACES collections you send (LineItems sent = all lines replaced). To edit one line, send the complete LineItems array back.

### Voiding
Invoices/CreditNotes: POST status VOIDED (only when no payments; remove payments first). ManualJournals: status VOIDED. Payments: DELETE via status DELETED. Nothing is hard-deleted except DRAFTs.

### Validation errors
HTTP 400 with Elements[].ValidationErrors[].Message - messages are precise ("Account code '6015' is not valid"). Surface them verbatim.

### Sharp edges
- The refresh token rotates EVERY refresh; concurrent refreshes race and orphan the grant. Serialize token refresh.
- xero-tenant-id missing = 403, not 401: do not treat as auth-expired.
- Dates: filter DateTime(y,m,d) syntax in where, but JSON payload dates are "YYYY-MM-DD". Responses use /Date(ms)/ in some old endpoints; request Accept: application/json.
- ManualJournal lines: LineAmount sign convention (positive debit, negative credit); a journal with all positives fails with "must sum to zero".
- UK VAT: TaxType must match the account's default or be explicitly valid; locked VAT periods reject writes (error mentions a lock date).
- ACCPAY invoice numbers are NOT unique; do not key on them.
- Attachments are a separate endpoint (PUT /Invoices/{id}/Attachments/{filename} with raw bytes).

## Field notes

Real-world gotchas from building against the Xero Accounting API (api.xro/2.0) -
the failure modes fixtures and the happy-path docs never show. Exact numbers are
flagged "(verify against live docs)" because they drift.

### The refresh token rotates on EVERY refresh - serialize refreshes
Each successful token refresh returns a NEW refresh token and INVALIDATES the one
you sent. If you do not persist the new one immediately, the next refresh fails
and the whole grant dies (forces full re-consent). Worse: two workers refreshing
the same connection at once race - one wins, the other's response carries a token
that is already dead, and whichever writes last can clobber the live token with a
stale one. Fix: serialize refresh per connection (lock / single-flight), refresh
once, broadcast the result. Treat the stored refresh token as a single-use,
mutable secret, not a constant. Access token lives ~30 min, refresh token ~60 days
of inactivity (verify against live docs).

### xero-tenant-id missing = 403, not 401 - do NOT treat as auth-expired
Every Accounting API call needs the `xero-tenant-id` header. Omit it and you get
403 Forbidden (sometimes a near-empty body), NOT 401. A naive client that treats
all 4xx-on-call as "token expired" will burn a refresh, succeed in getting a fresh
token, retry without the header, get 403 again, and loop. 401 = re-auth/refresh;
403 = you are authenticated but not allowed (missing tenant header, wrong scope,
or tenant you no longer have access to). Get the tenant id from
GET https://api.xero.com/connections, which lists {tenantId, tenantName}; one
token can span multiple orgs, so pick deliberately.

### POST is create-or-update, PUT is create-only
PUT /Invoices creates only and will error / duplicate if you resend. POST /Invoices
is create-or-update: include the entity's ID (InvoiceID, etc.) and it updates that
record; omit the ID and it creates a new one. The common bug: you mean to update
but forget to round-trip the ID, so POST silently CREATES a duplicate instead of
editing. Always carry the server-assigned ID back into the update payload.

### Updates REPLACE collections - send the FULL LineItems array
A POST update is not a deep merge of child collections. If you send a `LineItems`
array, Xero replaces ALL line items on that document with exactly what you sent.
Send two of five lines and you have just deleted the other three. To add or edit
one line, GET the document, mutate the full collection in memory, and POST the
complete array back. Same trap applies to other line/option collections (journal
lines, contact addresses/phones, tracking options). Top-level scalar fields merge;
collections you include are authoritative-replace.

### Batch writes fail all-or-nothing unless SummarizeErrors=false
POST a batch array ({"Invoices":[...]}) and by default ONE bad element fails the
whole request and you cannot tell which. Append `?SummarizeErrors=false`: now you
get HTTP 200 with per-element results - valid ones save, each element carries its
own StatusAttributeString (OK / ERROR / WARNING) and ValidationErrors[]. So a
"successful" batch can still contain rejected rows; you MUST inspect each element,
not just the HTTP status. Without the param, assume any 400 nuked the entire batch
and nothing persisted.

### Surface account-code validation messages verbatim
Validation failures come back HTTP 400 with Elements[].ValidationErrors[].Message,
and Xero's messages are precise and actionable - e.g. "Account code '6015' is not
valid" or "The TaxType field is mandatory". Do NOT collapse these into a generic
"write failed"; show the message text to the user/operator. Account-code errors in
particular pinpoint exactly which line and code; mapping them to a vague error
throws away the one piece of info that fixes the problem.

### Rate limits: 60/min, daily cap, concurrency - back off on 429
Per-tenant limits (verify against live docs): ~60 calls/minute, a daily cap
(~5000/day), and a small concurrent-request ceiling (~5). 429 responses include a
`Retry-After` header in seconds - honor it exactly, do not fixed-sleep. The
minute limit is bursty and recovers fast; the DAILY cap is the one that kills long
backfills mid-run with no recovery until reset. Shrink the call count before you
shrink the sleep: page large, use `If-Modified-Since` for incrementals, and
`summaryOnly=true` on list endpoints that support it to avoid per-record fan-out.

### ManualJournal lifecycle: DRAFT / POSTED / VOIDED
A manual journal posts to the GL only at status POSTED; DRAFT is parked and
affects nothing. You cannot edit a POSTED journal back into existence-altering
shape the way you can a draft - to reverse a posted journal you set status VOIDED
(it is not hard-deleted), or post an opposing journal. There is no "delete" for a
posted journal. Also: lines must sum to zero before it will post - sign convention
is positive LineAmount = debit, negative = credit; a journal with all-positive
amounts fails with a "must balance / sum to zero" error. Build the void/reversal
path up front, not after someone posts a wrong journal.

### Three different date formats - know which layer wants which
Dates bite because Xero uses different formats in different places:
- `where` FILTERS use .NET DateTime syntax: `Date>=DateTime(2026,01,01)` (and
  URL-encode the whole where string).
- REQUEST PAYLOAD (JSON body) dates are plain `"YYYY-MM-DD"` strings.
- Some older/legacy endpoints RETURN `/Date(1623456000000)/` (epoch ms, sometimes
  with a timezone offset) instead of ISO. Always send `Accept: application/json`,
  and parse the millisecond form defensively rather than assuming ISO 8601.
Mixing these up (e.g. putting `"YYYY-MM-DD"` inside a where, or feeding the
`/Date()/` blob straight into a date parser) is a classic source of empty result
sets and crashes.

### Everything is UTC - convert at the edges, not in the ledger
Xero stores and returns timestamps in UTC. `If-Modified-Since` is interpreted as
UTC. If you pass a local-time cutoff for an incremental sync you will silently
miss or re-pull records around the offset boundary. Convert to UTC on the way out,
convert to the org's locale only for display. Do not assume the org's timezone
equals the server's.

### TaxType must be valid for the org AND consistent with the account
A write can fail not because the TaxType code is malformed but because it is not
enabled/valid for THIS organisation or it conflicts with the account's default tax
treatment. Tax codes are org-specific (the standard UK set differs from AU/NZ/US,
and orgs can have custom rates). Pull the org's TaxRates and resolve codes against
them rather than hardcoding. Locked VAT/tax periods also reject writes dated into
the locked range - the error names a lock/end-of-year date; that is a period-lock,
not a bad payload, so do not retry it as-is.

### Tracking categories are Xero's only "dimensions" - max two
Xero has no departments/classes/locations/projects as first-class GL dimensions in
the Accounting API. The analog is TrackingCategories: at most TWO active
categories per org, each with its own Options list. Attach them per LINE as
`Tracking:[{Name, Option}]` (on invoice lines, journal lines, bank transaction
lines) - not at the document header. The Name and Option must already exist and be
active; you cannot invent an option inline on a transaction. Two is a hard ceiling
(verify against live docs), so multi-dimensional cost analysis often has to be
modelled outside Xero or collapsed into those two slots.

### Branding themes are referenced, not created on the fly
Invoice/quote PDF appearance is driven by BrandingThemes, which are configured in
the Xero UI, not via the write API. On an invoice you may set BrandingThemeID, but
it must be an EXISTING theme's GUID - you cannot create or edit a branding theme
through the API. Caching a stale BrandingThemeID after the org reworks its themes
silently falls back to the default. Resolve the GUID from
GET /BrandingThemes per org rather than hardcoding.

### ACCPAY invoice numbers are NOT unique - never key on them
Bills are Invoices with Type=ACCPAY, and unlike ACCREC (sales) invoice numbers,
supplier invoice/reference numbers are not enforced unique - two different bills
can share the same number. Dedupe and idempotency MUST key on the Xero InvoiceID
(GUID), never on InvoiceNumber/Reference. Keying on the number merges or skips
legitimately distinct bills.

### Attachments live on a separate endpoint with raw bytes
You cannot attach a file inside the entity payload. Attachments go to
PUT /{Entity}/{id}/Attachments/{filename} with the raw file bytes in the body and
the correct Content-Type for the file (not application/json). Expecting the main
POST to carry an attachment, or sending the file base64-wrapped in JSON, fails.
Create/update the entity first, get its ID, then push the attachment as a second
call.

### Nothing is hard-deleted except DRAFTs
Authorised/posted documents are never destroyed - the lifecycle terminus is a
status (VOIDED for invoices/journals, DELETED for payments via status, ARCHIVED
for contacts/accounts). Only DRAFT documents can be truly deleted. So "delete this
invoice" in your domain logic must map to the right status transition, and a
voided record still EXISTS in lists and history (filter it out with Statuses=). A
DELETE verb on a non-draft will not behave like a removal.

