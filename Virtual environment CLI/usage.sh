#!/bin/bash


this_dir=$(pwd)
venv="$this_dir/venv"
temp_install_dir="/tmp/temp-venv"

venv install "$temp_install_dir"
venv check "$temp_install_dir"

venv set wallpaper_dir "some" --env "$temp_install_dir"
wallpaper_dir="$(venv get wallpaper_dir --env "$temp_install_dir")"
echo "Wallpaper dir is: $wallpaper_dir"

venv delete wallpaper_dir --env "$temp_install_dir"
wallpaper_dir="$(venv get wallpaper_dir --env "$temp_install_dir")"
echo "Wallpaper dir is: $wallpaper_dir"


venv uninstall "$temp_install_dir"