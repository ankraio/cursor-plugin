---
name: ankra-profile
description: Capture a working cluster stack as a reusable, parameterised stack profile for the fleet
---

Turn a stack that works on one cluster into a reusable stack profile other clusters
and organisations can launch. Read the `ankra-stack-profiles` skill first, then `ankra-stacks-addons`.

1. **Pick the source.** `ankra cluster stacks list` on the cluster where it works. The source stack
   should be one concern, pinned, and already verified.
2. **Open a builder draft from it.**
   `ankra stack-profiles drafts create --name <profile> --source-cluster <cluster> --source-stack <stack>`.
3. **Turn the cluster-specific values into parameters.** `ankra stack-profiles drafts get <draft>` lists
   what was detected. Every domain, size, replica count, storage class and credential must be a
   parameter, not a literal carried over from the source cluster. Annotate each one with
   `ankra stack-profiles drafts annotate` so the launch form explains itself.
4. **Group the choices that move together.** Where one decision drives several inputs (a "model
   size" that sets the model id, the context length and the volume), declare it with
   `ankra stack-profiles drafts options set` so whoever launches it picks one thing instead of keeping
   four consistent.
5. **Mark the secrets.** Secret parameters must be declared as such, and any encrypted value needs
   its `encrypted_paths`. Opening a draft on a published profile drops encrypted paths — re-declare
   them before publishing.
6. **Validate, then publish.** `ankra stack-profiles drafts validate <draft>`, then
   `ankra stack-profiles drafts publish <draft> --changelog "..."`.
7. **Prove it launches clean.** `ankra stack-profiles apply <profile> --cluster <other> --dry-run` shows
   the value every input resolves to; then apply for real as a draft and review before deploying.
8. **Distribute.** `ankra stack-profiles share add` for named organisations,
   `ankra stack-profiles export-iac` to keep the definition in Git.
