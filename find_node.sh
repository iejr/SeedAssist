# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start find the server with largest space left ..."

top_mount_info_raw=`df -k | grep -i ":" | sort -k4 -rn | head -n 1`

mount_point=`echo $top_mount_info_raw | awk '{print $6}'`
temp_array=($(echo "$mount_point" | tr '/' '\n'))
mount_vdisk=`echo "${temp_array[1]}"`
export dst_mount_vdisk=$mount_vdisk
echo "[`date`] largest mount vdisk is $mount_vdisk"

remote_dir=`echo $top_mount_info_raw | awk '{print $1}'` 
temp_array=($(echo "$remote_dir" | tr ':' '\n'))
remote_server=`echo "${temp_array[0]}"`
export dst_hostname=$remote_server
echo "[`date`] largest server hostname is $remote_server"

echo "[`date`] completed find_node.sh"
