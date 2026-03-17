#!/bin/bash

ls -d /var/lib/docker/containers/1918b2a6eb682ebf1ac6302a9bfb6d7fbc8cce3e220ee345c9a03f62cbcc2643

if [ $? -ne 0 ] ; then

   systemctl stop containerd
   systemctl stop docker.socket
   systemctl stop docker
   rm -rf /var/lib/docker
   ln -sf /Home1/docker /var/lib/docker
   systemctl restart containerd
   systemctl restart docker.socket
   systemctl restart docker

fi

docker ps -a

mount | grep '\/cdrom ' | grep 'ro,noatime'

if [ $? -eq 0 ] ; then

   mount -o remount,rw /cdrom

fi
