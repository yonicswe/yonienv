#!/bin/bash

source ./bashrc_common.sh

setup_bash_profile ()
{
    local yonienv=$1;
    echo $FUNCNAME
    if [ -z "$(cat_bash_profile)" ] ; then
        echo "#startyonienv" >> ~/.bash_profile;
        echo -e "export PATH=\$PATH:${yonienv}/bin" >> ~/.bash_profile;
        echo "#endyonienv" >> ~/.bash_profile;
    else
        echo "~/.bash_profile is already setup";
    fi
}

clean_bash_profile ()
{
    sed  -i '/\#startyonienv/,/\#endyonienv/d' ~/.bash_profile;
    echo "cleared ~/.bash_profile";
}

cat_bash_profile ()
{
    sed -n '/\#startyonienv/,/\#endyonienv/p' ~/.bash_profile;
}

setup_bashrc () 
{
    local yonienv=$1;
    echo $FUNCNAME
    echo "#startyonienv" >> ~/.bashrc;
    echo "export yonienv=${yonienv};" >> ~/.bashrc;
    echo 'alias y="source ${yonienv}/bashrc_main.sh"' >> ~/.bashrc;
    echo "#endyonienv" >> ~/.bashrc;
}

clean_bashrc () 
{
    sed  -i '/\#startyonienv/,/\#endyonienv/d' ~/.bashrc;
    echo "cleared ~/.bashrc";
}

cat_bashrc () 
{
    sed  -n '/\#startyonienv/,/\#endyonienv/p' ~/.bashrc;
}

setup_bash_env ()
{
    setup_bash_profile ${yonienv};
    setup_bashrc ${yonienv};
}

clean_bash_env ()
{
    local ans=;
    local ask=${1:-askme};
 	
    if [[ "$ask" = "askme" ]] ; then
        read -p "clear bash env ? [y/N]" ans;
    else
        ans="y";
    fi

    if [ "$ans" == "y" ] ; then 
        clean_bashrc;
        clean_bash_profile;
        echo "removed yonienv from bash"
    fi 
} 

cat_bash_env ()
{
    echo -e "\n~/.bashrc"
    cat_bashrc;
    print_underline_size "_";
    echo -e "\n~/.bash_profile";
    cat_bash_profile;
    print_underline_size "_";
} 

setup_git_env () 
{
    local yonienv=$1;
    local git_user_name=$2
    local git_user_email=$3
    echo $FUNCNAME

	# clear previous yonienv backups
	rm -f ~/.gitconfig.yonienv 2>/dev/null;

    if [[  -e ~/.gitconfig ]] ; then 
        read -p "~/.gitconfig exit, backup and continue or skip ? [Y/s]" ans;
        if [[ ! "$ans" == "s" ]] ; then 
            set -x ; mv ~/.gitconfig ~/.gitconfig.yonienv; set +x
        fi
    fi

    ln -snf ${yonienv}/gitconfig ~/.gitconfig;

	read -p "setting git user/pass to Yonatan Cohen <yonic.swe@gmail.com> ? [Y/n]" ans;
	if [[ ! "$ans" == "n" ]] ; then 
		git config --global user.name "Yonatan Cohen";
		git config --global user.email yonic.swe@gmail.com;
	else
		read -p "Enter git user name: " git_user_name; 
		git config --global user.name "${git_user_name}";
		read -p "Enter git user email: " git_user_email; 
		git config --global user.email "${git_user_email}";
	fi

    # git ignore files that change from setup to setup
    git update-index --assume-unchanged env_common_args.sh
    git update-index --assume-unchanged vim/vimrc.guifont
}

clean_git_env ()
{
    local ask=${1:-"askme"};
    
    if [[ "$ask" = "askme" ]] ; then
        read -p "clear .gitcnofig ? [y/N]" ans;
    else
        ans="y";
    fi

    if [ "$ans" != "y" ] ; then 
        return;
    fi

    if [ -e ~/.gitconfig.yonienv ] ; then
        echo "Found yonienv backup for .gitconfig, restoring..."
        mv ~/.gitconfig.yonienv ~/.gitconfig
    else
        rm -f ~/.gitconfig;
        echo "Deleted .gitconfig file !!!"
    fi
}

cat_git_env ()
{
    echo -e "\n$FUNCNAME";
    ls -ld ~/.gitconfig;
    print_underline_size "_";
}

setup_cgdb_env () 
{
    local yonienv=$1;
    echo $FUNCNAME;
    ln -snf ${yonienv}/cgdb ~/.cgdb;
    ln -snf ${yonienv}/gdbinit ~/.gdbinit;
}

clean_cgdb_env () 
{
    local yonienv=$1;
    echo $FUNCNAME;
    [[ -e ~/.cgdb ]] && rm -v  ~/.cgdb;
    [[ -e ~/.gdbinit ]] && rm -v ~/.gdbinit;
}

cat_cgdb_env ()
{
    echo -e "\n$FUNCNAME";
    ls -ld ~/.cgdb;
    ls -ld ~/.gdbinit;
    print_underline_size "_";
}

