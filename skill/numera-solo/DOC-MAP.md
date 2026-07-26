# Doc map

Where to look, by platform and by task. Internal entries first, then the
vendor's own reference. All external links verified reachable 2026-07-26.

Read the internal entry before the vendor doc: it tells you what to look for.
Read the vendor doc before you write anything: it is the only authority on the
current contract.

## By task, before anything else

| Task | Read first |
| --- | --- |
| Any journal entry | `trove/entries/accounting-fundamentals.md` |
| P&L, balance sheet, cash flow | `trove/entries/financial-statements.md` |
| Closing a period | `trove/entries/month-end-close.md` |
| Sales tax, VAT, reverse charge | `trove/entries/sales-tax-and-vat.md` |
| US filings, entity types, payroll tax | `trove/entries/us-taxation.md` |
| A platform not listed below | `PLATFORM-PLAYBOOK.md` |
| Working from a phone | `REMOTE.md` |

## QuickBooks Online

Internal: `trove/entries/quickbooks-online.md`

| Need | Link |
| --- | --- |
| Journal entry reference | https://developer.intuit.com/app/developer/qbo/docs/api/accounting/all-entities/journalentry |
| OAuth 2.0 and tokens | https://developer.intuit.com/app/developer/qbo/docs/develop/authentication-and-authorization/oauth-2.0 |

Ask before writing: which **minorversion** is pinned, and is this Online or
Desktop? Desktop is a different product with a different model entirely.

The trap: a non-sparse update is a full replace and clears every field you
omit. Round-trip the whole entity, or set `sparse` explicitly. Line arrays are
replaced wholesale either way.

## Xero

| Need | Link |
| --- | --- |
| Manual journals | https://developer.xero.com/documentation/api/accounting/manualjournals |
| OAuth 2.0 flow | https://developer.xero.com/documentation/guides/oauth2/auth-flow/ |

Ask before writing: which tenant, and is the period locked?

The trap: the refresh token rotates on every refresh, so two concurrent
refreshes race and orphan the grant. Serialise refresh.

## Sage Intacct

Internal: `trove/entries/sage-intacct.md`

| Need | Link |
| --- | --- |
| Journal entries | https://developer.intacct.com/api/general-ledger/journal-entries/ |

Ask before writing: which entity in the multi-entity structure, and which
dimensions are required on a line? Intacct leans on dimensions rather than a
wide chart of accounts, so a technically valid entry can still be unusable for
reporting if the dimensions are missing.

## Dynamics 365 Business Central

| Need | Link |
| --- | --- |
| API v2.0 reference | https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/ |

Ask before writing: cloud or on premise, and which company.

## NetSuite, Sage 50, Sage 300, Sage 300 CRE, QuickBooks Desktop

No internal entry yet. Follow `PLATFORM-PLAYBOOK.md`, find the vendor's own
developer reference, and write the result into `platforms/` using
`platforms/_template.md`.

For the desktop and on-premise products, establish first whether an automation
path exists at all. Several are SDK or ODBC only, and the honest answer is often
that Numera Solo prepares an import file and the user brings it across.

## When the link is dead or the page has moved

Vendor documentation moves. If a link here 404s, find the current page from the
vendor's developer portal root, use that, and correct this file. Do not fall
back to a cached memory of what the API used to look like.
