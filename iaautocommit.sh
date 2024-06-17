#!/bin/bash

function display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "-h, --help    Show this help message"
    echo
    echo "Environment Variables:"
    echo "OLLAMA_MODEL  Model to use (default: llama3:8b)"
    echo "OLLAMA_PORT   Port to use (default: 11434)"
    echo "OLLAMA_HOST   Host to use (default: localhost)"
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    display_help
    exit 0
fi

OLLAMA_MODEL=${OLLAMA_MODEL:-openhermes:v2.5}
OLLAMA_PORT=${OLLAMA_PORT:-11434}
OLLAMA_HOST=${OLLAMA_HOST:-localhost}

GIT_STATUS=$(git status --porcelain)

if [ -z "$GIT_STATUS" ]; then
    echo "No changes to commit"
    exit 0
fi

function check_ollama_running() {
  if ! nc -z $OLLAMA_HOST $OLLAMA_PORT; then
    echo "Ollama is not running on $OLLAMA_HOST:$OLLAMA_PORT"
    exit 1
  fi
}

check_ollama_running

function ask_ollama() {
  content=$1
  model=${OLLAMA_MODEL}

  prompt=$(echo "Generate a commit message for the following changes. Explains what changes have been made. Do not include any description only the message. Only output the message. ---------- ${content}")
  prompt=$(echo "$prompt" | jq -Rsa .)

  response=$(curl -s "http://${OLLAMA_HOST}:${OLLAMA_PORT}/api/generate" -d '{
    "model": "'"$model"'",
    "prompt": '"$prompt"',
    "stream": false
  }')

  response=$(echo $response | jq -r '.response')
  response=$(echo $response | sed 's/^"//;s/"$//')
  echo "$response"
}

while read -r line; do
    action=$(echo $line | awk '{print $1}')
    action=$(echo $action | sed 's/ //g')
    file=$(echo $line | awk '{print $2}')

    commit_message=""

    case "$action" in
        "R") commit_message="Renamed $file" ;;
        "C") commit_message="Copied $file" ;;
        "T") commit_message="Type changed for $file" ;;
        "A") commit_message=$(ask_ollama "Added file: $file $(head -100 $file)") ;;
        "D") commit_message=$(ask_ollama "Deleted file: $file $(git diff $file)") ;;
        "M"|"AM") commit_message=$(ask_ollama " $(git diff $file)") ;;
    esac

    if [ -n "$commit_message" ]; then
        echo "Committing $file"
        echo "---"
        echo "$commit_message"
        echo "---"
        echo ""
        git commit -m "$commit_message" "$file"
    fi

done <<< "$GIT_STATUS"
