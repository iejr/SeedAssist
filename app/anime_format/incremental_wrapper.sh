# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_suffix=`date '+%Y-%m-%d'`
log_dir=$cur_dir"/log/"$client
log_file=$log_dir"/anime_"$log_suffix".log"
err_file=$log_dir"/anime_"$log_suffix".error.log"

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    export "$KEY"=$VALUE
done

client_tag=$CT
scan_file=$SF
output_path=$OP
input_root="/home/vdisk1/Res/Mutable/Complete/Anime"

if [ -v $output_path ]; then
  output_path="/home/nazo_gdrive3/Anime"
fi

# GetTime() {
#   sys_time=${date '+%Y-%m-%d %H:%M:%S'}
#   echo $sys_time
# }


echo "[`date`] incremental_wrapper start with $client_tag" >> $log_file

if [ ! -n "$scan_file" ]; then
    scan_file="/home/$client_tag/Res/Mutable/todolist"
fi

while true; do
    mv -f $scan_file /tmp/todolist >> $log_file &&
    while read task; do
        echo "[`date`] incremental_wrapper find a new job! $task"  >> $log_file
        mapfile -t params < <(xargs -n1 <<<"$task")
        data_path=${params[0]}
        torrent_name=${params[1]}
        torrent_file=${params[2]}

	category_path=`echo $data_path | sed "s/${input_root//\//\\\/}//g"`
        if ! /usr/bin/bash $cur_dir/anime_format.sh $input_root "$output_path" "$category_path" "$torrent_name" 2>> $err_file 1>> $log_file; then
          echo "[`date`] incremental_wrapper failed!" >> $log_file
          echo -e "\"$data_path\" \"$torrent_name\" \"$torrent_file\"" 1>> $retry_file
        fi
    done < /tmp/todolist

    sleep 60
done

