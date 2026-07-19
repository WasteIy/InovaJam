#!/bin/sh
printf '\033c\033]0;%s\a' Radio Loop
base_path="$(dirname "$(realpath "$0")")"
"$base_path/radio_loop.x86_64" "$@"
