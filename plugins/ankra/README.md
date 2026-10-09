# Ankra for Cursor

Build, ship and operate Kubernetes with [Ankra](https://ankra.ai) from Cursor.

The plugin gives the Cursor agent three things:

- **The Ankra MCP server.** Live access to your clusters, workloads, logs, metrics, alerts, stacks, applications and pipelines, plus the actions your token allows.
- **Agent skills.** Ankra's own guidance for clusters, stacks and Helm addons, GitOps, CI/CD, secrets, DNS and TLS, observability, security and troubleshooting. The agent loads the one that matches the task.
- **Slash commands.** Guided entry points for the common jobs.

You need an Ankra account. Sign up at [ankra.ai](https://ankra.ai).

## Setup

1. Install the plugin from the Cursor Marketplace.
2. The first time the `ankra` MCP server connects, Cursor opens a browser window. Sign in to Ankra and pick the organisation the agent should work in. If the server shows as off, turn it on under **Cursor Settings > MCP**.
3. Optional, recommended: install the Ankra CLI, which the skills use for many operations.

   ```bash
   brew install ankraio/tap/ankra    # or: bash <(curl -sL https://github.com/ankraio/ankra-cli/releases/latest/download/install.sh)
   ankra login
   ```

Ask the agent "which Ankra clusters do I have?" to check the connection.

### Signing in with a token instead

If the browser sign-in does not complete, connect with a personal token instead. Turn off the plugin's `ankra` server, create a token, and add the server to your user-level `~/.cursor/mcp.json`:

```bash
ankra tokens create cursor --scopes mcp:read            # read-only
ankra tokens create cursor --scopes mcp:read,mcp:write  # read and write
```

```json
{
  "mcpServers": {
    "ankra": {
      "url": "https://platform.ankra.app/api/v1/mcp",
      "headers": { "Authorization": "Bearer <ankra-token>" }
    }
  }
}
```

Keep the token out of project files that are committed. A token is bound to the organisation that was selected when it was created.

## Slash commands

| Command | What it does |
|:--|:--|
| `/ankra-new-cluster` | Stand up a new cluster: provider, region, instance family, GitOps, ingress, DNS and TLS |
| `/ankra-ship-service` | Ship the code in this repository to a live, verified deployment on Ankra Pipelines |
| `/ankra-triage` | Investigate a failing workload, deployment or Ankra operation and propose the fix |
| `/ankra-connect-app` | Connect an application to an existing platform service and its secrets |
| `/ankra-promote` | Promote a verified change from dev or staging to production |
| `/ankra-profile` | Capture a working cluster stack as a reusable stack profile |
| `/ankra-harden` | Run a security pass over an organisation: tokens, access grants, secrets and image findings |

## Skills

| Area | Skills |
|:--|:--|
| Start here | `ankra-platform-principles`, `ankra-getting-started`, `ankra-cli` |
| Clusters | `ankra-cloud-clusters`, `ankra-managed-kubernetes`, `ankra-import-cluster`, `ankra-domains-dns`, `ankra-backups` |
| Stacks and GitOps | `ankra-stacks-addons`, `ankra-stack-profiles`, `ankra-gitops`, `ankra-helm-registries`, `ankra-sops-secrets`, `ankra-terraform` |
| Applications and CI/CD | `ankra-ship`, `ankra-applications`, `ankra-cicd`, `ankra-app-integrations`, `ankra-migrate` |
| Operations | `ankra-troubleshooting`, `ankra-observability`, `ankra-alerts-webhooks` |
| Security and AI | `ankra-security`, `ankra-ai-agents`, `ankra-ai-gateway` |

The plugin also adds a rule, applied when a task involves Kubernetes on Ankra, that steers the agent to change clusters through Ankra and GitOps rather than with direct `kubectl` or `helm` mutations.

## Safety

- What the agent can change is limited by the scopes you grant: `mcp:read` only reads, `mcp:write` can also act. Revoke a token at any time with `ankra tokens revoke` or in the Ankra portal.
- Tool results include text from your clusters and repositories (logs, events, manifests). The server strips invisible Unicode from them and tells the agent to treat them as data, not instructions.

## Links

- [Ankra documentation](https://docs.ankra.ai)
- [MCP server](https://docs.ankra.ai/platform/mcp-server)
- [Ankra CLI](https://docs.ankra.ai/integrations/ankra-cli)
- Support: support@ankra.ai
