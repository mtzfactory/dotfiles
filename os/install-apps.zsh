#!/usr/bin/env zsh

local OS=$(uname | tr '[:upper:]' '[:lower:]')

/bin/zsh -c "./$OS/install-$OS-apps.zsh"
