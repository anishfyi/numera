# US Federal Business Tax & Accounting Reference (2025-2026 Tax Years)

> Built for an AI accountant knowledgebase. Every figure is tagged with its applicable tax year. Inflation-adjusted figures (marked ANNUAL) and statutory provisions affected by the One Big Beautiful Bill Act of 2025 (OBBBA, Public Law 119-21, enacted July 4, 2025) are flagged. Verify ANNUAL figures each year against the cited IRS source.

---

## 1. Business Entity Types & Federal Tax Treatment

### 1.1 Overview table

| Entity | Federal return | Owner reporting | Entity-level tax? | Self-employment (SE) tax | Liability shield |
|---|---|---|---|---|---|
| Sole proprietorship | **Schedule C** (attached to Form 1040) | Net profit flows to owner's 1040 | No (pass-through) | Yes, on net profit (Schedule SE) | No |
| Single-member LLC (default = disregarded) | **Schedule C** (or Sch. E / F) on owner's 1040 | Same as sole prop | No (disregarded) | Yes | Yes (state-law shield) |
| Partnership / multi-member LLC (default) | **Form 1065** (info return) + **Schedule K-1** to each partner | K-1 income on partner's 1040 | No (pass-through) | General partners: yes on distributive share; limited partners: generally no | LP/LLC: yes |
| S corporation | **Form 1120-S** + **Schedule K-1** | K-1 income on shareholder's 1040 | No (with narrow exceptions: built-in gains, excess net passive income) | No SE tax on K-1 income; owner-employees must take **reasonable W-2 wages** subject to FICA | Yes |
| C corporation | **Form 1120** | Owners taxed only on dividends/wages | **Yes - 21% flat** | N/A (wages are FICA-taxed) | Yes |

### 1.2 When each is used

- **Sole proprietorship** - simplest; default for a single unincorporated owner. Good for low-risk businesses and testing an idea. No liability protection.
- **Partnership** - simplest structure for 2+ owners; common for professional groups. Pass-through.
- **LLC** - state-law entity combining liability protection with pass-through tax flexibility. Federal tax classification is *separate* from state status (see 1.3).
- **S corporation** - election available to eligible corporations/LLCs. Avoids double taxation; the main draw is that distributions beyond "reasonable compensation" escape SE/FICA tax. Restrictions: ≤100 shareholders, one class of stock, only eligible (generally US-individual) shareholders, domestic only.
- **C corporation** - a separate taxpaying entity at the flat 21% rate. Subject to **double taxation** (21% corporate, then dividends taxed to shareholders). Chosen for retained-earnings reinvestment, broad/foreign/institutional ownership, venture funding (preferred stock), and QSBS (§1202) eligibility.

### 1.3 LLC tax classification & elections

- **Default:** single-member LLC = **disregarded entity** (reported on owner's return; uses owner's SSN/EIN for income-tax reporting). Multi-member LLC = **partnership**.
- A multi-member entity **cannot** elect disregarded status.
- **Form 8832 (Entity Classification Election)** - elect to be taxed as a corporation (or back to default).
- **Form 2553 (Election by a Small Business Corporation)** - elect S-corp status. An LLC that timely files Form 2553 is *deemed* to also have elected corporate (association) status, so it need not separately file Form 8832.
- **60-month limit:** once an entity changes classification, it generally cannot change again for 60 months after the effective date.

---

## 2. Key Federal Forms & Filing Deadlines (calendar-year filers)

### 2.1 Income tax returns and extensions

| Form | Entity | Original due date (CY filer) | Extension form | Extended due date | Notes |
|---|---|---|---|---|---|
| **1065** | Partnership / multi-member LLC | 15th day of 3rd month → **Mar 15** | **7004** | **Sep 15** (6 mo) | Info return; issues K-1s |
| **1120-S** | S corporation | 15th day of 3rd month → **Mar 15** | **7004** | **Sep 15** (6 mo) | Issues K-1s |
| **1120** | C corporation | 15th day of 4th month → **Apr 15** | **7004** | **Oct 15** (6 mo) | June 30 fiscal-year C-corps (years beginning before 1/1/2026) get a 7-month extension |
| **1040 + Schedule C** | Sole prop / SMLLC | **Apr 15** | **4868** | **Oct 15** (6 mo) | Schedule C attaches to 1040 |

