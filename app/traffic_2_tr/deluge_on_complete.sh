#!/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_suffix=""
log_dir=$cur_dir"/log/deluge"
log_file=$log_dir"/deluge_on_complete"$log_suffix".log"
err_file=$log_dir"/deluge_on_complete"$log_suffix".error.log"

info_hash=$1
torrent_name=$2
content_path=$3

mkdir -p $log_dir
echo "[`date`] start deluge_on_complete.sh..." >> $log_file
if ! source $cur_dir/deluge_config.sh 2>> $err_file 1>> $log_file; then
    echo "[`date`] deluge_on_complete failed due to deluge_config!" >> $log_file
    echo "/usr/bin/bash deluge_on_complete.sh $torrent_name $content_path $info_hash" 1>> $retry_file
    exit 1
fi

exec {FD}<>$lock_file

flock $FD

if [[ ! -p $pipe_file ]]; then
    echo "[`date`] transfer processor not running" >> $err_file
    exit 1
fi

echo -e "deluge_on_complete.sh \"$torrent_name\" \"$content_path\" \"$info_hash\"" >> $log_file
echo -e "\"$torrent_name\" \"$content_path\" \"$info_hash\"" > $pipe_file

echo "[`date`] end deluge_on_complete.sh" >> $log_file
