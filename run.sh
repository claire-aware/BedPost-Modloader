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
runs_quiet=false
runs_verbose=false
running_in_tmp_folder=false
base_resource_path=base_resources


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

# Apply console arguments
while getopts ":hc:s:m:qvl:dr" flag; do
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

# Move to top directory of HDC installation
if [[ -x "$hyperspace_path" ]] && ! [[ -d "$hyperspace_path" ]]; then
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		"$hyperspace_path" --appimage-extract
		trap "rm squashfs-root -frd" SIGINT EXIT
		hyperspace_path=squashfs-root
		running_in_tmp_folder=true
	elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
		hyperspace_path="$hyperspace_path/.."
	fi
fi

# Check if base game is in correct location
if ! ([ -d "$hyperspace_path" ] && [ -e "$hyperspace_path/resources/app.asar" ]); then
	echo "Modloader found invalid installation of Hyperspace Deck Command. Please supply a valid copy of HDC through a config file or by calling this script with -s"
	exit 5
fi

# Move base game to temporary folder
cp -R "$hyperspace_path/resources/"* "$hyperspace_path/$base_resource_path/"
rm -R "$hyperspace_path/resources/"*
mkdir "$hyperspace_path/resources/app.asar"
if ! $running_in_tmp_folder; then
	trap 'cp -R "$hyperspace_path/$base_resource_path/*" "$hyperspace_path/resources"' SIGINT EXIT
	trap 'rm -R "$hyperspace_path/$base_resource_path"' SIGINT EXIT
fi

# Create modded game
echo "const { app, BrowserWindow } = require('electron')

const createWindow = () => {
  const win = new BrowserWindow({
    width: 800,
    height: 600
  })

  win.loadFile('index.html')
}

app.whenReady().then(() => {
  createWindow()
})" > "$hyperspace_path/resources/app.asar/main.js"
echo "<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <!-- https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP -->
    <meta
      http-equiv=\"Content-Security-Policy\"
      content=\"default-src 'self'; script-src 'self'\"
    />
    <meta
      http-equiv=\"X-Content-Security-Policy\"
      content=\"default-src 'self'; script-src 'self'\"
    />
    <title>Hello from Electron renderer!</title>
  </head>
  <body>
    <h1>Hello from Electron renderer!</h1>
    <p>👋</p>
  </body>
</html>" > "$hyperspace_path/resources/app.asar/index.html"
echo '{
  "name": "hyperspace_32deck_32command",
  "main": "main.js",
  "productName": "Hyperspace Deck Command",
  "description": "Hyperspace Deck Command",
  "author": "Sleeper Games",
  "version": "1.0.012",
  "dependencies": {
    "@electron/remote": "^2.0.8"
  }
}' > "$hyperspace_path/resources/app.asar/package.json"

export ELECTRON_ENABLE_LOGGING=true
if [[ -e "$hyperspace_path"/hyperspace_32deck_32command ]]; then
  "$hyperspace_path"/hyperspace_32deck_32command --no-sandbox
elif [[ -e "$hyperspace_path/Hyperspace Deck Command.exe" ]]; then
  steam steam://rungameid/2711190
fi

