Full-Disk Encrypted Arch Installation Version 2
===============================================


Metadata
--------

Created: 2016-03-10

Updated: 2018-01-30

Maintainer: Gu Zhengxiong <rectigu@gmail.com>

License: `GNU Free Documentation License`_ Version 1.3

.. contents:: :local:


Foreword
--------

This documentation is the fruit of my spending many hours in reading
various `Arch Wiki`_ articles on `disk encryption`_,
specifically, via `dm-crypt`_,
and still many hours in experimenting all necessary steps,
installing and reinstalling Arch to try out some different schemes.

Hope it helps.


Comparison Between `Version 2`_ & `Version 1`_
----------------------------------------------

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


Let's Get Started
-----------------

Before booting, you might want to consider adding some kernel parameters, e.g., ``copytoram=y`` or ``consoleblank=0``.

Again_, now that the installation medium has been booted,
a root shell appears.

.. _Again: `Version 1`_


Securely Erase Disks
++++++++++++++++++++

- Identify block devices with ``lsblk``.

  ::

     lsblk

- Wipe disks.

  Suppose that we are going to install Arch on ``/dev/XXX``,
  and the boot partition on ``/dev/YYY``.
  We'll want to wipe them to prevent unintended data recovery,
  as suggested by `dm-crypt/Drive preparation`_.

  Note that this might consume several hours.
  See ``shred --help`` for more details.

  ::

     time shred /dev/XXX &
     time shred /dev/YYY

- A preferred alternative: randomize your disks.

  - Using ``/dev/urandom`` and ``dd``

    It's unbearably slow no matter what ``bs`` value you choose,
    due to the bottleneck of pseudo-random number generation.

    ::

       dd if=/dev/urandom of=/dev/XXX
       dd if=/dev/urandom of=/dev/YYY

  - Using ``cryptsetup`` and ``dd``

    This gains randomness by encryption
    and is faster when you use a reasonable ``bs`` value.

    ::

       cryptsetup --key-file /dev/random open --type plain /dev/XXX one
       dd if=/dev/zero of=/dev/mapper/one
       cryptsetup close one

       cryptsetup --key-file /dev/random open --type plain /dev/YYY two
       dd if=/dev/zero of=/dev/mapper/two
       cryptsetup close two


Perform Some Boring Routines
++++++++++++++++++++++++++++

See the `Installation guide`_ or `Beginners' guide`_
for more details.

- Check the UEFI mode.

  ::

     ls /sys/firmware/efi/efivars

- Load necessary key maps and set console fonts if needed.

  ::

     # loadkeys skipped
     # setfont skipped

- Check or configure the network.

  ::

     # network configuration skipped

     ping -c4 archlinux.org

- Update the system clock.

  ::

     timedatectl status
     timedatectl set-ntp true
     timedatectl status


Prepare Partitions a.k.a Interesting Part I
+++++++++++++++++++++++++++++++++++++++++++

Choose algorithms
*****************

Running benchmarks may help you choose the algorithms.

Also, see `Encryption options for LUKS mode`_
and `Ciphers and modes of operation`_ for more information.

I will take ``serpent-xts-plain64`` and ``whirlpool`` for example.
Nevertheless, ``serpent`` is very likely to be a bad choice for NVMe SSDs,
which are capable of reading and writing at several GB/s.

Tips
@@@@

``serpent-xts-plain64`` reads that
the encryption algorithm is `serpent`_,
other candidates being `twofish`_ and `aes`_,
the `chain mode`_ is `xts`_,
and the `initialization vector`_ generator is plain64.

::

   cryptsetup benchmark

An example output.

