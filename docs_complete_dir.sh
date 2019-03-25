
_docs ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply;


    _cur=$docs_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$docs_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}

# docs_dir=${HOME}/share/docs
docs_dir=${yonidocs};
cddocs() { cd $docs_dir/$1; }
complete -F _docs -o nospace cddocs

#==========================================================
_code ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply;

    _cur=$code_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$code_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}


# code_dir=${HOME}/share/code
code_dir=${yonicode};
cdcode() { cd $code_dir/$1; }
complete -F _code -o nospace cdcode

#==========================================================
_devel ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply;

    _cur=$devel_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$devel_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}


devel_dir=${HOME}/devel
cddevel() { cd $devel_dir/$1; }
complete -F _devel -o nospace cddevel

#==========================================================
_share ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply;

    _cur=$share_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$share_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}


share_dir=${HOME}/share
cdshare() { cd $share_dir/$1; }
complete -F _share -o nospace cdshare

#==========================================================
_bugs ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply;

    _cur=$bugs_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$bugs_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}

bugs_dir=${HOME}/share/tasks/bugs
cdbugs() { cd $bugs_dir/$1; }
complete -F _bugs -o nospace cdbugs

#==========================================================
_features ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply;

    _cur=$features_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$features_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}

features_dir=${HOME}/share/tasks/features
cdfeatures() { cd $features_dir/$1; }
complete -F _features -o nospace cdfeatures
