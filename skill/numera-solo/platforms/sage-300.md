# Sage 300

> On premise / hosted. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Auth and limits

### Endpoint shape
REST/OData v4 web API hosted by IIS next to the Sage 300 install (on-prem or partner-hosted): https://server/Sage300WebApi/v1.0/-/{COMPANY}/{Resource}. The "-/" segment is the tenant placeholder on single-tenant installs. {COMPANY} is the company database id (e.g. SAMINC).

### Auth
HTTP Basic with a Sage 300 user that has Web API security authorization (assign the SAGE 300 WEB API security group per module). No tokens, no refresh - send credentials each call over HTTPS. Self-signed certs are common on-prem; allow a verify_ssl=off toggle but warn.

### Availability
The web API must be installed/enabled (web screens feature). GET {base}/ returns the OData service document listing resources - use it as the connection test and capability probe; modules not licensed/activated simply do not appear.

### Limits
No published rate limits; the bottleneck is the app server. Keep $top modest (<=1000), avoid unbounded $expand, serialize writes. Long imports: chunk into batches.

## Entities

### GLAccounts
UnformattedAccount (key, no separators), Description, AccountType (e.g. IncomeStatement/BalanceSheet), NormalBalance, Status, structure/segment fields. Account segments matter for posting validation.

### GLJournalBatches (journal entries)
Batch-oriented like the desktop: create a batch with JournalHeaders[] each containing JournalDetails[] {AccountNumber, TransactionAmount (debit positive / credit negative), JournalDate, Description, Reference}. Header must balance. Batches post via the PostGLBatch process or remain open for review. BatchNumber/EntryNumber assigned by the system.

### ARInvoiceBatches / APInvoiceBatches
Same batch pattern: ARInvoiceBatches{ARInvoices[{CustomerNumber, DocumentType Invoice/CreditNote, DocumentDate, ARInvoiceDetails[{RevenueAccount, ExtendedAmountIncludingTax,...}]}]}. AP mirrors with VendorNumber. Documents get document numbers on add; posting is a separate batch action.

### ARCustomers / APVendors
CustomerNumber/VendorNumber (key), CustomerName/VendorName, address fields flat on the resource, CurrencyCodeId, AccountSetCode (controls the control account), OnHold, Status.

### ARReceiptBatches / APPaymentBatches
Receipts/payments also batch-shaped: header + details applying amounts to documents (ApplyDocumentNumber). MiscellaneousReceipts for non-AR cash.

### ICItems
ItemNumber, Description, AccountSetCode, units of measure list, costing fields. Inventory transactions (receipts/shipments/adjustments) are separate IC batch resources.

### TaxGroups / TaxAuthorities / TaxClasses
Tax setup read mostly; documents carry TaxGroup + per-line tax class indices. Let the ERP calculate tax: send TaxCalculationMethod default and review returned tax buckets.

## Queries

### Query options
Standard OData v4: $filter, $select, $orderby, $top, $skip, $count=true, $expand for child collections (e.g. GLJournalBatches?$expand=JournalHeaders($expand=JournalDetails)). Responses: {"@odata.context":..., "value":[...]}.

### $filter syntax
eq, ne, gt, ge, lt, le, and, or, not; functions contains(Field,'x'), startswith, endswith. Strings in single quotes; dates as ISO 8601 (DocumentDate ge 2026-01-01T00:00:00Z) - some date fields are Edm.DateTimeOffset, some plain strings; check $metadata when a filter 400s.

### Paging
Server may impose a page size and return @odata.nextLink; follow it. Otherwise loop $top/$skip. Always $orderby a stable key when paging.

### $metadata
GET {base}/$metadata returns the EDMX schema for every exposed resource - the ground truth for field names (they differ subtly from desktop labels). Probe it when unsure rather than guessing.

### Reading the GL
Posted GL detail: GLPostedTransactions / GLTransactionDetails style resources vary by version; if absent, read GLJournalBatches with Posted status filter, or use GLAccounts fiscal-set fields for period balances (e.g. fiscal year/period net change fields on the account resource).

## Writes and sharp edges

### Create / update / delete
POST {Resource} with the nested batch JSON creates batch+entries in one call. PATCH {Resource}({key}) sparse-updates - composite keys look like GLJournalBatches(BatchRecordType='JE',BatchNumber=123). DELETE only for unposted batch documents and non-referenced masters.

### Posting
Creating a batch does NOT post it. Posting = invoking the process resource (e.g. POST .../GLPostGLBatches style action or setting the batch ReadyToPost then running post) - exact action name varies by version; check the service document. Until posted, the GL does not reflect the entries: tell the user a batch number was created and whether it was posted.

