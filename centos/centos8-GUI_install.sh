#!/bin/bash
# centos8-GUI_install.sh 
# CentOS8安装图形界面，使用ustc源
# OS：CentOS-8.1.1911-x86_64-dvd1.iso


echo "**************************************************"
echo -e "\e[1;32m    CentOS Install GUI !      \e[0m"
echo "**************************************************"

read -p "Press <Enter> to continue ..." < /dev/tty

#firsttime=`date +%T`
firsttime=`date +"%F %T"`

if [ $UID != "0" ]; then
   echo "Not Root!!! Please exit, and login as root again!"
   exit
fi


# 自定义用户
read -p "Enter Normal-User: " User_Owner

# 备份源
CentOSBase="/etc/yum.repos.d/CentOS-Base.repo"
[ -f ${CentOSBase}.bak ] && cp ${CentOSBase}.bak ${CentOSBase} || cp ${CentOSBase} ${CentOSBase}.bak

CentOSExtras="/etc/yum.repos.d/CentOS-Extras.repo"
[ -f ${CentOSExtras}.bak ] && cp ${CentOSExtras}.bak ${CentOSExtras} || cp ${CentOSExtras} ${CentOSExtras}.bak

CentOSAppStream="/etc/yum.repos.d/CentOS-AppStream.repo"
[ -f ${CentOSAppStream}.bak ] && cp ${CentOSAppStream}.bak ${CentOSAppStream} || cp ${CentOSAppStream} ${CentOSAppStream}.bak

# centos8更新源
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/centos|g' \
    -i /etc/yum.repos.d/CentOS-Base.repo \
    -i /etc/yum.repos.d/CentOS-Extras.repo \
    -i /etc/yum.repos.d/CentOS-AppStream.repo

# 更新缓存
yum clean all && yum makecache

# 开始要下载的软件
yum install -y epel-release elrepo-release wget nano

# 其他更新源
# EPEL是企业版 Linux 附加软件包
sed -e 's|^metalink|#metalink|g' \
    -e 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.ustc.edu.cn|g' \
    -i /etc/yum.repos.d/epel.repo \
    -i /etc/yum.repos.d/epel-modular.repo \
    -i /etc/yum.repos.d/epel-playground.repo 
    
sed -e 's|^metalink|#metalink|g' \
    -e 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.ustc.edu.cn|g' \
    -i /etc/yum.repos.d/epel-testing.repo \
    -i /etc/yum.repos.d/epel-testing-modular.repo 
    
# RPM Fusion 由于专利许可等一些原因不能包含在Fedora源里的东西是可以在RPM Fusion这个第三方仓库中找到的
rpm -Uvh  https://mirrors.ustc.edu.cn/rpmfusion/free/el/rpmfusion-free-release-8.noarch.rpm  
rpm -Uvh  https://mirrors.ustc.edu.cn/rpmfusion/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm

sed -e 's|^mirrorlist|#mirrorlist|g' \
    -e 's|^#baseurl=http://download1.rpmfusion.org|baseurl=https://mirrors.ustc.edu.cn/rpmfusion|g' \
    -i /etc/yum.repos.d/rpmfusion-free-updates.repo \
    -i /etc/yum.repos.d/rpmfusion-free-updates-testing.repo \
    -i /etc/yum.repos.d/rpmfusion-nonfree-updates.repo \
    -i /etc/yum.repos.d/rpmfusion-nonfree-updates-testing.repo

# ELRepo : 增强硬件驱动包支撑
# 修改/etc/yum.repos.d/elrepo.repo 字段[elrepo]中“baseurl”添加一行
# http://mirrors.ustc.edu.cn/elrepo/elrepo/el8/$basearch/
elrepo="/etc/yum.repos.d/elrepo.repo"
[ -f ${elrepo}.bak ] && cp ${elrepo}.bak ${elrepo} || cp ${elrepo} ${elrepo}.bak

cat << EOF > /etc/yum.repos.d/elrepo.repo
[elrepo]
name=ELRepo.org Community Enterprise Linux Repository - el8
baseurl=http://mirrors.ustc.edu.cn/elrepo/elrepo/el8/$basearch/
	http://elrepo.org/linux/elrepo/el8/$basearch/
	http://mirrors.coreix.net/elrepo/elrepo/el8/$basearch/
	http://jur-linux.org/download/elrepo/elrepo/el8/$basearch/
	http://repos.lax-noc.com/elrepo/elrepo/el8/$basearch/
mirrorlist=http://mirrors.elrepo.org/mirrors-elrepo.el8
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
protect=0

[elrepo-testing]
name=ELRepo.org Community Enterprise Linux Testing Repository - el8
baseurl=http://mirrors.ustc.edu.cn/elrepo/testing/el8/$basearch/
	http://elrepo.org/linux/testing/el8/$basearch/
	http://mirrors.coreix.net/elrepo/testing/el8/$basearch/
	http://jur-linux.org/download/elrepo/testing/el8/$basearch/
	http://repos.lax-noc.com/elrepo/testing/el8/$basearch/
mirrorlist=http://mirrors.elrepo.org/mirrors-elrepo-testing.el8
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
protect=0

