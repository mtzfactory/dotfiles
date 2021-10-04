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