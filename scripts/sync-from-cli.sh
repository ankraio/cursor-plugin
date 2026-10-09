#!/usr/bin/env bash
# Regenerates plugins/ankra/skills and plugins/ankra/commands from an ankra-cli
# release. ankra-cli is the single source of truth for the Ankra agent skills
# and workflow commands; this repository only packages them for Cursor.
#
# The skills are read from the release tag and the commands are rendered by the
# installed `ankra` binary, so the two must be the same release. By default the
# script uses the version of the `ankra` on PATH.
#
# Usage: scripts/sync-from-cli.sh [vX.Y.Z]
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
plugin="$root/plugins/ankra"

command -v ankra >/dev/null || { echo "ankra CLI not found; install it: brew install ankraio/tap/ankra" >&2; exit 1; }
installed="$(ankra --version | awk '{print $NF}')"
tag="${1:-$installed}"
if [ "$tag" != "$installed" ]; then
	echo "requested $tag but the installed ankra is $installed; install $tag first so skills and commands match" >&2
	exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

git -c advice.detachedHead=false clone -q --depth 1 --branch "$tag" https://github.com/ankraio/ankra-cli "$work/cli"
commit="$(git -C "$work/cli" rev-parse HEAD)"

ankra skills install --client cursor --project "$work/render" \
	--source "$work/cli/internal/skills/embedded/skills" --no-rules --force >/dev/null

rm -rf "$plugin/skills" "$plugin/commands"
cp -R "$work/render/.cursor/skills" "$plugin/skills"
mkdir -p "$plugin/commands"

# Cursor plugin commands need a `name` in their frontmatter; the CLI renders
# only `description`, so derive the name from the file name.
for file in "$work/render/.cursor/commands"/*.md; do
	name="$(basename "$file" .md)"
	awk -v name="$name" 'NR == 1 && $0 == "---" { print; print "name: " name; next } { print }' \
		"$file" >"$plugin/commands/$name.md"
done

cat >"$plugin/SOURCE" <<EOF
ankra-cli $tag
commit $commit
EOF

echo "synced $(ls "$plugin/skills" | wc -l | tr -d ' ') skills and $(ls "$plugin/commands" | wc -l | tr -d ' ') commands from ankra-cli $tag ($commit)"
