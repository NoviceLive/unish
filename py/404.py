#!/usr/bin/env python3


from logging import basicConfig, DEBUG, root as logger
from sys import argv, exit
from subprocess import Popen


def main():
    """Intentional command not found handler."""
    basicConfig(level=DEBUG)
    logger.debug('argv: %s', argv)
    args = ' '.join(argv[1:])
    handle_args(args)


def handle_args(args):
    parts = args.split()
    start = parts[0]
    if start[0] == '@':
        operator = start[1:] if start[1:] else 'google'
        args = ' '.join(parts[1:])
        logger.debug('operator: %s', operator)
        logger.debug('args: %s', args)
        handle_operator(operator, args)
    else:
        raise RuntimeError('undefined!')


def handle_operator(operator, args):
    if args:
        try:
            url = globals()['handle_' + operator](args)
        except KeyError:
            raise
        args = ['firefox', url]
        logger.debug('Popen: %s', args)
        Popen(args)
    else:
        # TODO: Integrate with UrlMark.
        pass


def handle_google(args):
    return 'https://www.google.com/#newwindow=1&q=' + args


def handle_bing(args):
    return 'https://bing.com/search?q=' + args


def handle_baidu(args):
    return 'https://www.baidu.com/s?wd=' + args


if __name__ == '__main__':
    main()
