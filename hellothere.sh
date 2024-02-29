#!/bin/bash

cat << 'EOF'
         {
      {   }
       }_{ __{
    .-{   }   }-.
   (   }     {   )
   |`-.._____..-'|
   |             ;--.
   |            (__  \
   |             | )  )
   |             |/  /
   |             /  /    -Good Morning, Gavin-
   |            (  /
   \             y'
    `-.._____..-'

EOF

# need to be root or run as sudo
check_uid(){
        if [[ $EUID != 0 ]]
        then
                printf "\nNeed root or sudo......"
                exit 1
        fi
}

# check internet connection - only wifi, it is assumed this morning script is ran when wifi is available
int_check(){
        if ping 8.8.8.8 -c 2 > /dev/null 2>&1
        then
                printf "\nInternet is up"
                #exit 0
        else
                printf "\nInternet is down"
                sleep 1
                printf "\n [+] Scanning Wifi Access Points"
                sleep 1
                nmcli dev wifi list
                printf "\nEnter BSSID and press enter []; "
                read bssid
                if nmcli dev wifi connect $bssid > /dev/null 2>&1; [ "$?" -eq 0 ]
                then
                        printf "\n\nConnected to $bssid"
                        ip_add=$(ifconfig wlan0|grep 'inet'|grep -v 'inet6'|awk -F " " '{print $2}')
                        printf "\nConnected on IP $ip_add"
                        sleep 1 
                else
                        printf "\nError...." 
                        exit 1
                fi
        fi
}

run_speedtest(){
        printf "\nRunning Speed Test........"
        dload_output=$(speedtest --no-upload)
        speed=$(echo "$dload_output" |grep Download|awk -F " " '{print $2, $3}')
        if [[ -n "$speed" ]]
        then
                printf "\nTodays Download Speed is............$speed\n"
        else
                printf "\nCould Not Get Download Speed\n"
        fi
}

# run apt update && apt upgrade

run_apt(){
        printf "\nUpdating the OS with apt.......may take a while"
        if apt update > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1
        then
                printf "\nOS Updated"
        else
                printf "\nUpdate Failed....no idea why"
                exit 1
        fi
}

# sync obsidian

sync_obsidian(){
        printf "\nSync'ing Obsidian with rclone"
        orig_user="$SUDO_USER"
        if sudo -u "$orig_user" rclone copy --exclude "Testing Notes/" /home/gd/Tools/Obsidian/ google_drive:obsidian_rclone
        then
                printf "\nObsidian synced with google drive"
        fi
}


play_music(){
        read -rp "You want some Beats ^^^ !!! ***** : " response
        if [[ "$response" == "y" ]]
        then
                printf "\nDont have a good day......have a great day!\n\n"
                parole /home/gd/Tools/musikcube/251_kush_sessions.mp3 > /dev/null 2>&1 &
        fi
        printf "\nDont have a good day......have a great day!"
}


main() {
        check_uid
        int_check
        run_apt
        sync_obsidian
        run_speedtest
        play_music
}

# Run the main function
main
