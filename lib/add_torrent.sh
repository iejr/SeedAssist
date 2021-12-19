# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start add_torrent ..."

dst_hostname=$1
torrent_file=$2
data_path=$3
tr_id=$4

echo "[`date`] hostname: " $dst_hostname
echo "[`date`] torrent_file: " $torrent_file
echo "[`date`] data_path: " $data_path

if ! source $cur_dir/credential_config.sh; then
    echo "[`date`] transfer failed import credetials from credential_config.sh! It's likely to fail when adding torrent to tr"
fi

if [ ! -z $tr_id ]; then
    tr_port=$(($tr_port+$tr_id))
fi

echo "to start add_torrent.py"
if ! /usr/bin/python3 $cur_dir/add_torrent.py "$dst_hostname" "$tr_port" "$tr_username" "$tr_password" "$torrent_file" "$data_path"; then
    echo "Failed to execute add_torrent.py!"
    exit 1
fi

echo "[`date`] end add_torrent ..."
