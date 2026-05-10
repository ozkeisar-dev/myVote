<!--
Fill in every section. Delete sections only if they are genuinely N/A
(say so explicitly — e.g. "N/A — docs-only change").
-->

## Summary

<!-- 1–3 bullets. Focus on the WHY, not the WHAT (the diff already shows what). -->

-

## Linked issue

<!-- Required. Use the Multica issue identifier and a link. -->

[MYV-NN](https://multica.ai/issue/...)

## Test plan

<!--
What did you actually run? Paste the commands and the relevant output.
For UI changes, attach screenshots or a short recording.
-->

- [ ] `pnpm -r typecheck`
- [ ] `pnpm -r lint`
- [ ] `pnpm -r test` (if test scripts exist)
- [ ] Manual / UI verification (attach screenshots or recording for UI changes)

## Breaking change?

<!-- Anything that requires consumers to update code, env vars, or infra. -->

- [ ] No
- [ ] Yes — migration notes:

## Migration safety

<!--
For DB / schema / data shape / env-var changes only.
Skip ("N/A") if this PR doesn't touch any of those.
-->

- [ ] N/A
- [ ] Schema change — backfill plan:
- [ ] Reversible? (how to roll back):
- [ ] Deploys cleanly with old + new code running side by side?

## Reviewer checklist

<!--
The CODEOWNERS file auto-requests reviewers based on the changed paths.
Reviewers tick the relevant boxes; do not delete this section.
-->

- [ ] Architecture / standards (Tech Lead or Team Lead)
- [ ] QA / acceptance criteria (QA Engineer)
- [ ] Secrets handling — no plaintext secrets, naming follows `docs/secrets.md`
- [ ] Docs / runbooks updated if behaviour changed
