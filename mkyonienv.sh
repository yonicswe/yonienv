#!/bin/bash 

setup_bash_profile ()
{
    local yonienv=$1;
    echo "export PATH=$PATH:${yonienv}/bin" >> ~/.bash_profile;
}

setup_bashrc () 
{
    local yonienv=$1;
    echo "export yonienv=${yonienv};" >> ~/.bashrc;
    echo  'source ${yonienv}/bashrc_main.sh;' >> ~/.bashrc;
}

setup_vim_env () 
{
    local yonienv=$1;
    ln -snf ${yonienv}/vim ~/.vim;
    echo "source ~/.vim/.vimrc" >> ~/.vimrc;
}

setup_git_env () 
{
    local yonienv=$1;
    ln -snf ${yonienv}/gitconfig ~/.gitconfig;
}

main  ()
{
    local yonienv=$1;

    if [ -z ${yonienv} ] ; then 
        yonienv=$(dirname $(readlink -f $0));
    fi

    echo "yonienv set to ${yonienv}";

    if [ -z ${yonienv} ] ; then 
        echo "you must give the path to yonienv";
        echo "bailing out...";
        return;
    fi

    setup_bash_profile ${yonienv};
    setup_bashrc ${yonienv};
    setup_vim_env ${yonienv};
    setup_git_env ${yonienv};
}

main $@;
