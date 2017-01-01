#!/bin/zsh
# 26 july 2016
#
# script to help copy over libraries to make a chroot.
#
# by default, does not touch anything. merely prints shell commands
# to stdout.
#
#
#

function error {
    printf -- "\002\033[38;5;124m\003[!]\002\033[m\003 %s\n" "$*" >&2
}

# makes a minimal /etc folder with a few files
function make_etc {
    [[ $PWD =~ ^/+$ ]] && {
        error 'not making etc folder from /, don’t want to fuck your computer!'
        exit 1
    }

    # 'test -e passwd || echo "root:x:0:0::/:/bin/sh" > passwd'
    # 'test -e resolv.conf || echo "nameserver 8.8.8.8" > resolv.conf'

    files=(
        passwd
        resolv.conf
        services
        hosts
        hostname
        group
        issue
    )

    printf -- "%s\n" 'mkdir ./etc'

    for i in $files
    do
        printf -- "cp %-50q ./etc\n" "/etc/$i"
    done

}

function formatty {
    # if no target dir given for the files, use cp's --parents flag
    # to give us a sweet dir structure. used for libraries, not for
    # binaries, because in a chroot i personally prefer just having
    # everything in /bin rather than /bin, /usr/sbin, /usr/local/bin etc
    if [[ -z $1 ]] {
        target_dir='.'
        cpflags=( -n --parents )
    } else {
        target_dir=$1
        cpflags=( -n )
        [ -d $target_dir ] || printf -- "mkdir %15q\n" "$target_dir"
    }
    
    awk '{ if (!seen[$0]++) print }' \
    | sed 's~^ *[0-9]\+\t~~' \
    | while read line
    do
        printf -- "%-15s %-37q %q\n" "cp $cpflags" "$line" "$target_dir"
    done
}

function chrooty {
    prog=$(hash -v $(basename ${1:?}) 2>/dev/null)
    prog=${prog/*=}

    if [[ -z $prog ]] {
        error "$1: command not found, or not in hash table at least"
        return 1
    }

    # the executable itself
    printf -- "%s\n" "$prog" >> $binaries

    # get the libraries
    ldd $prog | tr '\t ' '\n' | grep / >> $libraries

}


coreutils=(
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




libraries=$(mktemp /tmp/chrooty.libs.XXXXXXXXXX)
binaries=$(mktemp  /tmp/chrooty.bins.XXXXXXXXXX)

args="${@:?need a program for argv1}"

cat << EOF
#!/bin/sh -e
#
# this script was generated at $(date +%T\ %D),
# with args: '$0 $args'
#
# https://github.com/raincoats/chrooty
#

EOF

for i in $@
do
    if [[ "$i" = 'coreutils' ]]
    then
        for o in $coreutils; do chrooty $o; done
    elif [[ "$i" = 'etc' ]]; then
        printf -- "#\n# /etc\n#\n"
        make_etc
    else
        chrooty $i
    fi
done

# this keeps the dir structure of the libraries, but puts all the
# binaries into /bin
printf -- "#\n# libraries\n#\n"
sort $libraries | formatty
printf -- "#\n# binaries\n#\n"
sort $binaries  | formatty './bin'

# temp files
rm -f $libraries $binaries
