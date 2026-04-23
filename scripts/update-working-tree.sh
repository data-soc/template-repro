#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_FILE="$REPO_ROOT/README.md"
MAX_DEPTH="${MAX_DEPTH:-4}"

if [[ ! -f "$README_FILE" ]]; then
  echo "README.md not found in $REPO_ROOT" >&2
  exit 1
fi

if ! grep -q "WORKING_TREE_START" "$README_FILE" || ! grep -q "WORKING_TREE_END" "$README_FILE"; then
  echo "Markers WORKING_TREE_START/WORKING_TREE_END not found in README.md" >&2
  exit 1
fi

generate_tree() {
  local root_name
  root_name="$(basename "$REPO_ROOT")"

  if command -v tree >/dev/null 2>&1; then
    (
      cd "$REPO_ROOT"
      echo "$root_name/"
      tree -a -L "$MAX_DEPTH" -I ".git" --noreport . \
        | sed '1d' \
        | sed 's/^/ /'
    )
    return
  fi

  (
    cd "$REPO_ROOT"
    echo "$root_name/"
    find . -mindepth 1 -maxdepth "$MAX_DEPTH" \
      -path './.git' -prune -o -print \
      | sed 's|^\./||' \
      | LC_ALL=C sort \
      | awk -F'/' '
        {
          depth = NF - 1
          prefix = ""
          for (i = 1; i <= depth; i++) prefix = prefix "|  "
          name = $NF
          full = $0
          cmd = "test -d \"" full "\""
          is_dir = (system(cmd) == 0)
          printf " %s|- %s%s\n", prefix, name, (is_dir ? "/" : "")
        }
      '
  )
}

TMP_TREE="$(mktemp)"
TMP_README="$(mktemp)"

generate_tree > "$TMP_TREE"

awk -v treefile="$TMP_TREE" '
  BEGIN {
    while ((getline line < treefile) > 0) tree = tree line "\n"
  }
  /<!-- WORKING_TREE_START -->/ {
    print
    print "```text"
    printf "%s", tree
    print "```"
    in_block = 1
    next
  }
  /<!-- WORKING_TREE_END -->/ {
    in_block = 0
    print
    next
  }
  !in_block { print }
' "$README_FILE" > "$TMP_README"

mv "$TMP_README" "$README_FILE"
rm -f "$TMP_TREE"

echo "README working tree updated."
