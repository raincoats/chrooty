# chrooty

helps you copy necessary libraries for a chroot. spits shell commands to stdout, pipe it to sh.

## usage

    $ chrooty [some progs] | sh

    $ chrooty coreutils | sh

## example

	$ mkdir test; cd test

	$ ../chrooty.sh sh ls | sh

	$ sudo chroot . /bin/sh

	sh-4.4# pwd
	/
	
	sh-4.4# ls -la
	total 0
	drwxr-xr-x 1 1000 1000 22 Dec 31 23:48 .
	drwxr-xr-x 1 1000 1000 22 Dec 31 23:48 ..
	drwxr-xr-x 1 1000 1000  8 Dec 31 23:48 bin
	drwxr-xr-x 1 1000 1000 40 Dec 31 23:48 lib64
	drwxr-xr-x 1 1000 1000  6 Dec 31 23:48 usr

	sh-4.4# ls -la /bin
	total 936
	drwxr-xr-x 1 1000 1000      8 Dec 31 23:48 .
	drwxr-xr-x 1 1000 1000     22 Dec 31 23:48 ..
	-rwxr-xr-x 1 1000 1000 126480 Dec 31 23:48 ls
	-rwxr-xr-x 1 1000 1000 828320 Dec 31 23:48 sh

	sh-4.4# cat
	sh: cat: command not found
