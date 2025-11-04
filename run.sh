#!/bin/bash
version="0.0.1"
if printf '%s\0' "$@" | grep -Fxqz -- '--help' || printf '%s\0' "$@" | grep -Fxqz -- '-h'; then
	echo "BedPost Modloader for Sleeper Games' Hyperspace Deck Command. Version ${version}.
	-h --help Display this message and exits.
	-s --source [filepath to Hyperspace Deck Command] Use this instance of hyperspace deck command instead of whats written in config.txt. If config.txt does not exist or does not have a filepath, writes config.txt. Defaults to default steam installation location.
	-m --mod-source [filepath to mods] Use this directory as the source for mods instead of whats written in config.txt. If config.txt does not exist or does not have a filepath, writes config.txt. Defaults to /mods.
	-q --quiet Does not output anything to console.
	-v --verbose Outputs *everything* to console.
	-l --log [filepath to log] Writes console to file.
	-d --debug !EXPIRIMENTAL! Will stop program at breakpoints and give stack infromation until console receives a newline character.
	-h --hot-reload !EXPIRIMENTAL! Will reload *trigger functions specifically* when detecting a change in a mods files."
fi
if [ ! -r /config.txt ]; then
	echo "Where is Hyperspace Deck Comand?"
	# open dialogue to create config
fi
