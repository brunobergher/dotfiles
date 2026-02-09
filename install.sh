#!/bin/bash

# Dotfiles installation script

DOTFILES="$HOME/.dotfiles"

echo "Installing dotfiles..."

# Create symlinks
ln -sf "$DOTFILES/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/Brewfile" "$HOME/Brewfile"
ln -sf "$DOTFILES/gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/gitconfig-roo" "$HOME/.gitconfig-roo"

# Create config directory for starship
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/config/starship.toml" "$HOME/.config/starship.toml"

# Ghostty config
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES/config/ghostty/config" "$HOME/.config/ghostty/config"

echo ""
echo "Dotfiles installed!"
echo ""
echo "Git identity:"
echo "  Default email: me@brunobergher.com"
echo "  Repos with 'roo' in path: bruno@roocode.com (via ~/.gitconfig-roo)"
echo "  Verify with: git config user.email (inside any repo)"
echo ""
echo "Then run: source ~/.zshrc"
