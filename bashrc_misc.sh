#!/bin/bash

alias connect2remoteDesktop='source $(yonienv)/bin/connectToRemoteDesk.sh'
alias yuminstallfromiso='yum install --disablerepo=\* --enablerepo=c7-media'
alias yumsearchiniso='yum search --disablerepo=\* --enablerepo=c7-media'
alias yuminfoiniso='yum info --disablerepo=\* --enablerepo=c7-media'

alias sd='echo $TERM'
alias diff='diff -up'

alias xtermblack="xterm -bg black -fg green -fa 'Monospace' -fs 10 &"
