#!/bin/bash
# Links files under dotfiles/home into $HOME. Existing real files are backed up.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
timestamp="$(date +%Y%m%d-%H%M%S)"

declare -a repointed=() backed_up=() created=()

link_file() {
  local src="$1" dest="$2" current_link backup
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    current_link="$(readlink "$dest")"
    case "$current_link" in
    "$src")
      printf 'link-dotfiles: already linked %s\n' "$dest"
      return 0
      ;;
    *)
      printf 'link-dotfiles: updating link %s\n' "$dest"
      ln -sfn "$src" "$dest"
      repointed+=("$dest")
      return 0
      ;;
    esac
  fi

  if [ -e "$dest" ]; then
    backup="${dest}.backup.${timestamp}"
    printf 'link-dotfiles: backing up %s as %s\n' "$dest" "$backup"
    mv "$dest" "$backup"
    backed_up+=("$backup")
  fi

  printf 'link-dotfiles: linking %s -> %s\n' "$dest" "$src"
  ln -s "$src" "$dest"
  created+=("$dest")
}

map_rel() {
  # Turn an underscore-prefixed path component into a dot-prefixed component.
  printf '%s\n' "$1" | sed -E 's#^_#.#; s#/_#/.#g'
}

printf 'link-dotfiles: scanning %s\n' "$repo/dotfiles/home"
# NUL-delimited paths handle spaces; process substitution keeps counters here.
while IFS= read -r -d '' src; do
  rel="${src#"$repo/dotfiles/home/"}"
  rel="$(map_rel "$rel")"
  link_file "$src" "${HOME}/${rel}"
done < <(find "$repo/dotfiles/home" -type f -print0)

# Stale links for removed source files are left alone; we don't scan all of $HOME.
printf 'link-dotfiles: created %d, repointed %d, backed up %d\n' \
  "${#created[@]}" "${#repointed[@]}" "${#backed_up[@]}"
if [ "${#backed_up[@]}" -gt 0 ]; then
  for backup in "${backed_up[@]}"; do
    printf 'link-dotfiles: backup %s\n' "$backup"
  done
fi
