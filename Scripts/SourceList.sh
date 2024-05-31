#!/bin/bash
version=$(lsb_release -cs)
cat > /etc/apt/sources.list << EOF
# $version
deb http://deb.debian.org/debian $version main non-free-firmware contrib non-free
deb-src http://deb.debian.org/debian $version main non-free-firmware contrib non-free
 
# $version-updates
deb http://deb.debian.org/debian $version-updates main non-free-firmware contrib non-free
deb-src http://deb.debian.org/debian $version-updates main non-free-firmware contrib non-free
 
# $version-security
deb http://security.debian.org/debian-security/ $version-security main non-free-firmware contrib non-free
deb-src http://security.debian.org/debian-security/ $version-security main non-free-firmware contrib non-free
 
# $version-backports
deb http://deb.debian.org/debian $version-backports main non-free-firmware contrib non-free
deb-src http://deb.debian.org/debian $version-backports main non-free-firmware contrib non-free
EOF