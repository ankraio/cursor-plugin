---
name: ankra-new-cluster
description: Stand up a new Ankra cluster: provider, region, instance family, GitOps, ingress, DNS and TLS
---

Stand up a cluster on Ankra for the user, from the provider choice through to a
hostname that resolves with TLS. Read the `ankra-getting-started` skill first, then
`ankra-cloud-clusters` (or `ankra-managed-kubernetes`) and `ankra-domains-dns`.

Settle these five before creating anything - creating first and retrofitting is the expensive path:

1. **Import or build?** If Kubernetes already runs, adopt it (`ankra-import-cluster`, or
   `ankra cluster managed discover` / `import` for a managed cluster) instead of building a second one.
2. **Who runs the control plane?** `ankra cluster managed create` when the provider should own its
   uptime and you do not need cluster-admin over it; `ankra cluster <provider> create` when you need
   control-plane access, node-level control, or a provider with no managed offering.
3. **Region and instance family.** Never guess these. List them for the actual credential:
   `ankra cluster hetzner locations|server-types`, `ankra cluster digitalocean regions|sizes`,
   `ankra cluster ovh regions --with-zones`, `ankra cluster proxmox sizes|hosts`,
   `ankra cluster morpheus plans|layouts`. A region the account cannot deploy in fails late, at
   private-network setup. Size the control plane and workers per the table in
   `ankra-cloud-clusters/reference.md`, and use `--control-plane-count 3` for anything that must
   survive losing a node.
4. **The GitOps repository.** Pass `--gitops-repository`, `--gitops-credential-name` and
   `--gitops-branch` on the create command itself, so the generated cloud-provider stack lands as a
   reviewable commit rather than existing only in the platform.
5. **The domain.** The generated `<cluster>.ankra.cc` subdomain needs nothing and gives you HTTPS
   today. Your own domain either delegates to Ankra (`ankra org domain set`) or stays in your DNS
   account and is declared with `ankra org custom-dns-zones add`. Declare org-wide, or clusters
   created later come up with your hostnames silently unserved.

Then:

- **Store the credentials first** (`ankra credentials <provider> create`, plus an SSH key credential);
  `create` takes credential **IDs**, which `ankra credentials list` gives you.
- **Take the batteries.** `--external-cloud-provider`, `--include-networking` and `--include-dns`
  default on and give load balancers, volumes, ingress, DNS and TLS from the first minute.
- **Create, then watch.** `create` has no `--wait`: follow with `ankra cluster operations list` and
  `ankra cluster agent status`. Do not re-submit.
- **Verify before handing it over:** the agent is online, nodes are Ready, a test Ingress on the
  cluster domain resolves and serves a valid certificate.

Report the cluster id, its domain, what was installed, what it costs per month at this size, and
the one command to tear it down.
