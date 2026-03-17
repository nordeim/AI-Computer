#!/bin/bash
#
#telinit 1
#exit 0

rm /etc/xdg/plasma-workspace/env/nx-sourceenv.sh

#mv /opt/brave.com /opt/brave.com.1
#ln -sf /Home1/brave.com /opt/brave.com
sed -i 's/^ConditionPathExists=/#ConditionPathExists=/' /usr/lib/systemd/system/apparmor.service

systemctl stop postgresql
mv /etc/postgresql /etc/postgresql.1
ln -sf /Home1/etc/postgresql /etc/postgresql
mv /var/lib/postgresql /var/lib/postgresql.1
ln -sf /Home1/postgresql /var/lib/postgresql

systemctl stop mysql
chown -R mysql:mysql /var/log/mysql
chown -R mysql:mysql /var/lib/mysql
chmod -R o-rwx /var/lib/mysql
chmod -R o-rwx /var/log/mysql
#systemctl restart mysql

#ls -L /var/lib/docker
ls -d /rofs/var/lib/docker/overlay2
#ls -d /var/lib/docker/containers

if [ $? -ne 0 ] ; then

  systemctl stop containerd
  systemctl stop docker.socket
  systemctl stop docker
  rm -rf /var/lib/docker
  ln -sf /Home1/docker /var/lib/docker

fi

#mv /usr/share/code /usr/share/code.1
###ln -sf /Home1/code /usr/share/code

systemctl daemon-reload
systemctl restart apparmor
systemctl restart containerd
systemctl restart docker.socket
systemctl restart docker

# /home/node.sh
exit 0

ln -sf /Home1/kiro /usr/share/kiro
ln -sf /Home1/kiro/bin/kiro /usr/bin/kiro
ls -L /usr/share/code || mv /usr/share/code /usr/share/code.1
ln -sf /Home1/code /usr/share/code

mv /usr/share/cursor /usr/share/cursor.1
ln -sf /Home1/cursor/usr/share/cursor /usr/share/cursor
ln -sf /Home1/cursor/usr/share/cursor/cursor /usr/bin/cursor

#/cdrom/home/start_ollama.sh

mv /opt/google /opt/google.1
ln -sf /Home1/google /opt/google
mv /opt/microsoft /opt/microsoft.1
ln -sf /Home1/microsoft /opt/microsoft
mv /opt/brave.com /opt/brave.com.1
ln -sf /Home1/brave.com /opt/brave.com

ls -L /etc/apt || mv /etc/apt /etc/apt.1
ln -sf /Home1/neon/to/etc/apt /etc/apt
mv /etc/dpkg /etc/dpkg.1
ln -sf /Home1/neon/to/etc/dpkg /etc/dpkg
mv /var/cache/apt /var/cache/apt.1
ln -sf /Home1/neon/to/var/cache/apt /var/cache/apt
mv /var/lib/apt /var/lib/apt.1
ln -sf /Home1/neon/to/var/lib/apt /var/lib/apt
mv /var/lib/dpkg /var/lib/dpkg.1
ln -sf /Home1/neon/to/var/lib/dpkg /var/lib/dpkg
systemctl stop bluetooth ; rmmod btusb
systemctl stop bluetooth && mv /var/lib/bluetooth /var/lib/bluetooth.1 && ln -sf /Home1/neon/to/var/lib/bluetooth /var/lib/bluetooth
modprobe btusb
systemctl restart bluetooth 
bluetoothctl power on ; bluetoothctl scan on ; bluetoothctl devices ; bluetoothctl pair 41:42:90:32:6A:7B ; bluetoothctl trust 41:42:90:32:6A:7B ; bluetoothctl connect 41:42:90:32:6A:7B ; bluetoothctl pair A1:AC:07:71:42:59 ; bluetoothctl trust A1:AC:07:71:42:59 ; bluetoothctl connect A1:AC:07:71:42:59

exit 0
echo "===================================================="

# kiro -> /usr/share/kiro/bin/kiro
# cursor -> /Home1/cursor/usr/share/cursor/cursor
# windsurf -> /usr/share/windsurf/bin/windsurf

echo "===================================================="
systemctl stop nordvpnd
ls /var/lib/nordvpn/data__ && rm -rf /var/lib/nordvpn/data__
[ -L /var/lib/nordvpn/data ] || mv /var/lib/nordvpn/data /var/lib/nordvpn/data__ && ln -sf /home/nordvpn/var_lib_nordvpn/data /var/lib/nordvpn/data
systemctl start nordvpnd
systemctl status nordvpnd

bluetoothctl info 41:42:90:32:6A:7B | grep 'Paired: yes' 
if [ $? -ne 0 ] ; then
   [ -f /home/connect_bluetooth.sh ] && sh /home/connect_bluetooth.sh > /run/log/connect_bluetooth.sh.log
fi

#if [ -f /cdrom/home/ethernet_connect.sh ] ; then
#
#   sh /cdrom/home/ethernet_connect.sh
#
#else
#   
#   systemctl stop wifi_connect
#   
#   if [ $? -eq 0 ] ; then
#     systemctl stop NetworkManager
#     systemctl start NetworkManager
#   fi
#   
#   nmcli device status | egrep 'eth0|enp3s0|eno1'
#   
#   if [ $? -ne 0 ] ; then
#   
#     ip addr | grep eth0
#     if [ $? -eq 0 ] ; then
#       nmcli connection add type ethernet ifname eth0 con-name "eth0-connection" ipv4.method auto
#       nmcli connection up "eth0-connection"
#     fi
#   
#     ip addr | grep enp3s0
#     if [ $? -eq 0 ] ; then
#       nmcli connection add type ethernet ifname enp3s0 con-name "enp3s0-connection" ipv4.method auto
#       nmcli connection up "enp3s0-connection"
#     fi
#   
#     ip addr | grep eno1
#     if [ $? -eq 0 ] ; then
#       nmcli connection add type ethernet ifname eno1 con-name "eno1-connection" ipv4.method auto
#       nmcli connection up "eno1-connection"
#     fi
#   
#   fi
#   
#fi

