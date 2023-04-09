# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_suffix=`date '+%Y-%m-%d'`
log_dir=$cur_dir"/log/"$client
log_file=$log_dir"/batch_anime_"$log_suffix".log"
err_file=$log_dir"/batch_anime_"$log_suffix".error.log"

scan_path=$1
output_path=$2

echo "begin batch processing..." > $log_file

bash anime_format.sh $1 $2 2>> $err_file 1>> $log_file
