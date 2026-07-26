# <Platform name> · <edition, cloud or on premise, region>

> Status: <verified against vendor docs on YYYY-MM-DD | partially verified | inferred>
> Primary source: <url>

Fill every heading. If a section is unknown, write UNKNOWN rather than guessing.
An empty heading is honest; a plausible invention is not.

## Auth and limits

- Auth mechanism:
- Token lifetime:
- **Does the refresh token rotate on every use?** (yes/no/UNKNOWN)
- Rate limits:
- Tenant or company selector required on each call:

## Entities

Map the platform's names onto the accounting concepts.

| Concept | Platform name | Notes |
| --- | --- | --- |
| Chart of accounts | | |
| Journal entry | | |
| Invoice (AR) | | |
| Bill (AP) | | |
| Payment | | |
| Customer | | |
| Vendor | | |
| Item | | |
| Dimensions | | classes, locations, departments, tracking categories |

## Queries

- Read one by id:
- Query/filter syntax:
- Pagination:
- How voided or deleted records appear:

## Writes and sharp edges

- Create endpoint:
- Update endpoint:
- **Is update a full replace?** (this is the one that destroys data)
- Concurrency control (sync token, ETag, version):
- Do line collections merge or replace?
- Void / reverse path:
- Hard delete available:
- Period lock behaviour:

Known traps:

- 

## Reconciliation to double entry

- Debit/credit representation (separate columns, or signed amount):
- Sign convention:
- Does the platform enforce balance on write:
- Multicurrency handling:

## Open questions

Things not answered by the documentation. Do not write against these.

- 
