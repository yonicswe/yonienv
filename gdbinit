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

define xac
    dont-repeat
    if $argc == 3
        set $width = $arg2
    else
        set $width = 8
    end
    set $addr = (char *)($arg0)
    set $endaddr = $addr + $arg1
    while $addr < $endaddr
        printf "%p: ", $addr
        set $lineendaddr = $addr + $width
        if $lineendaddr > $endaddr
            set $lineendaddr = $endaddr
        end
        set $a = $addr
        while $a < $lineendaddr
            printf "0x%02x ", *(unsigned char *)$a
            set $a++
        end
        while $a < $addr + $width
            printf "     "
            set $a++
        end
        printf "'"
        set $a = $addr
        while $a < $lineendaddr
            printf "%c", *(char *)$a < 32 || *(char *)$a > 126 ? '.' : *(char *)$a
            set $a++
        end
        printf "'\n"
        set $addr = $addr + $width
    end
end

document xac
    usage: xac address count [width=8]
end
source .gdb_breakpoints
