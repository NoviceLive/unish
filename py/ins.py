#!/usr/bin/env python3


"""
Initial package installation manager.

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
from logging import basicConfig, DEBUG

import click
from plumbum import local, FG


@click.command()
@click.argument(
    'streams', nargs=-1, required=True, metavar='FILENAME ...',
    type=click.File('r'))
@click.option('-b', '--binary', default='pacman', show_default=True,
              help='Use the binary.')
def main(streams, binary):
    """Initial package installation manager."""
    basicConfig(level=DEBUG)
    if binary == 'pacman':
        doer = Pacman()
    elif binary == 'yaourt':
        doer = Pacman('yaourt')
    elif binary == 'pip2':
        doer = Pip(2)
    elif binary == 'pip3':
        doer = Pip(3)
    else:
        raise RuntimeError('No doers for %s', binary)
    for stream in streams:
        for packages, comment in parse(stream.read()):
            if comment:
                print(comment)
            doer.install(packages)


class Pip(object):
    def __init__(self, version=3):
        if version == 3:
            self.pip = local['pip3']
        else:
            self.pip = local['pip2']

    def install(self, packages):
        self.pip['install', packages] & FG


class Pacman(object):
    def __init__(self, binary='pacman'):
        self.pacman = local[binary]
        self.refresh()

    def refresh(self):
        self.pacman['--sync', '--refresh', '--refresh'] & FG

    def install(self, packages):
        self.pacman['--sync', '--needed', packages] & FG


def parse(text):
    lines = filter(bool, text.splitlines())
    for line in lines:
        try:
            index = line.index('#')
        except ValueError:
            packages = line
            comment = ''
        else:
            packages = line[:index]
            comment = line[index+1:].strip()
        packages = packages.strip().split()
        if list(filter(bool, packages)):
            yield (packages, comment)


if __name__ == '__main__':
    main()
