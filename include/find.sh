find_index() {
	unset _result
	declare -g -a _result=(-1 "")
        local pattern=$1 string=$2 begin=${3:-0} substring i
        for (( i=$begin; i<${#string}; i++ )); do
                substring=${string:$i}
                if [[ "$substring" =~ ^$pattern ]]; then
                        _result=($i "${BASH_REMATCH[0]}")
                        return
                fi
        done
}
