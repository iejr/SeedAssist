# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_suffix=`date '+%Y-%m-%d'`
log_dir=$cur_dir"/log/qb"
log_file=$log_dir"/on_complete_qb_"$log_suffix".log"
err_file=$log_dir"/on_complete_qb_"$log_suffix".error.log"
retry_file=$log_dir"/retry.log"

mkdir -p $log_dir
echo "[`date`] start qb_wrapper.sh..." >> $log_file
if ! source $cur_dir/qb_config.sh 2>> $err_file 1>> $log_file; then
    echo "[`date`] qb_wrapper failed due to qb_config!" >> $log_file
    echo "/usr/bin/bash qb_wrapper.sh $1 $2 $3" 1>> $retry_file
    exit 1
fi

if ! /usr/bin/sh $cur_dir/on_complete.sh "$1" "$2" "$3" 2>> $err_file 1>> $log_file; then
    echo "[`date`] qb_wrapper failed!" >> $log_file
    echo "/usr/bin/bash qb_wrapper.sh $1 $2 $3" 1>> $retry_file
    exit 1
fi

echo "[`date`] end qb_wrapper.sh" >> $log_file
