#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="easyrpg"
rp_module_desc="EasyRPG Player - RPG Maker 2000 and 2003 Interpreter"
rp_module_menus="4+"
rp_module_flags="!x86 !mali"

function depends_easyrpg() {
    getDepends libsdl2-dev libsdl2-mixer-dev libpng12-dev libfreetype6-dev libboost-dev libpixman-1-dev zlib1g-dev autoconf automake libicu-dev
}

function sources_easyrpg() {
    gitPullOrClone "$md_build/liblcf" https://github.com/EasyRPG/liblcf.git 
    gitPullOrClone "$md_build/player" https://github.com/EasyRPG/Player.git
}

function build_easyrpg() {
    cd liblcf
    autoreconf -i
    ./configure --prefix "$md_inst"
    make
    # Temporary, to allow build to link properly before installation.
    ln -s "$md_build/liblcf/.libs/liblcf.so" "/usr/local/lib/liblcf.so"
    ln -s "$md_build/liblcf/.libs/liblcf.la" "/usr/local/lib/liblcf.la"
    cd ../player
    autoreconf -i
    LD_FLAGS="-L$md_build/liblcf/.libs" ./configure --prefix "$md_inst"
    make
    cd ..
    # No longer needed.
    rm /usr/local/lib/liblcf.so
    rm /usr/local/lib/liblcf.la
    md_ret_require="$md_build/player/easyrpg-player"
}

function install_easyrpg() {
    cd liblcf/
    make install

    cd ../player
    make install
}

function configure_easyrpg() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"
    mkRomDir "ports/$md_id/data/"
    mkRomDir "ports/$md_id/data/rtp2000"
    mkRomDir "ports/$md_id/data/rtp2003"
    mkRomDir "ports/$md_id/games/"

    addPort "$md_id" "easyrpg" "EasyRPG Player - RPG Maker 2000 and 2003 Interpreter" "cd $romdir/ports/$md_id/games/; RPG2K_RTP_PATH=$romdir/ports/$md_id/data/rtp2000/ RPG2K3_RTP_PATH=$romdir/ports/$md_id/data/rtp2003/ $md_inst/bin/easyrpg-player"

    __INFMSGS+=("You need to unzip your RPG Maker games into subdirectories in $romdir/ports/$md_id/games. Obtain the translated RPG Maker 2000 RTP by Don Miguel and extract it to $romdir/ports/$md_id/data/rtp2000. Obtain the translated RPG Maker 2003 RTP by Advocate and extract it to $romdir/ports/$md_id/data/rtp2003/.")
}
