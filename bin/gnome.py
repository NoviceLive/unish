#!/usr/bin/env python


from collections import OrderedDict, namedtuple
from subprocess import check_output
from functools import partial


Shortcut = namedtuple('Shortcut', 'name command binding')


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


def main():
    setup_preferences()
    setup_shortcuts()


def setup_shortcuts():
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
        gsettings('set', key, 'name', shortcut.name)
        gsettings('set', key, 'command', shortcut.command)
        gsettings('set', key, 'binding', shortcut.binding)
        print('    Done.')
    print('==> Round up')
    original = gsettings('get', root, 'custom-keybindings')
    print('    Original Value:', original)
    gsettings('set', root, 'custom-keybindings', str(keys))
    current = gsettings('get', root, 'custom-keybindings')
    print('    Current Value:', current)
    print('    Done')


def setup_preferences():
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
