#!/bin/sh
clear
echo " Bienvenid@s al script de creacion"
sleep 1
echo " de la imagen Ubuntu Xenial para una la arquitectura ARM "
sleep 1
echo " Instalando dependencias"
sleep 3
apt-get update
apt-get install -y gcc-arm-linux-gnueabihf debootstrap qemu-user-static 
echo " Instalación de dependencias completado "
sleep 3
mkdir	  /mnt/ramdisk
mount -t tmpfs none /mnt/ramdisk -o size=4000M 
dd if=/dev/zero of=/mnt/ramdisk/xenial.img bs=1 count=0 seek=3500M
mkfs.ext4 -b 4096 -F /mnt/ramdisk/xenial.img
chmod 777 /mnt/ramdisk/xenial.img
mkdir /xenial
mount -o loop /mnt/ramdisk/xenial.img /xenial
clear
echo "Iniciando proceso deboostrap"
sleep 1
debootstrap --arch=armhf --foreign xenial /xenial
cp /usr/bin/qemu-arm-static /xenial/usr/bin
cp /etc/resolv.conf /xenial/etc
> config.sh
cat <<+ >> config.sh
#!/bin/sh
echo " Configurando debootstrap segunda fase"
sleep 3
/debootstrap/debootstrap --second-stage
export LANG=C
echo "deb http://ports.ubuntu.com/ xenial main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Europe/Berlin" > /etc/timezone
echo "xenial" >> /etc/hostname
echo "127.0.0.1 xenial localhost
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" >> /etc/hosts
echo "auto lo
iface lo inet loopback" >> /etc/network/interfaces
echo "/dev/mmcblk0p1 /	   ext4	    errors=remount-ro,noatime,nodiratime 0 1" >> /etc/fstab
echo "tmpfs    /tmp        tmpfs    nodev,nosuid,mode=1777 0 0" >> /etc/fstab
echo "tmpfs    /var/tmp    tmpfs    defaults    0 0" >> /etc/fstab
sync			
cat <<END > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
END

apt-get update
echo "Reconfigurando parametros locales"
sleep 3
locale-gen es_ES.UTF-8
export LC_ALL="es_ES.UTF-8"
update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata
apt-get upgrade -y
apt-get -f install -y
apt-get install -y ubuntu-desktop xfce4 onboard iw 
adduser xenial
addgroup xenial sudo
exit
+
chmod +x config.sh 
cp config.sh /xenial/home
echo "Montando directorios"
sleep 3
sudo mount -o bind /dev /xenial/dev
sudo mount -o bind /dev/pts /xenial/dev/pts
sudo mount -t sysfs /sys /xenial/sys
sudo mount -t proc /proc /xenial/proc
chroot /xenial /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh && exit 
umount /xenial/{sys,proc,dev/pts,dev}
umount /xenial
cp  /mnt/ramdisk/xenial.img /home/
rm config.sh
exit
