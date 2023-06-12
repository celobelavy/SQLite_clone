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

expect_line() {
    IFS='' local ACTUAL_OUTPUT="$(run_script "$1")"
    local LINE_NUMBER=$(($2))
    IFS='' local EXPECTED_OUTPUT="$3"
    if [ "$LINE_NUMBER" -lt 0 ]
    then
        ACTUAL_LINE=$(echo "$ACTUAL_OUTPUT" | tail -n $(($LINE_NUMBER * -1)) | head -n 1)
    else
        ACTUAL_LINE=$(echo "$ACTUAL_OUTPUT" | head -n $LINE_NUMBER | tail -n 1)
    fi
    if [ "$ACTUAL_LINE" = "$EXPECTED_OUTPUT" ]
    then
        echo "SUCCEED"
	SUCCEED=$((SUCCEED+1))
    else
        echo "FAILED"
	echo "EXPECTED:"
        echo "$EXPECTED_OUTPUT"
        echo "ACTUAL:"
	echo "$ACTUAL_LINE"
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

echo "TEST 2: prints error message when table is full"
SCRIPT=
for i in {1..1401}
do
SCRIPT="$SCRIPT
insert $i user$1 person$1@example.com"
done
SCRIPT="$SCRIPT
.exit"
expect_line \
"$SCRIPT" \
-2 \
'db > Error: Table full.'

echo "TEST 3: allows inserting strings that are the maximum length"
LONG_USERNAME=$(printf '%*s' 32 | tr ' ' 'a')
LONG_EMAIL=$(printf '%*s' 255 | tr ' ' 'a')
expect \
"insert 1 $LONG_USERNAME $LONG_EMAIL
select
.exit" \
"db > Executed.
db > (1, $LONG_USERNAME, $LONG_EMAIL)
Executed.
db > "

echo "TEST 4: prints error message if strings are too long"
LONG_USERNAME=$(printf '%*s' 33 | tr ' ' 'a')
LONG_EMAIL=$(printf '%*s' 256 | tr ' ' 'a')
expect \
"insert 1 $LONG_USERNAME $LONG_EMAIL
select
.exit" \
'db > String is too long.
db > Executed.
db > '

echo "TEST 5: prints error message if id is negative"
expect \
'insert -1 cstack foo@bar.com
select
.exit' \
'db > ID must be positive.
db > Executed.
db > '

echo "SUCCEED: $SUCCEED"
echo "FAILED: $FAILED"
echo "DONE."
