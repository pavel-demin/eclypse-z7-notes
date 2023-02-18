alpine_url=http://dl-cdn.alpinelinux.org/alpine/v3.14

uboot_tar=alpine-uboot-3.14.2-armv7.tar.gz
uboot_url=$alpine_url/releases/armv7/$uboot_tar

tools_tar=apk-tools-static-2.12.7-r0.apk
tools_url=$alpine_url/main/armv7/$tools_tar

firmware_tar=linux-firmware-other-20210716-r0.apk
firmware_url=$alpine_url/main/armv7/$firmware_tar

linux_dir=tmp/linux-5.10
linux_ver=5.10.107-xilinx

modules_dir=alpine-modloop/lib/modules/$linux_ver

passwd=changeme

test -f $uboot_tar || curl -L $uboot_url -o $uboot_tar
test -f $tools_tar || curl -L $tools_url -o $tools_tar

test -f $firmware_tar || curl -L $firmware_url -o $firmware_tar

for tar in linux-firmware-ath9k_htc-20210716-r0.apk linux-firmware-brcm-20210716-r0.apk linux-firmware-cypress-20210716-r0.apk linux-firmware-rtlwifi-20210716-r0.apk
do
  url=$alpine_url/main/armv7/$tar
  test -f $tar || curl -L $url -o $tar
done

mkdir alpine-uboot
tar -zxf $uboot_tar --directory=alpine-uboot

mkdir alpine-apk
tar -zxf $tools_tar --directory=alpine-apk --warning=no-unknown-keyword

mkdir alpine-initramfs
cd alpine-initramfs

gzip -dc ../alpine-uboot/boot/initramfs-lts | cpio -id
rm -rf etc/modprobe.d
rm -rf lib/firmware
rm -rf lib/modules
rm -rf var
find . | sort | cpio --quiet -o -H newc | gzip -9 > ../initrd.gz

cd ..

mkimage -A arm -T ramdisk -C gzip -d initrd.gz uInitrd

mkdir -p $modules_dir/kernel

find $linux_dir -name \*.ko -printf '%P\0' | tar --directory=$linux_dir --owner=0 --group=0 --null --files-from=- -zcf - | tar -zxf - --directory=$modules_dir/kernel

cp $linux_dir/modules.order $linux_dir/modules.builtin $modules_dir/

depmod -a -b alpine-modloop $linux_ver

tar -zxf $firmware_tar --directory=alpine-modloop/lib/modules --warning=no-unknown-keyword --strip-components=1 --wildcards lib/firmware/ar* lib/firmware/rt*

for tar in linux-firmware-ath9k_htc-20210716-r0.apk linux-firmware-brcm-20210716-r0.apk linux-firmware-cypress-20210716-r0.apk linux-firmware-rtlwifi-20210716-r0.apk
do
  tar -zxf $tar --directory=alpine-modloop/lib/modules --warning=no-unknown-keyword --strip-components=1
done

mksquashfs alpine-modloop/lib modloop -b 1048576 -comp xz -Xdict-size 100%

rm -rf alpine-uboot alpine-initramfs initrd.gz alpine-modloop

root_dir=alpine-root

mkdir -p $root_dir/usr/bin
cp /usr/bin/qemu-arm-static $root_dir/usr/bin/

mkdir -p $root_dir/etc
cp /etc/resolv.conf $root_dir/etc/

mkdir -p $root_dir/etc/apk
mkdir -p $root_dir/media/mmcblk0p1/cache
ln -s /media/mmcblk0p1/cache $root_dir/etc/apk/cache

cp -r alpine/etc $root_dir/
cp -r alpine/apps $root_dir/media/mmcblk0p1/

