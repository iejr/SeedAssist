# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
lib_dir=$cur_dir/../../lib
echo "[`date`] start transfer.sh..."

data_path=$1
torrent_name=$2
torrent_file=$3
client_tag=$4
cache_file=$5

if [[ $data_path == Res/Mutable/Complete/Local* ]]; then
    echo "[`date`] local file, won't transfer to seed server"
    exit 0
fi

file_id="$data_path"/"$torrent_name"

if [ ! -z $cache_file ]; then
    while read record; do
        mapfile -t params < <(xargs -n1 <<<"$record")
	test_file_id=${params[0]}
	test_dst_id=${params[1]}
	if [[ $file_id == $test_file_id ]]; then
	    cache_hit=1
	    export dst_id=$test_dst_id
	    break
	fi
    done < $cache_file
fi

if ! source $lib_dir/find_client.sh; then
    echo "[`date`] transfer failed due to find_client.sh!"
    exit 1
fi

output_path="$dst_mount_point/"$data_path
client_local_path="$dst_local_path/"$data_path
data_path="/home/$client_tag/"$data_path
torrent_file="/home/$client_tag/"$torrent_file

echo "input path: $data_path"
echo "input filename: $torrent_name"
echo "output path: $output_path"
echo "torrent file: $torrent_file"

if ! /usr/bin/bash $lib_dir/copy_to_secondary.sh "$data_path" "$torrent_name" "$output_path"; then
    echo "[`date`] transfer.sh failed due to copy_to_secondary.sh!"
    exit 1
fi

if [ -z $cache_hit ] && [ -n "$cache_file" ]; then
    echo -e \"$file_id\" \"$dst_id\" | tee -a $cache_file
fi

if ! /usr/bin/bash $lib_dir/add_torrent.sh "$torrent_file" "$client_local_path" "$dst_hostname" "$dst_port"; then
    echo "[`date`] transfer.sh failed due to add_torrent.sh!"
    exit 1
fi

rm "$torrent_file"

echo "[`date`] end transfer.sh"
