#!/usr/bin/env python3


from sys import argv
from subprocess import Popen


def main():
    """Intentional command not found handler."""
    args = ['firefox', 'https://www.google.com/#newwindow=1&q=' + ' '.join(argv[1:])]
    Popen(args)


if __name__ == '__main__':
    main()
