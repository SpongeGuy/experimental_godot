#!/bin/sh
printf '\033c\033]0;%s\a' eco
base_path="$(dirname "$(realpath "$0")")"
"$base_path/eco.x86_64" "$@"
