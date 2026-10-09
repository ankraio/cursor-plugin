---
name: ankra-ship-service
description: Ship the code in this repository to a live, verified deployment on Ankra Pipelines and wire day 2
---

Take the service in the current repository (or the path the user names) from source
to a running, verified deployment on Ankra, and leave it wired for day 2. Read the
`ankra-ship` skill first, then `ankra-applications` and `ankra-platform-principles`;
`ankra-cicd` only if the repository is not, and will not be, an Ankra application.

Work in this order and confirm the target with the user before anything mutating:

1. **Orient.** `ankra login status`, `ankra org current`, `ankra cluster list`,
   `ankra org ci-settings get`, `ankra cluster agent ci get --cluster <cluster>`. Establish the
   organisation, the target cluster, that the CI cluster has workers advertised, and whether the
   repo is already an application (`ankra application list`). Zero CI workers means zero runs and
   no error - fix it here (`ankra cluster agent ci set --workers 2 --cluster <cluster>`).
2. **Make the source shippable.** One port from the environment, a health endpoint, config from
   env vars only, no committed secrets, a lockfile and one test command, a Dockerfile if the
   framework is unusual. Fix and commit before registering - the first run is the one everyone
   watches.
3. **Ship.** `ankra application ship . --cluster <cluster>` (add `--name` in a monorepo,
   `--ankra-build` for an unattended first image, `--registry-url`/`--registry-credential`
   when the organisation already runs a registry - declare it now, not later). It registers, waits
   for the setup PR, the first image, the deploy and the healthy installation, then prints
   `Live: https://...`. On a timeout, re-run the same command: it resumes.
4. **Read what Ankra generated.** `ankra application branch-files <id>` - the Dockerfile's entrypoint
   and port, `.ankra/pipeline.yaml`'s test command and scanners, the manifests' probes and
   requests. Push corrections back with `ankra application files`.
5. **Approve the authority.** `ankra pipeline definitions approve <definition-id>` needs a human;
   an unapproved definition runs with no registry auth and the build is refused. If you are an
   agent, stop and ask here.
6. **Run and gate.** `ankra pipeline run --application <id> --wait`, then
   `ankra pipeline findings <run> --application <id>` and `ankra pipeline logs <run> --application <id> --step build`.
   A failed run names its error class: `step_failed` is the code, `image_gate_blocked` is a
   finding, `build_runtime_confined` is the node (fall back to platform builders).
7. **Supply configuration and secrets.** `ankra application env-secrets list <id>`, set each by stdin
   (never `--value`), then `ankra application env-secrets apply <id>`. Non-secret values are
   organisation or cluster variables.
8. **Verify before claiming.** `ankra cluster operations list --cluster <cluster> --failed`,
   `ankra cluster get pods -n <ns>`, `ankra cluster events -n <ns> --type Warning`,
   `ankra cluster logs -l app=<name> -n <ns> --follow=false`, and a curl of the health endpoint.
9. **Wire day 2.** `ankra application auto-deploy get <id>` (on by default; turn it off for
   production with `--enabled=false` and promote the same `sha-` tag instead); previews on
   pull requests (`ankra application demo deploy <id> --pr-number <n>`, and a wildcard DNS record
   for the preview domain); route `pipeline_run_failed` and `image_gate_blocked` with
   `ankra alerts routes create`; read the AI reviews with
   `ankra application pull-request-reviews <id>`. Auto-fix of a broken build is already on.
10. **Reach the rest of the fleet.** A published add-on (`ankra application publish-addon`) or a
    stack profile (`ankra-stack-profiles`) with per-cluster parameters - never copied YAML.

Report back: the application id, the pipeline run and its outcome, the registry and the
`sha-` tag it published, which clusters it is live on, the URL(s), what the AI reviewed or
fixed, and what is still manual (an approval you could not give, a DNS record, a merge).
