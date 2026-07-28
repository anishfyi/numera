# Lease accounting (IFRS 16 / ASC 842)

How a lessee gets a lease onto the balance sheet and unwinds it across any ledger:
recognise a right-of-use (ROU) asset and a lease liability up front, then depreciate
the asset and accrete interest on the liability while the cash payment pays the
liability down. Cross-cutting domain knowledge under IFRS 16 / ASC 842; the platform
tags live in each system's docs.

## Initial recognition: ROU asset and lease liability
At the commencement date the lessee records the lease on balance sheet. The lease
liability is the present value of the future lease payments, discounted at the rate
implicit in the lease, or the lessee's incremental borrowing rate if the implicit
rate is not readily determinable. (Jurisdiction caveat: under ASC 842 a lessee that
is NOT a public business entity may elect, by class of underlying asset, to use a
risk-free rate as an alternative to the incremental borrowing rate; the implicit
rate still takes precedence when readily determinable.) The ROU asset starts at that
same liability amount plus any initial direct costs, prepaid lease payments and
estimated restoration costs, less any lease incentives received. Entry: DR ROU asset,
CR lease liability (and DR ROU asset / CR cash for initial direct costs paid). Cash
does NOT move for the discounted-payments part; that is the whole point of the model,
the obligation is recognised before it is paid.

## Subsequent measurement: depreciation plus interest, payment reduces the liability
Two things run each period and they are separate. (1) Depreciate the ROU asset,
usually straight-line over the shorter of the lease term and the asset's useful
life: DR depreciation expense, CR accumulated depreciation. (2) Accrete interest on
the liability using the discount rate on the opening carrying amount: DR interest
expense, CR lease liability. The cash payment then reduces the liability: DR lease
liability, CR cash. So a single rental payment splits into an interest portion (the
P&L charge above) and a principal portion (the rest, reducing the liability). The
liability runs down on an amortised-cost schedule. In the plain-vanilla case (no
transfer of ownership, no reasonably-certain purchase option, and no purchase price
or guaranteed residual built into the liability) the liability reaches zero at the
end of the lease term and the ROU asset depreciates to nil on its own (usually
straight-line) schedule. Where ownership transfers or a purchase option is reasonably
certain to be exercised, the liability includes that purchase/residual amount and the
ROU asset is depreciated over the asset's USEFUL LIFE, which extends beyond the lease
term, so neither balance necessarily lands at nil at the end of the term. Either way,
the two balances do not track each other period by period.

## IFRS 16: one lessee model, no operating/finance split
Under IFRS 16 a lessee has a SINGLE model: almost every lease goes on balance sheet
as ROU asset and liability with the depreciation-plus-interest pattern above. There
is no operating-versus-finance distinction for lessees. The P&L therefore shows a
front-loaded total charge (interest is higher early when the liability is largest)
and splits the cost between depreciation and interest/finance costs rather than a
single rent line. (Lessor accounting still keeps the finance/operating split under
both standards; this doc is the lessee side.)

## US ASC 842: operating vs finance survives for lessees
Under US GAAP (ASC 842) lessees still classify each lease as finance or operating,
and both go on balance sheet (ROU asset and liability), so the recognition entry is
the same shape. The difference is P&L geography. A FINANCE lease behaves like IFRS
16: separate depreciation and interest, front-loaded total cost. An OPERATING lease
reports a SINGLE straight-line lease expense each period; mechanically you still
accrete interest and amortise the liability, but the ROU asset is amortised by the
plug that makes total expense straight-line (lease cost minus interest), so the
P&L shows one even rent figure. Same balance sheet, different income-statement shape,
that is the headline IFRS-16-versus-842 contrast.

## Short-term and low-value exemptions
Both standards let a lessee skip balance-sheet treatment for short-term leases (term
of 12 months or less, no purchase option); this election is made by CLASS of
underlying asset. IFRS 16 adds a low-value asset exemption, elected LEASE-BY-LEASE:
it is assessed by the asset's value when new (often cited around the USD 5,000 mark
as a guide, not a hard rule), and it also requires that the lessee can benefit from
the asset on its own (or together with readily available resources) and that the
asset is not highly dependent on, or highly interrelated with, other assets. ASC 842
has no separate low-value exemption. Where an exemption applies, recognise the cost
straight to P&L on a straight-line basis: DR lease/rent expense, CR cash. The
exemption is a deliberate, scoped election, not a licence to expense ordinary leases.

## Common mistakes
- **Expensing rent straight to P&L under the new standards** - this is the old
  operating-lease habit; under IFRS 16, and for ASC 842 finance leases, it skips the
  ROU asset and liability and understates both assets and debt. Right move: recognise
  the lease on balance sheet unless a short-term or low-value exemption genuinely
  applies.
- **Treating the whole cash payment as one thing** - booking the full rental to
  interest, or all of it against the liability, misstates finance cost and the
  liability balance. Right move: split each payment into interest (rate times opening
  liability) and principal (the remainder) using the amortisation schedule.
- **Using the wrong discount rate** - discounting at an arbitrary or stale rate
  mis-sizes both the liability and the ROU asset at day one. Right move: use the rate
  implicit in the lease if determinable, otherwise the incremental borrowing rate at
  commencement (or, for an ASC 842 non-public business entity that has so elected, a
  risk-free rate by class of underlying asset).
- **Depreciating the ROU asset over the wrong horizon** - using full asset life when
  the lease does not transfer ownership overstates the asset. Right move: depreciate
  over the shorter of lease term and useful life unless ownership transfers or a
  purchase option is reasonably certain (in which case depreciate over the asset's
  useful life).
- **Forgetting to remeasure on a change** - a rent review, term change or index
  reset is not just a new payment. Right move: remeasure the liability at the revised
  payments and discount rate and adjust the ROU asset by the same amount.
