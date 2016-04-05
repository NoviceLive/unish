#!/usr/bin/env python3


from os.path import basename, splitext
from logging import basicConfig, DEBUG

import click
from plumbum import local, FG


__author__ = 'Gu Zhengxiong'
__version__ = '0.1.0'

PROGRAM_NAME = 'GH'
PACKAGE_NAME = PROGRAM_NAME.lower()
VERSION_PROMPT = (
    '{version}\n\nCopyright 2015-2016 {author} '
    '<rectigu@gmail.com>\n\n'
    'This is free software; see the source for '
    'copying conditions.\nThere is NO warranty; '
    'not even for MERCHANTABILITY nor \nFITNESS FOR '
    'A PARTICULAR PURPOSE.'.format(
        version=__version__, author=__author__)
)


@click.group(
    context_settings=dict(help_option_names=['-h', '--help']))
@click.version_option(VERSION_PROMPT,
                      '-V', '--version', prog_name=PROGRAM_NAME)
def main():
    """Simplified & Unfied Interface Of Mercurial & Git."""
    basicConfig(level=DEBUG)


@main.command()
@click.argument('url')
def cl(url):
    """Clone a repository in a simplified manner."""
    SCM(url).doer.clone()


class SCM(object):
    def __init__(self, url):
        suffix = self.get_suffix(url)
        if suffix == Hg.suffix:
            self.doer = Hg(url)
        elif suffix == Git.suffix:
            self.doer = Git(url)
        else:
            raise RuntimeError('No handler for URL: %s', url)

    @staticmethod
    def get_suffix(url):
        """Determine the suffix for the URL.

        Example Git URL:
        1. https://github.com/NoviceLive/unish.git
        2. git@github.com:NoviceLive/unish.git
        3. https://novicelive@bitbucket.org/novicelive/good.git
        4. git@bitbucket.org:novicelive/good.git

        Example Mercurial URL:
        1. ssh://hg@bitbucket.org/novicelive/unish
        """
        suffix = splitext(basename(url))[1]
        return Git.suffix if suffix == Git.suffix else Hg.suffix


class Git(object):
    suffix = '.git'
    git = local['git']

    def __init__(self, url):
        self.url = url
        self.base = basename(url)

    def clone(self, dest=None):
        if dest is None:
            dest = self.base
        self.git['clone', self.url, dest, '--recursive'] & FG


class Hg(object):
    suffix = '.hg'
    hg = local['hg']

    def __init__(self, url):
        self.url = url
        self.base = basename(url)

    def clone(self, dest=None):
        if dest is None:
            dest = self.base + self.suffix
        self.hg['clone', self.url, dest] & FG


if __name__ == '__main__':
    main()