#mv /usr/sbin/telinit /usr/sbin/telinit.1

lsblk -f | grep '\/Home1'

if [ $? -eq 0 ] ; then

  echo "/Home1 already mounted" >> /run/log/casper-md5check.sh.log

elif [ -L /dev/disk/by-label/Home1 ] ; then

   mkdir /Home1 
   fsck.ext4 -p /dev/disk/by-label/Home1
#   mount -t ext4 /dev/disk/by-label/Home1 /Home1
   lsblk -f

fi

swapon -L SWAP1
swapon -L SWAP2
#cd /usr/lib/modules
#ls -l
#[ -d 6.10.10-1-liquorix-amd64 ] || ln -sf /home/6.10.10-1-liquorix-amd64 .
#ls -l
date >> /run/log/casper-md5check.sh.log
#
#cd  /opt
#rm -rf /opt/libreoffice24.8
#rm -rf /opt/google 
#rm -rf /opt/firefox
#[ -d /opt/microsoft ] && rm -rf /opt/microsoft
#[ -L /opt/microsoft ] || ln -sf /home/microsoft /opt/microsoft
#rm -rf /opt/brave.com 
#ln -sf /home/microsoft .
#ln -sf /home/google .
#ln -sf /home/firefox .
#ln -sf /home/kingsoft .
#ln -sf /home/brave.com .
#ln -sf /home/libreoffice24.8 /opt/libreoffice24.8
#ln -sf /home/gcc-13 /opt/gcc-13
#mv /usr/lib/modules/`uname -r`/misc /usr/lib/modules/`uname -r`/misc.1
#ln -sf /home/modules/`uname -r`/misc /usr/lib/modules/`uname -r`/misc
#
#
rm /usr/local/lib/libm.so.6
#ldconfig -v
#rm /usr/local/lib/libm.so.6
#systemctl enable nordvpnd.service
#rm /usr/local/lib/libm.so.6
#usermod -aG nordvpn pete
#systemctl restart nordvpnd.service
#systemctl status nordvpnd.service
#rm /usr/local/lib/libm.so.6
#
#modprobe 8192eu
#modprobe vboxdrv
#rm /usr/local/lib/libm.so.6
#
sync
sync
#ls -l /opt
##ip addr show enp3s0 | grep '192.168' || dhclient enp3s0
#[ -f /cdrom/home/etc_xdg_xfce4.tgz ] && tar -xf /cdrom/home/etc_xdg_xfce4.tgz -C /
#if [ -f /home/xfce_defaults_perchannel.tgz ] ; then
#   tar -xvf /home/xfce_defaults_perchannel.tgz -C /
#elif [ -f /cdrom/home/xfce_defaults_perchannel.tgz ] ; then
#   tar -xvf /cdrom/home/xfce_defaults_perchannel.tgz -C /
#fi
#[ -f /cdrom/home/xfce4-panel.xml ] && cp /cdrom/home/xfce4-panel.xml /home/pete/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml && chown pete:pete /home/pete/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml 
#ls -l /home/pete/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
#[ -f /home/pete/xfce4-panel.xml ] && cp /home/pete/xfce4-panel.xml /home/pete/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
##ls -l /home/pete/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
#apt remove xfce4-power-manager light-locker xfce4-power-manager-data -y
#apt install /cdrom/home/patch/*deb -y
lsblk -f | grep '\/home' >> /run/log/casper-md5check.sh.log
#if [ $? -eq 0 ] ; then
#   ( telinit 3 ; telinit 5 ) &
#fi
#sed -i 's|agetty --autologin \$LIVE_USERNAME --noclear %I|agetty --autologin pete --noclear %I linux|' /etc/systemd/system/getty@tty?.service.d/override.conf
#systemctl daemon-reload
#systemctl restart getty@tty1.service getty@tty2.service getty@tty3.service getty@tty4.service getty@tty5.service getty@tty6.service
#systemctl stop bluetooth
#tar -xvf /home/bluetooth_devices.tgz -C /
#systemctl start bluetooth
#systemctl status bluetooth
ping -c 2 192.168.2.1 || systemctl restart NetworkManager
#unzstd /lib/firmware/rtl_bt/rtl8761bu*zst
#tar -zxvf /home/pete/bluetooth_var-lib.tgz  -C /var/lib/bluetooth
#ln -sf /home/modules/`uname -r`/updates /usr/lib/modules/`uname -r`/updates
#tar -xvf /home/modules/dkms_installed_2024-10-09.tgz -C /
#depmod -a
#ln -sf /home/gcc-13/bin/gcc /usr/bin/gcc-13
#ln -sf /home/gcc-13/bin/gcc /usr/bin/x86_64-linux-gnu-gcc-13
#mv /var/lib/dkms /var/lib/dkms.1
#ln -sf /home/modules/dkms /var/lib/dkms
#mv /usr/src/rtl8192eu-1.0 /usr/src/rtl8192eu-1.0_
#ln -sf /home/modules/src/rtl8192eu-1.0 /usr/src/rtl8192eu-1.0
# tar -xvf /home/pete/virtualbox-7.0.20_installed_backup.tgz etc usr/lib usr/bin usr/sbin usr/local usr/share -C /
