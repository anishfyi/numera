# Oracle NetSuite

> Cloud, SuiteTalk / REST. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Auth and limits

### Token-Based Authentication (TBA)
OAuth 1.0a signing with HMAC-SHA256 (SHA1 retired). Four credentials: consumer key/secret (Integration record) + token id/secret (Access Token for a user+role). The Authorization header realm is the ACCOUNT ID in upper case with underscores (e.g. 1234567_SB1). Role needs REST Web Services + relevant record permissions; "Log in using Access Tokens" on the integration.

### OAuth 2.0 alternative
Auth-code grant against https://{account}.app.netsuite.com/app/login/oauth2/authorize.nl, token at .../services/rest/auth/oauth2/v1/token; access tokens 60 min, refresh 7 days (rotates). TBA is simpler for a local tool: no browser, no expiry.

### Hosts
REST records: https://{accountid}.suitetalk.api.netsuite.com/services/rest/record/v1/ - account id in the host is lower case with underscores replaced by hyphens (1234567-sb1). SuiteQL: /services/rest/query/v1/suiteql.

### Concurrency governance
Account-wide concurrency limit (base 5 for most tiers + per-license extras). Exceeding returns 429; queue and retry. Each REST call also consumes per-integration concurrency. Long SuiteQL queries: paginate, do not raise limit.

## Entities

### journalEntry
Body: subsidiary (required in OneWorld), trandate, memo, line: {items: [{account:{id}, debit OR credit, memo, department, class, location, entity}]}. Debits must equal credits. approved=true posts directly if the role allows; otherwise lands pending approval. Intercompany JEs are a separate record type (intercompanyJournalEntry) with toSubsidiary.

### account
acctnumber, acctname, accttype (enum: _expense, _income, _otherCurrentAsset, _costOfGoodsSold, _accountsReceivable...), subsidiary list, parent for hierarchies. Cannot delete once used; set isinactive.

### invoice / vendorBill
invoice: entity (customer), trandate, item.items[] {item:{id}, quantity, rate, amount, taxcode} or expense-style lines on vendorBill: expense.items[] {account, amount, department, class, location}. status read-only (e.g. Open, Paid In Full). vendorBill: entity = vendor.

### customerPayment / vendorPayment
customerPayment: customer, payment (amount), apply: {items:[{doc: invoice internal id, apply: true, amount}]}. Unapplied portions sit on the customer. vendorPayment analogous against vendorBills.

### customer / vendor
companyname or firstname/lastname (isperson), subsidiary required in OneWorld, entityid unique. Addresses are sublists (addressbook.items[].addressbookaddress).

### inventoryItem / serviceItem / nonInventoryItem
itemid unique, taxschedule required (US), incomeaccount/expenseaccount/assetaccount. Inventory adjustments via inventoryAdjustment record, not item updates.

### Dimensions
department, class (classification), location: standard segments on every line. Custom segments appear as custseg_ fields. Subsidiary is the legal-entity dimension (OneWorld).

### Custom fields
custbody_ (transaction body), custcol_ (line), custentity_ (entity). They appear directly as JSON properties.

## Queries

### SuiteQL
POST /query/v1/suiteql {"q": "SELECT ..."} with header Prefer: transient. SQL-92-ish over the analytics schema: transaction, transactionline, transactionaccountingline, account, customer, vendor, item, subsidiary, department, classification, location, entity. JOINs allowed; aggregates allowed.

### Key tables for accounting
- transaction T: id, tranid, trandate, type ('Journal','CustInvc','VendBill','CustPymt'...), entity, postingperiod, memo
- transactionline TL: transaction, id, item, account... (mainline = 'F' for real lines; old boolean semantics: mainline 'T' is the header)
- transactionaccountingline TAL: transaction, transactionline, account, amount, debit, credit, posting='T'
GL queries join T -> TAL -> account. Example aged AR: SELECT t.tranid, t.trandate, t.foreigntotal - NVL(t.foreignamountpaid,0) open FROM transaction t WHERE t.type='CustInvc' AND t.status='CustInvc:A'.

### Pagination
Response: items[], hasMore, links[rel=next], totalResults. Use ?limit=1000&offset=0 then follow offset += limit while hasMore. FETCH FIRST n ROWS ONLY also works inline.

