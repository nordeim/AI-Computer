rm -rf fin/www fin/lib.usr-is-merged
rm fin/*log fin/root/*log fin/root/*deb
diff fin/add-home.sh /rofs/add-home.sh || cp /rofs/add-home.sh fin/
ls -l fin/home/pete || ls -l fin/home.1 && rm -rf fin/home && mv fin/home.1 fin/home
ls -l fin/Home1 && rm -rf fin/Home1
sed -i 's/^ConditionPathExists=/#ConditionPathExists=/' fin/usr/lib/systemd/system/apparmor.service
grep -n ConditionPathExists= fin/usr/lib/systemd/system/apparmor.service
diff fin/etc/resolv.conf /rofs/etc/resolv.conf || cat /rofs/etc/resolv.conf > fin/etc/resolv.conf
diff fin/usr/lib/casper/casper-md5check.1 /rofs/usr/lib/casper/casper-md5check.1 || cp /rofs/usr/lib/casper/casper-md5check.1 fin/usr/lib/casper/casper-md5check.1
ls -L fin/etc/systemd/system/default.target.wants/casper-md5check.service || ln -sf /usr/lib/systemd/system/casper-md5check.service fin/etc/systemd/system/default.target.wants/casper-md5check.service
ls -L fin/etc/systemd/system/final.target.wants/casper.service || ln -sf /usr/lib/systemd/system/casper.service fin/etc/systemd/system/final.target.wants/casper.service
