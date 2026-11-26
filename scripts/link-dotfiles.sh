#!/bin/bash
# links every file under dotfiles/home into $HOME. existing real files are
# renamed in place to <name>.backup.<date>, never deleted.
set -u

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ts="$(date +%Y%m%d-%H%M%S)"
declare -a repointed=() backed_up=() created=()

link_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    return 0
  fi
  if [ -L "$dest" ]; then
    ln -sfn "$src" "$dest"
    repointed+=("$dest")
  elif [ -e "$dest" ]; then
    mv "$dest" "${dest}.backup.${ts}"
    backed_up+=("${dest}.backup.${ts}")
    ln -s "$src" "$dest"
    created+=("$dest")
  else
    ln -s "$src" "$dest"
    created+=("$dest")
  fi
}

map_rel() {
  # maps the underscore prefix to a dot on every path component
  local out="" part
  local IFS='/'
  for part in $1; do
    [[ "$part" == _* ]] && part=".${part:1}"
    out="${out:+$out/}$part"
  done
  printf '%s' "$out"
}

while IFS= read -r -d '' src; do
  rel="${src#"$repo"/dotfiles/home/}"
  rel="$(map_rel "$rel")"
  link_file "$src" "${HOME}/${rel}"
done < <(find "$repo/dotfiles/home" -type f -print0)

# vscode: link the custom css into the user dir and register it in settings.json
vscode_user="${HOME}/Library/Application Support/Code/User"
if [ -d "$vscode_user" ]; then
  link_file "$repo/vscode/css/markdown.css" "$vscode_user/markdown.css"
  python3 - "$vscode_user/settings.json" "$vscode_user/markdown.css" <<'PY'
import json, os, re, shutil, sys
from urllib.request import pathname2url
settings_path, css_path = sys.argv[1], sys.argv[2]
raw = ""
if os.path.exists(settings_path):
    with open(settings_path) as fh:
        raw = fh.read()
settings = {}
if raw.strip():
    cleaned = re.sub(r",\s*([}\]])", r"\1", raw)
    try:
        settings = json.loads(cleaned)
    except Exception as exc:
        print(f"vscode: cannot parse {settings_path} ({exc}); settings left untouched", file=sys.stderr)
        sys.exit(0)
imports = settings.setdefault("vscode_custom_css.imports", [])
url = "file://" + pathname2url(os.path.realpath(css_path))
needs_update = url not in imports or settings.get("vscode_custom_css.enabled") is not True
if needs_update:
    if url not in imports:
        imports.append(url)
    settings["vscode_custom_css.enabled"] = True
    if os.path.exists(settings_path):
        shutil.copy2(settings_path, settings_path + ".backup")
    with open(settings_path, "w") as fh:
        json.dump(settings, fh, indent=2)
PY
else
  echo "vscode: no VSCode user dir found, skipping css install"
fi

# Avoid crawling the entire home directory to find stale links. This target only
# creates or updates links for files that still exist in the repository.

echo "link-dotfiles: created ${#created[@]}, repointed ${#repointed[@]}, backed up ${#backed_up[@]}"
if [ "${#backed_up[@]}" -gt 0 ]; then
  for f in "${backed_up[@]}"; do echo "  backup: $f"; done
fi
exit 0
