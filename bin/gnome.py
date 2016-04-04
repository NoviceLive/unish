#!/usr/bin/env python


"""
Setup GNOME preferences using dconf.

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


from collections import namedtuple

from plumbum import local


Shortcut = namedtuple('Shortcut', 'name command binding')
dconf = local['dconf']
gsettings = local['gsettings']


def main():
    preferences = [
        ('desktop/media-handling/automount', 'false'),
        ('desktop/privacy/remember-recent-files', 'false'),
        ('terminal/legacy/default-show-menubar', 'false'),
        # Strings need extra quoting: "'single'".
        ('nautilus/preferences/click-policy', "'single'"),
        # This is actually the default.
        ('desktop/interface/monospace-font-name', "'Monospace 11'"),
    ]
    for item, value in preferences:
        key = '/org/gnome/' + item
        print('{}: {}'.format(key, value))
        old = set_key_value(key, value)
        print('Old: {}'.format(old))

    shortcuts = [
        Shortcut('GNOME Terminal', 'gnome-terminal', '<ctrl><alt>t'),
        Shortcut('Firefox', 'firefox', '<super>f'),
        Shortcut('VirtualBox', 'virtualbox', '<super>b'),
        Shortcut('Nautilus', 'nautilus', '<super>e'),
    ]
    setup_shortcuts(shortcuts)


def setup_shortcuts(shortcuts):
    root = 'org.gnome.settings-daemon.plugins.media-keys'
    path = root + '.custom-keybinding'
    more = '/{}/custom-keybindings'.format(root.replace('.', '/'))
    keys = []
    for index, shortcut in enumerate(shortcuts):
        key = '{}/custom{}/'.format(more, index)
        keys.append(key)
        print('==> Binding {} to {}'.format(
            shortcut.binding, shortcut.command))
        key = '{}:{}'.format(path, key)
        for one in ['name', 'command', 'binding']:
            gsettings('set', key, one, getattr(shortcut, one))
        print('    Done.')
    print('==> Rounding up')
    original = gsettings('get', root, 'custom-keybindings')
    print('    Original Value:', original)
    gsettings('set', root, 'custom-keybindings', str(keys))
    current = gsettings('get', root, 'custom-keybindings')
    print('    Current Value:', current)
    print('    Done.')


def set_key_value(key, value):
    old = dconf('read', key).strip()
    dconf('write', key, value)
    return old


if __name__ == '__main__':
    main()