**Critical rule:** Form 7004 and Form 4868 extend the time to **file**, NOT the time to **pay**. Tax owed is still due on the original date; interest/penalties accrue on unpaid balances.

When a due date falls on a Saturday, Sunday, or legal holiday, it shifts to the next business day. (For TY2025, e.g., June 15, 2025 is a Sunday, so Q2 estimates were due June 16, 2025.)

### 2.2 Estimated taxes

| | Individuals (incl. sole props, partners, S-corp shareholders) | C corporations |
|---|---|---|
| Form | **1040-ES** | EFTPS (Form **1120-W** is now historical - last revised 2022; used only as a worksheet) |
| Must pay if expected tax owed ≥ | **$1,000** | **$500** |
| Due dates (CY) | **Apr 15, Jun 15, Sep 15, Jan 15** (of next year) | 15th day of **4th, 6th, 9th, 12th** months → Apr 15, Jun 15, Sep 15, Dec 15 |
| Safe harbor (avoid underpayment penalty) | Pay ≥ **90%** of current-year tax OR **100%** of prior-year tax (**110%** if prior-year AGI > $150,000) | Generally 100% of current year; large corps (≥$1M taxable income in any of prior 3 years) must base on current year |

Payment channels: EFTPS, IRS Direct Pay, Business Tax Account. Corporations **must** deposit electronically via EFTPS.

### 2.3 Payroll / wage & information returns

| Form | Purpose | Filed with | Due date | Notes |
|---|---|---|---|---|
| **W-2** | Employee wage statement | SSA + employee | **Jan 31** | To both employee and SSA by Jan 31 |
| **W-3** | Transmittal of W-2s | SSA | **Jan 31** | Summary cover sheet |
| **941** | Employer's *quarterly* federal tax return (FIT withheld + FICA) | IRS | **Apr 30, Jul 31, Oct 31, Jan 31** | +10 days if all deposits made timely |
| **940** | *Annual* FUTA return | IRS | **Jan 31** | +10 days if FUTA fully deposited |
| **944** | Annual alternative to 941 (small employers ≤ $1,000 annual liability, IRS-assigned) | IRS | **Jan 31** | |
| **1099-NEC** | Nonemployee compensation | IRS + recipient | **Jan 31** (both paper & e-file) | |
| **1099-MISC** | Rents, royalties, other income | IRS + recipient | Recipient: Jan 31 (or Feb 15 for boxes 8/10); IRS: **Feb 28 paper / Mar 31 e-file** | |
| **1099-K** | Payment card / third-party network | IRS + recipient | Recipient: Jan 31; IRS: Feb 28 paper / Mar 31 e-file | |

**Information-return thresholds (FLAG - changed by OBBBA, phased):**

| Form | Through TY2025 | TY2026+ | TY2027+ |
|---|---|---|---|
| **1099-NEC / 1099-MISC** | **$600** | **$2,000** (OBBBA, for payments after 12/31/2025) | inflation-adjusted from 2027 |
| **1099-K** (third-party settlement orgs / TPSOs) | 2025: report if total payments > **$2,500** (transitional; no transaction count) | **2026+: reverts to > $20,000 AND > 200 transactions** (OBBBA repealed the $600 rule) | same |

> Note: payment-card transactions (e.g. credit-card processors) on 1099-K have always used the > $20,000 / > 200 threshold; the $600/$2,500 transitional rules applied to *third-party network* (TPSO/app) payments. **E-file mandate:** filers of 10+ information returns (aggregate) must e-file.

---

## 3. Income Tax Rates & Pass-Through Taxation

### 3.1 C corporation rate

- **Flat 21%** on taxable income (IRC §11). Applies to all C-corps including qualified personal service corporations. Computed on Form 1120: taxable income × 0.21. (No graduated brackets since the 2017 TCJA.) **Permanent** (not scheduled to sunset).

