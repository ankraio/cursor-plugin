#!/usr/bin/env bash
# Brings the plugin up to an ankra-cli release without a locally installed CLI.
#
# Resolves the release (the argument, or ankra-cli's latest stable release),
# exits early when plugins/ankra/SOURCE already names it, otherwise downloads
# that release's `ankra` binary, verifies it against the published .sha256,
# runs scripts/sync-from-cli.sh with it, bumps the plugin's minor version and
# runs the Cursor validator. The scheduled workflow .github/workflows/sync-from-cli.yml
# calls this and opens the pull request; it also works by hand.
#
# Usage: scripts/sync-latest-release.sh [vX.Y.Z]
# Writes `tag=` and `changed=` to $GITHUB_OUTPUT when that is set.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
plugin="$root/plugins/ankra"
repo="ankraio/ankra-cli"

output() {
	echo "$1=$2"
	if [ -n "${GITHUB_OUTPUT:-}" ]; then echo "$1=$2" >>"$GITHUB_OUTPUT"; fi
}

tag="${1:-}"
if [ -z "$tag" ]; then
	# /releases/latest never returns a draft or a pre-release.
	tag="$(curl -fsSL -H "Accept: application/vnd.github+json" \
		${GH_TOKEN:+-H "Authorization: Bearer $GH_TOKEN"} \
		"https://api.github.com/repos/$repo/releases/latest" |
		node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>process.stdout.write(JSON.parse(s).tag_name||""))')"
fi
# Stable tags only, and nothing that could smuggle shell or path syntax.
if ! [[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "refusing release tag '$tag': expected vMAJOR.MINOR.PATCH" >&2
	exit 1
fi

current="$(awk 'NR == 1 { print $2 }' "$plugin/SOURCE")"
output tag "$tag"
if [ "$tag" = "$current" ]; then
	echo "plugin already built from ankra-cli $tag; nothing to sync"
	output changed false
	exit 0
fi

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$(uname -m)" in
	x86_64 | amd64) arch=amd64 ;;
	arm64 | aarch64) arch=arm64 ;;
	*) echo "unsupported architecture $(uname -m)" >&2; exit 1 ;;
esac
asset="ankra-cli-$os-$arch"

bin="$(mktemp -d)"
trap 'rm -rf "$bin"' EXIT
base="https://github.com/$repo/releases/download/$tag"
curl -fsSL -o "$bin/ankra" "$base/$asset"
curl -fsSL -o "$bin/ankra.sha256" "$base/$asset.sha256"
# Fail closed: a release without a checksum is not synced.
expected="$(awk 'NR == 1 { print $1 }' "$bin/ankra.sha256")"
if command -v sha256sum >/dev/null; then
	actual="$(sha256sum "$bin/ankra" | awk '{ print $1 }')"
else
	actual="$(shasum -a 256 "$bin/ankra" | awk '{ print $1 }')"
fi
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
	echo "checksum mismatch for $asset $tag: expected '$expected', got '$actual'" >&2
	exit 1
fi
chmod +x "$bin/ankra"

PATH="$bin:$PATH" "$root/scripts/sync-from-cli.sh" "$tag"

# Every content sync is a new plugin release: bump the minor version.
node -e '
const fs = require("fs");
const file = process.argv[1];
const manifest = JSON.parse(fs.readFileSync(file, "utf8"));
const [major, minor] = manifest.version.split(".").map(Number);
manifest.version = `${major}.${minor + 1}.0`;
fs.writeFileSync(file, JSON.stringify(manifest, null, 2) + "\n");
console.log(`plugin version ${manifest.version}`);
' "$plugin/.cursor-plugin/plugin.json"

(cd "$root" && node scripts/validate-template.mjs)
output changed true
