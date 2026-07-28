# Dynamics 365 Business Central

> Cloud or on premise. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Auth and limits

### OAuth 2.0 client credentials (Entra)
App registration in Microsoft Entra with application permission Dynamics 365 Business Central / API.ReadWrite.All (admin consent required), then the app must also be registered INSIDE BC (Microsoft Entra Applications page, granted user permissions e.g. D365 BUS FULL ACCESS). Token: POST https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token, scope https://api.businesscentral.dynamics.com/.default. Tokens ~60 min; no refresh token needed - just request again.

### URL shape
https://api.businesscentral.dynamics.com/v2.0/{tenantId}/{environment}/api/v2.0/companies({companyGuid})/{resource}. Environment names: production, sandbox, or custom. GET .../companies first to find the company GUID (filter by name).

### Rate limits
Per environment: 600 requests/min sandbox, 6000/min production (and 5 concurrent OData/API calls per user historically); 429 with Retry-After on breach, 504 on long operations. Use $top paging and avoid chatty per-record loops; batch with $batch when bulk-writing.

### API versions
Standard APIs: /api/v2.0. Custom APIs publish under /api/{publisher}/{group}/{version}. ODataV4 web-service endpoints (/ODataV4/Company('name')/...) expose pages - different URL style, same auth.

## Entities

### accounts
GL accounts: id (GUID), number, displayName, category (Assets..Expense), subCategory, blocked, accountType (Posting only is writable-relevant). Read-only via API v2.0 - manage CoA in BC.

### journals + journalLines
journals = general journal batches: id, code, displayName. Lines: POST companies({c})/journals({j})/journalLines with accountType ('G/L Account', 'Customer', 'Vendor', 'Bank Account'), accountId or accountNumber, postingDate, documentNumber, amount (positive=debit, negative=credit), description, dimensions via dimensionSetLines. Balancing: single-line entries need balancingAccountNumber, or add offsetting lines. POST companies({c})/journals({j})/Microsoft.NAV.post posts the whole batch (action endpoint).

### salesInvoices
customerId/customerNumber, invoiceDate, postingDate, dueDate, currencyCode, salesInvoiceLines[{itemId or accountId, lineType Item/Account, quantity, unitPrice, taxCode}]. Draft until the post action: POST .../salesInvoices({id})/Microsoft.NAV.post. After posting it becomes a posted invoice (number changes, id stays addressable); status: Draft -> Open -> Paid. cancel/correct actions exist for posted ones.

### purchaseInvoices
vendorId, vendorInvoiceNumber (required for posting), purchaseInvoiceLines analogous to sales. Post action same pattern.

### payments
customerPayments (under customerPaymentJournals) and vendorPayments: journal-based, appliesToInvoiceId links the open invoice; post the journal to apply.

### customers / vendors
number, displayName, addressLine1.., email, taxRegistrationNumber, paymentTermsId, blocked ('' or reason). number auto-assigned from number series if omitted.

### items
number, displayName, type (Inventory/Service/Non-Inventory), unitPrice, unitCost, inventory (read-only qty), itemCategoryId, taxGroupId.

### dimensions
dimensions + dimensionValues read the configured dimensions (e.g. DEPARTMENT, PROJECT). Transactional lines accept dimensionSetLines [{id (dimension GUID), valueId}]. Default dimensions per master record via defaultDimensions.

### generalLedgerEntries
Read-only posted GL: postingDate, accountNumber, debitAmount, creditAmount, documentNumber - the source of truth for trial-balance style questions (filter + aggregate client-side).

## Queries

### Query options
$filter, $select, $top, $skip, $orderby, $count=true, $expand (e.g. salesInvoices?$expand=salesInvoiceLines). Response {"value":[...]} with @odata.nextLink for server paging - follow it.

### $filter
eq/ne/gt/ge/lt/le, and/or/not, contains(displayName,'ltd'), startswith. GUIDs bare (customerId eq 0863f293-...), dates ISO (postingDate ge 2026-01-01), strings single-quoted. Enum-ish string fields compare as strings (status eq 'Open').

### Deltas
Most v2.0 entities expose lastModifiedDateTime - filter on it for incremental sync.

### Aggregation
No server-side aggregates on standard APIs; pull generalLedgerEntries with a tight $filter + $select and sum locally. For heavy reporting, BC has dedicated report APIs (e.g. trialBalance in the reports group: companies({c})/trialBalances?$filter=dateFilter...) - probe availability per version.

### $batch
POST {env}/api/v2.0/$batch with a JSON batch body (requests[] each with method/url/headers/body, atomicityGroup for transactions). Counts as one HTTP call against limits; required pattern for bulk line inserts.

## Writes and sharp edges