### Record-level queries
GET /record/v1/{type}?q=email IS "x@y.com" supports a tiny filter grammar (field op value, AND/OR; ops EQUAL, IS, CONTAIN, GREATER_THAN...); easier to use SuiteQL for anything non-trivial. GET /record/v1/{type}/{id} returns one record; sublists come as links unless ?expandSubResources=true.

### Dates and enums
SuiteQL dates: TO_DATE('2026-05-31','YYYY-MM-DD') or BUILTIN functions. Type/status values are internal codes; discover with SELECT DISTINCT type FROM transaction.

## Writes and sharp edges

### Create / update / delete
POST /record/v1/{type} creates (204 + Location header containing the new internal id - parse it, the body is empty). PATCH /record/v1/{type}/{id} sparse-updates: send only changed fields; sublist items REPLACE when you send the sublist (use line "id" to target existing lines). DELETE removes if the record allows it; most posted transactions need void/reverse instead.

### Voiding and reversing
Direct void exists only where the UI offers it (depends on "Void Transactions Using Reversing Journals" preference). Safest API pattern: create a reversing journalEntry (or set reversaldate on the original JE). Do not DELETE posted transactions in a closed period.

### Posting periods
postingperiod derives from trandate unless set. Closed/locked periods reject writes with INVALID_KEY_OR_REF or "period closed"; reclass into the next open period or have an admin reopen.

### Subsidiary discipline (OneWorld)
Entity, accounts and lines must belong to the same subsidiary (or be intercompany). Mismatches error INVALID_KEY_OR_REF, which also fires for plain wrong internal ids - check both.

### Error shape
HTTP error body: o:errorDetails[] {detail, o:errorCode}. Common: USER_ERROR (validation, message is human-readable), INVALID_KEY_OR_REF, INSUFFICIENT_PERMISSION (role lacks the record permission), CONCURRENCY_LIMIT_EXCEEDED.

### Sharp edges
- 204-with-Location on create surprises everyone: the new id is ONLY in the Location URL.
- Field names are all lower case in REST JSON (trandate, not tranDate).
- Select fields take {"id": "123"} objects, not bare ids.
- Booleans on legacy tables are 'T'/'F' strings in SuiteQL.
- approvalstatus on JEs/bills depends on approval-routing features; creating as approved needs permission.
- Sandbox account ids: 1234567_SB1 - remember hyphen form in the host, underscore form in the realm.

## Field notes

Scar tissue from real integrations: the failure mode, the cause, the fix.
The edge cases fixtures never contain. Exact numbers tagged "(verify against
live docs)" because tiers and limits drift.

### TBA returns 401 INVALID_LOGIN_ATTEMPT but creds are right: it's the signature base string
OAuth 1.0a signing is unforgiving and the error never tells you which part is wrong.
Build the base string as: METHOD + "&" + percent-encode(URL) + "&" + percent-encode(sorted, encoded params). Most-common breakages, in order seen:
- Query params (e.g. ?limit=1000&offset=0) MUST be folded into the signature param set together with the oauth_* params, all sorted together AFTER encoding. Forget the query string and every paginated call past page 1 fails signing.
- Percent-encoding must be RFC 3986 (uppercase hex, encode `!*'()`); language/library default encoders that leave those raw produce a wrong signature.
- The URL in the base string is scheme+host+path only - strip the query, do not lowercase the path, do not include a trailing port.
- Sign with HMAC-SHA256 (SHA1 retired); signing key is `consumerSecret&tokenSecret` (the trailing `&` is required even though token secret is present).

### realm in the Authorization header is the ACCOUNT ID, not a token, and it is case/format-sensitive
realm = the account id in UPPER case with the sandbox suffix joined by an underscore: `1234567_SB1` (prod is just `1234567`). Wrong realm = 401 even with a perfect signature. Do not confuse it with the host form of the account id, which is LOWER case with the underscore turned into a hyphen: host `1234567-sb1.suitetalk.api.netsuite.com`, realm `1234567_SB1`. Same account, two spellings, used in two places.

### nonce/timestamp rejection: clock skew and reuse
oauth_timestamp is Unix seconds; if the box clock drifts more than the allowed window (a few minutes, verify against live docs) you get 401. oauth_nonce must be unique per request - reusing one (e.g. caching a whole signed header for retries) trips replay protection. Regenerate nonce + timestamp + signature on EVERY attempt, including retries after a 429.

