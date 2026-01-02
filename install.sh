#!/usr/bin/env zsh
set -euo pipefail

BIN_DIR="./bin"
TARGET_DIR="/usr/local/bin"

echo "Installing dotfiles scripts..."

# Check bin folder exists
if [ ! -d "$BIN_DIR" ]; then
  echo "No ./bin directory found. Aborting."
  exit 1
fi

# Find all .sh files
scripts=( "$BIN_DIR"/*.sh )
if [ ${#scripts[@]} -eq 0 ]; then
  echo "No .sh scripts found in $BIN_DIR. Aborting."
  exit 1
fi

# Copy and chmod each script
for script in "${scripts[@]}"; do
  name=$(basename "$script")
  echo "Installing $name to $TARGET_DIR"
  sudo cp "$script" "$TARGET_DIR/$name"
  sudo chmod +x "$TARGET_DIR/$name"
done

echo "Installation complete. The scripts are now available in your PATH."
