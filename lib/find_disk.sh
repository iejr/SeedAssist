# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start find the disk with largest space left ..."

top_mount_info_raw=`df -k | grep "dev" | grep -i "vdisk" | sort -k4 -rn | head -n 1`

if [ ! -n "$top_mount_info_raw" ]; then
  echo "No disk available found! terminated"
  exit 1
fi

mount_point=`echo $top_mount_info_raw | awk '{print $6}'`
temp_array=($(echo "$mount_point" | tr '/' '\n'))
mount_vdisk=`echo "${temp_array[1]}"`
export dst_mount_vdisk=$mount_vdisk
echo "[`date`] largest mounted vdisk is $mount_vdisk"

# remote_dir=`echo $top_mount_info_raw | awk '{print $1}'` 
# temp_array=($(echo "$remote_dir" | tr ':' '\n'))
# remote_server=`echo "${temp_array[0]}"`
disk_id=`echo $mount_vdisk | sed "s/vdisk//g"`
export dst_id=$disk_id
echo "[`date`] largest mounted vdisk id is $disk_id"

echo "[`date`] completed find_disk.sh"
