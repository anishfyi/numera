# Foreign operations and translation

How to bring a foreign OPERATION (a subsidiary, branch or division that keeps its
own books) into the group accounts. This is translation of a whole self-contained
set of books for consolidation, which is a different mechanism from translating
individual foreign transactions in one ledger (covered in the multicurrency doc).

## Functional vs presentation currency
Each operation has a functional currency: the currency of the primary economic
environment in which it earns and spends (where it prices, is paid, settles costs
and holds cash). The group presents its consolidated accounts in a presentation
(reporting) currency. When a subsidiary's functional currency differs from the
group's presentation currency, its complete, already-balanced functional-currency
financial statements are translated into the presentation currency for
consolidation. Determine functional currency from substance, not from where the
entity is registered: a UK-registered shell that prices, banks and settles entirely
in USD is functionally USD. The functional ledger is never re-stated line by line;
you translate the finished statements.

## The closing-rate (current-rate) method
Translate a foreign operation as follows: all assets and liabilities at the closing
rate (the rate at the balance-sheet date); income and expenses at the rate on the
transaction dates, in practice a period-average rate as a proxy. IAS 21 (and ASC
830) prescribe these two rules explicitly. For equity, the standards do not
prescribe a specific rate; in practice share capital and pre-acquisition reserves
are carried at historical rates (the rate when each tranche was contributed or
acquired), which is an established convention under IFRS and a requirement under US
GAAP. Because the balance sheet is translated at the closing rate but the P&L flows
through at average rates, and equity sits at historical rates, the translated
balance sheet will NOT balance on its own. The residual that makes it balance is
the translation difference; equivalently, it is the difference that arises from
retranslating the opening net assets at a new closing rate and the period's result
at average rather than closing rates. This is a mechanical consequence of using
different rates for different lines, not an error to be plugged into profit.

## The cumulative translation adjustment (CTA) goes to OCI/equity, not profit
The translation difference is taken to other comprehensive income and accumulated
in a separate equity reserve, the cumulative translation adjustment (CTA, also
called a foreign currency translation reserve). It is explicitly kept OUT of the
profit and loss account. The reasoning: the group has not transacted or settled
anything; the change reflects re-expressing a stable foreign net investment in a
different currency, an unrealised re-measurement of the whole operation rather than
a realised gain or loss. Each period's movement: DR or CR the relevant net assets
on translation, with the balancing entry DR/CR CTA in equity (via OCI). The CTA
balance grows and shrinks period to period as rates move.

## Recycling the CTA on disposal
The CTA sits in equity only while the group still owns the operation. On disposal
(or loss of control) of the foreign operation, the cumulative amount attributable
to that operation is reclassified ("recycled") from the CTA reserve to the P&L, as
part of the gain or loss on disposal. So translation differences DO eventually
reach profit, but only once, at the point the net investment is realised. Lines on
full disposal: clear the net assets and goodwill, take the proceeds, recycle the
CTA (DR CTA / CR disposal gain if it was a credit balance, or the reverse), and the
balancing figure is the gain/loss on disposal. Partial disposals depend on what is
retained: under IFRS, a proportionate amount of the CTA is recycled to P&L only
where control, joint control or significant influence is lost, or on partial
disposal of an associate or joint arrangement. On a partial disposal of a
subsidiary where control is RETAINED, the proportionate CTA is re-attributed to
non-controlling interests within equity and is NOT recycled to profit. Apply the
detailed rule in the applicable standard.

## Average vs closing rate, and why both
Using the closing rate for the balance sheet states the net investment at its
year-end value; using the average rate for the P&L approximates translating each
day's trading at that day's rate without doing so line by line. The average is only
a proxy; where revenue or costs are lumpy or rates move sharply, a weighted or
monthly average is more faithful than a simple full-year average. Never translate
the P&L at the closing rate as a shortcut, it distorts margins and dumps a larger
artificial difference into the CTA. Across jurisdictions the broad method is the
same under IFRS (IAS 21) and US GAAP (ASC 830); recycling on disposal and the OCI
treatment are common ground, though detailed disposal mechanics differ.

## Common mistakes
- **Putting the translation difference in the P&L.** Why wrong: it inflates or
  depresses reported profit with an unrealised re-measurement of the net
  investment. Right move: route it through OCI into the CTA reserve in equity; it
  only hits profit on disposal via recycling.
- **Using one rate for everything.** Why wrong: translating the whole balance sheet
  and P&L at the closing rate (or all at average) collapses the method and either
  hides or grossly overstates the CTA. Right move: closing rate for assets and
  liabilities, average rate for income and expenses, historical rates for equity
  (by convention).
- **Confusing transaction FX gain/loss with the translation CTA.** Why wrong: they
  are different things in different places. Transaction FX (settling a foreign
  invoice, revaluing an open monetary balance) is a realised/unrealised gain or loss
  in the operation's own P&L. The CTA arises only when translating that whole
  operation into the group's presentation currency. Right move: book transaction FX
  in the functional ledger's P&L first, THEN translate the finished statements;
  never net the two.
- **Forgetting to recycle the CTA on disposal.** Why wrong: the accumulated reserve
  is stranded in equity and the disposal gain/loss is misstated. Right move:
  reclassify the operation's CTA to profit as part of the disposal result (on full
  disposal or loss of control); on a partial disposal that retains control,
  re-attribute the proportionate CTA to NCI rather than recycling it.
- **Translating non-monetary items at historical rates here.** Why wrong: that is
  the temporal method, used when the operation's books are in a currency other than
  its functional currency. Under the standard closing-rate method for a self-
  contained foreign operation, assets and liabilities all go at the closing rate.
