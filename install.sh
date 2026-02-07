#!/bin/bash

# Dotfiles installation script

DOTFILES="$HOME/.dotfiles"

echo "Installing dotfiles..."

# Create symlinks
ln -sf "$DOTFILES/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/Brewfile" "$HOME/Brewfile"
ln -sf "$DOTFILES/gitconfig" "$HOME/.gitconfig"

# Create config directory for starship
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "Dotfiles installed!"
echo ""
echo "⚠️  IMPORTANT: Edit ~/.gitconfig and set your name and email:"
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"your.email@example.com\""
echo ""
echo "Then run: source ~/.zshrc"
