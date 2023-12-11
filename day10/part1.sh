#!/usr/bin/bash
set -e
INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

get_char() {
	local ROW=$1 COL=$2
	declare -g WIDTH HEIGHT
	if [[ "$ROW" -lt 0 || "$ROW" -ge $HEIGHT || "$COL" -lt 0 || "$COL" -ge $WIDTH ]]; then
		RESULT=
		return
	fi
	RESULT=${INPUT_ROWS[$ROW]:$COL:1}
}

ROW=0
START_ROW=
START_COL=
INPUT_ROWS=()

while read LINE; do
	HEIGHT=$((ROW+1))
	if [[ "$ROW" -eq 0 ]]; then
		WIDTH=${#LINE}
	fi
	INPUT_ROWS+=($LINE)
	if [[ -z "$START_ROW" ]]; then
		for ((COL=0;COL<${#LINE};COL++)); do
			get_char $ROW $COL
			if [[ "$RESULT" == S ]]; then
				START_ROW=$ROW
				START_COL=$COL
				break
			fi
		done
	fi
	ROW=$HEIGHT
done <<<"$INPUT_DATA"

# Determine loop length
ROW=$START_ROW
COL=$START_COL
LEN=0
IN_DIR=
OUT_DIR=
while true; do
	# printf "%1s (%3d,%3d) %1s\n" "$IN_DIR" $ROW $COL "$OUT_DIR"
	if [[ -z "$OUT_DIR" || $OUT_DIR == E ]]; then
		get_char $ROW $((COL+1))
		case $RESULT in
			[\-7J])
				# East connection detected
				IN_DIR=W
				COL=$((COL+1))
				LEN=$((LEN+1))
				case $RESULT in
					7) OUT_DIR=S ;;
					J) OUT_DIR=N ;;
					\-) OUT_DIR=E ;;
				esac
				;;
			S)	break ;; # end of loop of pipes
		esac
	fi
	if [[ -z "$OUT_DIR" || $OUT_DIR == S ]]; then
		get_char $((ROW+1)) $COL
		case $RESULT in
			[\|JL])
				# South connection detected
				IN_DIR=N
				ROW=$((ROW+1))
				LEN=$((LEN+1))
				case $RESULT in
					J) OUT_DIR=W ;;
					L) OUT_DIR=E ;;
					\|) OUT_DIR=S ;;
				esac
				;;
			S)	break ;; # end of loop of pipes
		esac
	fi
	if [[ -z "$OUT_DIR" || $OUT_DIR == W ]]; then
		get_char $ROW $((COL-1))
		case $RESULT in
			[\-LF])
				# West connection detected
				IN_DIR=E
				COL=$((COL-1))
				LEN=$((LEN+1))
				case $RESULT in
					L) OUT_DIR=N ;;
					F) OUT_DIR=S ;;
					\-) OUT_DIR=W ;;
				esac
				;;
			S)	break ;; # end of loop of pipes
		esac
	fi
	if [[ -z "$OUT_DIR" || $OUT_DIR == N ]]; then
		get_char $((ROW-1)) $COL
		case $RESULT in
			[\|F7])
				# North connection detected
				IN_DIR=S
				ROW=$((ROW-1))
				LEN=$((LEN+1))
				case $RESULT in
					F) OUT_DIR=E ;;
					7) OUT_DIR=W ;;
					\|) OUT_DIR=N ;;
				esac
				;;
			S)	break ;; # end of loop of pipes
		esac
	fi
done
LEN=$((LEN+1))
echo $((LEN/2))
