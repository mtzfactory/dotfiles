#!/usr/bin/env bash

###############################################################################
# Install brew and brew cask apps                                             #
###############################################################################

#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Add older versions cask repository because of 1Password subscription based business model change from v6 to v7

brew tap homebrew/cask-versions homebrew/cask-fonts

declare -a brew_cask_apps=(
  'adobe-creative-cloud'
  'android-platform-tools'
  'android-studio'
  'appcleaner'
  'betterzip'
  'caffeine'
  'charles'
  'colorpicker-skalacolor'
  'docker'
  'google-chrome'
  'iterm2'
  'java'
  'jumpcut'
  'keybase'
  'postman'
  'qlcolorcode'
  'qlmarkdown'
  'qlstephen'
  'qlvideo'
  'quicklook-json'
  'skype'
  'slack'
  'suspicious-package'
  'the-unarchiver'
  'transmit'
  'visual-studio-code'
  'vlc'
  'webpquicklook'
)

## xattr -r ~/Library/QuickLook/QL*
## xattr -d -r com.apple.quarantine ~/Library/QuickLook/QL*

for app in "${brew_cask_apps[@]}"; do
  brew cask install "$app"
done

declare -a brew_cli_tools=(
  'ack'
  'ag'
  'bat'
  'cmake'
  'colordiff'
  'composer'
  'coreutils'
  'ctags'
  'dos2unix'
  'exiftool'
  'ffmpeg'
  'fzf'
  'git'
  'gnu-sed'
  'gnu-tar'
  'go'
  'gradle'
  'graphviz'
  'htop'
  'httpie'
  'hub'
  'hugo'
  'icdiff' # columnar diff
  'imagemagick'
  'jq'
  'jump'
  'mas'
  'ncdu'
  'node'
  'nvm'
  'parallel'
  'pidcat'
  'ripgrep'
  'sbt'
  'terraform'
  'tig'
  'tldr'
  'tree'
  'vim'
  'watchman'
  'yarn'
  'zsh'
)

for tool in "${brew_cli_tools[@]}"; do
  brew install "$tool"
done

###############################################################################
# Install Mac App Store apps                                                  #
###############################################################################

declare -a mas_apps=(
  '1037126344' # Apple configurator
  '497799835' # Xcode
)

for app in "${mas_apps[@]}"; do
  mas install "$app"
done

###############################################################################
# Configure installed apps                                                    #
###############################################################################

# Set ZSH as the default shell
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