::

   # Tests are approximate using memory only (no storage IO).
   PBKDF2-sha1      1468593 iterations per second for 256-bit key
   PBKDF2-sha256    1648704 iterations per second for 256-bit key
   PBKDF2-sha512    1307451 iterations per second for 256-bit key
   PBKDF2-ripemd160 1036142 iterations per second for 256-bit key
   PBKDF2-whirlpool  758738 iterations per second for 256-bit key
   #     Algorithm | Key |  Encryption |  Decryption
           aes-cbc   128b  1041.6 MiB/s  3381.4 MiB/s
       serpent-cbc   128b    83.8 MiB/s   676.5 MiB/s
       twofish-cbc   128b   200.2 MiB/s   365.4 MiB/s
           aes-cbc   256b   792.3 MiB/s  2635.0 MiB/s
       serpent-cbc   256b    84.5 MiB/s   666.9 MiB/s
       twofish-cbc   256b   199.2 MiB/s   362.8 MiB/s
           aes-xts   256b  3306.3 MiB/s  3310.2 MiB/s
       serpent-xts   256b   639.2 MiB/s   647.5 MiB/s
       twofish-xts   256b   353.8 MiB/s   358.5 MiB/s
           aes-xts   512b  2643.5 MiB/s  2639.9 MiB/s
       serpent-xts   512b   636.0 MiB/s   645.7 MiB/s
       twofish-xts   512b   351.8 MiB/s   358.4 MiB/s


Prepare Root
************

Tips
@@@@

**There is no need to partition the root disk**.

- Setup LUKS using a remote header.

  **Recommendation:** Use or add a key file for the root drive
  so as to unlock automatically during the normal boot process.
  See corresponding notes below and around for more information.

  ::

     truncate -s 2M root.header

     cryptsetup --header root.header \
     --cipher serpent-xts-plain64 --key-size 512 \
     --hash whirlpool --iter-time 5000 --use-random \
     luksFormat /dev/XXX

     cryptsetup --header root.header open /dev/XXX root

- Setup LVM in the encrypted container.

  Note that you will want to make necessary adaptation.

  ::

     pvcreate /dev/mapper/root
     vgcreate vga /dev/mapper/root
     lvcreate -n swap -L 4G vga
     lvcreate -n root -L 96G vga
     lvcreate -n home -l 100%FREE vga

- Create the swap and file systems.

  ::

     mkswap /dev/vga/swap
     mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/vga/root
     mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/vga/home


Prepare Boot
************

Prepare partition and setup LUKS.

Feel free to use your own preferences.

In the following example, ``/boot/efi`` will get 56 MiB,
and ``/boot`` 200 MiB.

::

   lsblk
   parted /dev/YYY
   (parted) p
   (parted) mktable gpt
   (parted) p
   (parted) mkpart primary 1MiB 57MiB
   (parted) p
   (parted) set 1 boot on
   (parted) p
   (parted) mkpart primary 58MiB 258MiB
   (parted) p
   (parted) q

   cryptsetup --cipher serpent-xts-plain64 --key-size 512 \
   --hash whirlpool --iter-time 5000 --use-random \
   luksFormat /dev/YYY2
   cryptsetup open /dev/YYY2 boot
   mkfs.fat -F32 /dev/YYY1
   mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/mapper/boot

Activate The Swap And Mount File Systems
****************************************

Also, move the header into boot,
we will configure ``mkinitcpio`` to copy it into the initramfs.

**Note:** If key files are used to unlock the root drive,
remember to move them to our new boot partition also.

::

   swapon /dev/vga/swap
   mount /dev/vga/root /mnt
   mkdir /mnt/{home,boot}
   mount /dev/vga/home /mnt/home
   mount /dev/mapper/boot /mnt/boot
   mkdir /mnt/boo/efi
   mount /dev/YYY1 /mnt/boot/efi

   mv root.header /mnt/boot


Follow Some More Boring Routines
++++++++++++++++++++++++++++++++

Perform System Installation
***************************

- Choose nearby mirrors.

  They are essential to an enhanced download experience.

  ::

     nano /etc/pacman.d/mirrorlist

- Install the base system.

  ::

     pacstrap -i /mnt base base-devel zsh grml-zsh-config

- Generate ``fstab`` and check it.

  ::

     genfstab -U /mnt >> /mnt/etc/fstab
     nano /mnt/etc/fstab

- Change root.

  ::

     arch-chroot /mnt /bin/zsh


Configure Some Boring Stuff For The Freshly Installed System
************************************************************

