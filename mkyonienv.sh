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
        echo "found existing .vim directory : bail out or backup and continue ?"
        read -p "backup and continue ? [y/N]" ans;
        if [ "$ans" == "y" ] ; then 
            set -x ; mv ~/.vim ~/.vim.yonienv; set +x
        else
            exit;
        fi
    fi

    ln -snf ${yonienv}/vim ~/.vim;

    if [ -e ~/.vimrc ] ; then 
        echo "found existing .vimrc : bail out or backup and continue ?"
        read -p "backup and continue ? [y/N]" ans;
        if [ "$ans" == "y" ] ; then 
            set -x ; mv ~/.vimrc ~/.vimrc.yonienv; set +x
        else
            exit;
        fi
    fi
    echo "source ~/.vim/vimrc" >> ~/.vimrc;
}

setup_git_env () 
{
    local yonienv=$1;
    local git_user_name=
    local git_user_email=
    echo $FUNCNAME

    if [ -e ~/.gitconfig ] ; then 
        echo "found existing .gitconfig : Bail out OR Backup and continue ?"
        read -p "backup and continue ? [y/N]" ans;
        if [ "$ans" == "y" ] ; then 
            git_user_name=$(git config --global user.name);
            git_user_email=$(git config --global user.email);
            set -x ; mv ~/.gitconfig ~/.gitconfig.yonienv; set +x
        else
            return;
        fi
    fi

    ln -snf ${yonienv}/gitconfig ~/.gitconfig;

    read -p "set git user name to be ${git_user_name} ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        git config --global user.name ${git_user_name};
    fi
    read -p "set git user email to be ${git_user_email} ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        git config --global user.email ${git_user_email};
    fi

    # git ignore files that change from setup to setup
    git update-index --assume-unchanged env_common_args.sh
    git update-index --assume-unchanged vim/vimrc.guifont
}

clean_git_env ()
{
    read -p "clear .gitcnofig ? [y/N]" ans;
    if [ "$ans" != "y" ] ; then 
        return;
    fi

    if [ -e ~/.gitconfig.yonienv ] ; then
        echo "Found yonienv backup for .gitconfig, restoring..."
        mv ~/.gitconfig.yonienv ~/.gitconfig
    else
        read -p "Are you sure about deleting .gitconfig ? [y/N]" ans;
        if [ "$ans" == "y" ] ; then 
            rm -f ~/.gitconfig;
            echo "Deleted .gitconfig file !!!"
        fi
    fi
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
    echo "-e - invoke mkyonienv.sh while yonienv is not in current directory"         
    echo "-h - help"         
    exit;
}

clean_vim_env ()
{
    read -p "clear vimrc ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        if [ -e ~/.vimrc.yonienv ] ; then
            echo "Found yonienv backup for .vimrc, restoring..."
            mv ~/.vimrc.yonienv ~/.vimrc
        else
            read -p "Are you sure about deleting .vimrc ? [y/N]" ans;
            if [ "$ans" == "y" ] ; then 
                rm -f ~/.vimrc;
                echo "Deleted .vimrc file !!!"
            fi
        fi

        if [ -e ~/.vim.yonienv ] ;then 
            echo "Found yonienv backup for .vim link/directory, restoring..."
            rm -f ~/.vim;
            mv ~/.vim.yonienv ~/.vim
        else
            read -p "Are you sure about deleting .vim ? [y/N]" ans;
            if [ "$ans" == "y" ] ; then 
                rm -f ~/.vim;
                echo "Deleted .vim link/directory !!!"
            fi
        fi
    fi
}

source env_common_args.sh

setup_directories ()
{
    local yonienv=${1};

    echo "$FUNCNAME will create";
    echo "$yonidocs";
    echo "$yonicode";
    echo "$yonitasks";

    if [ -d $yonidocs ]  ; then 
        echo -e "$FUNCNAME(): \"$yonidocs\" already exists";
    else
        mkdir -p $yonidocs;
    fi
    if [ -d $yonicode ]  ; then 
        echo -e "$FUNCNAME(): \"$yonicode\" already exists";
    else
        mkdir -p $yonicode;
    fi
    if [ -d $yonitasks ]  ; then 
        echo -e "$FUNCNAME(): \"$yonitasks\" already exists";
    else
        mkdir -p $yonitasks;
    fi
}

clean ()
{
    local ans=;

    read -p "clear bashrc ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        sed  -i '/\#startyonienv/,/\#endyonienv/d' ~/.bashrc;
        sed  -i '/\#startyonienv/,/\#endyonienv/d' ~/.bash_profile;
        echo "removed yonienv from .bashrc"
    fi 

    clean_vim_env;
    clean_git_env;
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
    local setup_misc=0;

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
    setup_directories ${yonienv};
    messages
}

main $@;
