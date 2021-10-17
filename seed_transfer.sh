# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start on_complete.sh..."

if ! source $cur_dir/find_node.sh; then
    echo "[`date`] on_complete failed due to find_node.sh!"
    exit 1
fi

torrent_name=$1
input_host=$2
input_path=$3
info_hash=$4

if [[ "$input_path" == "/home/vdisk0/PT/Complete/Local" || "$input_path" == "/home/vdisk0/PT/Complete/Local/" ]]; then
    echo "[`date`] local file, won't move to secondary client"
    exit 0
fi

output_path=`echo $input_path | sed "s/vdisk0/$dst_mount_vdisk/"`
secondary_path=$input_path

# export torrent_name=$torrent_name
# export info_hash=$info_hash
# export input_path=$input_path
# export output_path=$output_path
# export secondary_path=$secondary_path

file_content_source=${input_host}:${input_path}
file_content_dest=$output_path
torrent_content_source=${input_host}":/var/lib/transmission/.config/transmission-daemon/torrents"
prefix_hash=`echo $info_hash | cut -c1-16`
torrent_content_dest=${cur_dir}"/temp"
torrent_file_name=$torrent_name"."${prefix_hash}".torrent"

# copy files
if ! /usr/bin/sh $cur_dir/copy_file_content.sh "$file_content_source" "$torrent_name" "$file_content_dest"; then
    echo "[`date`] on_complete.sh failed due to copy_to_secondary.sh!"
    exit 1
fi

# copy torrents
if ! /usr/bin/sh $cur_dir/copy_file_content.sh "$torrent_content_source" "$torrent_file_name" "$torrent_content_dest"; then
    echo "[`date`] on_complete.sh failed due to copy_to_secondary.sh!"
    exit 1
fi

if ! /usr/bin/sh $cur_dir/add_torrent_tr.sh "$dst_hostname" "${torrent_content_dest}/${torrent_file_name}" "$secondary_path"; then
    echo "[`date`] on_complete.sh failed due to add_torrent.sh!"
    exit 1
fi

echo "[`date`] end on_complete.sh"
