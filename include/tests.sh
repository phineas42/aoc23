. binarysearch.sh
. quicksort.sh
. min.sh
. max.sh
. lcm.sh

assert() {
	TEST_DESCRIPTION=$1
	shift
	if eval "$@"; then
		echo "ASSERT passed: $TEST_DESCRIPTION"
	else
		echo "ASSERT FAILED: $TEST_DESCRIPTION"
	fi
}

is_sorted() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	local PREV ELEM
	for ELEM in ${ARRAY[@]}; do
		if [[ -n "$PREV" ]]; then
			if [[ "$PREV" -gt "$ELEM" ]]; then
				return 1
			fi
		fi
		PREV=$ELEM
	done
	return 0
}

RANDOM_ARRAY=(5 -2 0 3 2 -10 4 8 10 -8 7 -4 6 1 -1 -7 9 -9 -3 -6 -5)

TEST_ARRAY=(${RANDOM_ARRAY[*]})
assert "Original Test array is not sorted" ! is_sorted TEST_ARRAY

# Sort using default sorting condition (works for integers)
quicksort_array TEST_ARRAY
assert "Test array is sorted after quicksort call" is_sorted TEST_ARRAY

# Find a number in the TEST_ARRAY
binarysearch_array TEST_ARRAY searchcondition_equals -4
assert "Test find of negative number in sorted list" [[ "$RESULT" -eq 6 ]]

min_array RANDOM_ARRAY
assert "min_array" [[ "$RESULT" -eq -10 ]]

min ${RANDOM_ARRAY[@]}
assert "min" [[ "$RESULT" -eq -10 ]]

max_array RANDOM_ARRAY
assert "max_array" [[ "$RESULT" -eq 10 ]]

max ${RANDOM_ARRAY[@]}
assert "max" [[ "$RESULT" -eq 10 ]]

lcm 123 456 789
assert "lcm" [[ "$RESULT" -eq 4917048 ]]

NUMBERS=(123 456 789)
lcm_array NUMBERS
assert "lcm_array" [[ "$RESULT" -eq 4917048 ]]