### 3.2 Pass-through taxation

- Sole props, partnerships, LLCs, and S-corps pay **no entity-level federal income tax** (with narrow S-corp exceptions: built-in gains tax and excess net passive income tax). Income/loss "passes through" to owners and is taxed at their **individual rates** (10%-37% for TY2025).
- Partners and general-partnership/sole-prop owners owe **SE tax** (15.3% = 12.4% Social Security up to the wage base + 2.9% Medicare) on net earnings via Schedule SE. S-corp shareholder-employees pay FICA only on W-2 wages, not on K-1 distributions - the basis of the "reasonable compensation" planning point.

### 3.3 QBI deduction - IRC §199A (FLAG: made permanent + new floor by OBBBA)

- Up to **20%** deduction of qualified business income from pass-throughs, plus 20% of qualified REIT dividends and PTP income. Available whether or not the taxpayer itemizes.
- **Was scheduled to expire after TY2025; OBBBA made it permanent.**
- **TY2025 taxable-income thresholds (ANNUAL)** where limitations (W-2 wage / UBIA caps and the specified-service-trade-or-business "SSTB" phase-out) begin: **$197,300** single / **$394,600** married filing jointly.
  - Below threshold: generally a clean 20% (no wage/SSTB limits).
  - Above threshold: subject to the greater-of (50% of W-2 wages, or 25% of W-2 wages + 2.5% of UBIA) limit; SSTBs (health, law, accounting, consulting, etc.) phase out entirely.
- **New OBBBA minimum deduction:** $400 (inflation-adjusted) for taxpayers with ≥ $1,000 of net QBI from active material-participation businesses, beginning TY2026.
- Forms: **8995** (simplified, at/under threshold) or **8995-A** (over threshold).

---

## 4. Payroll & Employment Taxes

### 4.1 FICA (Social Security + Medicare)

| Component | Rate (employee) | Rate (employer) | Combined | Wage base |
|---|---|---|---|---|
| **Social Security (OASDI)** | 6.2% | 6.2% | 12.4% | **TY2025: $176,100** • **TY2026: $184,500** (ANNUAL) |
| **Medicare (HI)** | 1.45% | 1.45% | 2.9% | **No cap** (all wages) |
| **Additional Medicare** | 0.9% | none | 0.9% | On wages **> $200,000** (per employer; withholding threshold is flat $200,000 regardless of filing status) |

- Self-employed pay both halves: **15.3%** SE tax (12.4% + 2.9%) up to the Social Security wage base, then 2.9% Medicare on the remainder, plus 0.9% Additional Medicare above the filing-status threshold. Half the SE tax is deductible above-the-line.

### 4.2 FUTA (federal unemployment) - TY2025

- Gross FUTA rate **6.0%** on the first **$7,000** of each employee's annual wages.
- Standard **5.4% credit** for timely state unemployment tax → **net 0.6%** = max **$42/employee/year**.
- **Credit-reduction states** (states with outstanding federal UI loans) lose part of the credit → higher effective FUTA; check the annual FUTA credit-reduction list.
- Deposit: if FUTA liability **> $500** in a quarter, deposit by the last day of the following month; if ≤ $500, carry forward. File Form **940** annually.

### 4.3 Federal income tax withholding (FITW)

- Employers withhold per employee **Form W-4** and IRS **Publication 15 / 15-T** percentage or wage-bracket methods. Reported with FICA on Form **941** (or 944).

### 4.4 Deposit schedules (Form 941 taxes - FITW + both FICA halves)

- **Lookback period:** 12 months ending June 30 of the prior year (the 4 quarters July 1 - June 30).
- **Monthly depositor:** lookback liability **≤ $50,000** → deposit by the **15th of the following month**.
- **Semiweekly depositor:** lookback liability **> $50,000** → Wed/Thu/Fri paydays deposit by following **Wednesday**; Sat-Tue paydays deposit by following **Friday**.
- **$100,000 next-day rule:** accumulate ≥ $100,000 on any day → deposit by **next business day**; you then become semiweekly for the rest of the year and the next year.
- All federal tax deposits must be made electronically (EFTPS).

