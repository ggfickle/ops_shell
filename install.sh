#!/bin/bash

INSTALL_PATH=/usr/local/bin
HERE=`pwd`
for F in `ls` 
do
    if [[ $F != "install.sh" ]] ; then
        if [ ! -f $INSTALL_PATH/$F ]; then
            echo "Install $F ..."
            ln -s $HERE/$F $INSTALL_PATH/$F
        fi
    fi
done
