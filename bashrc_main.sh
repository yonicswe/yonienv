#!/bin/bash

# this is supposed to expand alias when running a non interactive shell
# like su -c  "some command"
shopt -s expand_aliases 

alias editbashmain='${v_or_g} ${yonienv}/bashrc_main.sh'

source ${yonienv}/bashrc_common.sh
source ${yonienv}/bashrc_misc.sh
source ${yonienv}/bashrc_fs.sh
# source ${yonienv}/bashrc_screen.sh
source ${yonienv}/bashrc_bookmarks.sh
source ${yonienv}/bashrc_tags.sh
source ${yonienv}/bashrc_devel.sh
source ${yonienv}/bashrc_vim.sh
# source ${yonienv}/bashrc_svn.sh
source ${yonienv}/bashrc_git.sh

# office related 
# source ${yonienv}/bashrc_nice.sh
source ${yonienv}/bashrc_mlx.sh
# source ${yonienv}/bashrc_huawei.sh
source ${yonienv}/bashrc_habana.sh