---

## 5. Depreciation

### 5.1 MACRS basics

- **Modified Accelerated Cost Recovery System** is the default tax depreciation system. Each asset is assigned a recovery period/class (e.g., 5-year: cars, computers; 7-year: office furniture/equipment; 15-year: qualified improvement property/land improvements; 27.5-year: residential rental; 39-year: nonresidential real property) and a method (200%/150% declining balance switching to straight-line, or straight-line for real property).
- **Conventions:** half-year (default for personalty), mid-quarter (if >40% of personalty placed in service in Q4), mid-month (real property). Reported on **Form 4562**.

### 5.2 Section 179 expensing (FLAG: ANNUAL + permanently raised by OBBBA)

- **TY2025: max deduction $2,500,000**, phase-out begins when §179 property placed in service exceeds **$4,000,000** (dollar-for-dollar reduction).
- **TY2026 (inflation-adjusted): max $2,560,000**, phase-out begins at **$4,090,000**.
- **SUV cap: $31,300 (TY2025)** for SUVs over 6,000 lbs GVWR.
- Limited to **taxable business income** (cannot create/increase a loss); excess carries forward.
- OBBBA permanently raised the $2.5M/$4M limits (from prior ~$1.25M/$3.13M) starting TY2025, with inflation indexing thereafter.

### 5.3 Bonus depreciation (IRC §168(k)) - FLAG: major OBBBA change

- **OBBBA restored permanent 100% bonus depreciation** for qualified property **acquired and placed in service after January 19, 2025**.
- For property placed in service after Jan 19, 2025, a taxpayer may *elect down* to **40%** (or **60%** for certain long-production-period property and aircraft) instead of 100%.
- **Pre-OBBBA / old phase-down (still relevant for property acquired on or before Jan 19, 2025, and for amended/transition returns):**

| Placed in service / acquired | Bonus % (old TCJA phase-down) |
|---|---|
| 2022 | 100% |
| 2023 | 80% |
| 2024 | 60% |
| 2025 (acquired ≤ Jan 19, 2025) | 40% |
| After Jan 19, 2025 (OBBBA) | **100%** (permanent) |

- Bonus applies to assets with recovery period ≤ 20 years (and certain others). Unlike §179, bonus has no taxable-income cap and **can** create a loss. **OBBBA also created a new 100% deduction for "qualified production property"** (certain nonresidential real property used in manufacturing).

---

## 6. R&D Tax Credit (§41) & Payroll-Tax Offset

### 6.1 Credit for Increasing Research Activities - Form 6765

