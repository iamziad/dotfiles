#!/bin/bash

# 1. Check if the user provided a program name
if [ -z "$1" ]; then
    echo "Error: Please provide the binary name. Usage: $0 <binary_name>"
    exit 1
fi

# 2. Define the full path to the binary
f="$HOME/.local/bin/$1"

# 3. Check if the file exists and is executable
if [ ! -x "$f" ]; then
    echo "Error: Binary '$1' not found in ~/.local/bin or it is not executable."
    exit 1
fi

# 4. Get the base name
name=$(basename "$f")

# 5. Create the .desktop file
cat > "$HOME/.local/share/applications/$name.desktop" <<EOF
[Desktop Entry]
Name=$name
Exec=$f
Type=Application
Terminal=false
EOF

echo "Success: Desktop entry created for $name."
