#!/bin/sh
# freebsd安装
# vbox中替换pkg源，然后安装lftp，然后下载安装脚本

# 等同于 firsttime=`date +"%Y-%m-%d %H:%M:%S"`
firsttime=`date +"%F %T"`

echo ""
echo "Shell is sh before install!!"

# 自定义用户
# 如果和开始创建的用户不一样，案子完毕后要使用"adduser"命令新建用户
#User_Owner=pang
echo ""
read -p "Enter Normal-User: " User_Owner

# =============================================================================================
#                         FreeBSD系统四类源服务器解释
# =============================================================================================

# 1.pkg源：为pkg工具提供二进制远程下载仓储目录，为使用 pkg 工具安装二进制软件包的必须条件
# 2.ports源：为ports工具提供远程源码下载缓存目录，为使用 ports 工具编译安装软件包的必须条件
# 3.portsnap源：为ports框架当前快照，portsnap 为系统安装或者更新 ports 框架辅助工具
# 4.freebsd-update源：为FreeBSD更新基系统、内核、源码树的快照源，更新操作系统时需要使用此源
echo ""
echo "======================================"
echo "FreeBSD Source Servers"
echo "1.sources pkg"
echo "2.sources ports"
echo "3.sources portsnap" 
echo "4.sources freebsd-update"  
echo "======================================"
echo ""

# ～～～～～～～～～～～～～～～～～～～～～～
#     1.pkg源 二进制源
# ～～～～～～～～～～～～～～～～～～～～～～
# 禁用默认 PKG 仓储源,如有问题则启用默认pkg源
# 如果要使用滚动更新的 latest 仓库，把 url 配置最后的 quarterly 换成 latest 即可。运行 pkg update -f 更新索引。
# 建议只选用一个最快的PKG源，而不是同时启用多个，如果同时启用了多个 PKG 源，那么在安装软件包或升级 PKG 源时候请使用 -r 选项指定要操作的 PKG 源。

# FreeBSD中pkg源分为系统级和用户级两个源.不建议直接修改/etc/pkg/FreeBSD.conf,因为该文件会随着基本系统的更新而发生改变.
# 创建用户级源目录
[ ! -d "/usr/local/etc/pkg/repos" ] &&  mkdir -p /usr/local/etc/pkg/repos
#cp /etc/pkg/FreeBSD.conf /usr/local/etc/pkg/repos/bjtu-freebsd.conf

