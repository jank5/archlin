# Это скрипт который устанавливает арч линукс.

## В этом скрипте какие то траблы с грабом, когда всё утсановлено и готово, и начинаю ребут, и всегда нет меню граба, вместо этого загрузчик арча от флешки
### Как это фиксить?Шаги:
1. Надо зайти в загрузчик арча
2. Монтировать корневой раздел /mnt
3. Чрутнутся
4. Монтировать раздел биос
5. grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
6. grub-mkconfig -o /boot/grub/grub.cfg
7. Настроить файл /etc/fstab
8. Чтобы узнать про UUID надо в терминале писать blkid
- Если там нету строки про раздел бут, то надо добавить эту строку
#/dev/sda
UUID=XXXX-XXXX /boot vfat rw,relatime,defaults 0 1
9. Выйти из чрут
10. Ребут и готово
