---
name: ankra-triage
description: Investigate a failing workload, deployment, or Ankra operation and propose the fix
---

Triage what is broken on the Ankra-managed cluster the user names. Read the
`ankra-troubleshooting` skill first. Work read-only until you have a diagnosis; propose the
change, do not apply it unasked.

1. **Scope it.** `ankra cluster info` to confirm the cluster, then
   `ankra cluster operations list` — a failed platform execution explains far more failures than
   the pod logs do. `ankra cluster operations steps <id>` for the failing step.
2. **Look at the object.** `ankra cluster get pods -n <ns>`, then
   `ankra cluster describe pod <name> -n <ns>` for conditions and its own events, and
   `ankra cluster events -n <ns>` for the namespace timeline.
3. **Read the log that has the failure in it.** For CrashLoopBackOff that is the previous
   container: `ankra cluster logs <pod> -n <ns> --previous`. For a set of replicas use
   `ankra cluster logs -l <selector> -n <ns> --follow=false --tail 200`, and `--all-containers` when an
   init container is the suspect.
4. **Check resources before blaming the code.** `ankra cluster top pods -n <ns>` and
   `ankra cluster top nodes` read the metrics API directly; `ankra cluster metrics query '<promql>'`
   for trends where Prometheus is installed.
5. **Classify.** Configuration or secret missing, image or chart version, scheduling and capacity,
   dependency ordering (a stack resource whose `parents` are wrong deploys too early), an
   external dependency, or genuine application code.
6. **Propose the smallest correct fix**, at the right layer: stack/addon values and ordering for
   platform problems, the application repository and a pull request for code problems. Say which
   one it is. For a terminal execution that failed on a transient cause, `ankra cluster operations retry <id>`
   is the right move — say so rather than re-applying everything.

Finish with: what is broken, the evidence, the fix, and the blast radius of applying it.
