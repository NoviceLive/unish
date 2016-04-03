#!/usr/bin/env python3


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