- Choose locales and generate them and
  set the locale, which shall be the first chosen entry and
  in my case, it's the following: ``LANG=en_US.UTF-8``.

  ::

     nano /etc/loacle.gen
     locale-gen

     nano /etc/locale.conf

- Configure ``/etc/vconsole.conf`` if necessary.

  ::

     # /etc/vconsole.conf configuration skipped

- Select and set the time zone.

  ::

     tzselect
     ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

- Set or update the hardware clock.

  ::

     hwclock --systohc --utc

- Again, check or configure the network.

  ::

     # network configuration skipped
     # I will simply use ``systemctl enable dhcpcd@enp4s0f2``

     ping -c4 archlinux.org


- Set the hostname and add it to ``/etc/hosts``.

  ::

     nano /etc/hostname
     nano /etc/hosts


Configure For Disk-Encryption a.k.a Interesting Part II
+++++++++++++++++++++++++++++++++++++++++++++++++++++++

Configure The Kernel
********************

- Edit ``/etc/fstab``.

  Add ``noauto`` to options of ``/boot`` and ``/boot/efi``
  so as to unplug the pendrive after loading the kernel.

  We will need to plug it in, unlock and mount them,
  whenever access to ``/boot`` is required,
  for instance, when there are kernel updates
  or when we want to regenerate the initramfs.

- Create ``/etc/crypttab.initramfs``

  In our example, add the following line.

  ::

     vga /dev/XXX none header=/boot/root.header

  - **Tips**

    It's strongly recommended to use persistent device naming,
    e.g., using ``/dev/disk/by-id/``, e.g.,
    ``anon /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10006PH244KE /boot/keyfile header=/boot/header``.

    **Note:** The above exemplary persistent device naming line
    demonstrates a configuration
    that achieves automatic unlock of the root disk,
    if it's been set up properly.

- Edit ``/etc/mkinitcpio.conf``

  Add ``nvme`` to ``MODULES`` if necessary.

  ::

     MODULES=(nvme)

  Add the header to ``FILES``.

  **Note:** Remember to include key files also if they are used.

  ::

     FILES=(/boot/root.header)

  As a result, the header will be copied into the initramfs.

  As for ``HOOKS``, replace ``udev`` with ``systemd``,
  and add ``sd-encrypt`` and ``sd-lvm2``
  between ``block`` and ``filesystems``.

  In my example, it reads.

  ::

     HOOKS=(base systemd autodetect modconf block sd-encrypt sd-lvm2 filesystems keyboard fsck)

- Regenerate initramfs.

  ::

     mkinitcpio -p linux


Configure The Bootloader
************************

- Install GRUB and efibootmgr.

  ::

     pacman -S grub efibootmgr

  For Intel CPUs, it's advised to install ``intel-ucode``.

  ::

     pacman -S intel-ucode

  The following packages are also suggested to be installed,
  if not previously done,
  at this stage for systems mainly depending on Wi-Fi.

  ::

     pacman -S dialog wpa_supplicant


- Edit ``/etc/default/grub``.

  Add or uncomment the line,
  ``GRUB_ENABLE_CRYPTODISK=y``,
  and add necessary kernel parameters.

  - **Tips**

    It's strongly recommended to use persistent device naming,
    e.g., using ``/dev/disk/by-id/``, e.g.,
    ``/dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10006PH244KE``
    .

  In this example, it looks like the following.

  ::

     GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=/dev/XXX:root:header"

  Note that ``root`` is the mapped name of our encrypted container.
  (**FIXME: No, this seems to be false.**)

  Also, I removed the ``quiet`` parameter.

  - **Tips**

    It might be preferred or necessary to blacklist ``nouveau``, when there is a recent Nvidia chip.

    Adding the following parameter to the kernel command line will do this for you.

    ::

       modprobe.blacklist=nouveau

- Generate ``grub.cfg``.

  ::

     grub-mkconfig -o /boot/grub/grub.cfg

- Install GRUB to the pendrive.

  **Notice:** Don't forget ``--removable``.

  ::

     grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable


Perform Some Most Boring Post Installation Tasks
++++++++++++++++++++++++++++++++++++++++++++++++

