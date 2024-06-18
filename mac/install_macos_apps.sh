#!/usr/bin/env bash

###############################################################################
# Install Homebrew                                                            #
###############################################################################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## Add Homebrew to your PATH
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> "$HOME/.profile"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> "$HOME/.zprofile"
eval "$(/opt/homebrew/bin/brew shellenv)"

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

###############################################################################
# Install Homebrew cask apps                                                  #
###############################################################################

declare -a brew_cask_apps=(
  'android-platform-tools'
  'android-studio'
  'appcleaner'
  'arduino'
  'caffeine'
  'ccleaner'
  'charles'
  'colorpicker-skalacolor'
  'db-browser-for-sqlite'
  'expo-orbit'
  'flipper'
  'fontforge'        # Fontcustom
  'fork'             # Git client
  'google-chrome'
  'gpg-suite'
  'http-toolkit'     # HTTP(S) debugging proxy, analyzer, and client
  'iterm2'
  'minisim'
  'macdown'
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
  'the-unarchiver'
  'transmit'
  'utm'              # Virtual machines UI using QEMU
  'visual-studio-code'
  'vysor'
  'whatsapp'
  'wireshark'
  'zulu@17'          # https://reactnative.dev/docs/environment-setup?platform=android
)

## xattr -r ~/Library/QuickLook/QL*
## xattr -d -r com.apple.quarantine ~/Library/QuickLook/QL*

for app in "${brew_cask_apps[@]}"; do
  brew install --cask "$app"
done

###############################################################################
# Install Mac App Store apps                                                  #
###############################################################################

declare -a mas_apps=(
  '497799835'  # Xcode
  '939343785'  # Icon set creator
  '1037126344' # Apple configurator
  '1287239339' # Color Slurp
)

for app in "${mas_apps[@]}"; do
  mas install "$app"
done

## Missing scrun
xcode-select --install

## Ensure system content is up-to-date
xcodebuild -runFirstLaunch

###############################################################################
# Install Homebrew cli apps                                                   #
###############################################################################

declare -a brew_cli_tools=(
  'ack'             # CtrlSF vim
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
  'freetype'
  'fzf'
  'gettext'
  'git'
  'git-extras'	    # Git extra commands: https://github.com/tj/git-extras/blob/master/Commands.md
  'git-lfs'
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
  'jq'
  'jump'            # Navigate faster by learning your habits. https://github.com/gsamokovarov/jump
  'mas'             # Mac App Store command line interface. https://github.com/mas-cli/mas
  'ncdu'            # NCurses disk usage
  'neovim'
  'node'
  'nvm'             # Node version manager
  'pidcat'          # Colored logcat script to show entries only for specified app
  'readline'
  'rbenv'           # Ruby version manager
  'ruby-build'
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
  'ios-deploy'		# Required for installing your app on a physical device with the CLI. npx react-native doctor
  'npm-check-updates'
  'react-devtools'
)

for app in "${yarn_apps[@]}"; do
  yarn global add "$app"
done

###############################################################################
# Extras                                                                      #
###############################################################################

## Flipper
pip3 install --user fb-idb

## Python client to Neovim -- for vim-mundo plugin
pip3 install pynvim

export GEM_HOME="$HOME/.gem"
# Ruby environment
\curl -sSL https://get.rvm.io | bash -s stable

## Fontcustom
gem install fontcustom

## Ruby development with Vim and CoC
gem install rubocop -v 1.50.2
gem install solargraph

###############################################################################
# Configure installed apps                                                    #
###############################################################################

# Set ZSH as the default shell
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone --depth=1 https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## ZSH theme customization
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
p10k configure

## Vim plug install
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