for project in led_blinker sdr_receiver_hpsdr sdr_receiver_wide sdr_transceiver
do
  mkdir -p $root_dir/media/mmcblk0p1/apps/$project
  cp -r projects/$project/server/* $root_dir/media/mmcblk0p1/apps/$project/
  cp -r projects/$project/app/* $root_dir/media/mmcblk0p1/apps/$project/
  cp tmp/$project.bit $root_dir/media/mmcblk0p1/apps/$project/
done

cp -r alpine-apk/sbin $root_dir/

chroot $root_dir /sbin/apk.static --repository $alpine_url/main --update-cache --allow-untrusted --initdb add alpine-base

echo $alpine_url/main > $root_dir/etc/apk/repositories
echo $alpine_url/community >> $root_dir/etc/apk/repositories

chroot $root_dir /bin/sh <<- EOF_CHROOT

apk update
apk add openssh ucspi-tcp6 iw wpa_supplicant dhcpcd dnsmasq hostapd iptables avahi dbus dcron chrony gpsd libgfortran musl-dev libconfig-dev alsa-lib-dev alsa-utils curl wget less nano bc dos2unix cifs-utils nfs-utils ntfs-3g

rc-update add bootmisc boot
rc-update add hostname boot
rc-update add hwdrivers boot
rc-update add modloop boot
rc-update add swclock boot
rc-update add sysctl boot
rc-update add syslog boot
rc-update add urandom boot

rc-update add killprocs shutdown
rc-update add mount-ro shutdown
rc-update add savecache shutdown

rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add mdev sysinit

rc-update add avahi-daemon default
rc-update add chronyd default
rc-update add dhcpcd default
rc-update add local default
rc-update add dcron default
rc-update add sshd default
rc-update add nfsmount default

mkdir -p etc/runlevels/wifi
rc-update -s add default wifi

rc-update add iptables wifi
rc-update add dnsmasq wifi
rc-update add hostapd wifi

sed -i 's/^SAVE_ON_STOP=.*/SAVE_ON_STOP="no"/;s/^IPFORWARD=.*/IPFORWARD="yes"/' etc/conf.d/iptables

sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' etc/ssh/sshd_config

echo root:$passwd | chpasswd

setup-hostname eclypse-z7
hostname eclypse-z7

sed -i 's/^# LBU_MEDIA=.*/LBU_MEDIA=mmcblk0p1/' etc/lbu/lbu.conf

cat <<- EOF_CAT > root/.profile
alias rw='mount -o rw,remount /media/mmcblk0p1'
alias ro='mount -o ro,remount /media/mmcblk0p1'
EOF_CAT

ln -s /media/mmcblk0p1/apps root/apps
ln -s /media/mmcblk0p1/wifi root/wifi

lbu add root
lbu delete etc/resolv.conf
lbu delete root/.ash_history

lbu commit -d

apk add patch make gcc gfortran linux-headers

for project in led_blinker server sdr_receiver_hpsdr sdr_receiver_wide sdr_transceiver
do
  make -C /media/mmcblk0p1/apps/\$project clean
  make -C /media/mmcblk0p1/apps/\$project
done

dpmutil_dir=/media/mmcblk0p1/apps/dpmutil
dpmutil_tar=/media/mmcblk0p1/apps/dpmutil.tar.gz
dpmutil_url=https://github.com/pavel-demin/dpmutil/archive/master.tar.gz

curl -L \$dpmutil_url -o \$dpmutil_tar
mkdir -p \$dpmutil_dir
tar -zxf \$dpmutil_tar --strip-components=1 --directory=\$dpmutil_dir
rm \$dpmutil_tar
make -C \$dpmutil_dir

EOF_CHROOT

cp -r $root_dir/media/mmcblk0p1/apps .
cp -r $root_dir/media/mmcblk0p1/cache .
cp $root_dir/media/mmcblk0p1/eclypse-z7.apkovl.tar.gz .

cp -r alpine/wifi .

hostname -F /etc/hostname

rm -rf $root_dir alpine-apk

zip -r eclypse-z7-alpine-3.14-armv7-`date +%Y%m%d`.zip apps boot.bin cache devicetree.dtb modloop eclypse-z7.apkovl.tar.gz uEnv.txt uImage uInitrd wifi

rm -rf apps cache modloop eclypse-z7.apkovl.tar.gz uInitrd wifi
