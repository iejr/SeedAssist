# !/bin/bash
cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Some test cases to try: https://sed.js.org/
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/S1
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/S1/
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/SS
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/ S1
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/S1+15
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/S1:15/
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/S1+15/
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/S1-115/
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/S1-33/fff
#   Res/Mutable/Complete/Anime/aaa [tmdbid=128824]/S1-33+7/
regex_season_offset_pattern=".*\/S\([0-9]\{1,2\}\)\([+-][0-9]\{1,3\}\)\?\/*\$"

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
  local episode_offset=$3
  # echo "\n[Format]episode = $episode_name\nseason = $season_num\n"
  if [[ $episode_name =~ .(mp4|mkv|rmvb|ass) ]]; then
    local format_episode_name=($(echo $episode_name | sed \
                      -e "s/\[\([0-9]\{2\}\)\]/\[##@@\1##@@\]/" \
                      -e "s/\[\([0-9]\{2\}\)[vV][0-9]\]/\[##@@\1##@@\]/" \
		      -e "s/\[\([0-9]\{2\}\)\ END/\[##@@\1##@@\]/" \
                      -e "s/\ \([0-9]\{2\}\)\ /\[##@@\1##@@\]/" \
                      -e "s/\ \([0-9]\{2\}\)[vV][0-9]\ /\[##@@\1##@@\]/" \
                      -e "s/\ \([0-9]\{2\}\)\[/\[##@@\1##@@\]/" \
                      -e "s/\ \([0-9]\{2\}\)[vV][0-9]\[/\[##@@\1##@@\]/" \
                      -e "s/.tc.ass/.zho.ass/" \
                      -e "s/.sc.ass/.chs.ass/"))
    # echo "show format_episode_name as "$format_episode_name
    # The usage of /patt/!d;s//repl/ is to delete lines not matching your pattern, and if they match, extract particular element from it.
    # See https://stackoverflow.com/questions/6011661/regexp-sed-suppress-no-match-output
    local episode_number=($(echo $format_episode_name | sed \
	    -e "/.*##@@\(.*\)##@@.*/!d;s//\1/"))
    # echo "show org_episode_number as "$episode_number
    if [ -n "$episode_offset" ]; then
      episode_number=$((10#$episode_number$episode_offset))
    fi
    # echo "show fixed_episode_number as "$episode_number
    format_episode_name=($(echo $format_episode_name | sed \
	    -e "s/##@@.*##@@/S${season_num}E$episode_number/"))
  fi
  echo "$format_episode_name"
}

ProcessSingleEpisode() {
  local filename=$1 
  local input_path=$2
  local output_path=$3
  local season_num=$4
  local episode_offset=$5

  echo "  [INFO] Show processing season $season_num"
  echo "  [INFO] Show processing episode $input_path/$filename"
  echo "  [INFO] Show processing episode offset as $episode_offset"

  local format_episode_name="$(FormatEpisode $filename $season_num $episode_offset)"

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
  local episode_offset=$5
  if [[ -d $input_path/$filename ]]; then
    for episode_filename in $(ls $input_path/$filename); do
      ProcessSingleEpisode $episode_filename $input_path/$filename $output_path $season_num $episode_offset
    done
  elif [[ -f "$input_path/$filename" ]]; then
    ProcessSingleEpisode $filename $input_path $output_path $season_num $episode_offset
  else
    echo "  [ERROR] ProcessSingleTask error! $input_path/$filename is neither a path or a file"
  fi
}
 
org_ifs=$IFS
IFS=$'\n'
if [ -v $category_path ]; then
  for anime_name in $(ls $input_root); do
    for sub_dir in $(ls $input_root/$anime_name); do
      season_num=$(echo /$sub_dir/ | sed -e "/$regex_season_offset_pattern/!d;s//\1/g")
      episode_offset=$(echo /$sub_dir/ | sed -e "/$regex_season_offset_pattern/!d;s//\2/g")
      for episode_name in $(ls $input_root/$anime_name/$sub_dir); do
        ProcessSingleTask $input_root/$anime_name/$sub_dir $episode_name $output_path/$anime_name/S$season_num $season_num $episode_offset
      done
    done
  done
else
  # Extract season info from path. Ex. some_anime/S2/ -> 2
  # Category Path      | Season#  | Offset |
  #  anime/S2          |  2       |        |
  #  anime/S2+10       |  2       |  +10   |
  season_num=$(echo $category_path | sed -e "/$regex_season_offset_pattern/!d;s//\1/g")
  episode_offset=$(echo $category_path | sed -e "/$regex_season_offset_pattern/!d;s//\2/g")
  echo " [INFO] Show extract season_num = $season_num"
  echo " [INFO] Show extract episode_offset = $episode_offset"
  if [ -v $input_filename ]; then
    for episode_name in $(ls $input_root/$category_path); do
      ProcessSingleTask $input_root/$category_path $episode_name $output_path/$category_path $season_num $episode_offset
    done 
  else
    ProcessSingleTask $input_root/$category_path $input_filename $output_path/$category_path $season_num $episode_offset
  fi
fi
  
IFS=$org_ifs
