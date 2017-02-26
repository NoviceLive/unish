Unish - One Configuration To Rule Them All
==========================================


Hopefully it will eventually come true in ten years. :)


Current State: Primitive.


Some One-Liners That May Fade From Memory
=========================================

- ``tilsuc``: Unattended download of videos over unstable connection.

  It seems more appropriate to add a ``sleep`` in the ``while`` loop,
  when the main command doesn't support immediate re-entrance.

  ::

     tilsuc() { while true; do "${@}"; if [[ $? -eq 0 ]]; then break; fi; done; }; tilsuc youtube-dl --proxy 'socks5://127.0.0.1:1080' 'http://www.pbs.org/newshour/episode/pbs-newshour-full-episode-feb-24-2017/'

- If you have many Git repositories, this one-liner might come in handy.

  Note that all my repositories are named in this format, '<name>.<vcs>'.
  For instance, ``unish.git``, ``unish.hg`` and ``unish.svn``.

  ::

     find -maxdepth 1 -name '*.git' -exec sh -c 'cd {} && git status' \;

- Clean up compiled Python files before packaging or distributing.

  ::

     find -name '*.pyc' -delete && find -name '__pycache__' -delete

- I tend to use this ``pylint`` recently.

  E.g, ``1000``, to which pylint defaults,
  is not a good candidate for maximum line count,
  whereas ``999`` or ``9999`` is.

  Guess what?

  I refuse to pay the space of a single character, ``len('1000') - len('999')``,
  for a single line, ``1000 - 999``,
  when my editors always have line numbers on.

  ::

     pylint --reports n --output-format colorized --disable=missing-docstring,too-few-public-methods,too-many-ancestors,broad-except,invalid-name,too-many-locals,too-many-arguments,too-many-instance-attributes,too-many-public-methods,too-many-lines,too-many-branches,too-many-statements,duplicate-code


Documentation
=============

Some might not be related with Unish,
but with Linux or in general with POSIX or UNIX.


- How to

  - install Arch Linux with full-disk encryption `Version 1`_  `Version 2`_

    +-------------------+------------------------+-------------------------------------------+
    |      Item         |     `Version 1`_       |   `Version 2`_                            |
    +===================+========================+===========================================+
    | Encryption Scheme | `LVM on LUKS`_         | `LVM on LUKS`_ (`using a remote header`_) |
    +-------------------+------------------------+-------------------------------------------+
    | Boot Partition    | `Simple Partition Layout with LUKS`_ (`on a pendrive`_)            |
    +-------------------+------------------------+-------------------------------------------+
    | Unencrypted       | EFI System Partition (/boot/efi)                                   |
    +-------------------+------------------------+-------------------------------------------+
    | Partition Editor  | Parted (Not Required)                                              |
    +-------------------+------------------------+-------------------------------------------+
    | Partition Scheme  | UEFI/GPT                                                           |
    +-------------------+------------------------+-------------------------------------------+
    | Boot Manager      | GRUB (Required)                                                    |
    +-------------------+------------------------+-------------------------------------------+
    | Init Manager      | Systemd (Not Required) | Systemd (Required)                        |
    +-------------------+------------------------+-------------------------------------------+


Warning
-------

Unish may work only in Zsh 5.2 & Bash 4.3.
You have been warned.


Still Warning
-------------

You are not recommended to use Unish directly. (It sucks :(.)
Instead, absorbing or extracting and adapting
some bits or pieces that fit in your needs.

But it's not abandoned and will be updated regularly
as I experiment on various fancy stuffs.


Features
--------

- Intentional command-not-found handler

  Work in progress, prototype available.

  For more details, see ``py/found.py``, ``py/fdb.py``,
  as well as the command-not-found handling functions.

Update
++++++

``py/found.py`` and related code now reside in UrlMark_.

Show Cases
++++++++++

::

   $ # Search in Google or Bing, and many others.
   $ @google Who is the president of US
   $ @bing Who is the president of US

   $ # Open a website.
   $ @github

   $ # Search in dictionaries.
   $ @oxford pulchritude
   $ @urban '<3'

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

- Alternatively, you can just ``source`` the ``entry.sh`` of Unish.

  Both Zsh_ and Bash_ are supported.

  Suggestion: use ``export DISABLE_UNISH_PLUGINS=1``
  before you source to avoid unintentional side effects.

- Happy Tweaking!


Smart Commands
--------------

Take ``cd`` for instance, we think it ``smart`` when it:

- ``cd`` into the directory containing the given file

  if it's invoked with a single argument which is a file.
  For example, ``cd /etc/fstab`` behaves as ``cd /etc``.

- runs ``git status`` or ``hg status`` after ``cd``

  if it knows that the directory is a Git or Mercurial repository.

- displays files up to a default count in the given directory

  when it finds nothing special about that direcotry.

As matter of fact, we are able to add smartness further,
for instance, integrating autoenv_ or smartcd_.


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

- ``dog``

  Colorized ``cat`` (Actually ``less``) if applicable.

  This requires highlight_ or pygmentize_.

- ``lsgit`` and ``upgit``

  lsgit: Check the status of git repositories
  in the specified directory.

  upgit: Update the specified git repositories.

  And variants, ``lshg``, ``uphg``, etc.
  See ``help lsgit`` and ``help upgit``.

- ``lsmd5`` and ``rmmd5``

  lsmd5: List the md5sum of files (but without filenames)
  in the specified directory.

  rmmd5: Remove the files with the specified md5sum.

  And its siblings, ``lssha1``, ``lssha224``, ``lssha256``,
  ``lssha383``, ``lssha512`` and the corresponding ``rm`` versions.

  See ``help lsmd5`` for more.

- ``catmp3``

  Concatenate mp3 files in the specified directory.

  And its brothers, ``catflv``, ``catmp4``, etc. See ``help catmp3``.

  It requires ffmpeg_.

- ``summp3``

  Calculate total duration of mp3 files in the specified paths.

  And its brothers, ``sumflv``, ``summp4``, etc. See ``help summp3``.

  It requires ffmpeg_.


Bundled Packages
----------------

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
.. _highlight: http://www.andre-simon.de/doku/highlight/en/highlight.php
.. _pygmentize: http://pygments.org/
.. _GRUB: http://www.gnu.org/software/grub/
.. _Parted: http://www.gnu.org/software/parted/
.. _Zsh: http://www.zsh.org/
.. _Bash: http://www.gnu.org/software/bash/

.. _Version 1: https://github.com/NoviceLive/unish/blob/master/doc/arch-install.sh
.. _Version 2: https://github.com/NoviceLive/unish/blob/master/doc/v2-arch-install.rst


.. _Simple Partition Layout with LUKS: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Simple_partition_layout_with_LUKS
.. _LVM on LUKS: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS
.. _on a pendrive: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_.28GRUB.29
.. _using a remote header: https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Encrypted_system_using_a_remote_LUKS_header
.. _UrlMark: https://github.com/NoviceLive/urlmark