### Wrong host = 404/handshake failure, not an auth error
Two distinct base URLs, both account-scoped:
- Records: `https://{accountid}.suitetalk.api.netsuite.com/services/rest/record/v1/`
- SuiteQL: `.../services/rest/query/v1/suiteql`
The legacy `{accountid}.app.netsuite.com` host is the UI/SuiteScript domain, not REST. Hitting the wrong host looks like a network/SSL problem, not 401 - don't chase auth when the host is wrong.

### SuiteQL vs record REST: pick by read-vs-write and by join-need
- SuiteQL (POST /query/v1/suiteql) is READ-ONLY. It cannot create/update anything. Use it for any multi-record read, anything needing JOINs/aggregates, or GL-style transaction reads (transaction -> transactionaccountingline -> account).
- Record REST (GET/POST/PATCH/DELETE /record/v1/{type}) is the only path for WRITES, and for fetching one record with its sublists. Its `?q=` filter grammar is tiny (field op value, AND/OR) - anything non-trivial, switch to SuiteQL for the read and then PATCH by internal id.
- Common trap: trying to "update via SuiteQL" - there is no such thing. Read with SuiteQL, mutate with record REST.

### SuiteQL needs the Prefer: transient header or it errors
POST /query/v1/suiteql with body {"q":"SELECT ..."} REQUIRES request header `Prefer: transient`. Omit it and the call fails (often a 400-class error that doesn't obviously say "you forgot a header"). This catches people who reuse their record-REST client for SuiteQL.

### SuiteQL paging: 1000-row hard cap, follow offset until hasMore=false
A SuiteQL response returns at most 1000 rows per page (verify against live docs). Response carries items[], hasMore, totalResults, and links[] with rel "next"/"last". Page with `?limit=1000&offset=N`, then offset += limit while hasMore is true (or follow the rel=next link). Pitfalls:
- `FETCH FIRST n ROWS ONLY` inside the SQL works for capping, but for full extracts use limit/offset paging, not a giant FETCH.
- ORDER the query (e.g. by id) before offset paging; without a stable sort, offset paging can skip or duplicate rows as data shifts.
- totalResults can be expensive/absent on big sets - trust hasMore as the loop condition, not a precomputed count.

### OneWorld: a journal needs the RIGHT subsidiary, and every line must agree
In OneWorld, journalEntry.subsidiary is required, and the accounts, entities and segment values on each line must belong to that subsidiary (or be valid intercompany). Mismatch errors as INVALID_KEY_OR_REF - which is the SAME error you get for a plain wrong internal id, so check both: is the id real, AND does it belong to this subsidiary? Cross-subsidiary postings are NOT a normal JE: use intercompanyJournalEntry (with toSubsidiary), not a single JE spanning two legal entities.

### Book-specific posting (Multi-Book): the JE may need a book, and adjustment-only books reject primary postings
With Multi-Book Accounting, an account/book combination matters. Adjustment-only books accept entries via the book-specific adjustment journal, not the ordinary primary-book JE; posting a normal JE expecting it to hit a secondary book silently lands only in the primary book (or errors). If amounts "don't appear" in a secondary book's reports, confirm whether the entry type targets that book at all. (Exact field/record names vary by account config - verify against live docs.)

### externalId is your idempotency key; internalId is NOT stable across environments
- internalId is NetSuite's own numeric id, assigned on create, unique per record type, and DIFFERENT between sandbox and production (and after a sandbox refresh). Never hardcode internalIds across environments.
- externalId is YOUR id, set by you on create. Use it as the idempotency key: address records by `/record/v1/{type}/eid:{externalId}` (the `eid:` prefix selects by external id). Set a deterministic externalId on every create so a retried POST upserts the same record instead of duplicating it.
- externalId is unique per record TYPE, not globally - the same string on a customer and an invoice is fine.

### Create returns 204 with an empty body: the new internal id is ONLY in the Location header
POST /record/v1/{type} succeeds with HTTP 204 and NO body. The new record's internal id is in the `Location` response header URL (`.../record/v1/{type}/{id}`) - parse it out. Code that reads the JSON body for the id gets nothing and thinks the create failed.

### PATCH is sparse, but sending a sublist REPLACES it
PATCH /record/v1/{type}/{id} updates only the fields you send (sparse) - good. BUT if you include a sublist (e.g. line items), the sublist you send REPLACES the existing one. To edit one existing line, fetch the lines, include them all, and target the one to change by its line `id`. Send a partial sublist and you silently drop the lines you omitted.

### Role / field-level permissions cause SILENT omissions, not errors
This is the nastiest NetSuite gotcha. A role lacking permission on a field or sublist does not always 403 - on reads, the field is simply ABSENT from the response (looks like null/empty data); on writes, the field is silently ignored. A "missing" custbody value or a JE that "won't set department" is often a role permission problem, not a bug in your payload. Test integration role permissions against an admin pull of the same record to spot omitted fields. The integration role needs REST Web Services permission plus explicit permission on every record type AND the relevant fields/segments.

### INSUFFICIENT_PERMISSION vs INVALID_KEY_OR_REF: read both, they overlap
Error body shape: `{"o:errorDetails":[{"detail":"...","o:errorCode":"..."}]}`. INSUFFICIENT_PERMISSION = role lacks the record/feature permission (fix the role, not the payload). INVALID_KEY_OR_REF = bad internal id OR a subsidiary/segment mismatch OR a referenced record the role can't even see (so a permission gap can MASQUERADE as a bad reference). When an id you believe is valid throws INVALID_KEY_OR_REF, check role visibility before assuming the id is wrong.

### Governance and concurrency: it's per-ACCOUNT, and you hit 429 long before you expect to
Concurrency is governed account-wide, not per-integration: a base allowance (around 5 on many tiers, plus per-license/SuiteCloud-Plus add-ons - verify against live docs) is SHARED across all integrations, users and scripts hitting that account. So your service can 429 because someone ELSE's job is running. On 429 (often CONCURRENCY_LIMIT_EXCEEDED): back off and retry with a NEW nonce/timestamp/signature; do not parallelise harder. Serialize where you can; long SuiteQL extracts should paginate sequentially rather than fan out.

### Dates and times: trandate is date-only, datetimes are in the account/user timezone
- Transaction dates (trandate) are date-only; the posting period derives from trandate unless you set postingperiod explicitly. A date one day off can post into the wrong (or a closed) period.
- Datetime fields are interpreted in a timezone tied to the account / token user's preference, NOT UTC. A "lastmodifieddate > X" incremental sync silently drifts if you compare against UTC; align your boundary to the account timezone or you'll re-pull or miss records around midnight.
- In SuiteQL, build dates with TO_DATE('2026-05-31','YYYY-MM-DD'); type/status values are internal codes (e.g. transaction.status like 'CustInvc:A'), so discover them with SELECT DISTINCT, don't guess.

### Custom fields: custbody_/custcol_/custentity_ and they appear as plain JSON properties
- custbody_<name> = transaction BODY field, custcol_<name> = transaction LINE field, custentity_<name> = entity field. Custom segments are custseg_<name> (or custcol/custbody depending on placement).
- In REST JSON they appear as ordinary top-level (or per-line) properties under their script id, lower-cased. You must know the exact script id - there is no discovery in the payload; pull the field definition (or read it off an admin record) to learn the name.
- Standard fields are all lower case in REST JSON (trandate not tranDate), and select/reference fields take an OBJECT `{"id":"123"}`, never a bare id - a bare id on a select field is a common silent or USER_ERROR failure.

### Booleans bite differently in SuiteQL vs REST
In SuiteQL over the analytics schema, legacy boolean columns come back as 'T'/'F' STRINGS (e.g. mainline, posting, isperson), not true/false. In record REST JSON the same concepts are real JSON booleans. Code that filters `WHERE posting = true` in SuiteQL silently matches nothing - use `= 'T'`.

### Posted transactions don't DELETE - void or reverse, and never in a closed period
Most posted transactions reject DELETE; you void (where the UI/preference allows) or post a reversing journalEntry / set reversaldate on the original. Writing into a CLOSED or LOCKED period fails at post time with a period error (INVALID_KEY_OR_REF or a "period closed" message) - reclass into the next open period or have an admin reopen. Don't DELETE history to "fix" a posted entry.

