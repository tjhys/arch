#!/bin/bash
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

##variable Definitions
NORMAL=`echo "\033[m"`
MENU=`echo "\033[36m"` #Blue
NUMBER=`echo "\033[33m"` #yellow
FGRED=`echo "\033[41m"`
RED_TEXT=`echo "\033[31m"`
ENTER_LINE=`echo "\033[33m"`
j="1"

##function Definitions
show_menu(){
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Write AES random data to disk ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Quit ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
    echo -ne "${MENU}**${NUMBER}Choice: ${NORMAL}"
    read opt
}
function option_picked(){
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}


function countdown(){
        local OLD_IFS="${IFS}"
        IFS="-"
        local ARR=( $1 )
        local SECONDS=$((  (ARR[0] * 60 * 60) + (ARR[1] * 60) + ARR[2]  ))
        local START=$(date +%s)
        local END=$((START + SECONDS))
        local CUR=$START

        while [[ $CUR -lt $END ]]
        do
                CUR=$(date +%s)
                LEFT=$((END-CUR))

                printf "\r%02d:%02d:%02d" \
                        $((LEFT/3600)) $(( (LEFT/60)%60)) $((LEFT%60))

                sleep 1
        done
        IFS="${OLD_IFS}"
        echo "        "        
}

function sslwipe(){
	printf "Calculating size of chosen disk in blocks....\n"
	printf "Size in blocks of $_blockdevice is $_disksize\n"
	printf "Overwriting with cryptographic data is begining...\n"
	countdown "00-00-05"
	openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" -nosalt </dev/zero | pv -bartpes "$_disksize" | dd bs=64K of="$_blockdevice"
}
##end function definitions 

#present user with menu
show_menu

#user exits
if [[ $opt = 2 ]]; then
	#echo -e "${RED_TEXT}It was fun while it lasted${NORMAL}";
	option_picked "It was fun while it lasted";
	exit 1
fi


if [[ $opt = 1 ]]; then

option_picked "Will now print out available disks.."; 
sleep 1
fdisk -l

option_picked "Please choose the disk by number or device..";
for i in $(fdisk -l| grep "Disk /dev/"| cut -d " " -f 2 | sed 's/:/\ /g'); do
			echo -e "$j) Disk$j: $i\n"
			eval _disk$j="$i"
			let "j += 1"
done

option_picked "which disk would you like to overwrite with random cryptographic data: "
read _blockdevice
if (($_blockdevice)); then
	_blockdevice="/dev/sd$(echo "$_blockdevice" | tr '[1-9]' '[a-i]')"
fi
option_picked "Are you sure you want to overwrite $_blockdevice?"
option_picked "This operation can not be undone; Continue?(y/N)"
read _confirmation
if [[ ! "$_confirmation" =~ ^[nNyY]$ ]]; then
		echo -e "You must type y or n!";
		exit 1 
fi

if [[ "$_confirmation" =~ ^[nN]$ ]]; then
		echo -e "You did not write aes to drive";
		exit 1 
fi

if [[ "$_confirmation" =~ ^[yY]$ ]]; then
		echo -e "AES-256-ctr random write to begin on $_blockdevice";
		#Find disksize in blocks
		eval _disksize="$(blockdev --getsize64 $_blockdevice)"
		#works but testing 
		sslwipe 
fi



fi






















#openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" -nosalt </dev/zero | pv -bartpes "$_disksize" | dd bs=64K of="$_blockdevice"
