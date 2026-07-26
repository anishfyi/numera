---
title: US business taxation basics (entities, federal forms, payroll, deadlines)
slug: us-taxation
type: reference
created: 2026-06-29
tags: [taxation, us-tax, irs, payroll, entity-types]
---

Decent working knowledge of US business tax for a bookkeeping agent. Figures change
yearly - always verify current numbers against the primary source (irs.gov) before
relying on them. This is not tax advice; it informs the books, not a filing.

## Entity types and how they are taxed (federal)
| Entity | Return | Owner taxed how | Entity-level tax? | Liability shield |
|---|---|---|---|---|
| Sole proprietor | Schedule C on Form 1040 | On all profit | No (pass-through) | No |
| Single-member LLC | Schedule C (disregarded by default) | Like sole prop | No | Yes (state-law) |
| Partnership / multi-member LLC | Form 1065 + Schedule K-1 | On K-1 share | No (pass-through) | LP/LLC: yes |
| S corporation | Form 1120-S + K-1 | On K-1 share; owner-employees take reasonable W-2 wages | Mostly no | Yes |
| C corporation | Form 1120 | On wages + dividends (double tax) | Yes, flat 21% | Yes |

- **LLC** is a state-law entity; its federal tax treatment is separate (default
  disregarded/partnership, or elect S-corp via Form 2553, or C-corp via Form 8832).
- The S-corp draw: distributions beyond "reasonable compensation" avoid SE/FICA tax.
- The C-corp rate is a flat **21%**; pass-throughs are taxed at the owners' individual rates.

## Key federal forms and deadlines (calendar-year filers)
| Form | Who | Due | Extension -> |
|---|---|---|---|
| 1065 | Partnership / multi-member LLC | Mar 15 | Sep 15 (Form 7004) |
| 1120-S | S corporation | Mar 15 | Sep 15 (Form 7004) |
| 1120 | C corporation | Apr 15 | Oct 15 (Form 7004) |
| 1040 + Sch C | Sole prop / SMLLC | Apr 15 | Oct 15 (Form 4868) |

An extension extends time to **file**, not to **pay** - tax owed is still due on the
original date. Estimated taxes are paid quarterly (individuals: Apr 15, Jun 15, Sep
15, Jan 15; pay if you expect to owe >= $1,000).

## Payroll and employment taxes
- **FICA** = Social Security (6.2% employee + 6.2% employer, up to an annual wage
  base that rises yearly) + Medicare (1.45% each, no cap; +0.9% additional Medicare
  on high wages, employee only).
- **FUTA** - federal unemployment, 6.0% on the first $7,000 of wages, less a credit
  for state unemployment (commonly netting to 0.6%).
- **Self-employed** pay both halves: ~15.3% SE tax up to the SS wage base, then 2.9%
  Medicare above.
- **Forms**: 941 (quarterly payroll), 940 (annual FUTA), W-2/W-3 (employees, due Jan
  31), 1099-NEC (contractors, due Jan 31; thresholds change - verify the current one).

## Information returns
1099-NEC (nonemployee compensation), 1099-MISC (rents, other), 1099-K (card/marketplace).
File with the IRS and give to the recipient. E-file is mandatory above a low return count.

## Accounting method and tax year
- **Cash vs accrual** for tax: small businesses under the gross-receipts threshold
  may use cash and skip some inventory/UNICAP rules; C-corps and partnerships with a
  C-corp partner above the threshold must use accrual. The threshold is inflation-adjusted.
- **Tax year**: calendar or fiscal; S-corps/partnerships generally use a calendar
  year unless they elect otherwise.
- **Book vs tax differences** (depreciation, accruals, meals, etc.) are reconciled on
  the return (Schedule M-1/M-3). The books are GAAP/accrual; the return is per the code.

## What an agent should do with this
Keep the books clean and categorized so the return is easy; flag obvious items
(contractor payments needing a 1099, payroll liabilities, estimated-tax accruals);
never file or give tax advice - hand off to the accountant for the return.
See sales-tax-and-vat for transaction taxes.
