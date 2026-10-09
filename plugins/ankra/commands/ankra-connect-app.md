---
name: ankra-connect-app
description: Connect an application to an existing platform service and its secrets (LiteLLM, Harbor, a database, an internal API)
---

Connect the application the user names to a service that already runs in this
organisation — an LLM gateway (LiteLLM), a container registry (Harbor), a database, an
internal API — using the credentials that already exist rather than minting new ones by hand.
Read the `ankra-app-integrations` skill first, then `ankra-sops-secrets` and `ankra-security`.

1. **Find the service.** `ankra cluster stacks list` and `ankra cluster addons list` show what is
   deployed. `ankra cluster get services -n <namespace>` gives the in-cluster DNS name and port —
   that, not a public URL, is what a same-cluster consumer should use.
2. **Find the credential that already exists.** `ankra cluster addons values <addon>` (and
   `ankra cluster decrypt addon` where values are SOPS-encrypted) shows how the service itself is
   configured; `ankra credentials list` and `ankra helm credentials list` show the stored ones.
   Reuse an existing key or issue a scoped one from the service — never copy an admin token
   into an application.
3. **Decide where the value lives.** Application environment secrets
   (`ankra application env-secrets set`) for values only that application needs; a SOPS-encrypted
   manifest in the GitOps repo with `encrypted_paths` declared for anything a stack deploys; a
   cluster or organisation variable (`ankra cluster variables set` / `ankra org variables set`) for
   non-secret values such as base URLs and model names.
4. **Wire the consumer.** Point the application at the in-cluster endpoint, inject the secret by
   reference (a Secret `envFrom`/`valueFrom`, not a literal), and pin any model, chart or image
   version it depends on.
5. **Prove it end to end.** Roll the consumer, then read its logs for a successful call. For an
   LLM gateway, make one real request and confirm the gateway logged it. For a registry, confirm
   a pull with the generated `dockerconfigjson` pull secret actually succeeds.
6. **Leave it reproducible.** Every change lands in committed YAML or in Ankra's stored state —
   nothing configured only by hand in a live pod.

Never print a decrypted secret into the terminal transcript, a pull request, or chat.
