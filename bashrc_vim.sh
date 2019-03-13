#!/bin/bash

#       _        
# __ __(_) _ __  
# \ V /| || '  \ 
#  \_/ |_||_|_|_| 


export vimorgvimbackupfile=${HOME}/.vimorgvim;
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
    if [ "${v_or_g}" == "vim" ] ; then
        export v_or_g="gvim";
        export _vd="gvimdiff";
    else
        export v_or_g="vim";
        export _vd="vimdiff"
    fi

    git config --global diff.tool ${_vd};
    git config --global merge.tool ${_vd};
    echo $v_or_g | tee ${vimorgvimbackupfile};
}

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
vsessls () 
{
    session_ls=$(find -maxdepth 1 -name "*.vim" -printf "%f\n");
    find -maxdepth 1 -name "*.vim" -printf "%f\n";
    complete -W "${session_ls}" vsess;
#     complete -W "${session_ls}" gsess vsess;
}

# vsess ()
# { 
#     local sess=${1:-Session.vim};
#     gsess ${sess} v;
# }

# gsess () 
vsess () 
{
    complete -W "$(vsessls)" vsess
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


function gsources ()
{
    g  $(find -maxdepth 1 -regex ".*\.cpp\|.*\.c\|.*\.h" -printf "%f ")
}
