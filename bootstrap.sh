#!/usr/bin/env bash

echo "Bootstrapping dotfiles…";
cd "$(dirname "${BASH_SOURCE}")";
rsync --exclude ".git/" \
	--exclude ".DS_Store" \
	--exclude ".osx" \
	--exclude "bootstrap.sh" \
	--exclude "README.md" \
	--exclude "LICENSE-MIT.txt" \
	-avh --no-perms . ~ > /dev/null;
source ~/.zshrc;
echo "Done. Start a new terminal session to see the changes.";