# QuickBooks Desktop

> On premise, SDK / QBXML. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Writes and sharp edges

How writing actually works on QuickBooks Desktop (QBD), and the traps that bite an
integrator. QBD is NOT the cloud QuickBooks Online API: there is no REST endpoint
and no tenant URL. You talk to a company file (.QBW) on a Windows machine through
the QuickBooks SDK. Exact tag names, qbXML versions and error numbers below should
be verified against the QuickBooks SDK Onscreen Reference (OSR) for the installed
QB year, because they shift between versions.

### The integration model
Two paths, both local to the machine that holds the company file:
- **qbXML over QBFC/COM** - your app runs on the same Windows box (or a hosted
  desktop), opens a session to the company file, and exchanges qbXML request/response
  documents (e.g. a JournalEntryAddRq carrying the entry, back a JournalEntryAddRs).
- **The Web Connector** - for apps that are not co-located: QB's Web Connector
  POLLS your SOAP web service on a schedule and relays the qbXML. It is pull, on a
  timer; there is no real-time push and no webhook. The connector only runs while
  QuickBooks is open and the scheduled poll fires.
The human must authorize the app ONCE inside QuickBooks (and choose whether it may
run while the file is closed / in unattended mode). Reads and writes both go
through this same request/response channel.

### Posting an entry
- Write requests are typed qbXML add/mod objects: JournalEntryAddRq, BillAddRq,
  InvoiceAddRq, CheckAddRq, etc. A journal entry is DebitLine / CreditLine elements,
  each referencing an account.
- **Account references** are by ListID (a stable internal GUID) or FullName
  ("Parent:Child", colon-delimited, hierarchical and case-sensitive). Resolve the
  account against the chart first; a FullName typo lands nowhere or errors.
- **Updates use optimistic concurrency**: a Mod request must carry the current
  TxnID AND the current EditSequence. Read the object first, send back its
  EditSequence; if it is stale (someone else edited it) the Mod rejects. Never
  hardcode or reuse an EditSequence.

### Sharp edges
- **Sales tax / VAT is item-driven, not a tax-code field.** QBD models tax through
  tax ITEMS and the customer's tax code + a tax agency, unlike the cloud APIs where
  a line carries a TaxCodeRef. Reverse charge / domestic VAT schemes are set up as
  tax items; do not expect a single "tax code on the line".
- **No native idempotency key.** A dropped response after a timeout is the classic
  double-post risk. Guard it yourself: put a unique reference in RefNumber / the
  memo and QUERY for that reference before re-adding, rather than blindly retrying.
- **Mode matters.** Some operations behave differently in single-user vs
  multi-user mode, and a file open in the wrong mode (or by another user) can block
  a write. Errors are numeric (for example a 3xxx range for posting/validation
  problems) - map them from the OSR, do not parse the message text.
- **It only runs when QuickBooks does** (Web Connector path) - schedule writes for
  when the file is open and reachable, and treat the queue as eventually-processed,
  not synchronous.
- **List limits and element caps** apply (name lengths, line counts); long imports
  must be chunked.
(Verify exact request tags, qbXML version, and error codes against the QBSDK OSR
for the installed QuickBooks Desktop year.)

## Field notes

Operational scar tissue for an app driving QuickBooks Desktop (QBD) through qbXML, the QBFC COM library, or the Web Connector. These COMPLEMENT the write model in writes_and_sharp_edges; here it is the connection, versioning, change-detection and error-decoding traps. Exact version numbers, error codes and object names drift between QB years, so verify them against the QuickBooks SDK Onscreen Reference (OSR) and the QBFC/QBXMLRP2 type library docs.

### "Could not start QuickBooks / class not registered" = the COM component is missing or wrong-bitness
qbXML does not travel over a socket; it goes through a COM request processor (QBXMLRP2, or the QBFC wrapper around it). That runtime request processor is installed by QuickBooks Desktop itself (along with the Web Connector pathway); the QuickBooks SDK ships QBFC, the OSR, samples, headers and type libraries for development, but it is not what provides the runtime component. So a "class not registered" / "cannot create ActiveX object" failure on a box usually means one of: QuickBooks (and therefore its request processor) is not actually installed on THIS host, the COM registration is corrupt or never completed, or a bitness mismatch: QBXMLRP2 is a 32-bit in-process COM server, so a 64-bit process cannot load it directly. The fix: confirm QuickBooks is installed on the same Windows box as the company file and that the COM class is registered, and either run the caller as a 32-bit process or cross the 32/64-bit boundary out-of-process (a 32-bit surrogate/host process). A working dev box is no guarantee: the dev box also has the SDK (for the OSR/QBFC/build artifacts), but the production/hosted-desktop box needs QuickBooks itself with a healthy, registered request processor. (Verify the exact ProgID / component name, e.g. QBXMLRP2.RequestProcessor for the in-process server, against the SDK docs.)