### Validation
The API runs the same business rules as the desktop views; errors return 400/422 with a Sage message collection (often nested in error.innererror). Messages reference desktop field names. Common: unbalanced journal header, closed fiscal period, invalid account segment combination, inactive account.

### Sharp edges
- TransactionAmount sign convention carries debit/credit (positive=debit). There is no separate credit field on GL details.
- Fiscal calendars: dates must fall in an existing, unlocked fiscal period; otherwise "fiscal period does not exist/locked".
- Optional fields (custom fields) appear as child collections; write them as nested arrays.
- Number formats: account numbers unformatted (no dashes) in UnformattedAccount; formatted variants are display-only.
- Web API user licensing consumes a Sage 300 user seat while sessions are open... keep calls short-lived.
- Hosted/on-prem version skew is real: feature-detect via $metadata, never assume a resource exists.

## Field notes

Real-world scar tissue for the Sage 300c web API (REST/OData v4). Distilled
from integration work, partner forums and version-skew pain - the edge cases
the happy-path docs skip. Sage 300 is batch-and-post ERP wearing an OData
jacket; most surprises come from the desktop business logic underneath, not the
HTTP layer. Where an exact name/code/number is uncertain it is flagged
"(verify against live docs)".

### A created batch is NOT in the GL - posting is a separate step
The biggest mistake. POST to GLJournalBatches creates an OPEN batch and returns
a BatchNumber. That batch is invisible to the ledger, trial balance and reports
until it is POSTED. Posting is a distinct operation, not a flag you flip on
create. So the workflow is three acts: (1) create the batch, (2) add/confirm its
entries balance, (3) run the post process. If you stop after step 1 the user
sees "nothing happened" while a pile of unposted batches accumulates. Always
report back BOTH the batch number AND whether it was actually posted.

### How posting is triggered (and why the name varies)
Posting is invoked through a process/action resource, not by PATCHing the batch
to "posted". On many versions you mark the batch ready-to-post then call a
GL batch posting process resource (name like GLPostBatches / PostBatches);
the exact resource and payload differ across releases (verify against live
docs / the service document). Posting can also partially succeed: a multi-entry
batch may post some entries and reject others, leaving the batch in an ERROR
state with a posting journal/error report. Don't treat HTTP 200 on the post
call as "every entry is now in the GL" - read back the batch status.

### Posting errors surface at POST time, not create time
Sage validates lightly on create (does the header balance? do fields parse?)
but enforces the heavy business rules at POST. So "closed fiscal period",
"account does not allow posting", "inactive account", "missing required
optional field", "currency not authorized" all blow up when you post, after
the batch already exists. Build your flow to expect a created-but-unpostable
batch and to read the post error report, not just the create response.

### $metadata is the ground truth; field names are NOT the desktop labels
GET {base}/$metadata returns the EDMX schema for every exposed entity. The web
API field names differ subtly from the desktop UI captions and from what users
say (e.g. accounts live under UnformattedAccount, not "Account No."). When a
$filter or POST 400s on an unknown property, stop guessing and read $metadata.
It is also the only reliable capability probe: modules that are unlicensed or
not activated simply do not appear, and resources vary by version.

### "It works in the desktop but there's no API for it"
The web API does NOT expose the whole product. Large swathes are screen-bound:
many setup screens, several period-end/close routines, some inquiry screens,
and various process windows have no OData resource at all - or expose read but
not the action you need. Confirm a capability exists in $metadata/the service
document before promising it. When it isn't there, the honest answer is "that
operation is screen-bound in this version" (verify against live docs for your
exact release), not a workaround that posts garbage.

### Version/edition skew is the rule, not the exception
On-prem and partner-hosted installs run different Sage 300 versions, different
product updates, and different licensed modules. A resource, field, or post
action that exists on one tenant is genuinely absent on another. Never hardcode
"this entity exists" - feature-detect via the service document ($base/) and
$metadata at connection time and degrade gracefully. The "-/" tenant segment
and {COMPANY} database id in the URL also mean the same code points at totally
different schemas per company db.

### GL detail line sign: one amount field, sign carries debit/credit
GL journal detail lines have a single TransactionAmount where positive = debit
and negative = credit (verify the exact field name against $metadata for your
version). There is no separate debit/credit column. The journal HEADER must net
to zero. A common bug: summing magnitudes and forgetting the sign, producing an
"out of balance" rejection at post. Round to the GL currency's decimal places
before summing - floating-point drift causes spurious imbalances.

