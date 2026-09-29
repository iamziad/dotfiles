#!/usr/bin/env bash
# Symlink custom scripts into ~/.local/bin without .sh extension.

set -euo pipefail

# تحديد مسار مجلد السكريبتات ومجلد الهدف
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.local/bin"

mkdir -p "$TARGET_DIR"

shopt -s nullglob
for file in "$SCRIPT_DIR"/*; do
    [[ -f "$file" ]] || continue
    filename=$(basename "$file")

    # استثناء ملفات .nix والسكريبت ده نفسه
    if [[ "$filename" == *.nix || "$file" == "${BASH_SOURCE[0]}" ]]; then
        continue
    fi

    # تشفية امتداد .sh من اسم اللينك
    link_name="${filename%.sh}"

    chmod +x "$file"
    ln -sf "$file" "$TARGET_DIR/$link_name"
    echo "<Log>: linked $filename -> $TARGET_DIR/$link_name"
done
shopt -u nullglob

echo "<Log>: All scripts linked successfully to $TARGET_DIR"
