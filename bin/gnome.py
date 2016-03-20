#!/usr/bin/env python


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
    print('    Done')


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
