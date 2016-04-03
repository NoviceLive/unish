#!/usr/bin/env python3


"""
Package initial setup for Arch Linux.

Copyright 2015-2016 Gu Zhengxiong <rectigu@gmail.com>

This file is part of Unish.

Unish is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License
as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Unish is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Unish.  If not, see <http://www.gnu.org/licenses/>.
"""


from __future__ import print_function
from sys import argv, stderr, exit
from subprocess import check_call, CalledProcessError


def main():
    try:
        pacman('--sync', '--refresh', '--refresh')
    except OSError:
        print(error, file=stderr)
        exit(1)
    for filename in argv[1:]:
        with open(filename) as stream:
            text = stream.read()
            for packages, comment in parse(text):
                print(packages)
                print(comment)
                try:
                    pacman('--sync', '--needed', *packages)
                except OSError as error:
                    print(error, file=stderr)


def pacman(*args):
    commandline = ['pacman']
    commandline.extend(args)
    try:
        check_call(commandline)
    except CalledProcessError as error:
        raise OSError(error)


def parse(text):
    lines = filter(bool, text.splitlines())
    for line in lines:
        try:
            index = line.index('#')
        except ValueError:
            packages = line
            comment = 'No comment.'
        else:
            packages = line[:index]
            comment = line[index+1:].strip()
        packages = packages.strip().split()
        if list(filter(bool, packages)):
            yield (packages, comment)


if __name__ == '__main__':
    main()