Configure users
***************

- Set the root password.

  ::

     passwd

- Add a user and grant it administrator privilege.

  ::

     useradd -m -G wheel -s /bin/zsh your_username
     passwd your_username
     nano /etc/sudoers


Cleanup And Reboot
******************

Exit chroot, do some cleanup and reboot.

::

   exit

   umount -R /mnt
   swapoff /dev/vga/swap

   vgchange -an vga

   cryptsetup close root
   cryptsetup close boot

   reboot


Essential Package Check List
****************************

Here is my typical i3 installation.

- base base-devel zsh grml-zsh-config
- grub efibootmgr intel-ucode
- dialog wpa_supplicant
- xorg-server alsa-utils
- lightdm lightdm-gtk-greeter
- i3 dmenu termite tmux adobe-source-code-pro-fonts

- virtualbox virtualbox-guest-iso
- pkgfile macchanger redshift create_ap haveged
- bluez bluez-utils
- htop nethogs
- unzip unrar p7zip
- python-pip python2-pip
- wireshark-qt nmap


Troubleshooting
---------------

``/sbin/sulogin``
+++++++++++++++++

``/sbin/sulogin`` might not be copied into the initramfs,
and therefore you won't be able to get a root shell for maintenance
when something goes wrong.

In that circumstance, you can use the installation medium
to diagnose problems.

See `FS#36265`_,
``[systemd] rd.systemd.unit=emergency.target does not work``.


Caveats
-------

LUKS & SSD TRIM
+++++++++++++++

- Do you recommend LUKS encryption on a SSD (TRIM support)?, https://askubuntu.com/questions/59519/do-you-recommend-luks-encryption-on-a-ssd-trim-support


Don't be fooled by the eventual success of mkinitcpio
+++++++++++++++++++++++++++++++++++++++++++++++++++++

Once upon a time,
a breaking update of ``readline`` from 6 to 7 broke my initcpio images.

``lvm2`` was updated after the ``linux`` kernel,
before whose update ``readline`` had already been updated to version 7
and after that there was an initcpio regeneration process,
where some binaries, including those from the older ``lvm2`` package
since my ``mkinitcpio.conf`` included the ``sd-lvm2`` hook,
and their library dependencies,
which however might no longer exist,
due to the breaking update of ``readline`` from 6 to 7,
as complained by ``mkinitcpio``
but overlooked by a lazy as well as credulous user,
were bundled into the initramfs,
and thus problematic initcpio images were born.
``<-- English Language Proficiency Test?``

Log excerpt is as follows,
`click here <samples/readline.log>`_
for the full transaction log if needed.

::

   [2016-11-15 02:48] [ALPM] transaction started
   ...
   [2016-11-15 02:48] [ALPM] upgraded readline (6.3.008-4 -> 7.0-1)
   ...
   [2016-11-15 02:48] [ALPM] upgraded linux (4.8.6-1 -> 4.8.7-1)
   ...
   [2016-11-15 02:48] [ALPM-SCRIPTLET] >>> Generating initial ramdisk, using mkinitcpio. Please wait...
   ...
   [2016-11-15 02:48] [ALPM-SCRIPTLET] ==> ERROR: binary dependency `libreadline.so.6' not found for `/usr/bin/lvm'
   ...
   [2016-11-15 02:48] [ALPM-SCRIPTLET] ==> Image generation successful
   ...
   [2016-11-15 02:48] [ALPM-SCRIPTLET] ==> ERROR: binary dependency `libreadline.so.6' not found for `/usr/bin/lvm'
   ...
   [2016-11-15 02:48] [ALPM-SCRIPTLET] ==> Image generation successful
   ...
   [2016-11-15 02:48] [ALPM] upgraded lvm2 (2.02.166-1 -> 2.02.167-2)
   ...

Some seemingly innocuous packages would trigger initcpio regeneration
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

E.g., ``device-mapper``.

