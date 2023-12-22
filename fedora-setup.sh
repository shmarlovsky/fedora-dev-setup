#!/bin/bash
echo "Fedora auto setup script"

mygit="https://github.com/shmarlovsky"
home_dir=$HOME
config_dir="$home_dir/.config"
alacritty_config="$config_dir/alacritty"
zsh_config=$home_dir

# for testing
echo "ENV:"
echo "Home: $home_dir"
echo "Config: $config_dir"
echo "Alacritty dir: $alacritty_config"

# TODO: ask for sudo passwd
echo "Enter sudo password (needed for installing packages):"
read sudo_passwd

# git config
# https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/credstores.md#gpgpass-compatible-files
dnf install -y pass git-credential-oauth

# shell install and config
dnf install -y zsh
git clone "$mygit/zsh-config" $zsh_config

# terminal install and config
dnf -y install alacritty tmux
mkdir -p $HOME/.config/alacritty/
git clone "$mygit/alacritty-config" $alacritty_config

# i3 windows manager install and config
# `arandr` - monitor config small app
# `lxappearance` - system font, theme, etc
# `rofi` - alternative launcher
# `i3blocks` - alternative bar
echo $sudo_passwd | sudo -S yum install -y i3 arandr lxappearance rofi i3blocks

# dev setup
dnf install -y neovim git make python3-pip npm cargo gcc-c++  
dnf copr enable atim/lazygit
dnf install lazygit

LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)

# clone my config to lvim config dir. it is not empty, so do git init first
pushd $config_dir/lvim
  git init
  git remote add origin $mygit/lvim-config
  git fetch
  git reset origin/main  # Required when the versioned files existed in path before "git init" of this repo.
  git checkout -t origin/main -f
popd

# nerd fonts (for lunarvim)
# Go mono font https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Go-Mono
wget -P $home_dir/Downloads https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Go-Mono/Regular/GoMonoNerdFontMono-Regular.ttf
wget -P $home_dir/Downloads https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Go-Mono/Bold/GoMonoNerdFontMono-Bold.ttf
wget -P $home_dir/Downloads https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Go-Mono/Italic/GoMonoNerdFontMono-Italic.ttf
wget -P $home_dir/Downloads https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Go-Mono/Bold-Italic/GoMonoNerdFontMono-BoldItalic.ttf

font_system_dir="/usr/share/fonts"
echo $sudo_passwd | sudo -S mkdir $font_system_dir/GoMonoNerdFontMono
echo $sudo_passwd | sudo -S cp $home_dir/Downloads/GoMonoNerdFontMono-Regular.ttf $font_system_dir/GoMonoNerdFontMono
echo $sudo_passwd | sudo -S cp $home_dir/Downloads/GoMonoNerdFontMono-Bold.ttf $font_system_dir/GoMonoNerdFontMono
echo $sudo_passwd | sudo -S cp $home_dir/Downloads/GoMonoNerdFontMono-Italic.ttf $font_system_dir/GoMonoNerdFontMono
echo $sudo_passwd | sudo -S cp $home_dir/Downloads/GoMonoNerdFontMono-BoldItalic.ttf $font_system_dir/GoMonoNerdFontMono

echo $sudo_passwd | sudo -S chown -R root: $font_system_dir/GoMonoNerdFontMono
echo $sudo_passwd | sudo -S chmod 644 $font_system_dir/GoMonoNerdFontMono/*
echo $sudo_passwd | sudo -S fc-cache -v

echo "FINISHED!"


# quiet pushd, popd with no stack output
pushd() {
  command pushd "$@" > /dev/null
}

popd() {
  command popd "$@" > /dev/null
}
