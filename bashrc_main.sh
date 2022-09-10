#!/bin/bash

# this is supposed to expand alias when running a non interactive shell
# like su -c  "some command"
shopt -s expand_aliases 

alias editbashmain='${v_or_g} ${yonienv}/bashrc_main.sh'

echo "source bashrc_common.sh"
source ${yonienv}/bashrc_common.sh
echo "source bashrc_misc.sh"
source ${yonienv}/bashrc_misc.sh
echo "source bashrc_fs.sh"
source ${yonienv}/bashrc_fs.sh
# source ${yonienv}/bashrc_screen.sh
echo "source bashrc_bookmars.sh"
source ${yonienv}/bashrc_bookmarks.sh
echo "source bashrc_tags.sh"
source ${yonienv}/bashrc_tags.sh
echo "source bashrc_devel.sh"
source ${yonienv}/bashrc_devel.sh
echo "source bashrc_vim.sh"
source ${yonienv}/bashrc_vim.sh
# source ${yonienv}/bashrc_svn.sh
echo "source bashrc_git.sh"
source ${yonienv}/bashrc_git.sh

# office related 
# source ${yonienv}/bashrc_nice.sh
echo "source bashrc_mlx.sh"
source ${yonienv}/bashrc_mlx.sh
# source ${yonienv}/bashrc_huawei.sh
echo "source bashrc_habana.sh"
source ${yonienv}/bashrc_habana.sh
echo "source bashrc_dell.sh"
source ${yonienv}/bashrc_dell.sh
