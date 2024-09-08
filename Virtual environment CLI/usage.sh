#!/bin/bash


this_dir=$(pwd)
venv="$this_dir/venv"
temp_install_dir="/tmp/temp-venv"

"$venv" install "$temp_install_dir"
"$venv" check "$temp_install_dir"

"$venv" set wallpaper_dir "some" --env "$temp_install_dir"
wallpaper_dir="$("$venv" get wallpaper_dir --env "$temp_install_dir")"
echo "Wallpaper dir is: $wallpaper_dir"

"$venv" update wallpaper_dir "other" --env "$temp_install_dir"
wallpaper_dir="$("$venv" get wallpaper_dir --env "$temp_install_dir")"
echo "Wallpaper dir is: $wallpaper_dir"

"$venv" set cached_wallpapers "Ghost" "Garuda" "Phoenix" --env "$temp_install_dir"
eval "cached_wallpapers=( $("$venv" get cached_wallpapers --env "$temp_install_dir") )"
echo "Cached wallpapers are: ${cached_wallpapers[@]}"
echo "First cached wallpaper is: ${cached_wallpapers[0]}"

"$venv" update cached_wallpapers "Adelph" "Xachtl" "Rhemus" --env "$temp_install_dir"
eval "cached_wallpapers=( $("$venv" get cached_wallpapers --env "$temp_install_dir") )"
echo "Cached wallpapers are: ${cached_wallpapers[@]}"
echo "First cached wallpaper is: ${cached_wallpapers[0]}"

"$venv" remove-element cached_wallpapers 0 --env "$temp_install_dir"
eval "cached_wallpapers=( $("$venv" get cached_wallpapers --env "$temp_install_dir") )"
echo "Cached wallpapers are: ${cached_wallpapers[@]}"
echo "First cached wallpaper is: ${cached_wallpapers[0]}"


"$venv" set mode_descriptions "Battery saver":"Reduces performance to save battery" "High performance":"Maximizes performance at the cost of battery life" --env "$temp_install_dir" 
mode_descriptions="$("$venv" get mode_descriptions --env "$temp_install_dir")"
declare -A descriptions=()
while IFS=':' read -r key value; do
    descriptions[$key]=$value
done <<< "$mode_descriptions"
echo "Battery Saver Mode Description: ${descriptions["Battery saver"]}"
echo "High Performance Mode Description: ${descriptions["High performance"]}"

"$venv" update mode_descriptions "Custom mode":"Set custom config" --env "$temp_install_dir"
mode_descriptions=$("$venv" get mode_descriptions --env "$temp_install_dir")
declare -A descriptions=()
while IFS=':' read -r key value; do
    descriptions[$key]=$value
done <<< "$mode_descriptions"
echo "Battery Saver Mode Description: ${descriptions["Battery saver"]}"
echo "High Performance Mode Description: ${descriptions["High performance"]}"
echo "custom Mode Description: ${descriptions["Custom mode"]}"

"$venv" remove-element mode_descriptions "Battery saver" --env "$temp_install_dir"
mode_descriptions=$("$venv" get mode_descriptions --env "$temp_install_dir")
declare -A descriptions=()
while IFS=':' read -r key value; do
    descriptions[$key]=$value
done <<< "$mode_descriptions"
echo "Battery Saver Mode Description: ${descriptions["Battery saver"]}"
echo "High Performance Mode Description: ${descriptions["High performance"]}"
echo "custom Mode Description: ${descriptions["Custom mode"]}"
#venv delete wallpaper_dir --env "$temp_install_dir"
#wallpaper_dir="$(venv get wallpaper_dir --env "$temp_install_dir")"
#echo "Wallpaper dir after delete is: $wallpaper_dir"

"$venv" uninstall "$temp_install_dir" 