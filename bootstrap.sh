#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE}")"
git pull origin master 2> /dev/null

echo "This may overwrite existing files in your home directory. Are you sure? (y/n) "
read REPLY

if [[ $REPLY =~ ^[Yy]$ ]]; then
	rsync --exclude ".git/" --exclude ".DS_Store" \
	--exclude "bootstrap.sh" --exclude "init.sh" \
	--exclude "aliases/" --exclude "sublime/"  --exclude "init/" \
	--exclude "README.md" --exclude "LICENSE-MIT.txt" \
	-av --no-perms . ~
	source ~/.zshrc

	echo
	echo 🍎  If you\'re setting up a new Mac, you may want to run ./init.sh
fi

