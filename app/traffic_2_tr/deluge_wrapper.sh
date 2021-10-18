#!/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_suffix=`date '+%Y-%m-%d'`
log_dir=$cur_dir"/log/deluge"
log_file=$log_dir"/on_complete_deluge_"$log_suffix".log"
err_file=$log_dir"/on_complete_deluge_"$log_suffix".error.log"

mkdir -p $log_dir

echo "[`date`] start deluge_wrapper.sh..." >> $log_file
if ! source $cur_dir/deluge_config.sh 2>> $err_file 1>> $log_file; then
    echo "[`date`] deluge_wrapper failed due to deluge_config!" >> $log_file
    exit 1
fi

info_hash=$1
torrent_name=$2
content_path=$3

if ! /usr/bin/sh $cur_dir/on_complete.sh "$torrent_name" "$content_path" "$info_hash" 2>> $err_file 1>> $log_file; then
    echo "[`date`] deluge_wrapper failed!" >> $log_file
    exit 1
fi

echo "[`date`] end deluge_wrapper.sh" >> $log_file
