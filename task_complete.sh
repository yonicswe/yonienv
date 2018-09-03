#!/bin/bash

# base dir
git=$HOME/share/tasks/

function cdtasks () {
  export git=$HOME/share/tasks/
  cd $HOME/share/tasks/$1
}

# function cdofed () {
#   export git=$HOME/devel/ofed/
#   cd $HOME/devel/ofed/$1
# }
# 
# function cdcode () {
#   export git=$HOME/share/code
#   cd $HOME/share/code/$1
# }
# 
# function cddocs () {
#   export git=$HOME/share/docs
#   cd $HOME/share/docs/$1
# }
# 
# function cdupstream () {
#   export git=$HOME/devel/upstream
#   cd $HOME/devel/upstream/$1
# }


function _gcdcomplete()
{
  local cmd curb cur opts


  # last arg so far
  cur="${COMP_WORDS[COMP_CWORD]}"

  # dirname-esque, but makes "xyz/" => "xyz/" not "."
  curb=$(echo $cur | sed 's,[^/]*$,,')

  # get list of directories (use commened out line for dirs and files)
  # append '/' to directories
  # cmd="find $git$curb -maxdepth 1 -type d -printf %p/\n , -type f -print "
  cmd="find $git$curb -maxdepth 1 -type d -printf %p/\n "

  # remove base dir from list and remove extra trailing /s
  opts=$($cmd | sed s:$git:: | sed s://*$:/:)

  # generate list of completions
  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0;
}
complete -o nospace -F _gcdcomplete cdtasks
# complete -o nospace -F _gcdcomplete cdofed
# complete -o nospace -F _gcdcomplete cdcode
# complete -o nospace -F _gcdcomplete cddocs
# complete -o nospace -F _gcdcomplete cdupstream
# complete -o nospace -F _gcdcomplete cdofed
