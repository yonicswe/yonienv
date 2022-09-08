#!/bin/bash

#       _        
# __ __(_) _ __  
# \ V /| || '  \ 
#  \_/ |_||_|_|_| 

alias editbashvim="n ${yonienv}/bashrc_vim.sh"
alias cdnvimconfig="cd ~/.config/nvim/"
# alias vim='vim -u NONE'

export vimorgvimbackupfile=${HOME}/.vimorgvim.$(hostname -s);
if ! [ -e ${vimorgvimbackupfile} ] ; then 
    echo vim > ${vimorgvimbackupfile};
fi

export v_or_g="$(cat ${vimorgvimbackupfile})";

# if [ "${v_or_g}" == "gvim" ] ; then 
    # export _vd="gvimdiff"
# else
    # export _vd="vimdiff";
# fi

# git config --global diff.tool ${_vd};
# git config --global merge.tool ${_vd};

# if [ -e /usr/bin/gvim ] ; then
# else
#     export v_or_g="vim";
#     export _vd="vimdiff"
# fi
vimorgvim ()
{
    echo "deprecated using nvim"
    # local user_choice=$1;
    # if [ -n "${user_choice}" ] ; then 
        # if [ "${user_choice}" == "vim" ] ; then
            # export v_or_g="gvim";
        # elif [ "${user_choice}" == "gvim" ] ; then 
            # export v_or_g="vim";
        # fi
    # fi;

    # if [ "${v_or_g}" == "vim" ] ; then
        # export v_or_g="gvim";
        # export _vd="gvimdiff";
        # export EDITOR="gvim";
        # export VISUAL="gvim";
    # else
        # export v_or_g="nvim";
        # export _vd="nvimdiff"
        # export EDITOR="nvim";
        # export VISUAL="nvim";
    # fi

    # git config --global diff.tool ${_vd};
    # git config --global merge.tool ${_vd};
    # echo $v_or_g | tee ${vimorgvimbackupfile};

# #     r;
}
# export EDITOR="vim";
# complete -W "vim gvim" vimorgvim;

vd () { ${_vd} $1 $2 ;}



vim_args="-p"

gvim_args="-p"
# gvim_args+=" -geom 180x60"
gvim_args+=" -geom 160x40"

v ()
{
   local args=$vim_args;
   if [ -e ~/.vim/.vimrc.dictionary ] ; then 
      args+=" -S ~/.vim/.vimrc.dictionary"
   fi         
   ${v_or_g} $args $*
}

# g () 
# {
#     local args=$gvim_args;
#     if [ -e ~/.vim/.vimrc.dictionary ] ; then 
#         args+=" -S ~/.vim/.vimrc.dictionary"
#     fi         
#     gvim $args $*
# }

alias vo="${v_or_g} -O" 

vt () { 
    if [ 0 -eq $# ] ; then 
        if [ -e tags.vim ] ; then
            ${v_or_g} +"source tags.vim" 
            return;
        fi
        ${v_or_g};
        return;
    fi

    if [ -e tags.vim ] ; then
        ${v_or_g} -t "/$1" +"source tags.vim" 
        return;
    fi

    ${v_or_g} -t "/$1";
}
# alias gt="g -t"

# open vi with a compound string of file and number
vn () 
{
    file_and_line="$*"
    vi_param=$(echo "$file_and_line" | sed 's/\ //g' | sed 's/:/\ +/' | sed 's/://')

    if [ -e tags.vim ] ; then
        set -x
        ${v_or_g} $vi_param +"source tags.vim"
        set +x
        return;
    fi

    ${v_or_g} $vi_param
}

# gn () 
# {
#     file_and_line="$*"
#     vi_param=$(echo "$file_and_line" | sed 's/\ //g' | sed 's/:/\ +/' | sed 's/://')
#     g $vi_param
# }


vscript () 
{
    local file_name=${1};
    echo "#!/bin/bash" > ${file_name}
    chmod +x ${file_name};
    v ${file_name}
}

# gsessls () 
vsl () 
{
    session_ls=$(find -maxdepth 1 -name "vimsess*" -printf "%f\n");
    find -maxdepth 1 -name "vimsess*" -printf "%f\n";
    complete -W "${session_ls}" vs;
#     complete -W "${session_ls}" gsess vs;
}

# vsess ()
# { 
#     local sess=${1:-Session.vim};
#     gsess ${sess} v;
# }

alias ns='nvim -S Session.vim'

# gsess () 
vs () 
{
    complete -W "$(vsl)" vs
    local vimSession=${1}
#     local vim_or_gvim=${2:-g};

    if [ -e "${vimSession}"  ]  ; then 
        ${v_or_g} -S ${vimSession}; 
    elif [ -e Session.vim ] ; then 
        ${v_or_g} -S Session.vim;
    elif [ -e .session.vim ] ; then 
        ${v_or_g} -S .session.vim;
    else
        echo "No vim Session found";                
    fi

#     if [ -n "${vimSession}" ] ; then 
#         if [ -e "${vimSession}"  ]  ; then 
#             gvim -S ${vimSession}; 
#         else
#             echo "No vim Session found";                
#         fi
#     else 
#         if [ -e Session.vim ] ; then 
#             gvim -S Session.vim
#         else
#             echo "No vim Session found";                
#         fi
#     fi 
}

# start writing a bash script
editBashrcScript () 
{
    local file_name=${1};
    echo "#!/bin/bash" > ${file_name}
    chmod +x ${file_name};
    echo "#!/bin/bash" > ${file_name}
    g ${file_name}
    [ -z $2 ] && return;
    f=$2; touch $f ; chmod +x $f ; echo '#!/bin/bash' > $f ; $1 $f ; 
}
alias vbash='editBashrcScript v'
alias gbash='editBashrcScript g' 

#start writing a python script
editPythonScript () 
{ 
    [ -z $2 ] && return;
    f=$2; touch $f ; chmod +x $f ; echo '#!/usr/bin/python' > $f ; $1 $f ; 
}

alias vpython='editPythonScript v'
alias gpython='editPythonScript g' 



alias cleartrailingwhitespace="sed -i 's/[ \t]*$//'"


function vsources ()
{
    ${v_or_g}  $(find -maxdepth 1 -regex ".*\.cpp\|.*\.c\|.*\.h" -printf "%f ")
}

alias viminstall='sudo yum install -y vim-X11 ctags'

alias nvimgetconfig='l -d ~/.config/nvim ~/.local/share/nvim'
function nvimsetconfig ()
{
    local path=${1};

    if [[ -z ${path} ]] ; then 
        echo "path cannot be empty";
        return -1;
    fi;

    path=$(readlink -f ${path});

    if ! [[ -d ${path} ]] ; then 
        echo -e "\'${path}\' does not exist";
        return -1;
    fi;

    ln -snf ${path} ~/.config/nvim;
    ln -snf ${path} ~/.local/share/nvim;
    return 0;
}

alias viminstallplug='curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

function nviminstallplug ()
{
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
} 

alias nv=${yonienv}/bin/nvim.appimage
alias vimdiff='nv -d'
alias n=nvim
# alias n=/home/y_cohen/.local/bin/nvim
# alias n=/home/y_cohen/.local/bin/lvim
# alias nvim=/home/y_cohen/.local/bin/nvim

# install lunarvim
#   bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
# get latest release
#  LV_BRANCH=rolling bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/rolling/utils/installer/install.sh)
# get latest nvim
#   bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/rolling/utils/installer/install-neovim-from-release)
# uninstall
#  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/uninstall.sh)


