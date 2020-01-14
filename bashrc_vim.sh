#!/bin/bash

#       _        
# __ __(_) _ __  
# \ V /| || '  \ 
#  \_/ |_||_|_|_| 

alias vim='vim -u NONE'

export vimorgvimbackupfile=${HOME}/.vimorgvim.$(hostname -s);
if ! [ -e ${vimorgvimbackupfile} ] ; then 
    echo vim > ${vimorgvimbackupfile};
fi

export v_or_g="$(cat ${vimorgvimbackupfile})";

if [ "${v_or_g}" == "gvim" ] ; then 
    export _vd="gvimdiff"
else
    export _vd="vimdiff";
fi

git config --global diff.tool ${_vd};
git config --global merge.tool ${_vd};

# if [ -e /usr/bin/gvim ] ; then
# else
#     export v_or_g="vim";
#     export _vd="vimdiff"
# fi
vimorgvim ()
{
    local user_choice=$1;
    if [ -n "${user_choice}" ] ; then 
        if [ "${user_choice}" == "vim" ] ; then
            export v_or_g="gvim";
        elif [ "${user_choice}" == "gvim" ] ; then 
            export v_or_g="vim";
        fi
    fi;

    if [ "${v_or_g}" == "vim" ] ; then
        export v_or_g="gvim";
        export _vd="gvimdiff";
        export EDITOR="gvim";
    else
        export v_or_g="vim";
        export _vd="vimdiff"
        export EDITOR="vim";
    fi

    git config --global diff.tool ${_vd};
    git config --global merge.tool ${_vd};
    echo $v_or_g | tee ${vimorgvimbackupfile};

    r;
}
export EDITOR="vim";
complete -W "vim gvim" vimorgvim;

vd () { ${_vd} $1 $2 ;}


alias editbashvim="${v_or_g} ${yonienv}/bashrc_vim.sh"

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

vt () { ${v_or_g} -t $1; }
# alias gt="g -t"

# open vi with a compound string of file and number
vn () 
{
    file_and_line="$*"
    vi_param=$(echo "$file_and_line" | sed 's/\ //g' | sed 's/:/\ +/' | sed 's/://')
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
    session_ls=$(find -maxdepth 1 -name "*.vim" -printf "%f\n");
    find -maxdepth 1 -name "*.vim" -printf "%f\n";
    complete -W "${session_ls}" vs;
#     complete -W "${session_ls}" gsess vs;
}

# vsess ()
# { 
#     local sess=${1:-Session.vim};
#     gsess ${sess} v;
# }

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
