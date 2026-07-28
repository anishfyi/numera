# Sage Intacct

> Cloud, XML web services. Working notes for an agent posting to this platform.
> Read **Writes and sharp edges** before writing anything. The entity list
> tells you what exists; that section tells you what destroys data.

Source: distilled from the vendor's own developer documentation. Verify any
figure that changes (rate limits, API versions) against the live docs before
relying on it. See `../PLATFORM-PLAYBOOK.md` for how to refresh this.

## Auth and limits

### Web Services credentials
Endpoint: POST https://api.intacct.com/ia/xml/xmlgw.phtml, Content-Type application/xml. Two credential layers in every request envelope: <control> sender (senderid + sender password = the licensed Web Services sender) and <operation><authentication> user login (userid, companyid, user password) OR a sessionid.

### Sessions
Call getAPISession once to swap login creds for a sessionid; reuse it (lighter and faster). Sessions expire (~2h idle); on authentication failure with a session, re-login transparently. Entity-level (multi-entity) sessions: pass <locationid> in getAPISession to scope writes to an entity.

### Company setup
Web Services must be enabled (Company > Admin > Web Services), the sender id added to the company's Web Services authorizations list, and the user needs appropriate module permissions. Missing authorization yields XL03000006 "sender not authorized".

### Limits
Queue-based throttling rather than hard rate caps; keep requests serial-ish, batch via multiple <function> blocks (max 100 per request; all-or-nothing with <transaction>true</transaction>). readByQuery pagesize max 1000.

## Entities

### GLBATCH / GLENTRY (journal entries)
create GLBATCH: JOURNAL (symbol e.g. GJ), BATCH_DATE, BATCH_TITLE, ENTRIES{GLENTRY[]}. Each GLENTRY: TR_TYPE (1=debit, -1=credit), AMOUNT (positive), ACCOUNTNO, DEPARTMENT, LOCATION (required in multi-entity shared companies), DESCRIPTION, plus dimensions (CLASSID, PROJECTID, CUSTOMERID, VENDORID...). Debits and credits must balance. STATE: posting happens on create unless the journal requires approval.

### GLACCOUNT
ACCOUNTNO (key), TITLE, ACCOUNTTYPE incomestatement|balancesheet, NORMALBALANCE debit|credit, STATUS active|inactive, REQUIREDEPT/REQUIRELOC flags drive line validation.

### ARINVOICE / APBILL
ARINVOICE: CUSTOMERID, DATECREATED (struct year/month/day), TERMNAME or DATEDUE, ARINVOICEITEMS{ARINVOICEITEM[]: ACCOUNTNO or ACCOUNTLABEL, AMOUNT, LOCATIONID, DEPARTMENTID}. APBILL mirror with VENDORID + APBILLITEMS. RECORDNO is the system key; RECORDID is your document number.

### ARPYMT / APPYMT
Modern functions: create ARPYMT with PAYMENTMETHOD, CUSTOMERID, RECEIPTDATE, ARPYMTDETAILS[{RECORDKEY (invoice RECORDNO), TRX_PAYMENTAMOUNT}]. Legacy create_arpayment still works but prefer the object form.

### CUSTOMER / VENDOR
CUSTOMERID/VENDORID (your key, uppercase convention), NAME, STATUS, DISPLAYCONTACT block for address/email. Cannot delete once referenced; STATUS inactive.

### ITEM
ITEMID, NAME, ITEMTYPE (Inventory, Non-Inventory, ...), GLGROUP for account mapping.

### TAXDETAIL
Tax codes per jurisdiction (VAT setups); AR/AP lines reference TAXENTRIES or rely on tax schedules depending on company tax solution.

### Dimensions
LOCATIONID (also the entity dimension in multi-entity), DEPARTMENTID, CLASSID, PROJECTID, CUSTOMERID, VENDORID, EMPLOYEEID, ITEMID - all attachable per GL line; reportable via readByQuery on GLDETAIL.

## Queries

### readByQuery
<readByQuery><object>GLDETAIL</object><fields>*</fields><query>JOURNAL = 'GJ' AND ENTRY_DATE >= '05/01/2026'</query><pagesize>1000</pagesize></readByQuery>. Query syntax: SQL-ish WHERE with =, !=, <, >, like, in (...), and/or. Dates MM/DD/YYYY in queries. Empty <query> returns everything.

### Pagination
Response carries numremaining + resultId. Follow with <readMore><resultId>...</resultId></readMore> until numremaining = 0. resultIds expire; consume promptly.

### read / readByName
<read><object>ARINVOICE</object><keys>123</keys><fields>*</fields></read> by RECORDNO. readByName uses the NAME/ID field (e.g. CUSTOMERID). Multiple keys comma-separated.

### Useful query objects
GLDETAIL (posted GL lines - the general ledger), GLACCOUNTBALANCE (balances by period), ARAGING/APAGING via reports or query AR/AP with WHENDUE filters. TRIALBALANCE via get_trialbalance legacy function.

