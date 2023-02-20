#! /bin/sh

apps_dir=/media/mmcblk0p1/apps

source $apps_dir/stop.sh

cat $apps_dir/sdr_receiver_hpsdr/sdr_receiver_hpsdr.bit > /dev/xdevcfg

$apps_dir/sdr_receiver_hpsdr/setup

address=`awk -F : '$5="FF"' OFS=: /sys/class/net/eth0/address`

echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
echo 2 > /proc/sys/net/ipv4/conf/all/rp_filter

ip link add mvl0 link eth0 address $address type macvlan mode passthru

$apps_dir/sdr_receiver_hpsdr/sdr-receiver-hpsdr eth0 1 1 1 1 1 1 1 1 &
$apps_dir/sdr_receiver_hpsdr/sdr-receiver-hpsdr mvl0 1 1 1 1 1 1 1 1 &
