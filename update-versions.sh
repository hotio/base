#!/bin/bash
set -euo pipefail

while read -r line; do
    if [[ $line =~ _command ]]; then
        key="${line%%=*}"
        key="${key%_command}"
        command="${line#*=}"
        value=$(eval "${command}")
        echo "Result: [${key}] [${command}] [${value}]"
        json=$(cat meta.json)
        jq --sort-keys --arg key "$key" --arg value "$value" '.[$key] = $value' <<< "${json}" > meta.json
    fi
done < <(jq -r 'to_entries[] | [(.key),.value] | join("=")' < meta.json)
