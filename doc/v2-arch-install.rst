Full-Disk Encrypted Arch Installation Version 2
===============================================


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

Again, now that we have booted the installation medium,
we are given a root shell.


Securely Erase Your Disks
+++++++++++++++++++++++++

Identify block devices with ``lsblk``.

Suppose that we are going to install Arch on ``/dev/sdX``,
and the boot partition on ``/dev/sdY``.
We'll want to wipe them to prevent unintended data recovery,
as suggested by `dm-crypt/Drive preparation`_.

Note that this might consume several hours.
See ``shred --help`` for more details.

::

   lsblk
   time shred /dev/sdX &
   time shred /dev/sdY


Perform Some Boring Routines
++++++++++++++++++++++++++++

See the `Installation guide`_ or `Beginners' guide`_
for more details.

- Check the UEFI mode.

- Load necessary key maps.

- Set console fonts if needed.

- Check or configure the network.

- Update the system clock.

::

   ls /sys/firmware/efi/efivars

   # loadkeys skipped
   # setfont skipped

   # network configuration skipped
   ping -c4 google.com

   timedatectl status
   timedatectl set-ntp true
   timedatectl status


Prepare Partitions a.k.a Interesting Part I
+++++++++++++++++++++++++++++++++++++++++++

Choose algorithms
*****************

Running benckmarks may help you choose the algorithms.

Also, see `Encryption options for LUKS mode`_ for more information.


I take ``serpent-xts-plain64`` and ``whirlpool`` for example.

::

   cryptsetup benchmark


Prepare Root
************

**Warning: Don't do partition!**

Setup LUKS using a remote header.

::

   truncate -s 2M root.header

   cryptsetup --header root.header \
   --cipher serpent-xts-plain64 --key-size 512 \
   --hash whirlpool --iter-time 5000 --use-random \
   luksFormat /dev/sdX

   cryptsetup --header root.header open /dev/sdX root

Setup LVM in the encrypted container.

Note that you will want to make preferred adaptation.

::

   pvcreate /dev/mapper/root
   vgcreate vga /dev/mapper/root
   lvcreate -n swap -L 4G vga
   lvcreate -n root -L 96G vga
   lvcreate -n home -l 100%FREE vga

Create the swap and file systems.

::

   mkswap /dev/vga/swap
   mkfs.ext4 /dev/vga/root
   mkfs.ext4 /dev/vga/home


Prepare Boot
************

Prepare partition and setup LUKS.

Feel free to use your own preferences.

In the following example, ``/boot/efi`` will get 56 MiB,
and ``/boot`` 200 MiB.

::

   lsblk
   parted /dev/sdY
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
   luksFormat /dev/sdY2
   cryptsetup open /dev/sdY2 boot
   mkfs.fat -F32 /dev/sdY1
   mkfs.ext4 /dev/mapper/boot

Activate The Swap And Mount File Systems
****************************************

Also, move the header into boot,
we will configure ``mkinitcpio`` to copy the header into the initramfs.

::

   swapon /dev/vga/swap
   mount /dev/vga/root /mnt
   mkdir /mnt/{home,boot}
   mount /dev/vga/home /mnt/home
   mount /dev/mapper/boot /mnt/boot
   mkdir /mnt/boo/efi
   mount /dev/sdY1 /mnt/boot/efi

   mv root.header /mnt/boot


Follow Some More Boring Routines
++++++++++++++++++++++++++++++++

Perform System Installation
***************************

- Choose nearby mirrors.

  They are essential to an enhanced download experience.

- Install the base system.

- Generate ``fstab`` and check it.

- Change root.

::

   nano /etc/pacman.d/mirrorlist

   pacstrap -i /mnt base base-devel zsh grml-zsh-config

   genfstab -U /mnt >> /mnt/etc/fstab
   nano /mnt/etc/fstab

   arch-chroot /mnt /bin/zsh


Configure Some Boring Stuff For The Freshly Installed System
************************************************************

- Choose locales and generate them.

- Set the locale, which shall be the first chosen entry.

- Select and set the time zone.

- Set or update the hardware clock.

- Again, check or configure the network.

- Set the hostname and add it to ``/etc/hosts``.

::

   nano /etc/loacle.gen
   locale-gen
   nano /etc/locale.conf

   # /etc/vconsole.conf configuration skipped

   tzselect
   ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

   hwclock --systohc --utc

   # network configuraion skipped
   # ping -c4 github.com

   nano /etc/hostname
   nano /etc/hosts


Configure For Disk-Encryption a.k.a Interesting Part II
+++++++++++++++++++++++++++++++++++++++++++++++++++++++

Configure The Kernel
********************

Create ``/etc/crypttab.initramfs``,
and in our example, add the following line.

::

   vga /dev/sdX none header=/boot/root.header

Edit ``/etc/mkinitcpio.conf``, add the header to ``FILES``.

::

   FILES="/boot/root.header"

As a result, the header will be copied into the initramfs.

As for ``HOOKS``, replace ``udev`` with ``systemd``,
and add ``sd-encrypt`` and ``sd-lvm2`` between ``block`` and ``filesystems``.

In my example, it reads.

::

   HOOKS="base systemd autodetect modconf block sd-encrypt sd-lvm2 filesystems keyboard fsck"

Generate initramfs.

::

   nano /etc/crypttab.initramfs

   nano /etc/mkinitcpio.conf

   mkinitcpio -p linux


Install And Configure GRUB
**************************

- Install GRUB and efibootmgr.

- Edit the GRUB ``default`` file, add the line,
  ``GRUB_ENABLE_CRYPTODISK=y``,
  and add necessary kernel parameters.

  In this example, it looks like.

  ::

     GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=/dev/sdX:root:header"

  Note that ``root`` is the mapped name of our encrypted container.

  Also, I removed the ``quiet`` parameter.

- Generate ``grub.cfg``.

- Install GRUB to the pendrive.

::

   pacman -S grub efibootmgr
   nano /etc/default/grub
   grub-mkconfig -o /boot/grub/grub.cfg
   grub-install --target=x86_64-efi --efi-directory=/boot/efi --recheck --removable


Perform Some Most Boring Post Installation Tasks
++++++++++++++++++++++++++++++++++++++++++++++++

Configure users
***************

- Set the root password.

- Add a normal user.

::

   passwd

   useradd -m -G wheel -s /bin/zsh toor
   passwd toor
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


.. _Version 1: https://github.com/NoviceLive/unish/blob/master/doc/arch-install.sh
.. _Version 2: https://github.com/NoviceLive/unish/blob/master/doc/v2-arch-install.rst

.. _Simple Partition Layout with LUKS: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Simple_partition_layout_with_LUKS
.. _LVM on LUKS: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS
.. _on a pendrive: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_.28GRUB.29
.. _using a remote header: https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Encrypted_system_using_a_remote_LUKS_header
.. _dm-crypt/Drive preparation: https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation

.. _Encryption options for LUKS mode: https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encryption_options_for_LUKS_mode
.. _Installation guide: https://wiki.archlinux.org/index.php/Installation_guide
.. _Beginners' guide: https://wiki.archlinux.org/index.php/Beginners%27_guide
