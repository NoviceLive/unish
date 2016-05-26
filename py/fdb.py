#!/usr/bin/env python3


"""
Copyright 2016 Gu Zhengxiong <rectigu@gmail.com>
"""


from __future__ import division, absolute_import, print_function
from logging import root as logger
from sys import argv
from os.path import dirname, join, realpath
from sqlite3 import connect, IntegrityError


def main():
    """Database manager for Intentional command-not-found handler."""
    path = join(dirname(argv[0]), '..', 'dat', 'aliases.db')
    path = realpath(path)
    logger.debug('path: %s', path)
    with connect(path) as database:
        cursor = database.cursor()
        sql = 'create table if not exists ' \
              'aliases (name text unique, link text)'
        cursor.execute(sql)
        handle(cursor, argv[1:], parse_comment)


def parse_comment(line):
    from parse import parse
    tag = parse('{}[{name}]({link}){}<!--{mark}-->{}', line)
    try:
        return tag.named['mark'].strip(), tag.named['link'].strip()
    except AttributeError:
        return None


def parse_simple(line):
    return line.split()


def handle(cursor, filenames, parser):
    for filename in filenames:
        with open(filename) as stream:
            for line in stream:
                try:
                    name, link = parser(line)
                except TypeError:
                    pass
                else:
                    sql = 'insert into aliases values (?, ?)'
                    args = (name, link)
                    try:
                        cursor.execute(sql, args)
                    except IntegrityError:
                        pass
                    else:
                        print('Inserted', name, link)


if __name__ == '__main__':
    main()