::

  $ less -FXR /usr/share/libalpm/hooks/99-linux.hook
  [Trigger]
  Type = File
  Operation = Install
  Operation = Upgrade
  Target = boot/vmlinuz-linux
  Target = usr/lib/initcpio/*

  [Action]
  Description = Updating linux initcpios
  When = PostTransaction
  Exec = /usr/bin/mkinitcpio -p linux

  $ pkgfile -l device-mapper | grep -e boot -e initcpio
  core/device-mapper      /usr/lib/initcpio/
  core/device-mapper      /usr/lib/initcpio/udev/
  core/device-mapper      /usr/lib/initcpio/udev/11-dm-initramfs.rules

Still e.g., ``mkinitcpio-busybox`` and ``systemd``, among many others.


Appendices
----------


Example session of encrypting a loop device
+++++++++++++++++++++++++++++++++++++++++++

- Create a file.

  ::

     $ dd if=/dev/urandom of=secret.tomb bs=1M count=10

- Find an idle loop device and setup it with the file.

  ::

     # losetup /dev/loop0 secret.tomb

- Setup encryption.

  ::

     # cryptsetup luksFormat /dev/loop0
     # cryptsetup open /dev/loop0 tomb

- Create a file system and mount it.

  ::

     # mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0,root_owner=1000:1000 /dev/mapper/tomb
     # mkdir /mnt/tomb
     # mount /mnt/mapper/tomb /mnt/tomb

- Add some files.

- Unmount and cleanup.

  ::

     # umount /mnt/tomb
     # cryptsetup close tomb
     # losetup -d /dev/loop0


Readings / Projects Of Interests
++++++++++++++++++++++++++++++++

- Cryptography?

  - You Don't Want XTS, https://sockpuppet.org/blog/2014/04/30/you-dont-want-xts/

- TODO?

  - grub

    - Cryptomount enhancements - revised, http://lists.gnu.org/archive/html/grub-devel/2015-06/msg00109.html
    - Grub Crypt, http://grub.johnlane.ie/

- Others

  - https://tails.boum.org/contribute/design/memory_erasure/

    In order to protect against memory recovery such as cold boot attack, the system RAM is overwritten when Tails is being shutdown or when the boot medium is physically removed.

  - http://www.breaknenter.org/projects/inception/

    Inception is a physical memory manipulation and hacking tool exploiting PCI-based DMA. The tool can attack over FireWire, Thunderbolt, ExpressCard, PC Card and any other PCI/PCIe interfaces.


.. _NoviceLive: https://github.com/NoviceLive
.. _Arch Wiki: https://wiki.archlinux.org/
.. _disk encryption: https://wiki.archlinux.org/index.php/Disk_encryption
.. _dm-crypt: https://wiki.archlinux.org/index.php/Dm-crypt
.. _GNU Free Documentation License: https://gnu.org/licenses/fdl.html

.. _Version 1: https://github.com/NoviceLive/unish/blob/master/doc/arch-install.sh
.. _Version 2: https://github.com/NoviceLive/unish/blob/master/doc/v2-arch-install.rst

.. _Simple Partition Layout with LUKS: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Simple_partition_layout_with_LUKS
.. _LVM on LUKS: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS
.. _on a pendrive: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_.28GRUB.29
.. _using a remote header: https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Encrypted_system_using_a_remote_LUKS_header
.. _dm-crypt/Drive preparation: https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation

.. _Encryption options for LUKS mode: https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encryption_options_for_LUKS_mode
.. _Ciphers and modes of operation: https://wiki.archlinux.org/index.php/Disk_encryption#Ciphers_and_modes_of_operation
.. _serpent: https://en.wikipedia.org/wiki/Serpent_(cipher)
.. _twofish: https://en.wikipedia.org/wiki/Twofish
.. _aes: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
.. _xts: https://en.wikipedia.org/wiki/Disk_encryption_theory#XTS
.. _chain mode: https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation
.. _initialization vector: https://en.wikipedia.org/wiki/Initialization_vector

.. _Installation guide: https://wiki.archlinux.org/index.php/Installation_guide
.. _Beginners' guide: https://wiki.archlinux.org/index.php/Beginners%27_guide

.. _FS#36265: https://bugs.archlinux.org/task/36265
