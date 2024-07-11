# == MY ARCH SETUP INSTALLER == #
#part1
printf '\033c'
echo "Welcome to zemo's :D arch installer script"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Enter the drive: "
read drive
cfdisk $drive 
echo "Enter the linux partition /: "
read partition
mkfs.ext4 $partition 
read -p "Did you also create efi partition? [y/n]" answer
if [[ $answer = y ]] ; then
  lsblk
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
  mkdir /mnt/boot
  mount $efipartition /mnt/boot
fi
read -p "Did you also create swap partition? [y/n] " ans
if [[ $ans = y ]] ; then
  lsblk
  echo "Enter swap partition: "
  read swapn
  mkswap $swapn
  swapon $swapn
fi
mount $partition /mnt 
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
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
echo "Which bootloader you want use?(refind or grub)"
read bootl
if [[ $bootl == 'refind' ]]; then
  echo "We will install refind"
  pacman --noconfirm -S refind gdisk
  refind-install
elif [[ $bootl == 'grub' ]]; then
  pacman --noconfirm -S grub efibootmgr os-prober
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
  grub-mkconfig -o /boot/grub/grub.cfg
fi
pacman -S --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight xorg-xprop xorg\
     noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
     sxiv mpv zathura zathura-pdf-mupdf ffmpeg imagemagick  \
     man-db xwallpaper python-pywal unclutter xclip maim \
     zip unzip unrar p7zip xdotool brightnessctl  \
     ntfs-3g git sxhkd zsh pulseaudio pavucontrol \
     firefox dash kitty chromium\
     picom libnotify dunst slock jq aria2 cowsay \
     dhcpcd opendoas vim networkmanager wpa_supplicant rsync pamixer mpd ncmpcpp \
     xdg-user-dirs libconfig neofetch \
     bluez bluez-utils curl wget

echo "You have GPU nvidia?[y/n] "
read gpu
if [[ $gpu == 'y' ]] ; then
  echo "We will install nvidia"
  pacman --noconfirm -S nvidia
fi
echo "Which DE/WM you want install?(xfce4)"
read WM
if [[ $WM == 'xfce4' ]] ; then
  pacman --noconfirm -S xfce4 xfce4-goodies
fi
systemctl enable dhcpcd.service 
systemctl enable NetworkManager.service 
echo "permit persist :wheel" > /etc/doas.conf
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/zsh $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit 

#part3
printf '\033c'
cd $HOME
xdg-user-dirs-update
echo "Which DE/WM you will use?(xfce4,dwm)"
read DE
if [[ $DE == 'xfce4' ]] ; then
  echo "#!/bin/bash" > $HOME/.xinitrc
  echo "setxkbmap -model pc105 -option grp:alt_shift_toggle -layout us,ru" > $HOME/.xinitrc
  echo "exec startxfce4" >> $HOME/.xinitrc
elif [[ $DE == 'dwm' ]] ; then
  > $HOME/.xinitrc
  echo "#!/bin/bash" > $HOME/.xinitrc
  echo "setxkbmap -model pc105 -option grp:alt_shift_toggle -layout us,ru" > $HOME/.xinitrc
  echo "slstatus" >> $HOME/.xinitrc
  echo "exec dwm" >> $HOME/.xinitrc
fi
echo "We will setting startx"
> $HOME/.zprofile
echo '#!/bin/bash' > $HOME/.zprofile
echo '[[ $(fgconsole 2>/dev/null) == 1 ]] && exec startx --vt1' >> $HOME/.zprofile
echo "Now we will set default shell zsh"
chsh -s $(which zsh)
echo "Now we will install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
exit
