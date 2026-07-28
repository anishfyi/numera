# Bad debt and expected credit loss

Bad debt is the cost of customers who will not, or might not, pay. The discipline is to recognise that cost against profit BEFORE the specific account is known to be lost, using an allowance (provision) that sits as a contra-asset against receivables. The allowance smooths the P&L and keeps net receivables at recoverable value; the later write-off of a named debtor then hits the allowance, not the P&L again. An AI must distinguish the provision (an estimate) from the write-off (removing a specific receivable), and never double-count the expense.

## The allowance is a contra-asset
The allowance for doubtful accounts (also "bad debt provision", "loss allowance", "impairment of receivables") is a credit-balance account paired with the debit-balance AR control. It is NOT a reduction of revenue and NOT a separate liability. On the balance sheet it nets against gross receivables: net receivables = gross AR - allowance. Gross AR still equals the aged-receivables subledger; the allowance carries the estimated shortfall separately so the underlying customer balances stay intact and chase-able. Increasing the allowance: DR Bad-debt expense (P&L) / CR Allowance for doubtful accounts (contra-asset). Decreasing it (debtors recover, estimate falls): DR Allowance / CR Bad-debt expense.

## Raising and topping up the provision
At period end you measure the required allowance and adjust the existing balance to that target - you book only the movement, not the whole target again.
- Worked: required allowance £8,000; existing balance £5,000 → top up £3,000. DR Bad-debt expense 3,000 / CR Allowance 3,000.
- If the required allowance fell to £4,000 against an existing £5,000 → release £1,000. DR Allowance 1,000 / CR Bad-debt expense 1,000 (a credit to the P&L).
The classic error is re-provisioning the full target each period (DR expense 8,000) on top of an existing balance, which overstates both the allowance and the expense. Always reconcile to the carry-forward balance first.

## Specific write-off against the allowance
When a particular debt is confirmed irrecoverable (insolvency, statute-barred, written-off after recovery efforts), remove that receivable. If it was already provided for, there is NO further P&L hit - the cost was taken when the allowance was raised.
- DR Allowance for doubtful accounts / CR Trade receivables (the specific customer/invoice).
- Worked: write off a £900 invoice already inside the allowance. DR Allowance 900 / CR AR 900. P&L untouched; both gross AR and the allowance fall by 900, so net receivables are unchanged.
This is the allowance method. Posting the write-off straight to bad-debt expense instead bypasses the provision and double-counts the cost (once when provided, once on write-off).

## Direct write-off (no allowance)
Some entities skip the allowance and expense a debt only when it actually goes bad: DR Bad-debt expense / CR Trade receivables. This is simpler but delays recognition of the loss to a period later than the sale, so it does not satisfy the impairment/expected-credit-loss recognition requirements of IFRS 9 (or, in US GAAP, ASC 326/CECL) where the amounts are material. Note the tax position differs from the financial-reporting position: for US tax purposes most taxpayers are REQUIRED to use the specific charge-off (direct write-off) method under IRC §166 on an accrual basis, and the reserve/allowance method is generally disallowed for tax - so the direct method is common in tax filings, not because it is a cash-basis technique. If the books run an allowance for financial reporting, do not also use direct write-off for the same debts.

## Recovery of a written-off debt
A debt written off that later pays must be reinstated, then cleared by the cash. Reverse the write-off, then record the receipt.
- Reinstate: DR Trade receivables / CR Allowance for doubtful accounts.
- Cash received: DR Bank / CR Trade receivables.
- Net effect: bank up, allowance up (or, if booked direct, credit bad-debt expense / recoveries income instead). Worked: the £900 debt pays. DR AR 900 / CR Allowance 900, then DR Bank 900 / CR AR 900. The allowance now carries an extra 900; this is not a permanent surplus - at the next measurement date the allowance is re-measured to the required (matrix) target, so the recovery effectively reduces the next period's bad-debt expense (or is released to the P&L), with no double income.

## VAT on bad debts
Output VAT charged on the original sale was declared and accounted for on the VAT return (where it nets against input VAT in arriving at the period's payment or refund); when the debt goes bad you may reclaim it via bad-debt relief, but only once conditions are met (e.g. UK: invoice over 6 months overdue and written off in the accounts; rules and the waiting period vary by jurisdiction). The bad-debt provision/write-off itself carries no VAT entry - VAT relief is a separate, conditional claim on the VAT return, not part of the impairment journal. Provide/write off the net or gross amount per policy, and handle the VAT reclaim distinctly.

## IFRS 9 expected credit loss vs the incurred-loss model
The old incurred-loss model (IAS 39 / pre-ASU US GAAP) only recognised impairment once there was objective evidence a debt had gone bad - "too little, too late". IFRS 9 replaced it with the expected-credit-loss (ECL) model: forward-looking, you provide for expected losses from day one of the receivable, before any default event. For trade receivables most entities use the simplified approach - lifetime ECL measured via a provision matrix: group receivables by ageing bucket, apply a historical default rate adjusted for forward-looking factors (economic outlook, sector risk), and the result is the required allowance. US GAAP's analogue is CECL (current expected credit loss), under ASC 326. The journals are unchanged (DR expense / CR allowance); ECL changes only HOW the target is measured - probability-weighted and forward-looking, not waiting for evidence of loss.

## Provision matrix (simplified approach)
A table of ageing buckets, each with a loss rate, applied to that bucket's balance; the sum is the required allowance.
- Worked: Current £100,000 @ 0.5% = 500; 1-30 days £40,000 @ 2% = 800; 31-60 £20,000 @ 5% = 1,000; 61-90 £10,000 @ 15% = 1,500; 90+ £8,000 @ 40% = 3,200. Required allowance = £7,000. Adjust the existing allowance to £7,000 (movement only).
Loss rates come from historical write-off experience by bucket, then nudged for forward-looking expectations. Older buckets carry higher rates, but the provision each bucket contributes is balance × rate, so which bucket dominates depends on where the balances sit; in stressed or aged ledgers the older buckets often dominate, while in a young/healthy ledger the current bucket can. Re-run the matrix each close so the allowance tracks the current ageing.

## Common mistakes
- Writing a bad debt straight to bad-debt expense when an allowance already covers it → double-counts the cost (provided once, expensed again) and leaves the allowance overstated. Right move: DR Allowance / CR Receivable; only touch the P&L if the loss exceeds the provision held.
- Re-provisioning the full required allowance each period → expense and contra-asset balloon over time. Right move: book the movement from the existing allowance balance to the new target, not the whole target.
- Reducing revenue (DR Sales) to write off a debt → distorts turnover and VAT; a bad debt is an expense/impairment, not a sales reversal. Right move: DR Bad-debt expense or Allowance, never Sales.
- No provision on visibly aged debt (90+ days, customer in trouble) → net receivables and profit overstated; under IFRS 9 a forward-looking allowance is required even before default. Right move: run the provision matrix and provide for the expected loss now.
- Netting the allowance straight off gross AR in the subledger → the aged report no longer foots to the AR control and chase-able balances vanish. Right move: keep gross AR intact in the subledger; hold the estimate in a separate allowance contra-account.
- Recording a recovered debt as fresh sales income → overstates revenue and VAT. Right move: reinstate the receivable to the allowance (or credit recoveries/bad-debt expense), then clear it with the cash receipt.
