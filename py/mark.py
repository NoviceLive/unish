#!/usr/bin/env python3


"""
Copyright 2016 Gu Zhengxiong <rectigu@gmail.com>
"""


from __future__ import division, absolute_import, print_function
from sqlite3 import connect, IntegrityError
from sys import argv


def main():
    with connect('aliases.db') as database:
        cursor = database.cursor()
        sql = 'create table if not exists ' \
              'aliases (name text unique, link text)'
        cursor.execute(sql)
        for name in argv[1:]:
            with open(name) as stream:
                for line in stream:
                    name, link = line.split()
                    sql = 'insert into aliases values (?, ?)'
                    args = (name, link)
                    try:
                        cursor.execute(sql, args)
                    except IntegrityError:
                        pass
                    else:
                        print(name, link)


if __name__ == '__main__':
    main()