# 创建用户级源文件
# 注：只用1个，防止可能出现的问题
# cnfreebsd pkg源
cat > /usr/local/etc/pkg/repos/freebsdcn.conf << "EOF"
freebsdcn:{
  url: "pkg+http://pkg.freebsd.cn/${ABI}/quarterly",
  mirror_type: "srv",
  signature_type: "none",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF

# bjtu北京交通大学 pkg源
cat > /usr/local/etc/pkg/repos/bjtu.conf.bak << "EOF"
bjtu:{
  url: "pkg+http://freebsd-pkg.mirror.bjtulug.org/${ABI}/quarterly",
  mirror_type: "srv",
  signature_type: "none",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF

# ustc中科大 pkg源
cat > /usr/local/etc/pkg/repos/ustc.conf.bak << "EOF"
ustc:{
  url: "pkg+http://mirrors.ustc.edu.cn/freebsd-pkg/${ABI}/quarterly",
  mirror_type: "srv",
  signature_type: "none",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF


#禁用系统级 pkg源
echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
mv /etc/pkg/FreeBSD.conf /etc/pkg/FreeBSD.conf.bak-$$

# 验证当前生效源 pkg -vv
# 强制更新所有源 
pkg update -f 

# 使用 HTTPS 可以有效避免国内运营商的缓存劫持，但需要事先安装 security/ca_root_nss 软件包。
pkg install -y ca_root_nss

# ～～～～～～～～～～～～～～～～～～～～～～
#     2.ports源  源码源
# ～～～～～～～～～～～～～～～～～～～～～～
pkg install -y axel nano 
cat > /etc/make.conf << "EOF"
FETCH_CMD=axel -n 20 -a
DISABLE_SIZE=yes
MASTER_SITE_OVERRIDE?=\
http://ports.freebsd.cn/distfiles/${DIST_SUBDIR}/ \
http://mirrors.ustc.edu.cn/freebsd-ports/distfiles/${DIST_SUBDIR}/ 
#CPUTYPE=core2
WITH_GTK2=yes
WITH_PKGNG=yes
EOF

# ～～～～～～～～～～～～～～～～～～～～～～
#     3.portsnap源  快照源
# ～～～～～～～～～～～～～～～～～～～～～～
# 先安装gnu-sed
pkg install -y gsed

portsnapconf="/etc/portsnap.conf"
[ -f ${portsnapconf}.bak ] && cp ${portsnapconf}.bak ${portsnapconf} || cp ${portsnapconf} ${portsnapconf}.bak

# 注：使用gnu-sed,freebsd下的sed和gnu-sed有些不一样
gsed "s/SERVERNAME=portsnap.FreeBSD.org/SERVERNAME=portsnap.freebsd.cn/" -i /etc/portsnap.conf

# portsnap采用增量更新的方式，第一次需要执行fetch extract，以后只需要执行fetch update即可，增量更新的更新量很小
#portsnap fetch extract
#portsnap fetch update

# ～～～～～～～～～～～～～～～～～～～～～～
#     4.freebsd-update源  更新基系统/内核
# ～～～～～～～～～～～～～～～～～～～～～～
bsdconf="/etc/freebsd-update.conf"
[ -f ${bsdconf}.bak ] && cp ${bsdconf}.bak ${bsdconf} || cp ${bsdconf} ${bsdconf}.bak

gsed "s/ServerName update.FreeBSD.org/ServerName update.freebsd.cn/" -i /etc/freebsd-update.conf

# 更新基系统/内核(可选，或者全部安装好后再更新)
#freebsd-update fetch 
#freebsd-update install

#----------------------------------------------------
#              跨版本升级
#----------------------------------------------------
# 跨版本升级使用如下命令(版本在update.freebsd.cn 查看) 依次升级重启再升级
# 10.1 -> 10.2 -> 10.3 -> ... -> 11.1 -> 11.2
# 1. freebsd-version -k -u    # 查看当前版本
# 2. freebsd-update fetch     # 获取当前版本更新
# 3. freebsd-update install   # 安装更新
# 4. freebsd-update upgrade -r 12.2-RELEASE # 升级到  12.2-RELEASE
# 5. freebsd-update install   # 安装更新
# 6. reboot                   # 重启
# 7. freebsd-update install   # 再次安装更新(uname -r 和freebsd-version 不一致时使用)
# 8. freebsd-version -k -u    # 查看更新后的版本

# 注意：回退到上一次的修改。(尽量不使用，可能会出问题，谨慎操作)
# freebsd-update rollback 

#======================================================
# 安装sudo
pkg install -y sudo sudo-font bash bash-completion 
#printf "\n${User_Owner}    ALL=(ALL) ALL" >> /usr/local/etc/sudoers

#----------------------多系统引导---------------------------------#
# win7 + freebsd （boot0cfg引导）+ debian （grub引导）
# freebsd自有启动管理，进入freebsd后安装boot mgr到硬盘ada0（gpt未测试）
# 不安装grub,如果grub不行的话，则切换到boot0cfg启动管理
# boot0cfg -B ada0

#------------------------------------------------------------------------------------------------------#

# 等同于 date +"%Y-%m-%d %H:%M:%S"
secondtime=`date +"%F %T"`

echo " "
echo "#########################################################"
echo "FirstTime: ${firsttime} " 
echo "EndTime  : ${secondtime} "
echo "#########################################################"

