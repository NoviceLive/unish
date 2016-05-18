#!/usr/bin/env python3


"""
Copyright 2016 Gu Zhengxiong <rectigu@gmail.com>
"""


from __future__ import division, absolute_import, print_function
from sys import argv
from glob import glob
from re import sub
from os.path import join, basename
from subprocess import check_call, CalledProcessError


def main():
    path = '/var/lib/pacman/local/'
    found = False
    for name in argv[1:]:
        packages = glob(join(path, name + '*'))
        for package in packages:
            stem = sub(r'-\d+(\.\d+)*', '', package)
            if basename(stem) == name:
                install = join(package, 'install')
                try:
                    check_call(['less', '-F', '-X', '-R', install])
                except CalledProcessError:
                    print('Failed to view {}'.format(package))
                found = True
                break
        else:
            print('Failed to find {}'.format(name))
    if not found:
        exit(1)


if __name__ == '__main__':
    main()
