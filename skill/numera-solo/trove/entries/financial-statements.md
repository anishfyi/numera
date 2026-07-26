---
title: The financial statements and how they connect
slug: financial-statements
type: reference
created: 2026-06-29
tags: [accounting, financial-statements, pnl, balance-sheet, cash-flow]
---

Three core statements plus the equity bridge. They are different views of the
same ledger and must tie to each other.

## 1. Income Statement (P&L / Profit and Loss)
Performance over a **period** (a month, quarter, year).

```
Revenue (Sales)
- Cost of goods sold (COGS)
= Gross profit
- Operating expenses (rent, payroll, software, marketing, ...)
= Operating profit (EBIT)
+/- Other income / interest / tax
= Net profit (the "bottom line")
```

Useful margins: gross margin = gross profit / revenue; net margin = net profit / revenue.

## 2. Balance Sheet (Statement of Financial Position)
A snapshot at a **point in time**. Must satisfy Assets = Liabilities + Equity.

```
Assets            Liabilities
  Current           Current (AP, accruals, tax payable, deferred revenue)
   Bank, AR,        Non-current (loans)
   prepayments,   Equity
   inventory        Share capital / owner capital
  Non-current       Retained earnings (accumulated net profit - drawings/dividends)
   equipment
   (net of accum.
    depreciation)
```

## 3. Statement of Cash Flows
Where cash actually moved over the period, in three buckets:
- **Operating** - cash from the core business (start from net profit, add back
  non-cash items like depreciation, adjust for changes in AR/AP/inventory).
- **Investing** - buying/selling long-term assets (equipment, investments).
- **Financing** - loans drawn/repaid, capital raised, dividends/drawings.

Net change in cash for the period must equal the change in the Bank balance on the
balance sheet. Profit is not cash: a profitable business can run out of cash (e.g.
customers slow to pay -> AR grows -> cash doesn't).

## How they connect (the tie-outs an agent should check)
- **Net profit** (P&L) flows into **retained earnings** (balance sheet equity).
- **Closing cash** (cash flow statement) equals the **Bank** line (balance sheet).
- The balance sheet must **balance** (Assets = Liabilities + Equity). If it does
  not, something is mis-posted - the single best integrity check after a close.
- AR on the balance sheet should equal the sum of open customer invoices; AP should
  equal the sum of open bills.

## Statement of changes in equity
Bridges opening to closing equity: opening equity + capital introduced + net profit
- drawings/dividends = closing equity.

## GAAP vs cash-basis vs tax-basis
- **GAAP (accrual)** - the standard for financial reporting to lenders/investors.
- **Cash basis** - simplified small-business view.
- **Tax basis** - per the tax code; differs from book income (e.g. depreciation,
  accruals), reconciled on the tax return. Book profit and taxable profit routinely differ.
