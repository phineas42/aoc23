#!/usr/bin/bash

set -e
set -u

this_dir=${BASH_SOURCE[0]%/*}
if [[ "$this_dir" == "${BASH_SOURCE[0]}" ]]; then
        this_dir=.
fi

for inc_file in ${this_dir}/include/*.sh; do
	. $inc_file
done

assert() {
	local test_description=$1; shift
	if eval "$@"; then
		if [[ "$test_description" == "test" ]]; then
			echo $'\x1b[32mpassed\x1b[0m'
		else
			echo "ASSERT passed: $test_description"
		fi
	else
		if [[ "$test_description" == "test" ]]; then
			echo $'\x1b[31mFAILED\x1b[0m'
			echo "    $@"
		else
			echo "ASSERT FAILED: $test_description"
		fi
	fi
}

is_sorted() {
	local array_name=$1
	declare -n array=$array_name
	local prev elem
	for elem in ${array[@]}; do
		if [[ -n "${prev:-}" ]]; then
			if [[ "$prev" -gt "$elem" ]]; then
				return 1
			fi
		fi
		prev=$elem
	done
	return 0
}

random_array=(5 -2 0 3 2 -10 4 8 10 -8 7 -4 6 1 -1 -7 9 -9 -3 -6 -5)

test_array=(${random_array[*]})
echo -n "Test: Original Test array is not sorted ... "
assert "test" ! is_sorted test_array

# Sort using default sorting condition (works for integers)
echo -n "Test: array is sorted after quicksort call ... "
quicksort_array test_array
assert "test" is_sorted test_array

# Find a number in the test_array
echo -n "Test: find of negative number in sorted list ... "
binarysearch_array test_array searchcondition_equals -4
assert "test" [[ "$_result" -eq 6 ]]

echo -n "Test: find minimum number in an array ... "
min_array random_array
assert "test" [[ "$_result" -eq -10 ]]

echo -n "Test: find minimum number in arguments ... "
min ${random_array[@]}
assert "test" [[ "$_result" -eq -10 ]]

echo -n "Test: find maximum number in an array ... "
max_array random_array
assert "test" [[ "$_result" -eq 10 ]]

echo -n "Test: find maximum number in arguments ... "
max ${random_array[@]}
assert "test" [[ "$_result" -eq 10 ]]

numbers=(123 456 789)

echo -n "Test: compute least common multiple in arguments ... "
lcm ${numbers[@]}
assert "test" [[ "$_result" -eq 4917048 ]]

echo -n "Test: compute least common multiple in an array ... "
lcm_array numbers
assert "test" [[ "$_result" -eq 4917048 ]]

echo -n "Test: compute least common multiple in an array (factor method) ... "
lcm_array_by_factors numbers
assert "test" [[ "$_result" -eq 4917048 ]]

number=$((403831127700000))
array_to_multiply=(2 2 2 2 2 3 3 5 5 5 5 5 7 11 13 13 29 29 41)
expected_result=([2]="5" [3]="2" [5]="5" [7]="1" [11]="1" [13]="2" [29]="2" [41]="1")
echo -n "Test: prime factorize ... "
prime_factorize $number
assert "test" [[ \""${_result[*]}"\" == \""${expected_result[@]}"\" ]]

echo -n "Test: sum_array ... "
sum_array random_array
assert "test" [[ "$_result" == 0 ]]

echo -n "Test: sum_array with skip ... "
sum_array random_array 7
assert "test" [[ "$_result" == -2 ]]

echo -n "Test: sum_array with skip and len ... "
sum_array random_array 3 16
assert "test" [[ "$_result" == 8 ]]

echo -n "Test: product_array ... "
product_array array_to_multiply
assert "test" [[ "$_result" == 403831127700000 ]]

echo -n "Test: product_array with skip ... "
product_array array_to_multiply 2
assert "test" [[ "$_result" == 100957781925000 ]]

echo -n "Test: product_array with skip and len ... "
product_array array_to_multiply 3 10
assert "test" [[ "$_result" == 787500 ]]

string="....#..#.."
echo -n "Test: find_index first ... "
find_index "#" $string
assert "test" [[ \""${_result[0]}"\" -eq 4 ]]

echo -n "Test: find_index second ... "
find_index "#" $string $((_result[0] + 1))
assert "test" [[ \""${_result[0]}"\" -eq 7 ]]

echo -n "Test: find_index end ... "
find_index "#" $string $((_result[0] + 1))
assert "test" [[ \""${_result[0]}"\" -eq -1 ]]

echo -n "Test: abs positive ... "
abs 100
assert "test" [[ "$_result" == 100 ]]

echo -n "Test: abs negative ... "
abs -100
assert "test" [[ "$_result" == 100 ]]

echo -n "Test: tr ... "
tr "fuzzy zumba" "uz" "43"
assert "test" [[ \""$_result"\" == \""f433y 34mba"\" ]]

echo -n "Test: rev ... "
rev "fuzzy zumba"
assert "test" [[ \""$_result"\" == \""abmuz yzzuf"\" ]]

declare -a data=( [0]="abcd" [1]="efgh" [2]="ijkl" )
echo -n "Test: transpose_array ... "
transpose_array data
assert "test" [[ \""${_result[*]}"\" == \""aei bfj cgk dhl"\" ]]

echo -n "Test: hamming distance ... "
hamming_distance "telluride canal feral" "tellurium banal decal"
assert "test" [[ $_result -eq 5 ]]

#Note: this test can give false failures
echo -n "Weak test: no subshells ... "
assert "test" [[ $(bash -c 'echo $$') == $(($$ + 1)) ]]