### BeginSession fails because the file is not open, or is open in the wrong mode
A session must attach to a company file. If the file is not open and you did not request "file must be open" handling, or QuickBooks is sitting on a modal dialog, BeginSession errors. The deeper trap is mode: opening with an empty file path attaches to the currently-open file (the human's interactive session), while a specified path lets you open it unattended, but ONLY if unattended access was pre-authorised. Single-user vs multi-user also bites: some operations need single-user, and a file another user holds in single-user mode blocks you. The fix: decide attended (empty path, file must already be open) vs unattended (explicit path, pre-authorised) up front, and pin the open mode (DoNotCare only when you truly do not care).

### First connection just hangs until a human clicks Yes inside QuickBooks
An app must be authorised ONCE, interactively, inside QuickBooks before any request goes through. The first BeginSession (or the Web Connector's first run) raises a certificate/authorisation dialog ON THE QB SCREEN that a logged-in user must approve, including the choice of whether the app may run while the file is closed and as which login. If that screen is on a headless or locked server, your call appears to hang forever. The fix: do the one-time authorisation interactively, grant unattended access deliberately if you need it, and treat a brand-new app deploy as needing a human at the console once.

### A Mod request rejects with a concurrency error = stale EditSequence
QBD uses optimistic concurrency, and the symptom is a Mod (e.g. an *ModRq) bouncing even though your TxnID/ListID is correct. The cause: EditSequence is a snapshot token that changes every time the object is edited (by the UI, another integration, anything), and you sent an old one. The fix is the read-then-write dance every time: query the object immediately before the Mod, read its current EditSequence, send THAT back. Never cache, reuse or hardcode an EditSequence across runs; on rejection, re-read and retry.

### "Version not supported" / fields silently ignored = qbXML version too high for the installed QB
Each request document declares a qbXML version, and the installed QuickBooks only understands up to the version that shipped with that QB year. Ask for a version newer than the host supports and the request is rejected; reference a newer-version element against an older host and it can be dropped rather than error. The fix: query the supported versions at session start and send the highest version that is <= what the host returns, then gate any newer element behind that. Do not assume your build's max version; the field office's QB may be years behind. (Verify the version-to-QB-year mapping against the OSR.)

### Long names or huge imports fail validation = list-element and string-length caps
Writes reject not because the data is wrong but because it exceeds QBD's fixed caps: name/FullName lengths, memo/description lengths, and the number of line elements per transaction all have ceilings, and a colon is reserved as the list hierarchy separator so it cannot appear inside a single name. The fix: validate and truncate to the documented limits before sending, and chunk large imports into multiple requests rather than one giant document, which can also time out. (Verify the exact character and line caps against the OSR for the installed year.)

### Currency fields error or are ignored until multi-currency is enabled IN the file
Sending ExchangeRate or a CurrencyRef has no effect, or errors, when the company file is not multi-currency-enabled. Multi-currency is a per-FILE preference a human turns on inside QuickBooks (and once on it cannot be turned off), and it changes the data model. The fix: detect the home currency / multi-currency state from the file before writing any foreign-currency transaction; on a single-currency file, omit currency fields entirely and post in the home currency. Do not try to enable multi-currency through the SDK.

### You cannot see what changed: there are NO webhooks, poll and diff yourself
QBD pushes nothing. There is no event, no webhook, no "modified since" callback. To detect new, edited or DELETED records you must QUERY: pull with a ModifiedDateRangeFilter for incremental edits, and detect deletions separately (a deleted-transactions query for txns within a window, since a deleted record simply stops appearing in a normal list). The fix: run scheduled queries, persist TxnID/ListID + EditSequence locally, and diff against the prior pull to infer changes. Treat your local store as the change log, because QBD will not give you one.

### The Web Connector runs on ITS schedule, only while QB is open
On the Web Connector path your service is POLLED, not called on demand: the connector pulls work on a timer (and only when QuickBooks is running and the scheduled poll fires, or a user clicks Update Selected). The symptom is a write that "did not happen yet" because no poll has occurred. The fix: design the queue as eventually-processed, not synchronous; expect minutes of latency tied to the poll interval; and remember a closed QuickBooks means zero processing. Returning the right percent-complete from your SOAP responses is what drives the connector's loop, so a malformed response can stall the whole exchange.

### Branch on the numeric error code, not the message text
Failures come back as a numeric status code plus a human message, and the message wording changes between QB years and locales. Branching on text is fragile. The fix: map the numeric status code from the OSR (statusCode values; many validation/posting problems surface as 3xxx-style codes, while COM/connection faults surface as 0x8004... HRESULTs) and act on the code: stale EditSequence vs missing required field vs object-not-found vs version-unsupported each have their own number. Log the code AND the message, but key your retry/abort logic on the code. (Treat the specific ranges and numbers as things to verify against the OSR for the installed QuickBooks Desktop year, not as fixed constants.)

## Overview

QuickBooks Desktop (Pro / Premier / Enterprise) is an on-premise Windows application. There is NO general-purpose cloud REST API for it; treat every integration as local code talking to a running copy of QuickBooks via the QuickBooks SDK (qbXML/QBFC). The Intuit `quickbooks.api.intuit.com` v3 REST API is QuickBooks ONLINE only and does not reach a Desktop company file. Plan all reads and writes through the SDK request/response model below.

### Access model: SDK over the company file
All access goes through the QuickBooks SDK against an open company file (`.QBW`). Two transport paths:
- Request Processor (local): COM object `QBXMLRP2.RequestProcessor` (or QBFC's `QBSessionManager`) on the SAME Windows machine as QuickBooks. Direct, synchronous, request/response. Best for a local agent running beside QuickBooks.
- QuickBooks Web Connector (QBWC): for REMOTE integration. Your service exposes a SOAP web service; the Web Connector (installed next to QuickBooks) POLLS it on a schedule and relays qbXML. Pull-based only; your server can never push.
There is no socket/HTTP listener inside QuickBooks itself; nothing can connect inbound to it.

### qbXML vs QBFC
Two equivalent ways to express the same requests:
- qbXML: raw XML request/response documents (`<QBXML><QBXMLMsgsRq>...<JournalEntryAddRq>...`). Transport-agnostic; required for the Web Connector path (QBWC moves qbXML strings).
- QBFC (QuickBooks Foundation Classes): a COM object model that builds the same qbXML for you in code (`IJournalEntryAdd`, etc.) and parses responses. Local-only; thin wrapper over qbXML. (verify exact class names against live docs)
Both ultimately produce identical qbXML on the wire. Pick QBFC for local COM apps, qbXML strings for QBWC.

### Auth and authorization
There are no OAuth tokens. Authorization is granted ONCE inside the QuickBooks UI:
- First connection: an admin user, with the company file open, sees a certificate/trust prompt and grants the app access (typically "allow even when QuickBooks is not running" if you need unattended local automation). This is stored against the app name + a unique app ID. (verify exact prompt wording/flags against live docs)
- The app then opens a session naming the company file path (or "" to use the file currently open in the UI) and a desired access mode.
- QBWC additionally uses a `.QWC` config file (app name, URL, AppUniqueName, owner/file GUIDs) plus a password the user enters in the Web Connector once.
Authorization is per-machine and per-file; moving the file or renaming the app re-triggers the trust prompt.

### Company file must be open / accessible
The `.QBW` must be reachable by the SDK at session-begin time. Unattended local automation requires the "allow access when QuickBooks is not running" grant; otherwise QuickBooks (and a logged-in user) must be running. If the file is open in single-user mode by an interactive user, your local SDK session can be refused or forced to wait. Always handle "could not begin session" / file-in-use as an expected, retryable condition, not a hard failure.

### Single-user vs multi-user mode
Session begin requests an access mode (e.g. `omDontCare`, `omSingleUser`, `omMultiUser`). (verify exact enum names against live docs)
- Single-user mode: only ONE session (UI or SDK) can hold the file. If a person has it open single-user, your write session is blocked, and vice versa.
- Multi-user mode: multiple sessions coexist; required for concurrent SDK + human use. Switch the file to multi-user (Host Multi-User Access) before relying on background automation alongside users.
- Some operations (certain admin/maintenance tasks, some list edits) demand single-user and will error in multi-user. Request `omDontCare` and let QuickBooks pick when you don't strictly need exclusivity.

### Web Connector specifics (remote)
QBWC is a pull-based scheduler. Your SOAP service implements the QBWC callback contract: `authenticate`, `sendRequestXML`, `receiveResponseXML`, `getLastError`, `closeConnection` (and `clientVersion`, `serverVersion`). (verify exact method names/case against live docs) Flow: QBWC authenticates, then repeatedly calls `sendRequestXML` (you return one qbXML request), runs it against the open file, and returns the result via `receiveResponseXML`; you return a percent-complete to drive the loop. Implications: latency is bounded by the Web Connector RUN INTERVAL (minutes, user-configured) and by QuickBooks being open at poll time. No real-time, no server-initiated calls.

### qbXML request shape and entities
Every request is wrapped: `<QBXML><QBXMLMsgsRq onError="...">` containing one or more `*Rq` elements; responses come back as matching `*Rs` with a `statusCode`/`statusMessage`. Core verbs per entity: `*AddRq`, `*ModRq`, `*QueryRq`, `*DelRq` (deletes mostly for list entities). (verify exact element names against live docs) Accounting entities mirror the desktop ledger: `JournalEntryAdd/Mod/Query`, `InvoiceAdd`, `BillAdd`, `ReceivePaymentAdd`, `AccountAdd/Query`, `CustomerAdd`, `VendorAdd`, `ItemServiceAdd`/`ItemInventoryAdd`. A journal entry splits into debit lines and credit lines (e.g. `JournalDebitLine` / `JournalCreditLine`), each with an account reference and amount; debits must equal credits, same as on-prem QBO.

### Mapping the friendly {journal, date, lines} shape
The agent's neutral journal shape maps onto `JournalEntryAddRq` like this:
- `date` -> `TxnDate` (date the entry posts).
- each `line` with a positive (debit) amount -> a `JournalDebitLine` with `AccountRef` (by `ListID` or full `FullName`) and `Amount`; each credit -> a `JournalCreditLine`. QBXML uses SIGN-FREE amounts split into debit/credit blocks, NOT signed amounts in one list.
- line memo -> the line's `Memo`; entry-level note -> `Memo` on the `JournalEntryAdd`.
- optional `RefNumber` carries your document number. Customer/vendor/class tracking goes on the line via `EntityRef`/`ClassRef` where the line touches A/R or A/P. (verify exact tag names against live docs)
Sum the debit and credit blocks yourself before sending; QuickBooks rejects an unbalanced entry.

### Reads: QueryRq and filters
Reads use `*QueryRq` with optional filters (date ranges, `ModifiedDateRangeFilter` for incremental sync, name/ref filters, `MaxReturned` paging, and `IncludeRetElement` to trim returned fields). Reports are a separate family (`GeneralDetailReportQueryRq`, `GeneralSummaryReportQueryRq`) returning a row/column grid rather than entity objects. (verify exact element names against live docs) Incremental sync pattern: store the last sync timestamp and filter by `ModifiedDateRangeFilter` each run; there is no change-feed/webhook.

### QODBC and SQL-style reads (third-party)
For SQL-style access without writing qbXML, third-party ODBC drivers (notably QODBC) expose the company file as relational tables/views and translate `SELECT`/`INSERT`/`UPDATE` into SDK calls under the hood. Useful for read/reporting; it is still bound by the SAME constraints (file open, authorization, single/multi-user locks) because it is the SDK underneath. Writes via QODBC are possible but inherit qbXML's validation rules. Treat QODBC as convenience, not a different capability set; it is an extra licensed dependency.

### Version pinning (qbXML spec version)
qbXML is VERSIONED and pinned to the QuickBooks year/edition. The request header (or `<?qbxml version="N.N"?>`) declares a spec version; fields and entities added in a newer spec are unavailable on an older QuickBooks install. (verify exact version syntax and current max version against live docs) Always query the supported version range from the installed QuickBooks at startup and target the highest version it supports; never assume a field exists across editions. A version mismatch surfaces as unsupported elements, not a clean error.

### Sharp edges
- No realtime push: every read is a poll. QBWC adds a scheduled, minutes-granularity delay on top.
- File locks: single-user mode and an interactive user can block your session; design every call to retry on "file in use" / "could not begin session".
- Authorization is fragile: renaming the app, moving the `.QBW`, or running as a different Windows user can void the grant and re-prompt (which fails silently in unattended mode if no one clicks Allow).
- Version-pinned schema: the same qbXML can succeed on one QuickBooks year and fail on another; pin and feature-detect.
- Status codes, not HTTP: each `*Rs` carries its own `statusCode` (0 = OK); a "successful" `onError="continueOnError"` batch can contain individual failed requests, check every element.
- Deletes/voids differ by entity: transactions support void; list entities support delete or "MakeInactive". Closed-period and "books closed" protections apply just like on-prem and can reject postdated/backdated entries.
- Amounts and balancing: send sign-free amounts in debit/credit blocks and balance them yourself; rounding to 2dp before posting avoids penny-imbalance rejections.

