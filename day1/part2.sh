#!/usr/bin/bash
set -e
INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

declare -A WORD_DIGITS=(
	[one]=1
	[two]=2
	[three]=3
	[four]=4
	[five]=5
	[six]=6
	[seven]=7
	[eight]=8
	[nine]=9
)

reverse() {
	INPUT=$1
	RESULT=""
	for (( I=1; I<=${#INPUT}; I++ )); do
		RESULT+=${INPUT:(-$I):1}
	done
}

make_digit() {
	INPUT=$1
	if [[ "$INPUT" -gt 0 ]]; then
		RESULT="$INPUT"
	else
		RESULT=${WORD_DIGITS[$INPUT]}
	fi
}

for KEY in ${!WORD_DIGITS[@]}; do
	reverse $KEY
	WORD_DIGITS[$RESULT]=${WORD_DIGITS[$KEY]}
done

IFS=\|
KEYS_PATTERN=${!WORD_DIGITS[*]}
unset IFS

ACCUMULATOR=0
while read LINE; do
	if [[ "$LINE" =~ ([[:digit:]]|$KEYS_PATTERN) ]]; then
		DIGIT1=${BASH_REMATCH[1]}
		reverse $LINE
		[[ "$RESULT" =~ ([[:digit:]]|$KEYS_PATTERN) ]]
		DIGIT2=${BASH_REMATCH[1]}
		make_digit $DIGIT1
		DIGIT1=$RESULT
		make_digit $DIGIT2
		DIGIT2=$RESULT
		ACCUMULATOR=$((ACCUMULATOR+"$DIGIT1$DIGIT2"))
	else
		die "Failed to find a digit"
	fi
done <<<"$INPUT_DATA"
echo $ACCUMULATOR
