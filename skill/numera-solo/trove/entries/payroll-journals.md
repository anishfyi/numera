# Payroll journals: gross-to-net

How a pay run lands on the ledger from the employer's side: gross pay is the
expense, employee deductions are liabilities you hold and remit, and net pay is
what leaves the bank. Cross-cutting domain knowledge; the platform-specific
posting tags live in each system's docs.

## The full gross-to-net entry
A pay run is one journal that splits gross pay into what the employee takes home
and what you withhold on their behalf. The employer's cost is GROSS, not net.
Lines: DR gross wages/salaries expense (the full gross), DR employer
social-security expense (employer NIC in the UK, the employer FICA match -
Social Security + Medicare - in the US), DR employer pension expense (the
employer contribution); then CR net pay payable or bank (what the employee
actually receives), CR PAYE/income-tax payable (tax withheld), CR
social-security payable (commonly the employee deduction and the employer charge
are pooled in one payable since you remit them to the same body together, though
keeping employee and employer portions in separate sub-accounts is equally
valid), and CR pension payable (employee plus employer contributions owed to the
scheme). The entry balances because total debits (gross + employer on-costs)
equal net pay plus every withholding and on-cost credited away. The deductions
are not your money; they sit as liabilities until you pay them over.

## Employer cost vs employee deduction
Keep the two flows straight. An employee DEDUCTION (income tax, employee NIC,
employee pension) is carved OUT of gross pay - it does not add to the employer's
cost, it just reroutes part of gross from the bank to a payable. An employer
ON-COST (employer NIC, employer pension; in the UK the Apprenticeship Levy is a
further employer-only charge, though it is assessed on the annual paybill above
a threshold rather than per payslip) is ON TOP of gross - it is an extra expense
the business bears and a matching liability. So total employment cost = gross +
employer on-costs, while net pay = gross - employee deductions. The same payable
(e.g. NIC) collects from both sides but for different reasons: the employee half
via deduction, the employer half via expense.

## Remitting the liabilities, and the period-end accrual
When you pay the tax authority and the pension provider, you clear the payables:
DR PAYE/income-tax payable, DR social-security payable, DR pension payable, CR
bank. No expense touches the P&L here - the expense was booked on the pay run;
this is just settling the liability. If a pay period straddles the close (days
worked but not yet paid), accrue the unpaid portion: DR wages expense and DR
employer on-costs, CR accrued payroll, then reverse it when the actual run posts.
Without the accrual the period is understated and the cost lands in the wrong
month. Exact tax names, rates and thresholds vary by jurisdiction; the
debit/credit shape does not.

## Common mistakes
- **Booking only net pay to wages expense** - this understates the wage cost and
  leaves the withheld tax and pension off the books; book GROSS as the expense
  and the deductions as liabilities.
- **Treating employer NIC/FICA as a deduction** - the employer on-cost is an
  EXPENSE on top of gross (DR expense, CR payable), not something carved out of
  the employee's pay; misclassifying it understates employment cost.
- **Missing the period-end accrual** for days worked but unpaid - the cost lands
  in the next period and this period is understated; accrue and reverse.
- **Hitting the P&L again when you remit** - paying the tax/pension authority
  clears a payable (DR liability, CR bank); the expense was already taken on the
  pay run, so re-expensing double-counts.
- **One lump to a single payable** - split PAYE/income tax, social security and
  pension into their own payables (and, if useful, employee vs employer
  sub-accounts within each) so each reconciles to what is actually owed to that
  body.
