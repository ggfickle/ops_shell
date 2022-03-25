#!/usr/bin/env bash

SUDO=""
promote (){
    if [ ! `whoami` == 'root' ] ;then
        SUDO="sudo"
    fi 
}


promote
