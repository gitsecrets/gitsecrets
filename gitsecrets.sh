#!/usr/bin/env bash

GITSECRETS_PATTERN='password|passwd|secret|token|api_key|apikey|prodkey|prod_key|dev_key|credentials|private_key|privatekey|admin:|bindpw|PASS=|amqp:|;pwd='

{
    # Traverse through Git structure and cat each file
    # Then, search each file for regex pattern
    find .git/objects/pack/ -name "*.idx" \
    | while read -r i; do
        git show-index < "$i" | awk '{print $2}';
      done;
      find .git/objects/ -type f | grep -v '/pack/' | awk -F'/' '{print $(NF-1)$NF}';
} | while read -r o; do
    git cat-file -p "$o";
done | grep -Eai "$GITSECRETS_PATTERN" | while read -r line; do

    # Remove white space
    # Remove very long lines, most likely minified JS
    # Remove false positives, e.g. code comments, file names, or assertions
    echo "$line" \
        | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print }' \
        | awk 'length >= 300 { next } { print }' \
        | grep -ivE 'Exception|xxxx|return |\*\*\*\*\*|class | function |^func |\.(php|js|xml)|public|->assert|CREATE TABLE|VARCHAR\(|CONSTRAINT|UNIQUE KEY'
done
