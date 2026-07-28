# Reclasses and corrections · Fixing the books cleanly

## Three distinct fixes, never conflate them
Reclass: right amount, right period, WRONG account. Move balance between accounts; net P&L and net cash unchanged. Correction: WRONG amount (typo, duplicate, wrong sign, wrong rate). Changes P&L/balances. Adjustment: amount was an ESTIMATE that new information updates (accrual true-up, depreciation, allowance, FX revaluation). Each maps to a different journal and a different memo. Picking the wrong one corrupts the audit trail even when the closing balance lands correct.

## Reclass mechanics
Move X from account A to account B: DR B, CR A (or the reverse to pull out of B). Amount and date unchanged from the original. A reclass between two P&L accounts in the same period leaves net income flat, it only re-buckets. A reclass between two balance-sheet accounts leaves equity flat. RED FLAG: a "reclass" that changes total debits vs the original entry is not a reclass, it is a correction, relabel it. Reclass that crosses the P&L/balance-sheet line (e.g. expense to prepaid asset) DOES change current-period income, treat as an adjustment, document the basis.

## Correction mechanics
Two clean shapes. (1) Reverse-and-repost: book the exact opposite of the wrong entry, then post the right entry fresh, two journals, original preserved. (2) Delta journal: post only the difference (DR/CR the variance) when the original was directionally right but mis-sized. Prefer reverse-and-repost when account, sign, or date is wrong; prefer a delta when only the amount drifted and the original lines are otherwise correct. NEVER silently overwrite the original number in place if anyone downstream (auditor, tax, prior report) has consumed it.

## Adjustment mechanics
Estimate updates: book the change as a new entry dated in the current open period, not by rewriting the prior estimate. Accrual true-up: reverse the original accrual when the actual lands (or post the difference). Depreciation/amortization revisions are prospective, adjust future periods, do not restate booked past depreciation unless it was an error. Allowance/provision changes hit P&L in the period the estimate changes. Tag adjustments so they are distinguishable from errors: an estimate revision is not a mistake and should not read like one in the trail.

## Reverse-and-repost vs edit-in-place, the decision rule
Edit-in-place ONLY when: period is open AND the entry is unposted/draft AND nothing downstream has consumed it (no report issued, no return filed, no payment matched). Otherwise REVERSE-and-repost. Editing a posted entry destroys the original values; the trail then shows the corrected state with no record of what was wrong or why, the single most common way an AI corrupts auditability. Most ledgers (Xero ManualJournals, Intacct posted GLBATCH, NetSuite posted journals, QBO via audit log) treat posted entries as immutable-by-policy and expect a reversing entry, not a mutation.

## Closed period, do not edit it
A closed/locked period is closed for a reason: reports issued, VAT/tax filed, balances rolled to retained earnings. Writing into it (where the system even allows it) silently changes already-reported numbers and breaks reconciliation against filed figures. Two legitimate paths: (1) book an adjusting entry in the current OPEN period that corrects the cumulative balance going forward; (2) a documented, approved REOPEN of the closed period, make the fix, re-close, and re-issue affected reports. Default to path 1 unless the error is material enough to force a restatement.

## Prior-period adjustments
Immaterial prior-period error: correct in the current open period via a normal adjusting entry; no restatement. Material prior-period error: this is a restatement, the prior comparative figures themselves are corrected and equity (retained earnings / opening reserves) is adjusted, not current-period P&L. An AI must NOT decide materiality alone, flag, quantify the impact, and route to a human for the restate-vs-current-period call. The mechanical default an agent can safely propose: a current-period adjusting entry with a memo citing the original period and document.

## Suspense-account clearing
Suspense (a.k.a. clearing/uncategorized) holds amounts you cannot yet classify, never a resting place. Goal: suspense nets to zero every close. Clear by reclass: DR/CR the suspense line against the now-known correct account, same amount, dated when identity is established (or back to the open period of origin). A stuck suspense balance signals an unresolved bank line, an unmatched payment, or a failed import. Before closing, list every suspense entry, its age, and its blocker. NEVER close a period with un-investigated suspense, it hides errors that compound.

## One memo per correction
Every correcting/reclass/adjusting journal carries its OWN memo that states: what was wrong, the original entry reference (journal no / date), why the fix is correct, and who/what authorized it. One memo, one correction, do not bundle several unrelated fixes under one reference or one journal, because reversal, audit, and dispute resolution then cannot isolate a single change. The memo is the human-readable half of the audit trail; the journal lines are the machine half. A correction with no memo is indistinguishable from a fat-finger.

## Idempotency, never double-post a correction
A correction retried after a network timeout, or a fix re-proposed because the first looked un-applied, double-counts and creates a NEW error. Guard every correction with an idempotency key (client-generated id echoed by the platform: Intacct controlid+uniqueid, QBO RequestID, Xero idempotency header, verify against live docs per platform). Before posting, check whether a journal already exists referencing the same original entry + same memo + same amount; if found, treat the operation as already done. Reverse-and-repost is itself a two-step that must be atomic or idempotent, a reversal posted twice un-does and re-does, leaving the original error live.

## Tamper-evident audit trail
The point of reverse-over-edit, one-memo-per-fix, and idempotency is a trail where every state change is appended, attributed, timestamped, and reason-coded, never overwritten. A correct trail lets anyone reconstruct: the wrong value, the corrected value, who changed it, when, why, and under what authorization. Append-only + reversing entries make tampering detectable; in-place edits make it invisible. An AI posting to a real ledger must assume an auditor will replay the trail: every entry it creates should stand alone as evidence, not require tribal knowledge to interpret.

## Sharp edges
- A "reclass" that nets P&L to non-zero is a misfiled correction, re-classify the action before posting.
- Delta corrections silently inherit the original's date and tax treatment; if those were also wrong, a delta will not fix them, use reverse-and-repost.
- Reversing entries must use the ORIGINAL period's date logic, but if that period is closed, date the reversal in the open period and note the original.
- Tax/VAT corrections crossing a filed period are not just GL fixes, they may require an adjustment on the next return, not a journal rewrite.
- "Edit-in-place looks cleaner" is a trap: the cleaner the ledger looks after an in-place edit, the more history was destroyed.
- Foreign-currency corrections: fix at the ORIGINAL FX rate for a true correction; a rate change is a revaluation adjustment, a different entry.
- Suspense cleared to the wrong account is a reclass-on-a-reclass, trace to the source line, do not stack guesses.
