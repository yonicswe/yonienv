

# sudo yum install cowsay fortune-mod -y
# sudo cp me to /etc/profile.d/

cow=0;
msg=0;
yonimsg="welcome to yoni cohen setup...";
rpm --verify cowsay 1>/dev/null
ret=$?
[ $ret -eq 0 ] && cow=1
rpm --verify fortune-mod 1>/dev/null
ret=$?
[ $ret -eq 0 ] && msg=1

if (( $cow == 1 && $msg == 1 )) ; then 
    cowsay -f tux $(fortune)
elif (( $cow == 1 )) ; then 
    cowsay -f tux "echo $yonimsg";
elif (( $msg == 1 )) ; then 
    /usr/bin/fortune
else
    echo $yonimsg;
fi    
