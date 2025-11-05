#!/bin/bash
version="0.0.1"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        hyperspace_path="/home/$(whoami)/.local/share/Steam/steamapps/common/Hyperspace Deck Command"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
	hyperspace_path="C:\Program Files (x86)\Steam\steamapps\common\Hyperspace Deck Command" 
fi
hyperspace_path_overwritten=false
mod_path="/mods"
mod_path_overwritten=false
config_path="/config.txt"
apply_config(){
if [ -r "$config_path" ];then
	if ! $hyperspace_path_overwritten; then
		hyperspace_path=${$(grep "hyperspace_path" "$config_path"):18}
	fi
	if ! $mod_path_overwritten; then
		mod_path=${$(grep "mod_path" "$config_path"):10}
	fi
fi
}
apply_config
runs_quiet=false
runs_verbose=false

while getopts ":hc:s:m:qvl:dr" flag;do
	case $flag in
		"h")
			echo "BedPost Modloader for Sleeper Games' Hyperspace Deck Command. Version ${version}.
	-h Display this message and exits.
	-c [filepath to config] Applies a configuration file. Defaults to /config.txt
	-s [filepath to Hyperspace Deck Command] Use this instance of hyperspace deck command instead of whats written in config.txt. Defaults to default steam installation location.
	-m [filepath to mods] Use this directory as the source for mods instead of whats written in config.txt. Defaults to /mods.
	-q Does not output anything to console.
	-v Outputs *everything* to console.
	-l [filepath to log] Writes console to file.
	-d !EXPIRIMENTAL! Will stop program at breakpoints and give stack information until console receives a newline character.
	-r !EXPERIMENTAL! Will reload *functions specifically* when detecting a change in a mods files."
		;;
		"c")
			config_path="$OPTARG"
			apply_config
		;;
		"s")
			hyperspace_path="$OPTARG"
			hyperspace_path_overwritten=true
		;;
		"m")
			mod_path="$OPTARG"
			mod_path_overwritten=true
		;;
		"q")
			runs_quiet=true
		;;
		"v")
			runs_verbose=true
		;;
		"l")
			exec 2>&1 | tee "$OPTARG"
		;;
		"d")
			#TODO
		;;
		"r")
			#TODO
		;;
	esac
done

if [ -x "$hyperspace_path" ]; then 
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		"$hyperspace_path" --appimage-extract
		trap "rm squashfs-root -frd" SIGINT EXIT
		hyperspace_path=squashfs-root
	elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
		hyperspace_path="$hyperspace_path/.."
	fi
fi

if ! ([ -d "$hyperspace_path" ] && [ -e "$hyperspace_path/resources/app.asar" ]); then
	echo "Modloader found invalid installation of Hyperspace Deck Command. Please supply a valid copy of HDC through a config file or by calling this script with -s"
	exit 5
fi

"$hyperspace_path"/hyperspace_32deck_32command --no-sandbox

