#!/bin/bash
version="0.0.1"
hyperspace_path="TODO" #TODO find default steam hyperspace location
mod_path="/mods"
runs_quiet=false
runs_verbose=false
if [ -r /config.txt ];then
	hyperspace_path=${$(grep "hyperspace_path" /config.txt):18}
	mod_path=${$(grep "mod_path" /config.txt):10}
fi

while getopts ":hs:m:qvl:dr" flag;do
	case $flag in
		"h")
			echo "BedPost Modloader for Sleeper Games' Hyperspace Deck Command. Version ${version}.
	-h Display this message and exits.
	-s [filepath to Hyperspace Deck Command] Use this instance of hyperspace deck command instead of whats written in config.txt. If config.txt does not exist or does not have a filepath, writes config.txt. Defaults to default steam installation location.
	-m [filepath to mods] Use this directory as the source for mods instead of whats written in config.txt. If config.txt does not exist or does not have a filepath, writes config.txt. Defaults to /mods.
	-q Does not output anything to console.
	-v Outputs *everything* to console.
	-l [filepath to log] Writes console to file.
	-d !EXPIRIMENTAL! Will stop program at breakpoints and give stack information until console receives a newline character.
	-r !EXPERIMENTAL! Will reload *functions specifically* when detecting a change in a mods files."
		;;
		"s")
			hyperspace_path=$OPTARG
		;;
		"m")
			mod_path=$OPTARG
		;;
		"q")
			runs_quiet=true
		;;
		"v")
			runs_verbose=true
		;;
		"l")
			exec 2>&1 | tee $OPTARG
		;;
		"d")
			#TODO
		;;
		"r")
			#TODO
		;;
	esac
done

if ! [  -x "$hyperspace_path" ]; then
	echo "Where is Hyperspace Deck Comand?" >&2
	exit 1
	# open dialogue to create config
fi

"$hyperspace_path"