### Create / update / delete
POST creates (201 returns the entity with id + number). PATCH updates and REQUIRES header If-Match: with the current @odata.etag (If-Match: * to force). DELETE drafts only; posted documents need cancel/correct actions.

### ETags
Every entity carries @odata.etag. Stale etag = 409/412; GET fresh, re-PATCH. Cache the etag from the GET you based the change on, never reuse across edits.

### Bound actions
Posting/cancelling are POSTs to Microsoft.NAV.* action endpoints: .../salesInvoices({id})/Microsoft.NAV.post, .../Microsoft.NAV.cancel, journals({id})/Microsoft.NAV.post. 204 on success. After posting a draft invoice, re-GET it: number switches to the posted number series.

### Deferred numbers
documentNumber/number fields are assigned by number series at insert/post; do not invent them. vendorInvoiceNumber on purchase invoices is YOUR external reference and is mandatory before post.

### Error shape
{"error":{"code":"...","message":"... CorrelationId ..."}}. Codes like BadRequest_RequiredParamNotProvided, Internal_EntityWithSameKeyExists, BadRequest_InvalidOperation (posting validation - message carries the BC-side reason like a missing posting group or closed period).

### Sharp edges
- If-Match missing on PATCH = 428 error; this is the #1 integration bug.
- journalLines amount sign carries debit(+)/credit(-); there are no separate debit/credit fields on write.
- Posting setup gaps (no Gen. Bus./Prod. posting group, no number series) surface only at the post action, not at draft creation - always surface the action error verbatim.
- Posted invoices are different resources conceptually: a draft salesInvoice id remains usable but many fields freeze; corrections go through creditMemos or the correct action.
- Dimension writes need the dimension SET lines child, not flat fields; defaultDimensions only affect future documents.
- Client-credentials apps act as a service principal: license-free but permission-limited; if a call 403s, fix the BC-side Entra app permission sets.

## Field notes

### PATCH with no If-Match = blanket reject, not a 409
BC refuses any PATCH/DELETE that omits the If-Match header. This is the #1 integration bug. You do NOT get a "your data is stale" error; you get a hard reject for the missing precondition before BC even looks at the row. The status is 428 Precondition Required (verify against live docs). Fix: GET the entity, read its @odata.etag, send it back as `If-Match: "W/\"...\""`. Use `If-Match: *` only when you deliberately want last-writer-wins.

### 412 on PATCH/DELETE = your etag is stale, re-GET
Every entity carries @odata.etag. When the If-Match value no longer matches the server row (someone else edited it, or you reused a cached etag across two edits) you get 412 Precondition Failed (some versions surface 409). The etag is not a per-session token: it changes on EVERY write. GET fresh, take the new etag, re-apply your change. Never cache an etag past the single PATCH it was read for.

### Posting is a bound action, not a field write
You cannot post a journal/invoice by PATCHing a status field. Posting, cancelling, correcting are POSTs to Microsoft.NAV.* action endpoints on the entity: `.../journals({id})/Microsoft.NAV.post`, `.../salesInvoices({id})/Microsoft.NAV.post`, `.../salesInvoices({id})/Microsoft.NAV.cancel`. Success is typically 204 No Content. Setting `status: "Posted"` via PATCH is rejected (status is read-only / computed).

### Journal -> journal line -> post is the required order
You cannot post lines directly. Flow: (1) the journal batch exists (`companies({c})/journals` - the batch is usually pre-created in BC, you reference it by id/code), (2) POST each line to `journals({j})/journalLines`, (3) POST `journals({j})/Microsoft.NAV.post` to post the WHOLE batch. The post action operates on the batch, not on a single line. After post, the lines are consumed and the GL entries appear in generalLedgerEntries.

### Journal line amount sign IS the debit/credit
There are no separate debit/credit fields on a journal line write. `amount` positive = debit, negative = credit. A batch whose lines don't net to zero (against balancing accounts) will fail at the POST action, not at line insert. Single-line entries need `balancingAccountNumber`/`balancingAccountId`; otherwise add the offsetting line yourself.

### Posting-setup gaps surface at the action, never at draft creation
Missing Gen. Bus./Gen. Prod. posting group, missing number series, a closed/locked accounting period - none of these block the draft POST or the line inserts. They only blow up at the Microsoft.NAV.post call, returning a BadRequest with the real BC-side reason buried in the message (verify exact code against live docs). Always surface the action error verbatim; the message is the only place the actual cause appears.

### The company GUID lives in the URL path, not a header
URL shape: `https://api.businesscentral.dynamics.com/v2.0/{tenantId}/{environment}/api/v2.0/companies({companyGuid})/{resource}`. There is no "X-Company" header equivalent. You must GET `.../api/v2.0/companies` first and pick the GUID (filter by name/displayName) before any real call. Wrong company GUID = you silently operate on the wrong ledger, or 404 if the GUID doesn't exist in that environment. The company GUID differs PER environment - a sandbox copy has different company GUIDs than production.

