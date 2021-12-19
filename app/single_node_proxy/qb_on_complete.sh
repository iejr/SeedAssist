# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

task_file="/home/Res/Mutable/todolist"
torrent_src="/var/lib/qbittorrent/.local/share/data/qBittorrent/BT_backup/"
torrent_dst="/home/Res/Mutable/Torrent/"

torrent_name=$1
torrent_path=`echo $2 | sed "s/\/home\/vdisk0\///g"`
info_hash=$3

echo -e "\"$torrent_path\" \"$torrent_name\" \"Res/Mutable/Torrent/${info_hash}.torrent\"" >> $task_file
cp "${torrent_src}/${info_hash}.torrent" "$torrent_dst"
