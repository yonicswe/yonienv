#!/bin/bash

#       _        
# __ __(_) _ __  
# \ V /| || '  \ 
#  \_/ |_||_|_|_| 

alias editbashvim='g ${yonienv}/bashrc_vim.sh'

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
   vim $args $*
}

g () 
{
    local args=$gvim_args;
    if [ -e ~/.vim/.vimrc.dictionary ] ; then 
        args+=" -S ~/.vim/.vimrc.dictionary"
    fi         
    gvim $args $*
}

alias vt="v -t"
alias gt="g -t"

# open vi with a compound string of file and number
vn () 
{
    file_and_line="$*"
    vi_param=$(echo "$file_and_line" | sed 's/\ //g' | sed 's/:/\ +/' | sed 's/://')
    v $vi_param
}

gn () 
{
    file_and_line="$*"
    vi_param=$(echo "$file_and_line" | sed 's/\ //g' | sed 's/:/\ +/' | sed 's/://')
    g $vi_param
}

alias gd="gvimdiff"
alias vd="vimdiff"

vscript () 
{
    local file_name=${1};
    echo "#!/bin/bash" > ${file_name}
    chmod +x ${file_name};
    v ${file_name}
}

gsessls () 
{
    session_ls=$(find -maxdepth 1 -name "*.vim" -printf "%f\n");
    find -maxdepth 1 -name "*.vim" -printf "%f\n";
    complete -W "${session_ls}" gsess;
}

gsess () 
{
    complete -W "$(gsessls)" gsess
    vimSession=${1}

    if [ -e "${vimSession}"  ]  ; then 
        g -S ${vimSession}; 
    elif [ -e Session.vim ] ; then 
        g -S Session.vim;
    elif [ -e .session.vim ] ; then 
        g -S .session.vim;
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


function gsources ()
{
    g  $(find -maxdepth 1 -regex ".*\.cpp\|.*\.c\|.*\.h" -printf "%f ")
}
