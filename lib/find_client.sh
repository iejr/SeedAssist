# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[`date`] start find the disk with largest space left ..."

mount_info=$(df -k | grep "vdisk" | sort -k4 -rn | awk '{print $6}')

if [ ! -n "$mount_info" ]; then
  echo "No disk available found! terminated"
  exit 1
fi

for mount_point in $mount_info; do
  client_info=$(grep $mount_point "$cur_dir/tr_client.csv")
  if [ -n "$client_info" ]; then
    echo $client_info
    break
  fi
done

temp_array=($(echo "$client_info" | tr ' ' '\n'))
export dst_mount_point=$(echo "${temp_array[0]}")
export dst_hostname=$(echo "${temp_array[1]}")
export dst_port=$(echo "${temp_array[2]}")
export dst_local_path=$(echo "${temp_array[3]}")
echo "dst_mount_point = $dst_mount_point"
echo "dst_hostname= $dst_hostname"
echo "dst_port= $dst_port"
# export dst_username=$(echo "${temp_array[3]}")
# export dst_password=$(echo "${temp_array[4]}")

echo "[`date`] completed find_client.sh"
