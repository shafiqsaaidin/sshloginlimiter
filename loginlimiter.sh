#!/bin/sh

for user in `cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups | grep inject | awk '{ print $1 }'`; do 

    echo "Checking user: $user"
    instances=`ps -u $user| grep sshd | wc -l`
    echo "SSH instances  $instances"
    if [ $instances -gt 1 ] ; then
        echo "Too many connections detected, slaying sshd for user $user"
        if [ -e /tmp/$user ] ; then
            attempts=`cat /tmp/$user`
            echo "Detected $attempts attempts"

            # increment attempts counter
            echo $(($attempts+1)) > /tmp/$user

            if [ $attempts -gt 3 ] ; then
                echo "Blocking $user"
                /usr/sbin/usermod -L $user
            fi

        else
            echo "1" > /tmp/$user
        fi
        killall -u $user sshd

    fi
done
