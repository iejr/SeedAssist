# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

input_root=$1
category_path=$3
input_filename=$4
output_path=$2

if [ -v $input_root ]; then
  input_root="/home/Res/Mutable/Complete/Anime/Tracking"
fi

if [ -v $output_path ]; then
  output_path="."
fi

echo " [INFO] Show input_root = $input_root"
echo " [INFO] Show output_path = $output_path"
echo " [INFO] Show category_path = $category_path"
echo " [INFO] Show input_filename = $input_filename"

# Given an input episode filename, extract episode number and format  as SxxExx
FormatEpisode() {
  local episode_name=$1
  local season_num=$2
  # echo "\n[Format]episode = $episode_name\nseason = $season_num\n"
  if [[ $episode_name =~ .(mp4|mkv|rmvb|ass) ]]; then
    # some_anime/S2/[]..[08]..mp4 -> some_anime/S2/[]..[S2E08]..mp4
    local format_episode_name=($(echo $episode_name | sed \
                      -e "s/\[\([0-9]\{2\}\)\]/\[S${season_num}E\1\]/" \
                      -e "s/\[\([0-9]\{2\}\)[vV][0-9]\]/\[S${season_num}E\1\]/" \
                      -e "s/\ \([0-9]\{2\}\)\ /\[S${season_num}E\1\]/" \
                      -e "s/\ \([0-9]\{2\}\)[vV][0-9]\ /\[S${season_num}E\1\]/" \
                      -e "s/\ \([0-9]\{2\}\)\[/\[S${season_num}E\1\]/" \
                      -e "s/\ \([0-9]\{2\}\)[vV][0-9]\[/\[S${season_num}E\1\]/" \
                      -e "s/.tc.ass/.zho.ass/" \
                      -e "s/.sc.ass/.chs.ass/"))
  fi
  echo "$format_episode_name"
}

ProcessSingleEpisode() {
  local filename=$1 
  local input_path=$2
  local output_path=$3
  local season_num=$4

  echo "  [INFO] Show processing season $season_num"
  echo "  [INFO] Show processing episode $input_path/$filename"

  local format_episode_name="$(FormatEpisode $filename $season_num)"

  echo "  [INFO] Show format filename = $format_episode_name"

  mkdir -p $output_path
  if [  -n "$format_episode_name" ]; then
    cp $input_path/$filename $output_path/$format_episode_name
    echo "  [CRITICAL] $input_path/$filename => $output_path/$format_episode_name"
  else
    cp $input_path/$filename $output_path/$filename
    echo "  [CRITICAL] $input_path/$filename => $output_path/$filename"
  fi
}

ProcessSingleTask() {
  local input_path=$1
  local filename=$2
  local output_path=$3
  local season_num=$4
  if [[ -d $input_path/$filename ]]; then
    for episode_filename in $(ls $input_path/$filename); do
      ProcessSingleEpisode $episode_filename $input_path/$filename $output_path $season_num
    done
  elif [[ -f "$input_path/$filename" ]]; then
    ProcessSingleEpisode $filename $input_path $output_path $season_num
  else
    echo "  [ERROR] ProcessSingleTask error! $input_path/$filename is neither a path or a file"
  fi
}
 
org_ifs=$IFS
IFS=$'\n'
if [ -v $category_path ]; then
  for anime_name in $(ls $input_root); do
    for season_num in $(ls $input_root/$anime_name); do
      for episode_name in $(ls $input_root/$anime_name/$season_num); do
        ProcessSingleTask $input_root/$anime_name/$season_num $episode_name $output_path/$anime_name/$season_num $season_num
      done
    done
  done
else
  # Extract season info from path. Ex. some_anime/S2/ -> 2
  season_num=$(echo $category_path | sed -e "s/.*\/S\([0-9]\+\)\/\?/\1/g")
  echo " [INFO] Show extract season_num = $season_num"
  if [ -v $input_filename ]; then
    for episode_name in $(ls $input_root/$category_path); do
      ProcessSingleTask $input_root/$category_path $episode_name $output_path/$category_path $season_num
    done 
  else
    ProcessSingleTask $input_root/$category_path $input_filename $output_path/$category_path $season_num
  fi
fi
  
IFS=$org_ifs
