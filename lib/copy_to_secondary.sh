# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start copy_to_secondary ..."

input_path=$1
filename=$2
output_path=$3
speed_limit=$4

input_files=$input_path/$filename

if [ ! -v $speed_limit ]; then
    speed_arg="--bwlimit=$speed_limit"
fi

echo "[`date`] copy from: " $input_files
echo "[`date`] copy to: " $output_path
echo "[`date`] speed limit: " $speed_limit

/usr/bin/mkdir -p "$output_path"
if ! /usr/bin/rsync -avz $speed_arg "$input_files" "$output_path"; then
    echo "[`date`] rsync failed!"
    exit 1
fi

/usr/bin/chmod -R g+w "$output_path/$filename"

echo "[`date`] end copy_to_secondary ..."

