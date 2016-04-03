#!/usr/bin/env python


"""
Setup GNOME preferences.

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

An example session.

==> Setting up org.gnome.nautilus.preferences click-policy to single
    Original Value: 'double'
    Current Value: 'single'
    Done.
==> Setting up org.gnome.desktop.media-handling automount to false
    Original Value: true
    Current Value: false
    Done.
==> Setting up org.gnome.desktop.privacy remember-recent-files to false
    Original Value: true
    Current Value: false
    Done.
==> Binding <ctrl><alt>t to gnome-terminal
    Done.
==> Binding <super>f to firefox
    Done.
==> Binding <super>b to virtualbox
    Done.
==> Binding <super>e to nautilus
    Done.
==> Rounding up
    Original Value: @as []
    Current Value: ['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']
    Done.
"""


from collections import OrderedDict, namedtuple
from subprocess import check_output


Shortcut = namedtuple('Shortcut', 'name command binding')


def main():
    preferences = [
        {'org.gnome.nautilus.preferences click-policy': 'single'},
        {'org.gnome.desktop.media-handling automount': 'false'},
        {'org.gnome.desktop.privacy remember-recent-files': 'false'},
    ]
    shortcuts = [
        Shortcut('GNOME Terminal', 'gnome-terminal', '<ctrl><alt>t'),
        Shortcut('Firefox', 'firefox', '<super>f'),
        Shortcut('VirtualBox', 'virtualbox', '<super>b'),
        Shortcut('Nautilus', 'nautilus', '<super>e'),
    ]
    setup_preferences(preferences)
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


def setup_preferences(preferences):
    items = OrderedDict()
    for one in preferences:
        items.update(one)
    for key in items:
        print('==> Setting up {} to {}'.format(key, items[key]))
        original = gsettings('get', *key.split())
        print('    Original Value:', original)
        gsettings('set', *key.split(), items[key])
        current = gsettings('get', *key.split())
        print('    Current Value:', current)
        print('    Done.')


def gsettings(*args):
    output = check_output(['gsettings', *args],
                          universal_newlines=True)
    return output.strip()


if __name__ == '__main__':
    main()
