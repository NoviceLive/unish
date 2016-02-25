Unish - One Configuration To Rule Them All
==========================================


Hopefully it will come true in ten years. :)


Current State: Primitive.


Features
--------

- Smart Commands (Growing)

  Commands with knowledge of their invocation environment and behave
  accordingly.

  See the dedicated section below.

- Logging Layer (Primitive)

  I'm addicted to logs, and dream of writting fantastic ones,
  which give me a feeling that my code is more of myself,
  a human being,
  rather than some strange pieces run inside a cold machine.

  Because it's me that wrote it!

- Built-in Help Layer (Primitive)

  Created by a previous Bash user
  who missed that handy ``help`` builtin
  and appreciated the fantastic ``run-help`` in Zsh world.

- Documentation generator (Ongoing)

  I hate documentation that isn't generated from code.

  Known exceptions: readme, changelog as well as commit messages.

- Plugin Layer (Planned)


Installation
------------

- Clone this repository

  ``git clone https://github.com/NoviceLive/unish.git`` or

  ``git clone --recursive https://github.com/NoviceLive/unish.git``

  Clone recursively if you want the bundle packages as listed below.

- Use the included ``makefile`` to prepare symbolic links

  ``make zsh`` or ``make bash``

  Warning: Check the ``makefile`` before typing ``make``.

  Backup your original ~/.zshrc or ~/.bashrc if necessary.

- Happy Tweaking!


Smart Commands
--------------

Take ``cd`` for instance, we think it ``smart`` when it:

- ``cd`` into the directory containing the given file

  if it's invoked with a single argument which is a file.
  For example, ``cd /etc/fstab`` behaves as ``cd /etc``.

- runs ``git status`` or ``hg status`` after ``cd``

  if it knows that the directory are Git or Mercurial repositories.

- displays files up to a default count in the given directory

  when it finds nothing special about that direcotry.

As matter of fact, we are able to add smartness further,
for instance, integrating autoenv_ or smartcd_.


Documentation
=============

Some might not be related with Unish,
but with Linux or in general with POSIX or UNIX.


- How to

  - `install Arch Linux with full-disk encryption <doc/arch-install.sh>`_

    Boot Loader or Manager: GRUB

    Partition Scheme: UEFI/GPT

    Encryption Scheme: LVM on LUKS using dm-crypt

    Encrypted: ``/``, where there are ``/home`` and swap.

    Boot Partition: Encrypted on a removable disk.

    Unencrypted: ``/boot/efi``


Integrated Utilities
--------------------

Unish provides integration (wrapping)
of some useful daily utilities,
for example, ``ssh-agent`` and tmux_.

- ``ssh-agent``

  ``ssh-agent`` will be started if available when Unish is ready.

  You can use ``addkey`` function to add keys.

- tmux_

  If Unish finds tmux_,
  it will be started with the default session named ``main``.

  ``a`` function can be used to attach to the most recent session,
  or create a new session ``main`` if there is none.


Major Functions Currently Available
-----------------------------------

- ``lsgit`` and ``upgit``

  And variants, ``lshg``, ``uphg``, etc.
  See ``help lsgit`` and ``help upgit``.

- ``lsmd5`` and ``rmmd5``

  And its siblings, ``lssha1``, ``lssha224``, ``lssha256``,
  ``lssha383``, ``lssha512`` and the corresponding ``rm`` versions.

  See ``help lsmd5`` for more.

- ``catmp3``

  And its brothers, ``catflv``, ``catmp4``, etc. See ``help catmp3``.

  It requires ffmpeg_.

- ``summp3``

  And its brothers, ``sumflv``, ``summp4``, etc. See ``help summp3``.

  It requires ffmpeg_.


Bundled Packages
----------------

- zsh & bash

  - `virtualenvwrapper / virtualenvwrapper <https://bitbucket.org/virtualenvwrapper/virtualenvwrapper>`_ MIT

- zsh

  - `zsh-users/zsh-syntax-highlighting <https://github.com/zsh-users/zsh-syntax-highlighting>`_ BSD-3
  - `zsh-users/zsh-history-substring-search <https://github.com/zsh-users/zsh-history-substring-search>`_ BSD-3


Author & License
----------------

Copyright 2015-2016 Gu Zhengxiong <rectigu@gmail.com>

Unish is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License
as published by the Free Software Foundation,
either version 3 of the License,
or (at your option) any later version.


.. _smartcd: https://github.com/cxreg/smartcd
.. _autoenv: https://github.com/kennethreitz/autoenv
.. _tmux: https://tmux.github.io/
.. _ffmpeg: https://www.ffmpeg.org/
