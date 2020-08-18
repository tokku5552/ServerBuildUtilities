#!/bin/bash
###############################################################
#
# get_syscongig.sh
#
###############################################################

# variable declaration
tmpdir=/tmp/data

cat /proc/cpuinfo > ${tmpdir}/cpuinfo.txt
cat /proc/meminfo  > ${tmpdir}/meminfo.txt
lspci > ${tmpdir}/lspci.txt
lsmod > ${tmpdir}/lsmod.txt
lsblk > ${tmpdir}/lsblk.txt
lsusb > ${tmpdir}/lsusb.txt
df -h > ${tmpdir}/df_h.txt
parted -l > ${tmpdir}/parted.txt
systemctl list-unit-files > ${tmpdir}/systemctl_list.txt
sysctl -a > ${tmpdir}/sysctl.txt
ulimit -a > ${tmpdir}/ulimit.txt
dmesg > ${tmpdir}/dmesg.txt
ip addr > ${tmpdir}/ip_addr.txt
netstat -ano > ${tmpdir}/netstat_ano.txt
free > ${tmpdir}/free.txt
lsof > ${tmpdir}/lsof.txt
uname > ${tmpdir}/uname.txt
vgdisplay > ${tmpdir}/vgdisplay.txt
lvdisplay  > ${tmpdir}/lvdisplay.txt