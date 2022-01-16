#!/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

info_hash=$1
torrent_name=$2
content_path=$3
torrent_path=`echo $content_path | sed "s/\/home\/vdisk0\///g"`

task_file="/home/Res/Mutable/todolist"
torrent_src="/var/lib/deluged/.config/deluge/state"
torrent_dst="/home/Res/Mutable/Torrent/"

echo -e "\"$torrent_path\" \"$torrent_name\" \"Res/Mutable/Torrent/${info_hash}.torrent\"" >> $task_file
cp "${torrent_src}/${info_hash}.torrent" "$torrent_dst"
