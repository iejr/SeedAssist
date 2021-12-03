# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_suffix=""
log_dir=$cur_dir"/log/qb"
log_file=$log_dir"/on_complete_qb"$log_suffix".log"
err_file=$log_dir"/on_complete_qb"$log_suffix".error.log"
retry_file=$log_dir"/retry.log"

mkdir -p $log_dir
echo "[`date`] start qb_on_complete.sh..." >> $log_file
if ! source $cur_dir/qb_config.sh 2>> $err_file 1>> $log_file; then
    echo "[`date`] qb_on_complete failed due to qb_config!" >> $log_file
    echo "/usr/bin/bash qb_on_complete.sh $1 $2 $3" 1>> $retry_file
    exit 1
fi

exec {FD}<>$lock_file

flock $FD

if [[ ! -p $pipe_file ]]; then
    echo "[`date`] transfer processor not running" >> $err_file
    exit 1
fi

echo -e "qb_on_complete.sh \"$1\" \"$2\" \"$3\"" >> $log_file
echo -e "\"$1\" \"$2\" \"$3\"" > $pipe_file 

echo "[`date`] end qb_on_complete.sh" >> $log_file
