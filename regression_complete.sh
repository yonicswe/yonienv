regression_proj_dir=${HOME}/devel/regression

_regression ()
{
    local cmd=$1 cur=$2 pre=$3;
    local _cur compreply

    _cur=$regression_proj_dir/$cur
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#$regression_proj_dir/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}


cdregression()
{
    cd $regression_proj_dir/$1
}

complete -F _regression -o nospace cdregression
