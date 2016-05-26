#!/usr/bin/env python3


"""
Copyright 2016 Gu Zhengxiong <rectigu@gmail.com>
"""


from __future__ import division, absolute_import, print_function
from logging import basicConfig, DEBUG, root as logger
from sys import argv, exit
from os.path import dirname, join, realpath
from sqlite3 import connect, OperationalError
from subprocess import Popen


def main():
    """Intentional command-not-found handler."""
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
    else:
        path = join(dirname(argv[0]), '..', 'dat', 'aliases.db')
        path = realpath(path)
        logger.debug('path: %s', path)
        with connect(path) as database:
            cursor = database.cursor()
            sql = 'select link from aliases where name = ?'
            args = (operator,)
            logger.debug('sql: %s', sql)
            logger.debug('args: %s', args)
            try:
                cursor.execute(sql, args)
            except OperationalError:
                logger.exception('')
                exit(1)
            else:
                link = cursor.fetchone()
                if link:
                    url = link[0]
                else:
                    print('Sorry, you have not defined this alias!')
                    exit(1)
    args = ['firefox', url]
    logger.debug('Popen: %s', args)
    Popen(args)


def handle_github(args):
    return 'https://github.com/search?&q=' + args


def handle_tmall(args):
    return 'https://list.tmall.com/search_product.htm?q=' + args


def handle_google(args):
    return 'https://www.google.com/#newwindow=1&q=' + args


def handle_bing(args):
    return 'https://bing.com/search?q=' + args


def handle_baidu(args):
    return 'https://www.baidu.com/s?wd=' + args


def handle_urban(args):
    return 'https://www.urbandictionary.com/define.php?term=' + args


def handle_etym(args):
    return 'http://www.etymonline.com/index.php?search=' + args


def handle_ahd(args):
    return 'https://ahdictionary.com/word/search.html?q=' + args


def handle_oxford(args):
    return 'https://www.oxforddictionaries.com/' \
        'us/definition/american_english/' + args


if __name__ == '__main__':
    main()
