# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start add_torrent ..."

torrent_file=$1
data_path=$2
tr_hostname=$3
tr_port=$4

echo "[`date`] hostname: " $tr_hostname
echo "[`date`] port: " $tr_port
echo "[`date`] torrent_file: " $torrent_file
echo "[`date`] data_path: " $data_path

if ! source $cur_dir/credential_config.sh; then
    echo "[`date`] transfer failed import credetials from credential_config.sh! It's likely to fail when adding torrent to tr"
fi

echo "to start add_torrent.py"
if ! /usr/bin/python3 $cur_dir/add_torrent.py "$tr_hostname" "$tr_port" "$tr_username" "$tr_password" "$torrent_file" "$data_path"; then
    echo "Failed to execute add_torrent.py!"
    exit 1
fi

echo "[`date`] end add_torrent ..."