[elrepo-kernel]
name=ELRepo.org Community Enterprise Linux Kernel Repository - el8
baseurl=http://mirrors.ustc.edu.cn/elrepo/kernel/el8/$basearch/
	http://elrepo.org/linux/kernel/el8/$basearch/
	http://mirrors.coreix.net/elrepo/kernel/el8/$basearch/
	http://jur-linux.org/download/elrepo/kernel/el8/$basearch/
	http://repos.lax-noc.com/elrepo/kernel/el8/$basearch/
mirrorlist=http://mirrors.elrepo.org/mirrors-elrepo-kernel.el8
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
protect=0

[elrepo-extras]
name=ELRepo.org Community Enterprise Linux Extras Repository - el8
baseurl=http://mirrors.ustc.edu.cn/elrepo/extras/el8/$basearch/
	http://elrepo.org/linux/extras/el8/$basearch/
	http://mirrors.coreix.net/elrepo/extras/el8/$basearch/
	http://jur-linux.org/download/elrepo/extras/el8/$basearch/
	http://repos.lax-noc.com/elrepo/extras/el8/$basearch/
mirrorlist=http://mirrors.elrepo.org/mirrors-elrepo-extras.el8
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
protect=0
EOF

# 更新缓存
yum clean all && yum makecache



################################################################################
# vbox需要(vbox中增强包wayland无效，x11可以)
dnf install -y kernel kernel-devel dkms gcc cmake make bzip2

# dnf命令
dnf install -y dnf dnf-plugins-core 

# 关掉yum的自动更新
rm -f /var/run/yum.pid

# 编译环境
dnf install -y gcc gcc-c++ gcc-gfortran gdb  git git-svn perl elfutils-libelf-devel
dnf install -y rpm-build  rpmdevtools redhat-rpm-config  
 
dnf install -y libnotify libnotify-devel 
dnf install -y yum-utils bash-completion 


# 安装Xorg(vbox中增强包wayland无效，x11可以) Xorg类似gnome
dnf install -y Xorg 
dnf install -y xorg-x11-xinit xorg-x11-utils  xorg-x11-font-utils 
dnf install -y xorg-x11-drivers
ln -sf /lib/systemd/system/graphical.taget /etc/systemd/system/default.target

# 显示软件集
#dnf group list
# 显示仓库
#yum repolist

# 安装xfce软件集 等同于dnf install @xfce
dnf group install -y "xfce"
#dnf group install -y "Fedora Packager"


# 安装GTK相关（可选）
dnf install -y webkit2gtk3 webkit2gtk3-devel 
dnf install -y wxGTK3  wxGTK3-devel 
dnf install -y gtk2 gtk2-devel gtk3 gtk3-devel

#　安装中文字体命令
dnf install -y wqy*
dnf groupinstall -y "fonts"


# python相关
dnf install -y python3 python3-devel 
dnf install -y python2  python2-devel 

dnf install -y python3-pip  


dnf install -y PackageKit-yum  PackageKit-yum-plugin 

# 网络管理图形工具
dnf install -y net-tools  NetworkManager network-manager-applet　
systemctl enable NetworkManager


dnf install -y gvfs gvfs-fuse  ntfs-3g

# 输入法fcitx
dnf install -y fcitx  fcitx-devel  fcitx-table-chinese 
dnf install -y im-chooser gtk2-immodule-xim
imsettings-switch fcitx

cat << EOF >> /etc/profile
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
EOF

# 安装压缩工具:
dnf install -y p7zip unzip zip arj file-roller


echo "${User_Owner} ALL=(ALL) ALL" >> /etc/sudoers 

cat << EOF >> /root/.bashrc
alias dfls='df -Th'
alias top1='top -n 1'
alias psall='ps ux'
alias kill9='kill -9'
alias lns='ln -s'
EOF

# 中文化
cat << EOF > /etc/sysconfig/i18n
LANG="zh_CN.UTF-8"
LC_ALL="zh_CN.UTF-8"
EOF

#　然后修改本地文字
echo "LANG="zh_CN.UTF-8"" > /etc/locale.conf

#------------------------------------------------------------------------------------------------------#
#                                        计算耗时
#------------------------------------------------------------------------------------------------------#

# 等同于 date +"%F %T"
secondtime=`date +"%F %T"`

# 计算时间差
time_difference(){
	# 时间格式必须为 date +"%Y-%m-%d %H:%M:%S" ，即date +"%F %T"
	first="$1"
	second="$2"

	seconds_all=$(expr $(date +%s -d "${second}") - $(date +%s -d "${first}")) 
	hour=$(expr ${seconds_all} / 3600) 

	hour_remaining=$(expr ${seconds_all} % 3600) 
	min=$(expr ${hour_remaining}  / 60) 
	sec=$(expr ${hour_remaining}  % 60) 
	echo "Run-Times: ${hour} hour ${min} min ${sec} sec "  
};

echo " "
echo "#########################################################"
echo "FirstTime: ${firsttime} " 
echo "EndTime: ${secondtime} "
time_difference "${firsttime}"  "${secondtime}" ;
echo "#########################################################"


