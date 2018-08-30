g_proj_dir=${HOME}/share/docs

_docs ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply

    _cur=$g_proj_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$g_proj_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}


cddocs()
{
    cd $g_proj_dir/$1
}

complete -F _docs -o nospace cddocs
