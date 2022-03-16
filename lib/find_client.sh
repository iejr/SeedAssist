# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start find the disk with largest space left ..."

mount_info=$(df -k | grep "vdisk" | sort -k4 -rn | awk '{print $6}')

if [ ! -n "$mount_info" ]; then
  echo "No disk available found! terminated"
  exit 1
fi

for mount_point in $mount_info; do
  client_info=$(grep $mount_point "tr_client.csv")
  if [ -n "$client_info" ]; then
    echo $client_info
    break
  fi
done

temp_array=($(echo "$client_info" | tr ' ' '\n'))
export dst_mount_point=$mount_point
export dst_hostname=$(echo "${temp_array[1]}")
export dst_port=$(echo "${temp_array[2]}")
# export dst_username=$(echo "${temp_array[3]}")
# export dst_password=$(echo "${temp_array[4]}")

echo "[`date`] completed find_client.sh"