### The newer query function
<query><object>ARINVOICE</object><select><field>RECORDNO</field><field>TOTALDUE</field></select><filter><greaterthan><field>TOTALDUE</field><value>0</value></greaterthan></filter><pagesize>100</pagesize><offset>0</offset></query> - structured filters, orderby, and offset paging. Use it when filter logic nests.

## Writes and sharp edges

### create / update / delete
<create><OBJECT>{fields}</OBJECT></create> (max 100 records). <update><OBJECT><RECORDNO>n</RECORDNO>{changed fields}</UPDATE form: update is sparse - send key + changed fields only. <delete><object>X</object><keys>1,2</keys></delete>. Posted GL batches: update only in open periods and if the journal allows edits; otherwise reverse via a new batch (REVERSEDATE supported on create GLBATCH... use reverse function where exposed).

### Transactions (atomicity)
<operation transaction="true"> makes all <function> blocks in the request atomic - perfect for "create batch + payment together" multi-writes.

### controlid + idempotency
Give each <function> a controlid you generate; responses echo it. With <uniqueid>true</uniqueid> in <control>, Intacct rejects a replayed controlid - real idempotency, use it for writes when retrying network failures.

### Error shape
<errormessage><error><errorno>BL03000130</errorno><description2>human text</description2><correction>what to do</correction></error></errormessage>. description2 + correction are excellent; show them verbatim. errorno BL = business logic, XL = system/auth.

### Sharp edges
- XML escaping: &, <, > in memos/names WILL break the envelope; escape every user value.
- Dates: payload date structs are {year,month,day} for some objects, MM/DD/YYYY strings in queries - do not mix.
- Multi-entity: writes at top level need LOCATIONID per line where required; entity-scoped sessions implicitly filter reads.
- TR_TYPE 1/-1 with positive AMOUNT is the GLENTRY debit/credit convention; negative amounts flip meaning and break balance checks.
- The sender password and user password are different credentials; 'invalid login' usually means the USER part, XL03000006 means the SENDER part.
- pagesize default is 100; always set it and handle readMore or you silently process partial data.

## Community field notes

Distilled from developer-forum threads, SDK issue trackers and practitioner
guides - the edge cases fixtures never contain.

### Locked vs closed periods (they are different)
A CLOSED period can be reopened by an admin and accepts adjustment journal
entries via the adjustments workflow. A LOCKED period cannot be reopened and
cannot be changed at all, not even by adjustments. Posting into either fails
at post time (not at draft time) with a business-logic error naming the
period. Recovery: post to the next open period, or ask an admin to reopen a
closed (not locked) period. Cousin gotcha from Sage 300: the GL fiscal
calendar can show a period open while Common Services has it locked - when a
"period locked" error contradicts what the calendar shows, check both layers.

### Multi-currency journals
With multi-currency enabled, GLENTRY lines carry CURRENCY (transaction
currency), TRX_AMOUNT (amount in that currency), and exchange rate fields
(EXCH_RATE_DATE or EXCH_RATE_TYPE_ID; Oanda daily rates are the default
"Intacct Daily Rate", which is hidden from API list operations). The journal
must balance in the TRANSACTION currency; base-currency amounts are derived
via the rate. Never mix currencies across lines unless each currency group
balances on its own. Missing rate data fails at post with a rate-lookup error.

### readByQuery at scale (the 50k-row ledger)
- pagesize caps at 1000 for readByQuery and 2000 for the newer query function;
  bigger pages mean fewer round trips but slower individual responses.
- Restrict <fields> to what you need: wide selects can force server-side JOINs
  and multiply response time.
- resultId pins pagination to the original snapshot; consume promptly, ids expire.
- FIELD BUG (SDK issue tracker): readMore responses have come back with a
  DIFFERENT envelope shape than the first page (data wrapped in an extra
  array) and with FEWER rows than pagesize. Parse defensively: never assume
  page shape or size, only stop on numremaining = 0.
- For very large pulls prefer the query function, filter server-side, and
  expect to paginate dozens of pages; cap client-side and report truncation
  honestly rather than silently dropping rows.

### UK VAT realities
- Domestic reverse charge (construction/CIS since March 2021): the CUSTOMER
  accounts for the VAT. Software handles it with a dedicated RC tax code that
  posts Box 1 (output) and Box 4 (input) simultaneously - cash-neutral for
  fully-recoverable businesses. Invoices must state that the reverse charge
  applies and how much VAT the customer accounts for.
- Zero-rated is NOT exempt: zero-rated supplies charge 0% but count as taxable
  turnover and preserve input-VAT recovery; exempt supplies sit outside and
  can restrict recovery (partial exemption). Mapping a customer's "no VAT" to
  the wrong one misstates the return even though the amounts look identical.

