# Now that we have booted the installation medium,
# we are given a root shell.


# Identify the devices.
lsblk
# Suppose that there are three devices and
# the local hard disk is /dev/sda
# where /, /home and swap will reside,
# /dev/sdb is a removable disk where /boot and /boot/efi will reside,
# and /dev/sdc is the installation medium.


# Securely erase the disks.
# Check twice before you enter!
# This might consumes many hours.
time shred -z /dev/sda
time shred -z /dev/sdb


# Check for UEFI mode.
ls /sys/firmware/efi/efivars/


# No need to change console keymap and font,
# so skip them (in my case).


# Check for the Internet connection.
ping -c4 github.com
# DHCP works like a charm in my case, and skip network configuration.


# Update the system clock.
timedatectl set-ntp true
# Check the status.
timedatectl status


# # # # # # # # # # Interesting Part I Begins # # # # # # # # # #


# Prepare partition for /, /home and swap.
parted /dev/sda
# (parted) p
# (parted) mktable gpt
# (parted) p
# (parted) mkpart primary 0% 100%
# (parted) p
# (parted) set 1 lvm on
# (parted) q

# Prepare partition for /boot and /boot/efi.
parted /dev/sdb
# (parted) p
# (parted) mktable gpt
# (parted) p
# (parted) mkpart esp fat32 1mib 101mib
# (parted) p
# (parted) mkpart primary ext4 101mib 201mib
# (parted) p
# (parted) q

# Setup encryption using LVM on LUKS.
# Setup LUKS.
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 \
           --iter-time 5000 --use-random luksFormat /dev/sda1
cryptsetup open /dev/sda1 lvm
# Setup LVM.
pvcreate /dev/mapper/lvm
vgcreate vg0 /dev/mapper/lvm
lvcreate -L 4G vg0 -n swap
lvcreate -L 96G vg0 -n root
lvcreate -l 100%FREE vg0 -n home
# Create file systems and swap.
mkfs.ext4 /dev/mapper/vg0-root
mkfs.ext4 /dev/mapper/vg0-home
mkswap /dev/mapper/vg0-swap

# Setup encryption on boot partition.
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 \
           --iter-time 5000 --use-random luksFormat /dev/sdb2
cryptsetup open /dev/sdb2 boot
# Create file systems.
mkfs.fat -F32 /dev/sdb1
mkfs.ext4 /dev/mapper/boot

# Mount file systems and activate swap.
mount /dev/mapper/vg0-root /mnt
mkdir /mnt/home
mount /dev/mapper/vg0-home /mnt/home
swapon /dev/mappter/vg0-swap

mkdir /mnt/boot
mount /dev/mappter/boot /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sdb1 /mnt/boot/efi


# # # # # # # # # # Interesting Part I Ends # # # # # # # # # #


# Follow the boring routines until mkinitcpio.

lsblk

# NAME           MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
# sda              8:0    0 465.8G  0 disk
# └─sda1           8:1    0 465.8G  0 part
#   └─vg0        254:0    0 465.8G  0 crypt
#     ├─vg0-swap 254:1    0     4G  0 lvm   [SWAP]
#     ├─vg0-root 254:2    0    96G  0 lvm   /mnt
#     └─vg0-home 254:3    0 365.8G  0 lvm   /mnt/home
# sdb              8:16   0   7.5G  0 disk
# ├─sdb1           8:17   0   100M  0 part  /mnt/boot/efi
# └─sdb2           8:18   0   100M  0 part
#   └─boot       254:4    0    98M  0 crypt /mnt/boot

# Select mirrors.
nano /etc/pacman.d/mirrorlist

# Install base packages.
pacstrap -i /mnt base base-devel

# Generate an fstab file.
genfstab -U /mnt >> /mnt/etc/fstab

# Change root.
arch-chroot /mnt /bin/bash

# Uncomment locales.
nano /etc/locale.gen
# In my case, they are en_US.UTF-8 and zh_CN.UTF-8.

# Generate locales.
locale-gen

# Set locale.
nano /etc/locale.conf
# In my case, add this line.
#
# LANG=en_US.UTF-8

# Since I have not changed console keymap, skip this.
# nano /etc/vconsole.conf

# Determine the time zone.
tzselect
# Set time zone.
# Warning: You may not like Asia/Shanghai (UTC+8).
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# --systohc: set the hardware clock from the current system time.
# --utc: the hardware clock is kept in UTC.
hwclock --systohc --utc


# # # # # # # # # # Interesting Part II Begins # # # # # # # # # #


# Add `encrypt' and `lvm2' before `filesystems' to `HOOKS'.
nano /etc/mkinitcpio.conf

# Generate the initramfs image.
mkinitcpio -p linux

# Install grub and efibootmgr.
pacman -S grub efibootmgr


# Configure for root and boot partition encryption.
#
nano /etc/default/grub
# For root partition encryption,
# tell grub that it needs to pass necessary parameters to the kernel.
#
# Add the following line in GRUB_CMDLINE_LINUX_DEFAULT.
# Remember to replace `<uuid of /dev/sda>' with the UUID of /dev/sda,
# where / resides in our example.
# Warning: You may want to make necessary adaptation.
#
# cryptdevice=UUID=<uuid of /dev/sda>:vg0 root=/dev/mapper/vg0-root"
#
# For boot partition encryption,
# inform grub that it has to decrypt /boot
# before it can read configuration files such as `grub.cfg'
# and load the initramfs.
#
# Add the following line.
#
# GRUB_ENABLE_CRYPTODISK=y

# Install grub to /dev/sdb
# Warning: Do not forget `--removable'
# if your /boot and /boot/efi reside in a removable disk
# as in my case.
grub-install --target=x86_64-efi --efi-directory=/boot/efi \
             --removable --recheck /dev/sdb

# Generate grub.cfg
grub-mkconfig -o /boot/grub/grub.cfg


# Configure for the kernel

# Generate a random key file.
dd if=/dev/urandom bs=1024 count=8 of=/etc/mykeyfile

# Secure it.
chmod 0600 /etc/mykeyfile

# Add it to the encrypted boot partition.
cryptsetup luksAddKey boot /etc/mykeyfile

nano /etc/crypttab
# Add a line.
#
# boot /dev/sdb2 /etc/mykeyfile



# # # # # # # # # # Interesting Part II Ends # # # # # # # # # #


# Follow the boring routines again.


# Configure network.
# DHCP still works like a charm in my case.
# Warning: Replace `enp4s0f2' with your real interface name.
systemctl enable dhcpcd@enp4s0f2.service

# Set hostname.
# I like `localhost' or `bogon',
# which leak no information about myself.
nano /etc/hostname


# Set root password.
passwd


# Create a user for daily use.

# Install Zsh.
pacman -S zsh grml-zsh-config

# I use `toor' which also leaks no information and reminds me
# of the default root password of Kali Linux being `toor'.
useradd -m -G wheel -s /usr/bin/zsh toor

# Allow users in group `wheel' to execute any commands.
# Uncomment the line `%wheel ALL=(ALL) ALL'.
nano /etc/sudoers


# Exit chroot.
exit


# Unmount file systems.
umount -R /mnt

# Remove mapping.
cryptsetup close boot
# This may not succeed as in my case.
cryptsetup close lvm


# Reboot.
reboot
