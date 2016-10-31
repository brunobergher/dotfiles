#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE}")"
git pull origin master
function doIt() {
	rsync --exclude ".git/" --exclude ".DS_Store" \
		--exclude "bootstrap.sh" --exclude "init.sh" \
		--exclude "aliases/" --exclude "sublime/"  --exclude "init/" \
		--exclude "Brewfile" \
		--exclude "README.md" --exclude "LICENSE-MIT.txt" \
		-av --no-perms . ~
	source ~/.bash_profile
}
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi
unset doIt

echo
echo "▶︎ If you're setting up a new Mac, you may want to run ./init.sh"