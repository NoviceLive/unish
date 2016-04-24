#!/usr/bin/env python3


from logging import basicConfig, DEBUG, root as logger
from sys import argv
from subprocess import Popen


def main():
    """Intentional command not found handler."""
    basicConfig(level=DEBUG)
    logger.debug('argv: %s', argv)
    if argv[1] in '-_+=@':
        index = 2
    else:
        index = 1
    joined = ' '.join(argv[index:])
    logger.debug('joined: %s', joined)
    args = ['firefox', 'https://www.google.com/#newwindow=1&q=' + joined]
    logger.debug('Popen: %s', args)
    Popen(args)


if __name__ == '__main__':
    main()
