---
name: ankra-promote
description: Promote a verified change from dev or staging to production across one or many clusters
---

Promote a change that is already verified in a lower environment to the next one,
without rebuilding it. Read `ankra-platform-principles`, `ankra-stack-profiles` and `ankra-gitops`.

1. **Establish what is verified.** The exact image tag or digest, the chart version, and the
   cluster it is verified on. If nothing is pinned, stop: promote a pinned artefact or nothing.
2. **Diff the environments.** `ankra cluster stacks list <stack> -o json` on both clusters, or
   `ankra stack-profiles diff <profile> --from <v> --to <v>` for a profile. Name every difference that
   is deliberate (sizes, replicas, domains) and every one that is drift.
3. **Promote the same artefact.** Commit the verified tag to the production path in the GitOps
   repository, or `ankra stack-profiles apply <profile> --cluster <prod> --version <v>` binding the
   production values with `--set` / `--set-file` / `--set-env`. Never rebuild for production.
4. **Land it as a reviewable draft first.** `ankra stack-profiles apply` without `--deploy`, or
   `ankra cluster draft -f cluster.yaml`, stages the change for review instead of deploying it.
   Use `--dry-run` to show exactly which value every input resolves to.
5. **Roll out, then verify** with operations, pods, and logs before touching the next cluster.
   For a fleet, do one cluster, verify, then the rest — never all at once.
6. **Know the rollback.** `git revert` for a GitOps change, `ankra cluster roll-to` for a resource
   version, `ankra stack-profiles set-current-version` for a profile. State it before you deploy.