### Required fields on a GL batch entry (the ones that bite)
At minimum a usable journal detail needs the account (UnformattedAccount), the
signed TransactionAmount, and a date that falls in an existing, unlocked fiscal
period; the header needs a source/description and to balance. Source code,
reference and entry description are frequently required by the desktop rules
even when the schema marks them optional - the API enforces the same view
validation. If a post fails citing a field you didn't send, it's usually one of
these (verify the exact required set against $metadata + your company's setup).

### Fiscal period must exist AND be unlocked - and two layers can disagree
A posting date must land in a fiscal period that (a) exists in the GL fiscal
calendar and (b) is open/unlocked for that module. The Common Services fiscal
calendar and the GL module's period status are separate gates; one can show a
period open while the other locks it. When a "period locked / does not exist"
error contradicts what you see, check both layers. Posting into a future or
not-yet-created year fails outright.

### Account segments and the optional-fields trap
Accounts are segmented (the segment structure defines the account format).
$filter/POST want the UNFORMATTED account (no separators); the formatted,
dashed variant is display-only. Posting validates the segment combination - an
otherwise-valid account can be rejected for an invalid segment combo or because
the account/segment isn't authorized for the source. Separately, "Optional
Fields" (Sage's user-defined fields) are NOT flat properties - they hang off
the entity as a CHILD COLLECTION and must be written as a nested array. Some
accounts/transactions REQUIRE specific optional fields by setup; omit them and
the post fails for a "missing field" you can't see on the main object.

### OData quirks that 400 you
- $top: keep it modest. The server may impose its own page size and return
  @odata.nextLink regardless of your $top - follow the link rather than
  trusting one page (verify the cap against live docs).
- $skip-based paging is fragile; always pair it with a stable $orderby on a key
  or rows shift between pages.
- Dates: some fields are Edm.DateTimeOffset (need full ISO 8601 with offset,
  e.g. 2026-01-01T00:00:00Z) and some are plain strings/Edm.Date. A filter that
  400s on a date is usually the wrong literal type - check $metadata.
- $expand: deep nested expands (batch -> headers -> details) are supported but
  expensive and can time out on big batches; page the parent and expand
  narrowly instead of pulling everything at once.
- String literals are single-quoted; escape an embedded quote by doubling it
  ('O''Brien'). Composite keys in the URL look like
  GLJournalBatches(BatchType='GL',BatchNumber=123) (verify exact key names).

### Reading posted GL balances is version-dependent
There isn't one clean "give me the posted ledger" call across all versions.
Posted transaction detail resources (names vary - GLPostedTransactions /
GLTransactionDetail style) may or may not be exposed; when absent, read period
net-change / fiscal-set fields off the GLAccounts resource for balances, or read
GLJournalBatches filtered to a posted status for detail. Don't assume the posted
detail entity exists - probe $metadata (verify against live docs for your
release).

### Auth: Basic only, and the seat/session cost
Auth is HTTP Basic with a Sage 300 user that has Web API security authorization
(the user needs the right security groups per module, or calls 403 even with
valid credentials). No OAuth, no tokens, no refresh - credentials go on every
call, so HTTPS is mandatory. On-prem self-signed certs are common; gate any
verify-SSL-off toggle behind a loud warning. The web API consumes a Sage 300
LANUM/user seat while a session is active - long-lived or highly concurrent
clients can exhaust seats and lock out humans. Keep calls short-lived.

### 403 vs 401 - it's usually authorization, not bad credentials
With valid Basic credentials you can still get 403 because that user lacks the
Web API security group for the module/operation, or the company db isn't one
they're permitted on. Don't treat 403 as "password expired / re-auth" - it's a
Sage security setup problem fixed in the desktop security screens, not by
rotating the credential.

### Concurrency: serialize writes, expect lock errors
No published rate limit - the bottleneck is the IIS app server and the
underlying SQL/Pervasive db, plus the seat cap above. Concurrent posts to the
same batch/period or to shared masters can hit record-lock / "in use" errors
that look transient. Serialize writes per company, post batches one at a time,
and treat lock errors as retry-after-backoff, not hard failures. Long imports:
chunk into multiple batches rather than one giant batch that locks for minutes
and is all-or-nothing on post.

### Errors are nested Sage message collections, not flat strings
Validation failures return 400/422 with the real reason buried in a nested
error structure (commonly under error.innererror as a message collection) and
phrased in DESKTOP terms / field names. Surface the innermost messages to the
user, not just "400 Bad Request". The same message catalog the desktop shows is
what comes back - "Document already exists", "Account is inactive",
"Batch is not balanced" etc. (verify exact wording against live docs).

### AR/AP/IC follow the same batch-then-post shape
GL is not special: AR invoices, AP invoices, AR receipts, AP payments and IC
transactions are all batch-shaped - create a batch with nested documents, then
post the batch as a separate step. Same trap as GL: an unposted AR invoice
batch hasn't hit the customer's account or the GL. Let the ERP calculate tax
(send the tax group / default calculation method and read back the computed
buckets) rather than pushing your own tax amounts, which the views may override
or reject.

