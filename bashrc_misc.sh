#!/bin/bash

alias connect2remoteDesktop='source $(yonienv)/bin/connectToRemoteDesk.sh'
alias yuminstallfromiso='yum install --disablerepo=\* --enablerepo=c7-media'
alias yumsearchiniso='yum search --disablerepo=\* --enablerepo=c7-media'
alias yuminfoiniso='yum info --disablerepo=\* --enablerepo=c7-media'

alias now='date +"%d%b%Y_%H%M%S"'

alias sd='echo $TERM'
alias diff='diff -up'

alias xtermblack="xterm -bg black -fg green -fa 'Monospace' -fs 10 &"
if [ -e /usr/bin/xrandr ]  ; then 
complete -W "$(xrandr -q 2>/dev/null | awk '{print $1}')" xrandr 
fi

# pdfgrep to grep in pdf files.
# pdfgrep -n <pattern> <filename>
