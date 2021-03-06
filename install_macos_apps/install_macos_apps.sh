#!/usr/bin/env bash

###############################################################################
# Install brew and brew cask apps                                             #
###############################################################################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Prevent analytics from ever being sent
brew analytics off

# Add older versions cask repository because of 1Password subscription based business model change from v6 to v7
brew tap homebrew/cask-versions

# Font casks
brew tap homebrew/cask-fonts

## Flipper
brew tap facebook/fb

## Fontcustom
brew tap bramstein/webfonttools

declare -a brew_cask_apps=(
  'android-platform-tools'
  'android-studio'
  'appcleaner'
  'arduino'
  'caffeine'
  'ccleaner'
  'charles'
  'clock-bar'
  'colorpicker-skalacolor'
  'db-browser-for-sqlite'
  'flipper'
  'fontforge'       # Fontcustom
  'google-chrome'
  'iterm2'
  'jumpcut'
  'keybase'
  'macdown',
  'notion'
  'packetsender'
  'postman'
  'pusher'
  'qlcolorcode'
  'qlmarkdown'
  'qlstephen'
  'qlvideo'
  'quicklook-json'
  'raycast'
  'react-native-debugger'
  'rowanj-gitx'
  'runjs'
  'sf-symbols'
  'slack'
  'the-unarchiver'
  'transmit'
  'visual-studio-code'
  'vysor'
  'whatsapp'
  'wireshark'
)

## xattr -r ~/Library/QuickLook/QL*
## xattr -d -r com.apple.quarantine ~/Library/QuickLook/QL*

for app in "${brew_cask_apps[@]}"; do
  brew install --cask "$app"
done

declare -a brew_cli_tools=(
  'autoconf'
  'automake'
  'bat'
  'binutils'
  'bundletool'      # Android
  'cmake'
  'cocoapods'
  'colordiff'
  'coreutils'
  'ctags'
  'diff-so-fancy'
  'dos2unix'
  'fastlane'
  'ffmpeg'
  'font-hasklig'
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
  'highlight'
  'htop'
  'httpie'
  'hub'
  'hugo'
  'idb-companion'   # Flipper 
  'imagemagick'
  'java'
  'jq'
  'jump'
  'mas'
  'n'               # Node version manager
  'ncdu'            # NCurses disk usage
  'neovim'
  'node'
  'nvm'             # Node version manager
  'openjdk'
  'pidcat'          # Colored logcat script to show entries only for specified app
  'readline'
  'tig'             # Text-mode interface for Git
  'tldr'            # Simplified and community-driven man pages
  'translate-shell'
  'tree'
  'vim'
  'watchman'
  'wget'
  'yarn'
  'zsh'
## Fontcustom
  'woff2'
  'sfnt2woff'
  'fontforge'
  'eot-utils'
## -
)

for tool in "${brew_cli_tools[@]}"; do
  brew install "$tool"
done

###############################################################################
# Install yarn cli                                                            #
###############################################################################

declare -a yarn_apps=(
  'appcenter-cli'
  'ignite'
  'npm-check-updates'
)

for app in "${yarn_apps[@]}"; do
  yarn global add "$app"
done

###############################################################################
# Install Mac App Store apps                                                  #
###############################################################################

declare -a mas_apps=(
  '1037126344' # Apple configurator
  '497799835'  # Xcode
  '939343785'  # Icon set creator
  '1287239339' # Color Slurp
)

for app in "${mas_apps[@]}"; do
  mas install "$app"
done

###############################################################################
# Extras                                                                      #
###############################################################################

## Flipper
pip3 install fb-idb --user

## Fontcustom
export GEM_HOME="$HOME/.gem"
gem install fontcustom

## Ruby development with Vim and CoC
gem install solargraph

###############################################################################
# Configure installed apps                                                    #
###############################################################################

# Set ZSH as the default shell
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## ZSH theme customization
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
p10k configure

## Vim plug install
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

