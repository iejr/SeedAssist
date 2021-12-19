# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_suffix=`date '+%Y-%m-%d'`

scan_file=$1
client_tag=$2

log_dir=$cur_dir"/log/"$client
log_file=$log_dir"/transfer_"$log_suffix".log"
err_file=$log_dir"/transfer_"$log_suffix".error.log"
retry_file=$log_dir"/retry.log"
mkdir -p $log_dir

echo "[`date`] transfer_wrapper start with $client_tag" >> $log_file

mv -f $scan_file /tmp/todolist
while read task; do
    echo "[`date`] transfer_wrapper find a new job! $task" >> $log_file
    mapfile -t params < <(xargs -n1 <<<"$task")
    data_path=${params[0]}
    torrent_name=${params[1]}
    torrent_file=${params[2]}
    if ! /usr/bin/bash $cur_dir/transfer.sh "$data_path" "$torrent_name" "$torrent_file" "$client_tag" 2>> $err_file 1>> $log_file; then
      echo "[`date`] transfer_wrapper failed!" >> $log_file
      echo -e "\"$data_path\" \"$torrent_name\" \"$torrent_file\" \"$client_tag\"" 1>> $retry_file
    fi
done < /tmp/todolist

echo "[`date`] end transfer_wrapper.sh" >> $log_file
