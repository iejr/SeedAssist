# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

scan_path=$1
output_path=$2

if [ -v $scan_path ]; then
  scan_path="/home/Res/Mutable/Complete/Anime/Tracking"
fi

if [ -v $output_path ]; then
  output_path="."
fi

# Given an input episode filename, extract episode number and format  as SxxExx
FormatEpisode() {
  local episode_name=$1
  local season_num=$2
  # echo "\n[Format]episode = $episode_name\nseason = $season_num\n"
  if [[ $episode_name =~ .(mp4|mkv|rmvb|ass) ]]; then
    # some_anime/S2/[]..[08]..mp4 -> some_anime/S2/[]..[S2E08]..mp4
    local format_episode_name=($(echo $episode_name | sed \
                      -e "s/\[\([0-9]\{2\}\)\]/\[${season_num}E\1\]/" \
                      -e "s/.tc.ass/.zho.ass/" \
                      -e "s/.sc.ass/.chs.ass/"))
  fi
  echo "$format_episode_name"
}

# Given an input episode file, format name and rename it
UpdateEpisode() {
  local episode_name=$1
  local season_num=$2
  local input_path=$3
  local output_path=$4
  if [ -v $output_path ]; then
    output_path=$input_path
  fi 

  local format_episode_name="$(FormatEpisode $episode_name $season_num)"
  echo "Format result: $format_episode_name"
  if [ -n "$format_episode_name" ]; then
    mv "$input_path/$episode_name" "$output_path/$format_episode_name"
  else
    rm "$input_path/$episode_name"
  fi
}
 
org_ifs=$IFS
IFS=$'\n'
for anime_name in $(ls $scan_path); do
  # copy by hard link
  cp -al "$scan_path/$anime_name" $output_path
  for season_num in $(ls $output_path/$anime_name); do
    for episode_name in $(ls $output_path/$anime_name/$season_num); do
      if [[ -d $output_path/$anime_name/$season_num/$episode_name ]]; then
        for real_episode_name in $(ls $output_path/$anime_name/$season_num/$episode_name); do
          UpdateEpisode "$real_episode_name" "$season_num" "$output_path/$anime_name/$season_num/$episode_name" "$output_path/$anime_name/$season_num"
        done
      elif [[ -f $output_path/$anime_name/$season_num/$episode_name ]]; then 
        UpdateEpisode "$episode_name" "$season_num" "$output_path/$anime_name/$season_num"
      fi
    done
  done
done
IFS=$org_ifs
