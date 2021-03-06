#!/bin/bash -eu

# Reduce installed languages to just "en_US"
echo "==> Configuring locales"
sed -i '/^[^# ]/s/^/# /' /etc/locale.gen
LANG=en_US.UTF-8
LC_ALL=$LANG
locale-gen --purge $LANG
update-locale LANG=$LANG LC_ALL=$LC_ALL

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ :]*\).*/\1/;/[0-9]/!d' | xargs apt-get -y purge
echo "==> Removing linux source"
dpkg --list | awk '{print $2}' | grep linux-source | xargs apt-get -y purge
echo "==> Removing documentation"
dpkg --list | awk '{print $2}' | grep -- '-doc$' | xargs apt-get -y purge
echo "==> Removing X11 libraries"
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6 libxau6 libxdmcp6
echo "==> Removing other oddities"
apt-get -y purge accountsservice alsa-topology-conf alsa-ucm-conf bcache-tools \
    bind9-host btrfs-progs busybox-static command-not-found dmidecode dosfstools \
    fonts-ubuntu-console friendly-recovery hdparm info install-info iso-codes \
    krb5-locales language-selector-common lshw mdadm mtr-tiny nano ncurses-term ntfs-3g \
    open-iscsi os-prober parted pastebinit pci.ids pciutils plymouth popularity-contest \
    powermgmt-base publicsuffix python-apt-common sg3-utils shared-mime-info \
    ssh-import-id tcpdump thermald ufw usb.ids usbutils xdg-user-dirs xfsprogs
apt-get -y autoremove --purge

# Clean up orphaned packages with deborphan
apt-get -y install --no-install-recommends deborphan
deborphan --find-config | xargs apt-get -y purge
while [ -n "$(deborphan --guess-all)" ]; do
    deborphan --guess-all | xargs apt-get -y purge
done
apt-get -y purge deborphan

# Clean up the apt cache
apt-get -y autoremove --purge
apt-get clean

# echo "==> Removing APT files"
# find /var/lib/apt -type f -exec rm -rf {} \;
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;
