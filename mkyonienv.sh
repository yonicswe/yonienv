#!/bin/bash 

setup_bash_profile ()
{
    local yonienv=$1;
    echo $FUNCNAME
    echo "#startyonienv" >> ~/.bash_profile;
    echo -e "export PATH=\$PATH:${yonienv}/bin" >> ~/.bash_profile;
    echo "#endyonienv" >> ~/.bash_profile;
}

setup_bashrc () 
{
    local yonienv=$1;
    echo $FUNCNAME
    echo "#startyonienv" >> ~/.bashrc;
    echo "export yonienv=${yonienv};" >> ~/.bashrc;
    echo  'source ${yonienv}/bashrc_main.sh;' >> ~/.bashrc;
    echo "#endyonienv" >> ~/.bashrc;
}

setup_vim_env () 
{
    local yonienv=$1;
    echo $FUNCNAME;

    if [ -e ~/.vim ] ; then 
        echo "found existing .vim bailing out.."
        exit;
    fi

    ln -snf ${yonienv}/vim ~/.vim;

    if [ -e ~/.vimrc ] ; then 
        echo "found existing .vimrc. bailing out.."
        exit;
    fi
    echo "source ~/.vim/vimrc" >> ~/.vimrc;
}

setup_git_env () 
{
    local yonienv=$1;
    echo $FUNCNAME
    ln -snf ${yonienv}/gitconfig ~/.gitconfig;
}

setup_cgdb_env () 
{
    local yonienv=$1;
    echo $FUNCNAME;
    ln -snf ${yonienv}/cgdb ~/.cgdb;
    ln -snf ${yonienv}/gdbinit ~/.gdbinit;
}

setup_misc ()
{
    local yonienv=$1;
    echo $FUNCNAME;
#   echo "set completion-display-width 0" >> ~/.inputrc
}

usage () 
{
    echo "mkyonienv.sh  [-e <env_path>] [-v|-g|-h|-c]"
    echo "-c - clear env"         
    echo "-g - create only git conf"         
    echo "-v - create only vim conf"         
    echo "-m - create only misc conf"         
    echo "-h - help"         
    exit;
}

clean ()
{
    local ans=;

    read -p "clear bashrc ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        sed  -i '/\#startyonienv/,/\#endyonienv/d' ~/.bashrc;
        sed  -i '/\#startyonienv/,/\#endyonienv/d' ~/.bash_profile;
    fi 

    read -p "clear vimrc ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        rm -f ~/.vim;
        rm -f ~/.vimrc;
    fi 
}

messages () 
{
    echo "you might wanna to install ...";
    echo "sudo yum install tree";
    echo "sudo yum install screen";
    echo "sudo yum install colordiff";
    echo "sudo yum install figlet";
    echo "sudo yum install cgdb"; 
    echo "sudo yum install the_silver_searcher"; 
}


main  ()
{
    local yonienv=;
    local setup_vim=0;
    local setup_git=0;

    OPTIND=0;
    while getopts "e:vgmhc" opt; do
        case $opt in 
        e)  yonienv=${OPTARG};
            yonienv=$(readlink -f ${yonienv});
            ;;
        v)
            setup_vim=1;
            ;;
        g)
            setup_git=1;
            ;;
        m)
            setup_misc=1;
            ;;
        h)  
            usage;                
            ;;
        c)
            clean;
            return;
            ;;
        esac;
    done;

    if [ -z ${yonienv} ] ; then 
        yonienv=$(dirname $(readlink -f $0));
    fi

    echo "yonienv set to ${yonienv}";

    if [ -z ${yonienv} ] ; then 
        echo "you must give the path to yonienv";
        echo "bailing out...";
        return;
    fi

    if [ $setup_vim -eq 1 ] ; then 
        setup_vim_env ${yonienv};
        return;
    fi
    if [ $setup_git -eq 1 ] ; then 
        setup_git_env ${yonienv};
        return;
    fi
    if [ $setup_misc -eq 1 ] ; then 
        setup_misc ${yonienv};
        return;
    fi
    
    setup_bash_profile ${yonienv};
    setup_bashrc ${yonienv};
    setup_vim_env ${yonienv};
    setup_git_env ${yonienv};
    setup_cgdb_env ${yonienv};
#   setup_misc ${yonienv}
    messages
}

main $@;
