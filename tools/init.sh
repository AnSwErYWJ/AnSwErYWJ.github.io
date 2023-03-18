#! /bin/bash

username=
useremail=

while getopts "n:e:h" opt; do
    case $opt in
        n) username=$OPTARG;;
        e) useremail=$OPTARG;;
        h|?) echo "usage: $0 [options] [target]"; echo ""
             echo "options:"
             echo "    -h show help message and exit"
             echo "    -n config git username"
             echo "    -e config git useremail"
             exit
    esac
done

if [ "${username}" = "" ]
then
    echo "username is not config!"
else  
    git config --global user.name ${username}
fi

if [ "${useremail}" = "" ]
then
    echo "useremail is not config!"
else  
    git config --global user.email ${useremail}
fi

chmod 600 /root/.ssh/*

echo -e "\ncheck git config:"
git config --list

/bin/bash