- IRC **§41** credit, claimed on **Form 6765**. Two computation methods: **Regular** (20% of qualified research expenses over a base) and **Alternative Simplified Credit (ASC)** (14% of QREs exceeding 50% of the average of the prior 3 years' QREs). A **§280C** election allows claiming a reduced credit to avoid reducing the deduction.
- **Form 6765 update:** new Section E (controlled-group/business-component) and Section G (business-component detail). **Section G is OPTIONAL for all filers for TY2025 (processing year 2026)**, mandatory for many filers thereafter.

### 6.2 Payroll-tax offset for Qualified Small Businesses (QSBs) - Form 8974

- A **QSB** (gross receipts < $5M for the credit year, and no gross receipts more than 5 years prior) may elect to apply the §41 credit against **employer payroll taxes** instead of income tax - valuable for pre-profit startups.
- **Maximum election: $500,000 per year** (raised from $250,000 by the Inflation Reduction Act, for tax years beginning after Dec 31, 2022).
- **Mechanics:** first offsets the **employer 6.2% Social Security** portion (up to $250,000/quarter); any remaining amount then offsets the **employer 1.45% Medicare** portion.
- **How to claim:** elect on **Form 6765** attached to a timely-filed income tax return → then claim on **Form 8974** attached to **Form 941** for the first quarter *beginning after* the income return is filed. Unused credit carries to later quarters.

### 6.3 Section 174 / 174A R&D expensing (FLAG: major OBBBA reversal)

- TCJA had required **capitalize-and-amortize** of R&E expenditures (5 years domestic / 15 years foreign) for TY2022-2024.
- **OBBBA added §174A:** taxpayers may **immediately deduct domestic** research/experimental expenditures (including domestic software development) **for tax years beginning after Dec 31, 2024**, or elect to capitalize and amortize over ≥ 60 months. (Foreign R&E still amortized over 15 years.)
- **Small-business retroactive option:** certain small businesses may elect to deduct unamortized domestic R&E from tax years beginning after 12/31/2021 and before 1/1/2025 - **election deadline July 6, 2026** (per Rev. Proc. 2025-28 / 2025-23).

---

## 7. Accounting Methods & Tax Years

### 7.1 Cash vs. accrual

- **Cash method:** income when received, expenses when paid. Simpler; common for small service businesses.
- **Accrual method:** income when earned (right to receive), expenses when incurred (all-events test + economic performance). Required when inventory is material to income - unless the **small-business-taxpayer** exception applies.

### 7.2 Gross-receipts test / who must use accrual (FLAG: ANNUAL)

- A **small business taxpayer** = average annual gross receipts of **$31 million or less (TY2025)** over the **3 prior tax years**, and not a tax shelter. (Was $30M for TY2024; $29M for TY2023.) The same threshold gates several simplifications:
  - Use of the **cash method** despite having inventory.
  - Exemption from **UNICAP / §263A** capitalization.
  - Simplified treatment of inventory.
  - Exemption from the **§163(j)** business-interest limitation.
- **C corporations and partnerships with a C-corp partner** must use **accrual** if they exceed the $31M gross-receipts test (IRC §448). Tax shelters must always use accrual regardless of size.
- Changing methods generally requires **Form 3115** (Application for Change in Accounting Method), often via automatic consent.

### 7.3 Tax-year choices

- **Calendar year** (Jan-Dec) or **fiscal year** (12-month period ending the last day of any month other than December), or 52/53-week year.
- **Defaults/constraints:** S-corps and partnerships generally must use a calendar year (or the majority/principal-partner year) unless they establish a business purpose or make a **§444 election** (with required payments via **Form 8752**). Sole props use the owner's tax year. New entities adopt a year on their first return; later changes need IRS consent (**Form 1128**).

---

## 8. US GAAP Basics for Bookkeeping

### 8.1 The accounting equation & double-entry

- **Assets = Liabilities + Equity.** This must always balance.
- **Double-entry:** every transaction has equal **debits** and **credits**. Debits increase assets/expenses; credits increase liabilities/equity/revenue (and vice-versa). The sum of debits equals the sum of credits in every entry.

### 8.2 Accrual accounting concepts (GAAP basis)

- **Revenue recognition:** recognize revenue when *earned* (performance obligation satisfied), not when cash is received - governed by **ASC 606** (5-step model: (1) identify the contract, (2) identify performance obligations, (3) determine transaction price, (4) allocate price to obligations, (5) recognize revenue as/when obligations are satisfied).
- **Matching principle:** expenses recognized in the period they help generate revenue.
- **Deferred (unearned) revenue:** cash received before earning → recorded as a **liability** until earned.
- **Accrued revenue / accrued expenses:** earned/incurred but not yet billed or paid → recorded as a receivable or payable.
- **Prepaid expenses:** cash paid in advance for future benefit → recorded as an **asset**, expensed over time.

### 8.3 Core financial statements

1. **Balance Sheet** (Statement of Financial Position) - assets, liabilities, equity at a point in time.
2. **Income Statement** (P&L / Statement of Operations) - revenues and expenses over a period.
3. **Statement of Cash Flows** - operating, investing, financing cash movements.
4. **Statement of Changes in Equity / Retained Earnings.**
   Plus accompanying **notes/disclosures**.

### 8.4 FASB / ASC at a high level

- **FASB (Financial Accounting Standards Board)** sets **US GAAP**; it is the standard-setter recognized by the SEC for public companies.
- **ASC (Accounting Standards Codification)** is the single authoritative source of US GAAP, organized by **Topic** (e.g., ASC 606 Revenue, ASC 842 Leases, ASC 740 Income Taxes). Updates are issued as **ASUs (Accounting Standards Updates)**. FASB ASC 606 was developed jointly with the IASB's IFRS 15 to converge US GAAP and IFRS revenue rules.

### 8.5 GAAP vs. tax-basis vs. cash-basis (key distinctions)

| Basis | Purpose | Revenue/expense timing | Notes |
|---|---|---|---|
| **GAAP (accrual)** | Financial reporting to lenders/investors; required for audits & public companies | Earned/incurred (ASC 606, matching) | Most comprehensive; "book" income |
| **Tax basis** | Filing federal returns | Per Internal Revenue Code (e.g., §451 income, §461 deductions; method per §446) | Differs from GAAP → **book-tax differences** (e.g., bonus depreciation, R&D, bad debts), reconciled on **Schedule M-1/M-3** |
| **Cash basis** | Simplified small-business/personal bookkeeping | When cash received/paid | Allowed for tax if under the §448 gross-receipts test; an OCBOA (Other Comprehensive Basis of Accounting) for financial statements |

> Book income (GAAP) and taxable income routinely differ. The reconciliation appears on **Schedule M-1** (or **M-3** for larger entities) of Forms 1120, 1120-S, and 1065.

---

## Sources

- IRS - Topic No. 751, Social Security and Medicare withholding rates: https://www.irs.gov/taxtopics/tc751
- SSA - Contribution and Benefit Base (Social Security wage base): https://www.ssa.gov/oact/cola/cbb.html
- SSA - 2026 COLA Fact Sheet: https://www.ssa.gov/news/en/cola/factsheets/2026.html
- IRS - Questions and answers for the Additional Medicare Tax: https://www.irs.gov/businesses/small-businesses-self-employed/questions-and-answers-for-the-additional-medicare-tax
- IRS - Self-employment tax: https://www.irs.gov/businesses/small-businesses-self-employed/self-employment-tax-social-security-and-medicare-taxes
- IRS - Instructions for Form 4562 (2025) (Section 179 limits, SUV cap, bonus): https://www.irs.gov/instructions/i4562
- IRS - Publication 946, How To Depreciate Property (MACRS): https://www.irs.gov/publications/p946
- IRS - One, Big, Beautiful Bill provisions: https://www.irs.gov/newsroom/one-big-beautiful-bill-provisions
- IRS - Treasury/IRS guidance on additional first-year (bonus) depreciation under OBBBA: https://www.irs.gov/newsroom/treasury-irs-issue-guidance-on-the-additional-first-year-depreciation-deduction-amended-as-part-of-the-one-big-beautiful-bill
- IRS - Additional First Year Depreciation Deduction (Bonus) FAQ: https://www.irs.gov/newsroom/additional-first-year-depreciation-deduction-bonus-faq
- IRS - About Form 7004 (extension): https://www.irs.gov/forms-pubs/about-form-7004
- IRS - Instructions for Form 7004 (12/2025): https://www.irs.gov/instructions/i7004
- IRS - Publication 509, Tax Calendars (2026): https://www.irs.gov/publications/p509
- IRS - Instructions for Form 1120 (2025) (21% rate, due dates, gross-receipts test): https://www.irs.gov/instructions/i1120
- IRS - Instructions for Form 1120-S (2025): https://www.irs.gov/instructions/i1120s
- IRS - Instructions for Form 1065 (2025): https://www.irs.gov/instructions/i1065
- IRS - Publication 542, Corporations (corporate rate, estimated tax): https://www.irs.gov/publications/p542
- IRS - Qualified business income deduction (§199A): https://www.irs.gov/newsroom/qualified-business-income-deduction
- IRS - Instructions for Form 8995 (2025): https://www.irs.gov/instructions/i8995
- IRS - Instructions for Form 8995-A (2025): https://www.irs.gov/instructions/i8995a
- IRS - Instructions for Forms 1099-MISC and 1099-NEC (04/2025): https://www.irs.gov/instructions/i1099mec
- IRS - General Instructions for Certain Information Returns (2025): https://www.irs.gov/instructions/i1099gi
- IRS - FAQs on Form 1099-K threshold under OBBBA (reverts to $20,000/200): https://www.irs.gov/newsroom/irs-issues-faqs-on-form-1099-k-threshold-under-the-one-big-beautiful-bill-dollar-limit-reverts-to-20000
- IRS - Form 1099-K FAQs: https://www.irs.gov/newsroom/form-1099-k-faqs
- IRS - About Form 6765 (R&D credit): https://www.irs.gov/forms-pubs/about-form-6765
- IRS - Instructions for Form 6765 (12/2025): https://www.irs.gov/instructions/i6765
- IRS - About Form 8974 (QSB payroll-tax credit): https://www.irs.gov/forms-pubs/about-form-8974
- IRS - Qualified small business payroll tax credit for increasing research activities: https://www.irs.gov/businesses/small-businesses-self-employed/qualified-small-business-payroll-tax-credit-for-increasing-research-activities
- IRS - Research credit against payroll tax for small businesses: https://www.irs.gov/credits-deductions/research-credit-against-payroll-tax-for-small-businesses
- IRS - Rev. Proc. 2025-28 (§174A small-business retroactive method): https://www.irs.gov/pub/irs-drop/rp-25-28.pdf
- IRS - Internal Revenue Bulletin 2025-38: https://www.irs.gov/irb/2025-38_IRB
- IRS - Publication 334, Tax Guide for Small Business (2025) (cash vs accrual): https://www.irs.gov/publications/p334
- IRS - Publication 538, Accounting Periods and Methods: https://www.irs.gov/publications/p538
- IRS - Threshold for the gross receipts test (history): https://www.irs.gov/about-irs/threshold-for-the-gross-receipts-test-increased-to-29-million-for-2023
- IRS - Employment tax due dates: https://www.irs.gov/businesses/small-businesses-self-employed/employment-tax-due-dates
- IRS - Notice 931, Deposit Requirements for Employment Taxes (Rev. Sep 2025): https://www.irs.gov/pub/irs-pdf/n931.pdf
- IRS - Topic No. 757, Forms 941/944 deposit requirements: https://www.irs.gov/taxtopics/tc757
- IRS - Topic No. 759, Form 940 / FUTA: https://www.irs.gov/taxtopics/tc759
- IRS - Instructions for Form 940 (2025): https://www.irs.gov/instructions/i940
- IRS - FUTA credit reduction: https://www.irs.gov/businesses/small-businesses-self-employed/futa-credit-reduction
- IRS - Estimated taxes: https://www.irs.gov/businesses/small-businesses-self-employed/estimated-taxes
- IRS - When to Pay Estimated Tax (individuals): https://www.irs.gov/faqs/estimated-tax/individuals/individuals-2
- IRS - Jan. 31 filing deadline for W-2/1099 statements: https://www.irs.gov/newsroom/jan-31-filing-deadline-remains-for-employer-wage-statements-independent-contractor-forms
- IRS - Business structures: https://www.irs.gov/businesses/small-businesses-self-employed/business-structures
- SBA - Choose a business structure: https://www.sba.gov/business-guide/launch-your-business/choose-business-structure
- IRS - S corporations: https://www.irs.gov/businesses/small-businesses-self-employed/s-corporations
- IRS - Single member limited liability companies: https://www.irs.gov/businesses/small-businesses-self-employed/single-member-limited-liability-companies
- IRS - LLC filing as a corporation or partnership: https://www.irs.gov/businesses/small-businesses-self-employed/llc-filing-as-a-corporation-or-partnership
- IRS - About Form 8832 (Entity Classification Election): https://www.irs.gov/forms-pubs/about-form-8832
- IRS - Instructions for Form 2553 (S-corp election): https://www.irs.gov/instructions/i2553
- FASB - Revenue from Contracts with Customers (ASC 606), ASU 2014-09: https://storage.fasb.org/ASU%202014-09_Section%20A.pdf
- AICPA & CIMA - The revenue recognition standard (FASB ASC 606): https://www.aicpa-cima.com/resources/article/the-revenue-recognition-standard-fasb-asc-606

---
