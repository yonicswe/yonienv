upstream_proj_dir=${HOME}/devel/upstream

_upstream ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply

    _cur=$upstream_proj_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$upstream_proj_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}


cdupstream()
{
    cd $upstream_proj_dir/$1
}

complete -F _upstream -o nospace cdupstream
