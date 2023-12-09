prime_factorize() {
	local NUM=$1
	unset RESULT
	declare -g -a RESULT=()
	local I
	for ((I=2; I<$((NUM/2)); )); do
		if [[ $((NUM%I)) -eq 0 ]]; then
			if [[ -n ${RESULT[$I]} ]]; then
				RESULT[$I]=$((${RESULT[$I]}+1))
			else
				RESULT[$I]=1
			fi
			NUM=$((NUM/I))
		else
			I=$((I+1))
		fi
	done
	RESULT[$NUM]=$((${RESULT[$NUM]}+1))
}
