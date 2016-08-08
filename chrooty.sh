#!/bin/zsh
# 26 july 2016
# script to help copy over libraries to make a chroot
. /my/functions/init

function chrooty {
    program=${1:?}

    ldd "$program" \
    | tr ' \t' '\n' \
    | grep '/' \
    | while read i; do
        #printf -- "cp -n --parents %q .\n" "$i"
        echo $i
    done

    return $r
}

function formatty {
    awk '{ printf "%3d\t%s\n", length($0), $0 }' \
    | awk '{ if (!seen[$0]++) print }' \
    | sort -n \
    | sed 's~^ *[0-9]\+\t~~'
}

function shellify {
    if [[ $hardlinks -eq 1 ]] {
        while read line; do
            dirs=".$(dirname $line)"
            [ ! -e "$dirs" ] && printf -- "mkdir -p '%s'\n" "$dirs"
            printf -- "ln '%s' '.%s'\n" "$line" "$line"
        done
    } else {
        while read line; do
            printf -- "cp -n --parents %s .\n" "$line"
        done
    }
}


if [[ "X$1" = "X-h" ]] {
    hardlinks=1
    shift
} else {
    hardlinks=0
}

if [[ "$@" = 'coreutils' ]] {
    progs=(
        arch        base64      basename    cat
        chcon       chgrp       chmod       chown       chroot
        cksum       comm        cp          csplit      cut
        date        dd          df          dir         dircolors
        dirname     du          echo        env         expand
        expr        factor      false       fmt         fold
        groups      head        hostid      hostname    id
        install     join        kill        link        ln
        logname     ls          md5sum      mkdir       mkfifo
        mknod       mktemp      mv          nice        nl
        nohup       nproc       od          paste       pathchk
        pinky       pr          printenv    printf      ptx
        pwd         readlink    realpath    rm          rmdir
        runcon      seq         sha1sum     sha224sum   sha256sum
        sha384sum   sha512sum   shred       shuf        sleep
        sort        split       stat        stdbuf      stty
        sum         sync        tac         tail        tee
        test        timeout     touch       tr          true
        truncate    tsort       tty         uname       unexpand
        uniq        unlink      uptime      users       vdir
        wc          who         whoami      yes
    )
    progs=( $coreutils "$@" )
} else {
    progs=( "$@" )
}

for i in ${progs:?}
do
    if [[ ! -e "$i" ]] {
        p="$(hash -v $i | awk -F '=' '{ print $2 }')"
    }
    printf -- "%q\n" "$p"
    chrooty "$p"
done | formatty | shellify



