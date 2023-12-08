max() {
        unset RESULT
        declare -g RESULT=$1
        shift
        local N
        for N in $@; do
                if [[ $N -gt $RESULT ]]; then
                        RESULT=$N
                fi
        done
}

max_array() {
	local ARRAY_NAME=$1
	declare -n ARRAY=$ARRAY_NAME
	max ${ARRAY[@]}
}
