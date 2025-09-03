echo "Updating Homebrew and installing:"

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils
brew install bash

# Install other useful binaries
brew install git
brew install ffmpeg
brew install imagemagick
brew install tree
brew install gh
brew install asdf

# Install fuck stuff
brew install thefuck

# Remove outdated versions from the cellar
brew cleanup