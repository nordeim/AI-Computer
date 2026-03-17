#!/bin/bash

systemctl stop nordvpnd
rm -rf /var/lib/nordvpn/data__
[ -L /var/lib/nordvpn/data ] || mv /var/lib/nordvpn/data /var/lib/nordvpn/data__ && ln -sf /home/nordvpn/var_lib_nordvpn/data /var/lib/nordvpn/data

#tar -tvf /home/oracular-root-patch.tgz | grep 'var\/lib\/bluetooth' && tar -xvf /home/oracular-root-patch.tgz -C /home/pete/Videos var/lib/bluetooth

if [ -d /home/nordvpn/var_lib_nordvpn/data ] ; then

  tar -xvf /home/giga-orcular-root-patch.tgz | grep 'var\/lib\/bluetooth' && tar -xvf /home/giga-orcular-root-patch.tgz -C / var/lib/bluetooth etc/bluetooth/main.conf etc/netplan etc/NetworkManager/NetworkManager.conf etc/hosts etc/hostname etc/live/config.conf 

else

  tar -xvf /home/giga-orcular-root-patch.tgz | grep 'var\/lib\/bluetooth' && tar -xvf /home/giga-orcular-root-patch.tgz -C / var/lib/bluetooth etc/bluetooth/main.conf etc/netplan etc/NetworkManager/NetworkManager.conf etc/hosts etc/hostname etc/live/config.conf home/nordvpn/var_lib_nordvpn/data

fi

[ -f /home/giga-oracular-root-patch.tgz ] && systemctl restart bluetooth
[ -f /home/giga-oracular-root-patch.tgz ] && systemctl restart NetworkManager

[ -L /var/lib/nordvpn/data ] || ln -sf /home/nordvpn/var_lib_nordvpn/data /var/lib/nordvpn/data
systemctl start nordvpnd

lsmod | grep ^btusb && rmmod btusb && modprobe btusb

bluetoothctl power on
bluetoothctl scan on
bluetoothctl devices

# # bluetoothctl devices
# Device 41:42:90:32:6A:7B JX-BT
# Device A1:AC:07:71:42:59 XY-ABT

bluetoothctl pair 41:42:90:32:6A:7B
bluetoothctl trust 41:42:90:32:6A:7B
bluetoothctl connect 41:42:90:32:6A:7B

bluetoothctl pair A1:AC:07:71:42:59
bluetoothctl trust A1:AC:07:71:42:59
bluetoothctl connect A1:AC:07:71:42:59

exit 0

mybtdev=`bluetoothctl devices | egrep 'JQ-BT|JX-BT|XY-ABT' | head -1 | awk '{print $2}'`
bluetoothctl pair $mybtdev
bluetoothctl trust $mybtdev
bluetoothctl connect $mybtdev
