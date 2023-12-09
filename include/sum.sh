
sum_array() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	unset RESULT
	declare -g RESULT=0
	local T
	for T in ${ARRAY[@]}; do
		RESULT=$((RESULT+T))
	done
}
