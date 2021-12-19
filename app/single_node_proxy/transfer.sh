# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
lib_dir=$cur_dir/../../lib
echo "[`date`] start transfer.sh..."

data_path=$1
torrent_name=$2
torrent_file=$3
client_tag=$4

if [[ $data_path == Res/Mutable/Complete/Local* ]]; then
    echo "[`date`] local file, won't transfer to seed server"
    exit 0
fi


if ! source $lib_dir/find_disk.sh; then
    echo "[`date`] transfer failed due to find_disk.sh!"
    exit 1
fi

output_path="/home/$dst_mount_vdisk/"$data_path
data_path="/home/$client_tag/"$data_path
torrent_file="/home/$client_tag/"$torrent_file

export data_path=$data_path
export torrent_file=$torrent_file
export output_path=$output_path

echo "input path: $data_path"
echo "input filename: $torrent_name"
echo "output path: $output_path"
echo "torrent file: $torrent_file"

if ! /usr/bin/bash $lib_dir/copy_to_secondary.sh "$data_path" "$torrent_name" "$output_path"; then
    echo "[`date`] transfer.sh failed due to copy_to_secondary.sh!"
    exit 1
fi

if ! /usr/bin/bash $lib_dir/add_torrent.sh "127.0.0.1" "$torrent_file" "$output_path" "dst_id"; then
    echo "[`date`] transfer.sh failed due to add_torrent.sh!"
    exit 1
fi

rm $torrent_file

echo "[`date`] end transfer.sh"
