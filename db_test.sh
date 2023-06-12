#!/bin/bash

echo "Let's Start DB TEST"

SUCCEED=0
FAILED=0

run_script() {
    IFS='' local INPUT="$1"
    echo "$INPUT" | ./db
}

expect() {
    IFS='' local ACTUAL_OUTPUT="$(run_script "$1")"
    IFS='' local EXPECTED_OUTPUT="$2"
    if [ "$ACTUAL_OUTPUT" = "$EXPECTED_OUTPUT" ]
    then
        echo "SUCCEED"
	SUCCEED=$((SUCCEED+1))
    else
        echo "FAILED"
	echo "EXPECTED:"
	echo "$EXPECTED_OUTPUT"
	echo "ACTUAL:"
	echo "$ACTUAL_OUTPUT"
	FAILED=$((FAILED+1))
    fi
    echo "---"
}

echo "TEST 1: inserts and retrieves a row"
expect \
'insert 1 user1 person1@example.com
select
.exit' \
'db > Executed.
db > (1, user1, person1@example.com)
Executed.
db > '
