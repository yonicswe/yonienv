ofed_proj_dir=${HOME}/devel/ofed

_ofed ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply

    _cur=$ofed_proj_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$ofed_proj_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}


cdofed()
{
    cd $ofed_proj_dir/$1
}

complete -F _ofed -o nospace cdofed
