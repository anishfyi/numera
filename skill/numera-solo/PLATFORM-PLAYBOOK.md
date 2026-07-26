# Working with any accounting platform

Numera Solo is not limited to the platforms it ships knowledge for. This file is
the procedure for working against **any** accounting system: read its public
documentation, build a working model of it, and help the user without ever
guessing at a write.

Solo gives you the method. It does not ship credentials, and it does not post to
a remote ledger. Everything below produces either an answer, a local ledger
entry, or an import file the user carries across themselves.

## What Solo will and will not do

| | Solo (this skill) | Numera Pro |
| --- | --- | --- |
| Read a platform's public API docs | yes | yes |
| Reason about its data model, answer questions | yes | yes |
| Prepare a balanced entry for it | yes | yes |
| Emit a CSV or payload the user imports | yes | yes |
| Authenticate and post to the live ledger | **no** | yes |
| Curated per-platform failure modes | generic only | yes, battle tested |
| Tamper-evident audit chain across writes | no | yes |

If the user asks Solo to write directly into their cloud ledger, say plainly
that Solo does not hold credentials by design, and offer the import path.

## Step 1: identify the platform and its era

Ask, or infer from what the user says:

- **Which product exactly.** "Sage" is five different products. "QuickBooks" is
  Online and Desktop, which share a name and almost nothing else.
- **Cloud or on premise.** On premise usually means a local SDK or an ODBC
  connection, not an HTTP API, and often no realistic automation path at all.
- **Region.** Tax behaviour, statutory reports and even field names change by
  country edition.

Never proceed on "QuickBooks" alone. Online and Desktop have different data
models, different write paths, and different failure modes.

## Step 2: find the primary source

Prefer, in order:

1. The vendor's own developer/API reference.
2. The vendor's data-model or schema documentation.
3. The vendor's release notes, for version-specific behaviour.

Community posts are useful for symptoms but must not be treated as fact. If a
claim only exists in a forum thread, label it as unverified when you use it.

## Step 3: build the model, in this order

Answer these five questions before touching anything. They are the same five
regardless of platform, which is why this generalises.

### 3.1 Auth and limits
How does a caller authenticate, how long do tokens live, what rotates, and what
are the rate limits? Note specifically whether refresh tokens are single use,
because that one detail causes more broken integrations than any other.

### 3.2 Entities
What are the objects, and how do they map onto double entry? Find the platform's
name for: chart of accounts, journal entry, invoice, bill, payment, customer,
vendor, item, and whatever dimension system it uses (classes, locations,
departments, tracking categories, dimensions).

### 3.3 Queries
How do you read? Query language, filter syntax, pagination, and how deleted or
voided records are represented. Establish how to read one entity by id, because
you will need that for the read-then-write cycle below.

### 3.4 Writes and sharp edges
The dangerous part. Establish:

- Create versus update: same endpoint or different, and how the system tells them apart.
- **Whether an update is a full replace.** Many are. A full-replace update wipes
  every field you omit. This is the single most destructive default in this
  category of software.
- Concurrency control: version tokens, sync tokens, ETags, optimistic locking.
- Whether line collections merge or replace wholesale.
- How to void or reverse, and whether hard delete exists at all.
- Period locks and close dates that reject writes.

### 3.5 Reconciliation to double entry
Confirm how the platform represents debits and credits, including sign
conventions, because several use signed amounts rather than separate columns and
a sign error is a silent, balanced, completely wrong entry.

## Step 4: write it down

Record what you learned as a new file under `platforms/` using
`platforms/_template.md`. One file per platform, the same five headings. Next
session starts from knowledge instead of a search.

Say plainly which parts you verified against the vendor docs and which parts you
inferred. An inferred claim about a write path is a liability.

## Step 5: the four rules that hold everywhere

These are platform independent and are not negotiable.

1. **Read before you write.** Fetch the current record, apply the change to that
   fresh copy, write it back. Never write from a cached copy.
2. **Assume update means replace.** Send the complete object, or explicitly use
   the platform's partial-update mechanism after confirming it exists.
3. **Never invent an identifier.** Account codes, tax codes and entity ids must
   come from a read against the live system, not from a plausible guess.
4. **Propose, then write.** Same rule as the local ledger. Show the balanced
   entry, wait for a yes. This does not relax because a platform is involved.

## Step 6: when the docs run out

If the documentation does not answer a write question, stop. Do not experiment
against live books. Tell the user precisely what is unknown, and offer to
prepare the entry for manual entry instead. A wrong posting in a closed period
costs an accountant more time than doing it by hand would have.
