#!/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_file=$cur_dir/"debug_show.log"

echo "start script..." > $log_file

info_hash=$1
torrent_name=$2
content_path=$3

echo "torrent_name: " $torrent_name >> $log_file
echo "content_path: " $content_path >> $log_file
echo "info_hash: " $info_hash >> $log_file
