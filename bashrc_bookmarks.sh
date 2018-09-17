#!/bin/bash

#  ___            _    __  __             _       
# | _ ) ___  ___ | |__|  \/  | __ _  _ _ | |__ ___
# | _ \/ _ \/ _ \| / /| |\/| |/ _` || '_|| / /(_-<
# |___/\___/\___/|_\_\|_|  |_|\__,_||_|  |_\_\/__/
#                                                 

alias editbashbookmarks='g ${yonienv}/bashrc_bookmarks.sh'

pdc () 
{
    c=$1 
    if [ -z $c ] ; then 
        dirs -c 
    else
        popd +$c 2>/dev/null 1>/dev/null
    fi

    pd

    pdf_complete
    pd_complete 
}

pu ()
{
   p=$1

   if [ -n "$p" ] ; then 
      cd "$p"
   fi 
   pushd $(pwd) 1>/dev/null
   pd
   pdf_complete
   pd_complete
}


pd () 
{
    p=$1

    if [ -z $p ] ; then 
#         echo "---------------------------------------------"
        dirs -l -v   | awk '{if (NR > 1) {print $0}}'; 
        dirs -l -v   | awk '{if (NR > 1) {print "pushd -n " $2} }' > ${BM}
#         echo "---------------------------------------------"
    else
        # if $1 is a string then just cd otherwise find it in the bookmarks file
        path_or_ent=$(echo $p | grep "[[:alpha:]]"  | wc -l )
        if [ $path_or_ent -eq 1 ] ; then 
            cd $p
        else
            eval $(dirs -l -v | awk -vpp=$p '{if ($1 == pp) print "cd "$2 }' )
        fi
    fi

    echo -e "-->\033[1;34m$(pwd -P)\033[0m"
}

pdp ()
{ 
   p=$1

    [ -z $p ] && return 

    dirs -l -v | awk -vpp=$p '{if ($1 == pp) print $2 }'

}


BMF=~/.bookmarks_favorite.${HOSTNAME}

#
# called to add new or remove 
# favorite entries from bash-complete
#

pd_complete () 
{
   [ -z ${BM} ] && return
   ! [ -e ${BM} ] && return
   pd_bookmarks=$(cat ${BM} | awk '{print $3 }' | xargs )
   complete -W "$(echo $pd_bookmarks)" pd
}

pdf_complete ()
{
   [ -z ${BMF} ] && return
   ! [ -e ${BMF} ] && return
   bookmarks=$(cat ${BMF} |awk '{print $2 }' | xargs)
   complete -W "$(echo $bookmarks)" pdf
}

pdf_usage ()
{
   echo "pdf - a bookmark util working with pd"
   echo "====================================="
   echo "pdf [-a|-c|-d|-h]"
   echo "pdf without params shows the bookmark list"
   echo "pdf -h:\tshow this help"
   echo "pdf -a:\tadd a bookmark from the pd list pdf -a <number>"
   echo "pdf -d:\tdelete a bookmark from the pdf list "
   echo "pdf -c:\tclear all favorite bookmarsk"
   echo "pdf2pd:\t creates bookmarks from the pdf list"

}

pdf2pd ()
{
   #
   # use the favorite bookmarks to create bookmark list.      
   #
   \rm -f ${BM}
   awk '{
      print "pushd -n "$2  ;
   }' ${BMF}  >> ${BM}

   source ${BM} 1>/dev/null

}