setup_misc ()
{
    local yonienv=$1;
    echo $FUNCNAME;
#   echo "set completion-display-width 0" >> ~/.inputrc
}

setup_tmux_env () 
{
    local yonienv=$1;
    echo $FUNCNAME;
    ln -snf ${yonienv}/tmux.conf ~/.tmux.conf;
}

clean_tmux_env () 
{
    local yonienv=$1;
    echo $FUNCNAME;
    [[ -e ~/.tmux.conf ]] && rm -v  ~/.tmux.conf;
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

	# 
	#                  setup neovim configuration
	#

	# clean previous yonienv backups
	rm -f ~/.config/nvim.yonienv 2>/dev/null;
	rm -f ~/.local/share/nvim.yonienv 2>/dev/null;

	if [[ -e ~/.config/nvim ]] ; then
		echo -e "\'~/.config/nvim\' already exist"
		read -p "backup and continue or skip ? [Y/s]" ans;
		if [[ ! "$ans" == "s" ]] ; then
			set -x ; mv ~/.config/nvim ~/.config/nvim.yonienv ; set +x;
		fi
	fi
	
	if [[ -e ~/.local/share/nvim ]] ; then 
		echo -e "\'~/.local/share/nvim\' already exist";
		read -p "backup and continue or skip ? [Y/s]" ans;
		if [[ ! "$ans" == "s" ]] ; then 
			set -x; mv ~/.local/share/nvim ~/.local/share/nvim.yonienv ; set +x;
		fi
	fi

	[[ ! -e ~/.config ]] && mkdir ~/.config 
	[[ ! -e ~/.local ]] && mkdir -p ~/.local/share/

	ln -snf ${yonienv}/nvim ~/.config/nvim;
	ln -snf ${yonienv}/nvim ~/.local/share/nvim;
}

clean_vim_env ()
{
    local ask=${1:-"askme"};
    
    if [[ "$ask" = "askme" ]] ; then
        read -p "clear vimrc ? [y/N]" ans;
    else
        ans="y";
    fi

    if [ "$ans" != "y" ] ; then 
        return;
    fi

    if [ -e ~/.vimrc.yonienv ] ; then
        echo "Found yonienv backup for .vimrc, restoring..."
        mv ~/.vimrc.yonienv ~/.vimrc
    else
        rm ~/.vimrc;
        echo "Deleted .vimrc file !!!"
    fi

    if [ -e ~/.vim.yonienv ] ;then 
        echo "Found yonienv backup for .vim link/directory, restoring..."
        rm -f ~/.vim;
        mv ~/.vim.yonienv ~/.vim
    else
        rm ~/.vim;
        echo "Deleted .vim link/directory !!!"
    fi

	#
	#             clean neovim configuration
	# 
    if [ -e ~/.config/nvim.yonienv ] ; then 
        echo "Found yonienv neovim conf backup, restoring..."
        rm -f ~/.config/nvim;
        mv ~/.config/nvim.yonienv ~/.config/nvim
	elif [[ $(readlink -f ~/.config/nvim | grep yonienv | wc -l) -gt 0 ]] ; then 
        rm ~/.config/nvim;
    fi

	if [[ -e ~/.local/share/nvim ]] ; then 
        echo "Found yonienv neovim conf backup, restoring..."
		rm -f ~/.local/share/nvim
		mv ~/.local/share/nvim.yonienv ~/.local/share/nvim;
	elif [[ $(readlink -f ~/.local/share/nvim | grep yonienv | wc -l) -gt 0 ]] ; then 
		rm ~/.local/share/nvim;
	fi
}

cat_vim_env () 
{
    echo -e "\n$FUNCNAME";
    if [ -e ~/.vim ] ; then
        ls -ld ~/.vim;
    fi
    if [ -e ~/.vimrc ] ; then
        ls -ld ~/.vimrc;
        head -1 ~/.vimrc;
    fi
    print_underline_size "_";
}

source env_common_args.sh

setup_folders ()
{
	ask_user_default_no "create yonienv folders"
	[[ $? -eq 0 ]] && return;
	set -x
	mkdir -p $yonidocs;
	mkdir -p $yonicode;
	mkdir -p $yonitasks;
	mkdir -p $yonidevel
	mkdir -p $yonibugs;
	mkdir -p $yonishare;
	set +x
}

clean ()
{
    clean_bash_env ${1};
    clean_vim_env ${1};
    clean_git_env ${1};
    clean_cgdb_env ${1}; 
    clean_tmux_env ${1}; 
}

cat_yoni_env ()
{
    cat_bash_env;
    cat_vim_env;
    cat_cgdb_env;
    cat_git_env;
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
    while getopts "e:vgmhcd" opt; do
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
        d)  clean dontask
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
    
    setup_bash_env ${yonienv};
    setup_vim_env ${yonienv};
    setup_git_env ${yonienv};
    setup_cgdb_env ${yonienv};
    setup_tmux_env ${yonienv};
#   setup_misc ${yonienv}
	setup_folders;
    messages;
}

