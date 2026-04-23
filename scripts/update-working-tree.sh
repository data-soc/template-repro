#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_FILE="$REPO_ROOT/README.md"
MAX_DEPTH="${MAX_DEPTH:-4}"
EXCLUDE_PATHS="${EXCLUDE_PATHS:-.git,.github,.Rhistory,index_files,reporte-repro_files}"
EXCLUDE_FILES="${EXCLUDE_FILES:-.gitkeep}"

if [[ ! -f "$README_FILE" ]]; then
  echo "README.md not found in $REPO_ROOT" >&2
  exit 1
fi

has_start=0
has_end=0
if grep -q "WORKING_TREE_START" "$README_FILE"; then
  has_start=1
fi
if grep -q "WORKING_TREE_END" "$README_FILE"; then
  has_end=1
fi

if [[ "$has_start" -eq 1 && "$has_end" -eq 0 ]]; then
  echo "Missing WORKING_TREE_END marker. Appending it at end of README.md"
  printf "\n<!-- WORKING_TREE_END -->\n" >> "$README_FILE"
fi

if [[ "$has_start" -eq 0 && "$has_end" -eq 0 ]]; then
  echo "Markers not found. Appending a managed working tree block to README.md"
  cat >> "$README_FILE" <<'EOF'

## Working tree del proyecto

<!-- WORKING_TREE_START -->
```text
```
<!-- WORKING_TREE_END -->
EOF
fi

generate_tree() {
  local root_name
  root_name="$(basename "$REPO_ROOT")"

  (
    cd "$REPO_ROOT"
    echo "$root_name/"
    find . -mindepth 1 -maxdepth "$MAX_DEPTH" \
      -path './.git' -prune -o -name '.gitkeep' -prune -o -print \
      | sed 's|^\./||' \
      | LC_ALL=C sort \
      | awk -F'/' -v excludes="$EXCLUDE_PATHS" '
        BEGIN {
          n = split(excludes, ex, ",")
          for (i = 1; i <= n; i++) {
            gsub(/^ +| +$/, "", ex[i])
            excluded[ex[i]] = 1
          }
        }
        {
          if ($1 in excluded) next
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
