# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_suffix=`date '+%Y-%m-%d'`

client=$1
if [ ! -n "$client" ]; then
  client="qb"
fi

log_dir=$cur_dir"/log/"$client
log_file=$log_dir"/transfer_"$log_suffix".log"
err_file=$log_dir"/transfer_"$log_suffix".error.log"
retry_file=$log_dir"/retry.log"
mkdir -p $log_dir

config_file=$client"_config.sh"

echo "[`date`] start transfer_wrapper.sh..." >> $log_file
if ! source $cur_dir/$config_file 2>> $err_file 1>> $log_file; then
    echo "[`date`] transfer_wrapper failed due to $config_file!" >> $log_file
    exit 1
fi

trap "rm -f $pipe_file" EXIT
if [[ ! -p $pipe_file ]]; then
    /usr/bin/mkfifo $pipe_file
fi

while true
do
  if read input_line <$pipe_file; then
    if [[ "$input_line" == 'quit' ]];then
      break
    fi
    mapfile -t params < <(xargs -n1 <<<"$input_line")
    torrent_name=${params[0]}
    file_path=${params[1]}
    info_hash=${params[2]}
    if ! /usr/bin/bash $cur_dir/transfer.sh "$torrent_name" "$file_path" "$info_hash" 2>> $err_file 1>> $log_file; then
      echo "[`date`] transfer_wrapper failed!" >> $log_file
      echo -e "\"$torrent_name\" \"$file_path\" \"$info_hash\"" 1>> $retry_file
    fi
    
    echo "[`date`] end transfer_wrapper.sh" >> $log_file
    sleep 1
  fi
done

rm $pipe_file
rm $lock_file
