#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d)"
trap 'rm -rf "$test_home"' EXIT

HOME="$test_home"
DOTFILES_DIR="$repo_dir"

# shellcheck source=../install.sh
source "$repo_dir/install.sh"
install_skills

for target in "$HOME/.codex/skills/commit" "$HOME/.config/opencode/skills/commit"; do
  [[ -L "$target" ]]
  [[ "$(readlink "$target")" == "$repo_dir/.local/share/dotfiles/skills/commit" ]]
done

[[ -d "$HOME/.codex/skills" ]]
[[ -d "$HOME/.config/opencode/skills" ]]
