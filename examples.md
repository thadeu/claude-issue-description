# Examples

## Stakeholder postmortem (`/issue:desc`)

```markdown
## Postmortem — User signup redirect loop

**What happened**
New users who paid their first invoice via bank slip but had not yet created an attendant account were stuck in an infinite redirect between two onboarding screens.

**Why**
Two onboarding rules conflicted: one screen required payment acknowledgment before continuing; another required an attendant before showing the acknowledgment screen. The system never marked the payment as acknowledged.

**Impact**
Affected users could not complete signup after their first payment.

**How we fixed it**
1. **Immediate:** manual database update to mark payment as acknowledged for the affected user.
2. **Permanent:** code change to allow the acknowledgment screen without a registered attendant.

**Prevention**
Deploy the code fix to production so new signups cannot hit the same loop.
```

## Stakeholder short (`/issue:desc` — Slack style)

```markdown
**Summary:** Signup loop after first paid invoice with no attendant on the account.
**Cause:** Two onboarding screens redirected to each other; payment acknowledgment never ran.
**Fix:** DB hotfix for affected user + PR skipping attendant check on acknowledgment page.
**Status:** User unblocked; permanent fix deploy pending.
```

## Developer issue (`/issue:tech`)

```markdown
## Bug — Infinite redirect on /payments/acknowledge

### Summary
New users with a paid boleto payment and zero attendants enter a redirect loop between `/payments/acknowledge` and `/attendant_activations/new`. `acknowledged_first_payment` never flips to `true` because the acknowledge action never runs.

### Steps to reproduce
1. Create a user with `enabled_price_and_payments`, no attendants, `acknowledged_first_payment: false`.
2. Create a paid payment (`mundipagg_boleto`, state `paid`).
3. Sign in and hit any internal route (or go directly to `/attendant_activations/new`).
4. Observe 302 loop: `acknowledge` → `attendant_activations/new` → `acknowledge`.

### Expected vs actual
- **Expected:** user lands on `/payments/acknowledge`, `acknowledge_first_payment` runs, page renders.
- **Actual:** `check_attendants_and_redirect!` fires before the action and redirects away; flag stays `false`.

### Root cause
`InternalValidations` runs `check_attendants_and_redirect!` (line 13) before `check_first_payment_and_redirect_to_acknowledge!` (line 19). `PaymentsController#acknowledge` skips the payment check but not the attendant check. `AttendantActivationsController` does the opposite — loop.

### Fix
Skip `check_attendants_and_redirect!` on `PaymentsController#acknowledge` (and `check_status`).

### Developer notes
- Hotfix for stuck users: `user.update_column(:acknowledged_first_payment, true)`.
- Add controller spec: user with paid payment, no attendants → `acknowledge` renders template (no redirect).
- Users with cached redirect cookies may need a fresh session after deploy.

### Checklist
- [x] Root cause documented
- [x] Fix implemented
- [x] Regression test added
- [ ] Deployed to production
- [ ] Affected users verified
```

## Deploy note (`/issue:desc deploy`)

```markdown
## Deploy — First payment acknowledgment in onboarding

**What changed**
Users with a confirmed first payment can now see the acknowledgment screen before registering an attendant.

**Why**
The previous flow caused a redirect loop for new accounts with a paid invoice and no attendant.

**Impact**
Onboarding flow improvement only; no business rule change.

**Status**
Ready to deploy after merge.
```
