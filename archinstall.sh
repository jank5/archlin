#!/usr/bin/env sh

#part1
printf '\033c'
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true

# create partition
echo "Enter EFI partition(example: /dev/sda1 or /dev/nvme0n1p1)"
read EFI
echo "Enter Root(/) partition(example: /dev/sda3 or /dev/nvme0n1p3)"
read ROOT
echo "READ swap partition(example: /dev/sda2 or /dev/nvme0n1p2)"
read SWAP
echo -e "\nCreating FIlesystems...\n"
mkfs.ext4 "$ROOT"
mount "$ROOT" /mnt
mkfs.vfat -F32 "$EFI"
mkdir -p /mnt/boot/efi
mount "$EFI" /mnt/boot/efi
echo "Will swap?[y/n]"
read ans
if [[ $ans = y ]]; then
    mkswap "$SWAP"
    swapon "$SWAP"
fi

# preparation to chroot
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

# set locale,timezone, user and hostname
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "Hostname: "
read hostname
echo "Username: "
read user
echo "$hostname" > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

mkinitcpio -P
passwd
useradd -m "$user"
usermod -aG wheel,storage,audio,video "$user"
passwd "$user"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# grub boot
pacman --noconfirm -S grub efibootmgr
mkdir /boot/efi
mount "$EFI" /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# edit fstab
printf '/033c'
cat /etc/fstab
echo "We will edit file /etc/fstab boot partition UUID[y/n]"
read edit
if [[ $edit == 'y' ]]; then
  blkid
  echo "You remembered?[y/n]"
  read ready
  if [[ $ready == 'y' ]]; then
    echo "Write UUID"
    read wruuid
    echo "UUID=$wruuid    /boot    vfat    rw,relatime,defaults 0 1" >> /etc/fstab
  fi
  cat /etc/fstab
  sleep 5
fi


pacman -S --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight xorg-xprop \
     noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
     sxiv mpv imagemagick  \
     fzf man-db xwallpaper unclutter xclip maim \
     zip unzip unrar p7zip xdotool papirus-icon-theme brightnessctl  \
     dosfstools ntfs-3g git sxhkd zsh pipewire pipewire-pulse \
     emacs-nox arc-gtk-theme rsync qutebrowser dash \
     xcompmgr libnotify dunst slock jq aria2 cowsay \
     dhcpcd connman wpa_supplicant pamixer mpd ncmpcpp \
     xdg-user-dirs libconfig telegram-desktop firefox\
     bluez bluez-utils curl wget networkmanager opendoas rofi polybar\
     nitrogen dunst arandr picom feh syncthing

echo "We will install drivers for GPU and CPU"
pacman --noconfirm -S nvidia intel-ucode
systemctl enable dhcpcd.service
systemctl enable NetworkManager.service

echo "permit persist :wheel" > /etc/doas.conf
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$user/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $user:$user $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $user
exit

#part3
printf '\033c'
cd $HOME
xdg-user-dirs-update
git clone https://github.com/jank5/wallpapers.git ~/Pictures

wget -P $HOME/ https://raw.githubusercontent.com/jank5/wallpapers/refs/heads/main/.xinitrc

mkdir $HOME/.config/suckless

git clone https://github.com/jank5/dwm.git $HOME/.config/suckless/dwm
make -C $HOME/.config/suckless/dwm install

echo "We'll setting zprofile"
touch $HOME/.zprofile
echo '#!/bin/bash' > $HOME/.zprofile
echo '[[ $(fgconsole 2>/dev/null) == 1 ]] && exec startx --vt1' >> $HOME/.zprofile
echo "Now we will set default shell zsh"
chsh -s $(which zsh)
echo "Now we will install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
exit
