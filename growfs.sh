

swapoff --all

vi /etc/fstab

vi /etc/initramfs-tools/conf.d/resume

fdisk /dev/sda
d
w

sudo growpart /dev/sda 1
resize2fs /dev/sda1


update-initramfs -u -k all
update-grub



