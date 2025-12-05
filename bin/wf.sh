#!/usr/bin/env zsh

CMD="$1"
FILE="$2"

if [ -z "$CMD" ] || [ -z "$FILE" ]; then
  echo "Usage: $0 <command> <file-to-watch>"
  echo "Example: $0 'pytest' /path/to/test_file.py"
  exit 1
fi

while inotifywait -e close_write "$FILE"; do
  $CMD "$FILE"
done
