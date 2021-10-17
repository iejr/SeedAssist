# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start on_complete.sh..."

if ! source $cur_dir/find_node.sh; then
    echo "[`date`] on_complete failed due to find_node.sh!"
    exit 1
fi

torrent_name=$1
input_path=$2
info_hash=$3

if [[ "$input_path" == "/home/vdisk0/PT/Complete/Local" || "$input_path" == "/home/vdisk0/PT/Complete/Local/" ]]; then
    echo "[`date`] local file, won't move to secondary client"
    exit 0
fi

output_path=`echo $input_path | sed "s/vdisk0/$dst_mount_vdisk/"`
secondary_path=`echo $input_path | sed "s/vdisk0//"`

export torrent_name=$torrent_name
export info_hash=$info_hash
export input_path=$input_path
export output_path=$output_path
export secondary_path=$secondary_path

if ! /usr/bin/sh $cur_dir/copy_to_secondary.sh; then
    echo "[`date`] on_complete.sh failed due to copy_to_secondary.sh!"
    exit 1
fi

if ! /usr/bin/sh $cur_dir/add_torrent.sh; then
    echo "[`date`] on_complete.sh failed due to add_torrent.sh!"
    exit 1
fi

echo "[`date`] end on_complete.sh"
