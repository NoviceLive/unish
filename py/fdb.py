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
    from re import match
    re = r'\s*-\s\[(?P<name>.+)\]\((?P<link>.+)\)\s<!--(?P<mark>.+)-->'
    one = match(re, line)
    # If we have commented the alias, use it.
    try:
        return one.group('mark').strip(), one.group('link')
    except AttributeError:
        # If not, fallback to the lower case of the name,
        # which just works most of the time
        # and saves us from unnecessarily commenting.
        # TODO: Replace spaces with underscores and the like.
        re = r'\s*-\s\[(?P<name>.+)\]\((?P<link>.+)\)'
        one = match(re, line)
        try:
            return one.group('name').lower().strip(), one.group('link')
        except AttributeError:
            # This should never happen in my opinion.
            raise ValueError


# def parse_comment(line):
#     from parse import parse
#     tag = parse('{}[{name}]({link}){}<!--{mark}-->{}', line)
#     try:
#         return tag.named['mark'].strip(), tag.named['link'].strip()
#     except AttributeError:
        # raise ValueError


def parse_simple(line):
    return line.split()


def handle(cursor, filenames, parser):
    for filename in filenames:
        with open(filename) as stream:
            for line in stream:
                try:
                    name, link = parser(line)
                except ValueError:
                    pass
                else:
                    if link.strip() == '#':
                        continue
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
