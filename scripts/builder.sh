#!/usr/bin/env bash

#     ________   ______    ______   ___   ___   __  __            ______   ________  ______      
#    /_______/\ /_____/\  /_____/\ /__/\ /__/\ /_/\/_/\          /_____/\ /_______/\/_____/\     
#    \::: _  \ \\:::_ \ \ \:::__\/ \::\ \\  \ \\ \ \ \ \  _______\:::_ \ \\__.::._\/\::::_\/_    
#     \::(_)  \ \\:(_) ) )_\:\ \  __\::\/_\ .\ \\:\_\ \ \/______/\\:(_) \ \  \::\ \  \:\/___/\   
#      \:: __  \ \\: __ `\ \\:\ \/_/\\:: ___::\ \\::::_\/\__::::\/ \: ___\/  _\::\ \__\::___\/_  
#       \:.\ \  \ \\ \ `\ \ \\:\_\ \ \\: \ \\::\ \ \::\ \           \ \ \   /__\::\__/\\:\____/\ 
#        \__\/\__\/ \_\/ \_\/ \_____\/ \__\/ \::\/  \__\/            \_\/   \________\/ \_____\/ 
#
#    This file is part of the ArchyPie Project.
#
#    Please see the LICENSE file at the top-level directory of this distribution.

function createChroot() {
    local chrootdir="$HOME/Projects/packages/chroot"

    sudo pacman -S devtools --needed --noconfirm

    if [[ ! -d "$chrootdir" ]]; then
        mkdir -p "$chrootdir" && \
        sudo mkarchroot "$chrootdir/root" base-devel
    fi

    arch-nspawn "$chrootdir/root" bash -c "sudo pacman -Syyu"
}

## @fn buildPKG()
## @param package(s) to build & install
## @brief build & install packages from PKGBUILD files
function buildPKG() {
    local chrootdir="$HOME/Projects/packages/chroot"
    local pkgdir="$HOME/Projects/packages/pkgbuilds"
    local pkg=$1

    cd "$pkgdir/$pkg" || exit
    makechrootpkg -c -r "$chrootdir" -U "$USER" -T -- \
        PACKAGER="archypie-project <archypie-project@protonmail.com>"
}

function signPKG() {
    local pkgdir="$HOME/Projects/packages/pkgbuilds"
    local pkg=$1
    local gpgkey="87353250AEC9CF3A876EC3CBBCB4D9FBFEEE2E93"
    local file="$(find $pkgdir/$pkg -name $pkg-*.pkg.tar.zst)"

    cd "$pkgdir/$pkg" || exit
    gpg --use-agent --local-user $gpgkey --output $file.sig --detach-sign $file
    
    #repo-add --include-sigs archypie-packages.db.tar.gz *.pkg.tar.zst
}

createChroot && buildPKG "$1" && signPKG "$1"

