# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start copy_file_content ..."

input_path=$1
torrent_name=$2
output_path=$3

input_files="$input_path/$torrent_name"

if [ -v $speed_limit ]; then
    speed_limit=5000
fi

echo "[`date`] copy from: " $input_files
echo "[`date`] copy to: " $output_path
echo "[`date`] speed limit: " $speed_limit

/usr/bin/mkdir -p "$output_path"
if ! /usr/bin/rsync -savz --bwlimit=$speed_limit -e "ssh -i key/storage_chi1_hosthatch_pttransfer" "$input_files" "$output_path"; then
    echo "[`date`] rsync failed!"
    exit 1
fi

/usr/bin/chmod -R g+w "$output_path/$torrent_name"

echo "[`date`] end copy_file_content ..."
