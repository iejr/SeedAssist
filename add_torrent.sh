# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start add_torrent ..."

torrent_file=$torrent_path/$info_hash".torrent"

echo "[`date`] hostname: " $dst_hostname
echo "[`date`] torrent_file: " $torrent_file
echo "[`date`] secondary_path: " $secondary_path

echo "to start add_torrent.py"
if ! /usr/bin/python3 $cur_dir/add_torrent.py "$dst_hostname" "$torrent_file" "$secondary_path"; then
    echo "Failed to execute add_torrent.py!"
    exit 1
fi

echo "[`date`] end add_torrent ..."
