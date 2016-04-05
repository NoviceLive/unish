#!/usr/bin/env python3


from sys import exit
from logging import basicConfig, DEBUG, root as logger
try:
    from pathlib import Path
except ImportError:
    from pathlib2 import Path

import click
from git import Repo


@click.command()
@click.argument('source')
@click.argument('dest')
def main(source, dest):
    basicConfig(level=DEBUG)
    try:
        repo = Repo(source)
    except OSError as error:
        logger.exception('Error:')
        exit(1)
    else:
        dest = Path(dest)
        try:
            dest = dest.with_suffix('.git')
        except ValueError:
            logger.exception('Error:')
            exit(1)
        logger.info('Using dest: %s', dest)

        remote = repo.remote()
        logger.debug('Old URL: %s', remote.url)
        origin = Path(remote.url)
        logger.debug('Parent: %s', origin.parent)

        new = origin.parent / dest
        logger.info('Using URL: %s', new)

        conf = remote.config_writer
        conf.set('url', str(new))
        conf.release()

        Path(source).rename(dest)
        exit(0)


if __name__ == '__main__':
    main()
