# Bank reconciliation

Reconciling the GL cash account (book balance) to the bank statement balance for a period. The goal is not to make the two numbers equal by force; it is to explain every difference as either a timing item, a bank-only item, or an error, then book what belongs on the books.

## Two balances, two viewpoints
Book balance = the GL cash/bank account balance per your ledger. Bank balance = the closing balance on the bank statement. They almost never match on the statement date because each side records the same event on a different day, and each side knows about events the other does not yet. Reconciliation proves the book balance is correct by walking from one to the other through named differences. Reconcile per bank account, per statement period; never net two accounts together.

## The reconciliation formula
Adjusted bank balance must equal adjusted book balance.
- Adjusted bank balance = statement balance + deposits in transit - outstanding cheques/payments (+/- bank errors).
- Adjusted book balance = GL cash balance + bank-only credits (interest, refunds) - bank-only debits (fees, charges, NSF/returned items) (+/- book errors).
When the two adjusted figures agree, the reconciliation ties. The adjusted balance is the real cash position. If they do not agree after all four item classes are applied, an unexplained difference remains - do not sign off.

## The four reconciling-item classes
Every difference falls into exactly one of these:
1. Deposits in transit - cash/cheques you recorded as received and posted to the book, not yet on the statement. Bank-side timing.
2. Outstanding cheques/payments - payments you recorded and posted to the book, not yet cleared the bank. Bank-side timing.
3. Bank-only items - on the statement, not yet in your books: fees, interest, charges, standing-order/direct-debit hits you missed, NSF/returned deposits, FX adjustments. Book-side, requires a journal.
4. Errors - either side recorded a wrong amount, wrong sign, duplicate, or omission. Correct on whichever side made the mistake.

## Which side an item adjusts
A reconciling item adjusts the side that does NOT yet know about it. Deposits in transit and outstanding cheques are known to your books but not the bank, so they adjust the BANK balance. Fees and interest are known to the bank but not your books, so they adjust the BOOK balance (and get a journal). An error adjusts the side that made it. Mechanical rule: never adjust the side that already has the item recorded.

## Timing items vs items that book a journal
Timing items (deposits in transit, outstanding cheques) get NO journal. They are already on your books; they simply have not reached the bank. They self-clear next period when the deposit lands or the cheque presents. Carry them forward and watch them clear.
Bank-only items DO get a journal, because your books are missing them. Book them in the period they appear on the statement. After booking, they are no longer reconciling items next period.

## Journals for bank-only items
- Bank fee / charge: DR bank-charges expense, CR cash. (Reduces book cash to match what the bank already took.)
- Interest earned: DR cash, CR interest income.
- Interest/overdraft charged: DR interest expense, CR cash.
- Standing order / direct debit you missed: DR the relevant expense or payable, CR cash.
- NSF / returned customer cheque: reverse the original receipt - DR accounts receivable (re-establish the debt) plus any returned-item fee to expense, CR cash.
- Bank credit (e.g. supplier refund direct to bank): DR cash, CR the relevant expense/payable/income.
Always book the bank-only item to the period it cleared the bank, so the GL cash balance becomes the adjusted-book figure that ties.

## What a true match is
A match requires AMOUNT plus reasonable DATE PROXIMITY, not amount alone. A GBP 1,200.00 book entry on the 3rd matching a GBP 1,200.00 statement line on the 5th is a plausible match (2-day clearing lag). The same amount weeks apart, or two book lines competing for one statement line, is a red flag, not a match. Also check direction (debit vs credit / money in vs out) and counterparty/reference where available. Many wrong reconciliations come from auto-matching on amount only and pairing the wrong two transactions - which leaves a real item unmatched and a phantom one "cleared".

## Many-to-one and one-to-many matches
A single statement deposit often covers several book receipts batched together (and vice versa). The group's amounts must sum exactly and sit within the clearing window. Do not split a statement line across unrelated book items just to make totals work; that hides a genuine discrepancy. If a batched deposit is short by one cheque, the missing cheque is the reconciling item, not the whole batch.

## Common causes of an off-by
- Missed bank-only item: an uncaptured fee, interest, or direct debit - the most frequent single-line difference.
- Outstanding cheque not yet presented: legitimate timing, not an error; confirm it is still outstanding, not stale.
- Duplicate: the same transaction posted twice on one side (double the amount appears, or one side is exactly 2x).
- Transposition error: digits swapped (wrote 540 for 450). Tell-tale: the difference is divisible by 9.
- Sign/direction error: a receipt booked as a payment or vice versa. Tell-tale: the difference equals exactly 2x the transaction amount.
- Omission: a transaction on one side never recorded on the other.
- Wrong account: posted to the wrong bank/GL account, so it never appears where expected.

## Diagnosing the off-by amount
Use the difference to point at the cause before hunting line by line:
- Difference divisible by 9 -> likely a transposition (digit swap).
- Difference is exactly twice a known transaction -> likely a sign/direction error on that item.
- Difference equals a round, recognisable amount -> likely a single missed item of that value (find that exact figure on the unreconciled side).
- Difference equals 2x an existing line -> likely a duplicate.
These are heuristics to prioritise the search, not proof; still verify the actual transaction.

## Error vs timing: how to tell
Timing items will clear on their own next period: a deposit in transit appears on next month's statement; an outstanding cheque presents later. If an item has NOT cleared after a reasonable window, it has stopped being a timing item:
- A cheque outstanding beyond its validity (commonly ~6 months / stale-dated) will likely never present - void it and reinstate the cash/payable rather than carrying it forever.
- A deposit in transit that never lands was misrecorded, lost, or already counted - investigate as an error.
A difference is a TIMING item only if you can name the specific in-flight transaction and the period it will clear. A difference you cannot pin to a named in-flight transaction is an ERROR until proven otherwise - never plug it.

## Do not plug the difference
An unexplained residual is not a reconciling item and must never be written off to a suspense or "bank adjustment" line to force agreement. Every figure in the reconciliation must be a named, evidenced transaction. If a small residual cannot be explained, document it, flag it, and escalate; do not bury it. A plugged reconciliation hides duplicates, fraud, and posting errors that compound next period.

## Carry-forward and clearing discipline
Outstanding items roll to the next period until they clear. Each period, first clear last period's carried items against the new statement, then identify new ones. An item that has been carried for several periods is a problem (stale cheque, lost deposit, or an error masquerading as timing) and must be investigated, not re-carried silently. Reconciled/cleared status should be marked per line so an item is never matched twice.

## Opening balance and prior-period integrity
This period's reconciliation only ties if the prior period reconciled cleanly. The book opening balance plus this period's GL cash movements must equal the closing book balance you are reconciling. If the opening balances disagree, fix the prior period first - a broken prior reconciliation propagates forward and makes the current off-by uninterpretable.
