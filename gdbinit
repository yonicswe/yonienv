set auto-load safe-path /
set print pretty
set breakpoint pending on
set print frame-arguments none

# set output-radix 16 - will print values in hex

define xx
    x/40xb $arg0
end

define sb
    save breakpoints .gdb_breakpoints
end    

define lb
    source .gdb_breakpoints
end 
document lb
restore breakpoints saved by bsave
end

define ff
    fin
end    

define enaonly
    disable
    enable $arg0
end
document enaonly
enable only specified breakpoint and disable the rest
end

define disaonly
    enable
    disable $arg0
end
document disaonly
disable only specified breakpoint and enable the rest
end

define whereami
    info registers rip
end

define showmainargs
    print argv[0]@argc
end
document showmainargs
print the command line arguments
end

define showretval
    print/x $eax
end
document showretval
print the return value of a func before you actually return from it
end

source .gdb_breakpoints