pdf ()
{
   # save favorite bookmarks 
   # into a file called .bookmarks_favorite
   # usage : pdf [-a] [number]
   #     pdf              : show favorites 
   #     pdf <number>     : cd to specified bookmark
   #     pdf -a <number>  : add entry from the pd list to favorite
   #     pdf -d <number>  : remove entry from list 
   #     pdf -c           : delete all favorites


   pars=$#
   if [ $pars -eq 0 ] ; then 
      # show favorites
      cat ${BMF} 2>/dev/null
      pdf_complete

      return
   fi 

   oper=$1
   case $oper in 
   "-a")
      # add a bookmark
      fav=$2
      bm=$(pd | awk -v f=$fav '{if ($1 == f) {print $0 } }')
      if [ $( echo $bm | awk '{ print $1}' | grep $fav ) -eq $fav  ] ; then 
         if [ -e ${BMF} ] ; then 
            total_ents=$(cat ${BMF} | wc -l) 
         else
            total_ents=0
         fi

         ((next_ent = total_ents +1))
         echo $bm | awk -v ent=$next_ent '{ print ent" "$2  }' >> ${BMF}
         pdf_complete
      fi 

      ;;
   "-d")
      # del a bookmark
      fav=$2
      if ! [ -e ${BMF} ] ; then 
         return
      fi

      if  [ -e ${BMF}.tmp ] ; then 
         \rm -f ${BMF}.tmp 
      fi

      bm=$(cat ${BMF} | awk -v f=$fav '{if ($1 == f) {print $0 } }')
      if [ $( echo $bm | awk '{ print $1}' | grep $fav ) -eq $fav  ] ; then 
         total_ents=$(cat ${BMF} | wc -l) 
         awk -v f=$fav '{ 
            if (NR != f) {
               print $2 ;
            }
         }' ${BMF} >> ${BMF}.tmp 

         \rm -f ${BMF}

         awk '{print NR" "$0 }' ${BMF}.tmp >> ${BMF} 

         \rm -f ${BMF}.tmp

         pdf_complete
      fi
      ;;
   "-c")
      # clear all bookmarks
      rm -f ${BMF} 2>/dev/null
      ;;
   "-h")
      # usage
      pdf_usage      
      ;;
   *)
      fav=$1

      # if user sent a string then use it insead of the entry number
      path_or_ent=$(echo $fav | grep "[[:alpha:]]"  | wc -l )
      if [ $path_or_ent -eq 1 ] ; then 
         cd $fav
         return
      fi

      # the user probably sent an entry number from the favorite list.
      bm=$(cat ${BMF} | awk -v f=$fav '{if ($1 == f) {print $0 } }')
      [ -z "${bm}" ] && return

      # if its a valid bookmark cd to it
      if [ $( echo $bm | awk '{ print $1}' | grep $fav ) -eq $fav  ] ; then 
         p=$(echo $bm | awk '{print $2 }')
         cd $p
      fi 
   esac 
}

BM=~/.bookmarks.${HOSTNAME}
alias pdedit="v ${BM} ; cat ${BM}"

rebash ()
{
    unalias -a

    [ -e ~/.inview ] && rm -f ~/.inview 1>/dev/null;
    if [ -e ${BM} ] ; then 
       \mv ${BM} ${BM}.tmp ; 
    fi

#  delete all bookmarks they will be re-created by sourcing the bookmarks file
   pdc 1>/dev/null ; 

#    source ~/.bashrc ;
    source ${yonienv}/bashrc_main.sh;
    if [ -e ${BM}.tmp ] ; then 
       \mv ${BM}.tmp ${BM} ; 
    fi

#  create the bookmarks by sourcing the bookmarks file
    if [ -e ${BM} ] ; then 
        source ${BM} 1>/dev/null
    fi            

   pdf_complete 1>/dev/null
   pd_complete 1>/dev/null
}   

if [ -e ${BM} ] ; then 
	if [ $(dirs -l -v | grep -v "^.*0" | wc -l ) -eq 0 ] ; then 
        source ${BM} 1>/dev/null
	fi

# 	pdf_complete
	pd_complete
fi

complete -d cd c;

alias gdocs="cddocs ; g +e."
alias gtasks="cdtasks ; g +e."
greptasks ()
{
    local search_str=${1};
    greptxt ${search_str} ${yonitasks}
}
alias gcode="cdcode ; g +e."

source ${yonienv}/docs_complete_dir.sh
# cddocs () { cd ${yonidocs}    ; [ -n "$1" ] && cd $1; completecddocs; }
# completecddocs () { complete -W "$(find ${yonidocs} -maxdepth 1 -type d -exec basename {} \; )" cddocs; }
# if [ -d ${yonidocs} ] ; then completecddocs ; fi

# cdcode () { cd ${yonicode}    ; [ -n "$1" ] && cd "$1"; completecdcode; } 
# completecdcode () { complete -W "$(find ${yonicode} -maxdepth 1 -type d -exec basename {} \; )" cdcode; }
# if [ -d ${yonicode} ] ; then completecdcode ; fi

source ${yonienv}/task_complete.sh
# cdtask () { cd ${yonitasks} ; [ -n "$1" ] && cd "$1" ; completecdtask ;}
# completecdtask () { complete -W "$(find ${yonitasks} -maxdepth 1 -type d -exec basename {} \; )" cdtask; }
# if [ -d ${yonitasks} ] ; then completecdtask ; fi

mktask () 
{
   task_name=${1:-task.$(date +"%S")};

   mkdir ${task_name};

   cp ~/share/ipteam_env/log.txt ${task_name};

   chmod -R g+rw ${task_name} 
}