### Environment name and tenant are both in the path - easy to cross-wire
`{tenantId}` (the Entra tenant GUID) and `{environment}` (a name string: `production`, `sandbox`, or a custom env name) are separate path segments. A common scar: token minted for the right tenant but URL points at `sandbox` while you meant the custom prod env, so you read/write the wrong data with a perfectly valid 200. Pin the environment name explicitly per deployment; do not assume `production`.

### Entra OAuth: app must ALSO be registered inside BC
Client-credentials flow needs two registrations. (1) Entra app with the application permission for Business Central (e.g. API.ReadWrite.All) plus admin consent. (2) The SAME app must be created on BC's "Microsoft Entra Applications" page and granted permission sets (e.g. D365 BUS FULL ACCESS) and set to Enabled. Skip step 2 and the token is valid but every call 403s. A 403 here is a BC-side permission problem, NOT an expired token - do not loop on token refresh.

### Client-credentials runs as a service principal (license-free, permission-limited)
The app acts as a non-interactive principal, no user license consumed, but it can only do what its BC permission sets allow. Token endpoint: `POST https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token`, scope `https://api.businesscentral.dynamics.com/.default`. Tokens last ~60 min and there is no refresh token in client-credentials - just request a new one when it expires.

### 429 carries Retry-After - honor it, don't tighten the loop
On rate-limit breach BC returns 429 with a Retry-After header (seconds). Limits are per-environment and per-app, roughly 600 req/min on sandbox vs 6000/min on production, with a small concurrent-call ceiling historically ~5 (verify exact numbers against live docs - they change). Long-running operations can return 504. Mitigation: $top paging, $batch for bulk writes, avoid per-record chatty loops, and back off on the Retry-After value rather than a fixed sleep.

### /api/v2.0 (standard) vs /api/{publisher}/... (custom) are different URL spaces
Standard Microsoft APIs live under `.../api/v2.0/...`. Custom/extension APIs (an APIpublisher page exposed by an AL extension) live under `.../api/{publisher}/{group}/{version}/...` - different path, often different entity names, same auth and same company-in-path rule. A field you expect on a "customer" may only exist on the custom API's version of that entity. Don't assume v2.0 has every field the customization added; check the custom endpoint.

### Not every BC page is an API - exposure is opt-in
A page existing in the BC client does NOT mean it's queryable over the API. Standard API v2.0 covers a fixed entity set; everything else must be explicitly published either as a web service (ODataV4) or as a custom API page (APIpublisher) by someone with BC access. If an entity 404s, it's probably just not exposed - the fix is in BC (publish the page), not in your URL. Web-service pages live under the different `.../ODataV4/Company('name')/...` style URL and behave more like raw page exposure (different shape, weaker contract) than the curated /api/v2.0 entities.

### Dates and decimals: ISO dates, point decimals, watch the time zone
Date fields are `YYYY-MM-DD`; datetime fields are full ISO 8601 (`...T...Z`). In $filter, dates go bare-ISO and unquoted (`postingDate ge 2026-01-01`), strings single-quoted, GUIDs bare. Decimals use a `.` decimal separator regardless of the BC company's regional format - never send a locale-formatted "1.234,56". postingDate is a DATE (no time); reconciliation off-by-one-day bugs usually come from converting a UTC datetime to local and shifting the calendar date.

### documentNumber / number are assigned by number series - don't invent them
On insert/post, BC fills documentNumber/number from a configured number series. Sending your own can collide (Internal_EntityWithSameKeyExists) or be ignored. Exception: vendorInvoiceNumber on purchase invoices is YOUR external reference and IS required before you can post. After posting a draft, re-GET it: the number flips to the posted number series and the entity is conceptually a different (posted) resource even though the id stays addressable.

### DELETE only works on drafts; posted documents need cancel/correct
You cannot DELETE a posted invoice/journal entry - the ledger is append-only by design. DELETE is for drafts. To reverse a posted sales invoice use the cancel or correct bound action (the latter spawns a credit memo). generalLedgerEntries are strictly read-only; there is no API write or delete for posted GL.

### Error envelope: read the message, the CorrelationId is for support
Errors come back as `{"error":{"code":"...","message":"... CorrelationId ..."}}`. The `code` is a coarse bucket (BadRequest_*, Internal_*); the human-meaningful cause (a missing posting group, a closed period, a validation rule) is in the `message`. Log/surface the message verbatim and keep the CorrelationId - it's what Microsoft support needs, not you.

