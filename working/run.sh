#!/usr/bin/env bash

cd /root/working
livemedia-creator --make-tar --no-virt --nomacboot --iso=/root/working/boot.iso \
  --image-name=tos-7.4.1708-docker.tar.xz --project="Centos 7 Docker" --releasever="7" \
  --ks=/root/working/kickstart.ks