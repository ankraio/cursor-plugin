---
name: ankra-harden
description: Run a security pass over an Ankra organisation: tokens, access grants, secrets, and image findings
---

Review the security posture of the Ankra organisation the user names and report
findings ranked by exposure. Read the `ankra-security` and `ankra-sops-secrets` skills first.
This is a read-and-report pass: change nothing without asking.

1. **Identity and tokens.** `ankra tokens list` — flag tokens with no expiry, tokens holding
   `mcp:write` that only need `mcp:read`, and anything unused. `ankra org members` and
   `ankra org roles` for who holds what.
2. **Cluster access.** `ankra cluster access list` per cluster: flag every standing `admin` or
   `cluster-admin` grant (no Expires) and every cluster-wide grant that could be namespace-scoped.
   `ankra org access-policy get`: flag an organisation with no ceiling or no elevated lifetime.
3. **Secrets.** Confirm nothing sensitive is committed in plaintext: every SOPS-encrypted value has
   its `encrypted_paths` declared (`ankra cluster stacks list <stack> -o json`), and
   `ankra cluster sops-config` shows the key in use. Check application environment secrets are set
   rather than defaulted (`ankra application env-secrets list`).
4. **Supply chain.** `ankra application container-security <id>` and `ankra application code-security <id>`
   per application; flag any application whose build workflow has no scanning step
   (`ankra application upgrade-workflow` adds it). Flag floating image tags and unpinned chart
   versions — a mutable tag defeats every other control here.
5. **Agent autonomy.** `ankra org mcp-servers list` and `ankra org mcp-servers grants <server>` — flag
   read_write tiers and tool grants wider than the role needs. Check which integrations run in
   Agent rather than Ask mode.
6. **Registry and credential scope.** `ankra credentials list`, `ankra helm credentials list` — flag
   any credential that is broader than the repositories it is used for
   (`ankra credentials repositories <name>` shows what it can actually reach).

Report a ranked list: what is exposed, how it could be used, and the one command or change that
closes it. Do not print secret values.
