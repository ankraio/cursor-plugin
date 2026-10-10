# Ankra plugin for Cursor

The [Ankra](https://ankra.ai) plugin for the [Cursor Marketplace](https://cursor.com/marketplace). It connects the Cursor agent to the hosted Ankra MCP server and adds Ankra's agent skills, a rule and slash commands for building, shipping and operating Kubernetes through Ankra.

Using the plugin: see [plugins/ankra/README.md](plugins/ankra/README.md).

## Layout

```text
.cursor-plugin/marketplace.json   marketplace manifest
plugins/ankra/
  .cursor-plugin/plugin.json      plugin manifest
  mcp.json                        the hosted Ankra MCP server (browser sign-in)
  rules/ankra.mdc                 when and how to work through Ankra
  skills/                         generated from ankra-cli, do not edit here
  commands/                       generated from ankra-cli, do not edit here
  assets/logo.svg
  SOURCE                          the ankra-cli release the skills and commands came from
scripts/
  sync-from-cli.sh                regenerate skills and commands
  sync-latest-release.sh          download, verify and sync a release (used by the scheduled workflow)
  validate-template.mjs           Cursor's plugin validator, from cursor/plugin-template
```

## Updating the skills and commands

The skills and commands are maintained in [ankraio/ankra-cli](https://github.com/ankraio/ankra-cli) (`internal/skills`) and also ship through `ankra skills install`. Change them there, cut a CLI release, then regenerate this plugin from that release:

```bash
brew upgrade ankra            # the installed CLI must match the release
scripts/sync-from-cli.sh      # defaults to the installed CLI's version
node scripts/validate-template.mjs
```

Bump `version` in `plugins/ankra/.cursor-plugin/plugin.json` when the plugin content changes.

This also runs on its own: the **Sync from ankra-cli release** workflow (`.github/workflows/sync-from-cli.yml`) checks ankra-cli's latest stable release every morning. When it is newer than `plugins/ankra/SOURCE`, `scripts/sync-latest-release.sh` downloads that release's binary, verifies its checksum, regenerates the skills and commands, bumps the minor version and validates, and the workflow opens (or updates) a pull request from `sync/ankra-cli-release`. It uses only the repository's `GITHUB_TOKEN`. Run it by hand from the Actions tab, optionally with a `tag` or as a `dry_run`. The same script works locally without an installed `ankra`:

```bash
scripts/sync-latest-release.sh            # latest stable release
scripts/sync-latest-release.sh v0.30.0    # a specific release
```

## Testing locally

```bash
mkdir -p ~/.cursor/plugins/local
cp -R plugins/ankra ~/.cursor/plugins/local/ankra-marketplace
```

Reload Cursor (**Developer: Reload Window**) and check that the rule, skills, commands and the `ankra` MCP server appear. If `ankra skills install` already wrote a local `ankra` plugin, move it aside while testing so the two do not overlap.

## License

[Apache-2.0](LICENSE)
