#!/bin/bash

# Define a function to display help information
function display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "-h, --help    Show this help message"
    # Add more options here
}

# Check if the first argument is -h or --help
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    display_help
    exit 0
fi

ACTIONS=$(git status --porcelain)

if [ -z "$ACTIONS" ]; then
    echo "No changes to commit"
    exit 0
fi

function ask_ollama() {

  content=$1

  # use tr to transform new lines to spaces
#  content=$(echo $content | tr '\n' ' ')

  prompt=$(echo "Please generate a commit message for this: ${content}")
  prompt=$(echo "$prompt" | jq -Rsa .)

  response=$(curl -s http://localhost:11434/api/generate -d '{
    "model": "mistral",
    "prompt": '"$prompt"',
    "stream": false
  }')

  # use jw to get "response" from the json
  response=$(echo $response | jq -r '.response')
  echo "$response"
}

# loop through the actions
while read -r line; do
    # get the first word of the line
    action=$(echo $line | awk '{print $1}')

    # trim action with sed
    action=$(echo $action | sed 's/ //g')

    # get the second word of the line
    file=$(echo $line | awk '{print $2}')

    commit_message=""

    # if the action is D
    if [ "$action" == "D" ]; then
        commit_message="Deleted $file"
    fi

    # if the action is A
    if [ "$action" == "A" ]; then
        commit_message="Added $file"
    fi

    # if the action is R (rename)
    if [ "$action" == "R" ]; then
        commit_message="Renamed $file"
    fi

    # if the action is C (copy)
    if [ "$action" == "C" ]; then
        commit_message="Copied $file"
    fi

    # if the action is T (change in type of file)
    if [ "$action" == "T" ]; then
        commit_message="Type changed for $file"
    fi

    # if the action is M
    if [ "$action" == "M" ]; then
        commit_message=$(ask_ollama "$(git diff $file)")
    fi

    # if the action is AM
    if [ "$action" == "AM" ]; then
        commit_message=$(ask_ollama "$(git diff $file)")
    fi

    # check if commit_message is not empty
    if [ -n "$commit_message" ]; then
        echo "Committing $file with message: $commit_message"

        # commit the file
        git commit -m "$commit_message" "$file"
    fi

done <<< "$ACTIONS"