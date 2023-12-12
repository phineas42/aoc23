# Standard boilerplate
set -e
set -u

this_dir=${BASH_SOURCE[0]%/*}
if [[ "$this_dir" == "${BASH_SOURCE[0]}" ]]; then
        this_dir=.
fi

for inc_file in ${this_dir}/include/*.sh; do
        . $inc_file
done

input_file=$1
input_data=$(<"$input_file")

