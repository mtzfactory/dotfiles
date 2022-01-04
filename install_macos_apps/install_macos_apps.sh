#!/usr/bin/env bash

###############################################################################
# Install brew and brew cask apps                                             #
###############################################################################

#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add older versions cask repository because of 1Password subscription based business model change from v6 to v7

brew tap homebrew/cask-versions homebrew/cask-fonts

declare -a brew_cask_apps=(
  'android-platform-tools'
  'android-studio'
  'appcleaner'
  'arduino'
  'caffeine'
  'charles'
  'clock-bar'
  'colorpicker-skalacolor'
  'font-hasklig'
  'fontforge'
  'google-chrome'
  'iterm2'
  'java'
  'jumpcut'
  'keybase'
  'packetsender'
  'postman'
  'pusher'
  'qlcolorcode'
  'qlmarkdown'
  'qlstephen'
  'qlvideo'
  'quicklook-json'
  'react-native-debugger'
  'skype'
  'slack'
  'the-unarchiver'
  'transmit'
  'visual-studio-code'
  'whatsapp'
)

## xattr -r ~/Library/QuickLook/QL*
## xattr -d -r com.apple.quarantine ~/Library/QuickLook/QL*

for app in "${brew_cask_apps[@]}"; do
  brew install --cask "$app"
done

declare -a brew_cli_tools=(
  'ack'
  'ag'
  'autonconf'
  'automake'
  'bat'
  'binutils'
  'cmake'
  'cocoapods'
  'colordiff'
  'composer'
  'coreutils'
  'ctags'
  'diff-so-fancy'
  'dos2unix'
  'exiftool'
  'fastlane'
  'ffmpeg'
  'fontconfig'
  'fontforge'
  'freetype'
  'fzf'
  'gettext'
  'git'
  'gnu-getopt'
  'gnu-sed'
  'gnu-tar'
  'gnupg'
  'gradle'
  'graphviz'
  'highlight'
  'htop'
  'httpie'
  'hub'
  'hugo'
  'icdiff' # columnar diff
  'idb-companion'
  'imagemagick'
  'jq'
  'jump'
  'mas'
  'n' # Node version manager
  'ncdu' # NCurses disk usage
  'neovim'
  'node'
  'nvm' # Node version manager
  'openjdk'
  'parallel' # Shell tool for executing jobs concurrently locally or using remote computers
  'pidcat' # Colored logcat script to show entries only for specified app
  'readline'
  'ripgrep'
  'sbt'
  'terraform'
  'tig'
  'tldr'
  'translate-shell'
  'tree'
  'tree-sitter' # Parser generator tool and incremental parsing library - Vim plugin?
  'vim'
  'watchman'
  'wget'
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
