#!/bin/bash

# ****************************************************************************************************************** #
# 源码安装xfce4.16 ,只适合执行一次
# openEuler20.03-xfce4.16-sources-install.sh
# ISO : openEuler-20.03-LTS-SP1-x86_64-dvd.iso

# 只有一个桌面环境时，图形模式中启动有问题，无法启动xfce4-panel，有其他桌面环境（lxde）,图形模式中启动就没问题
# 解决方法(单个桌面xfce4):lightdm登陆时，不要选择"default"，选择xfce4  /usr/share/xsessions/xx default中没有命令

# https://docs.xfce.org/xfce/building 参考文档
# https://archive.xfce.org/src/xfce/ 软件下载
# wget https://archive.xfce.org/xfce/4.16/fat_tarballs/xfce-4.16.tar.bz2

# 注：适用于第一次安装图形界面GUI(xfce4)

# 大概目录结构：
#├── xfce-4.16.tar.bz2
#├── apps
#│   ├── catfish-1.4.13.tar.bz2
#│   ├── gigolo-0.5.1.tar.bz2

# ****************************************************************************************************************** #

# 等同于 date +"%F %T"
firsttime=`date +"%Y-%m-%d %H:%M:%S"`

echo "**************************************************"
echo -e "\e[1;32m    openEuler 20.03 LTS Install GUI !      \e[0m"
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

# 先关闭SELINUX，防止重启后出现“Failed to load SELinux policy. Freezing”错误 导致一直不能启动
sed -e 's/SELINUX=enforcing/SELINUX=disabled/' -i /etc/selinux/config

dnf install -y nano lftp bash-completion

# ------------------------------------------------------------------ #
#                         更新源
# ------------------------------------------------------------------ #
cat << EOF > /etc/yum.repos.d/openEuler.repo
# 源码包源
[openEuler-source]
name=openEuler-source
baseurl=https://repo.huaweicloud.com/openeuler/openEuler-20.03-LTS/source/
enabled=1
gpgcheck=1
gpgkey=https://repo.huaweicloud.com/openeuler/openEuler-20.03-LTS/source/RPM-GPG-KEY-openEuler

# base基础软件包源 OS
[openEuler-os]
name=openEuler-os
baseurl=https://repo.huaweicloud.com/openeuler/openEuler-20.03-LTS/OS/x86_64/
enabled=1
gpgcheck=1
gpgkey=https://repo.huaweicloud.com/openeuler/openEuler-20.03-LTS/OS/x86_64/RPM-GPG-KEY-openEuler

# everything全量软件包源
[openEuler-everything]
name=openEuler-everything
baseurl=https://repo.huaweicloud.com/openeuler/openEuler-20.03-LTS/everything/x86_64/
enabled=1
gpgcheck=1
gpgkey=https://repo.huaweicloud.com/openeuler/openEuler-20.03-LTS/everything/x86_64/RPM-GPG-KEY-openEuler

# EPOL openEuler扩展包
[openEuler-EPOL]
name=openEuler-epol
baseurl=https://repo.huaweicloud.com/openeuler/openEuler-20.03-LTS/EPOL/x86_64/
enabled=1
gpgcheck=0
EOF

# 更新缓存
dnf clean all && dnf makecache

# ---------------------------------基本配置--------------------------------- #
# 编译相关环境设置
ldconf="/etc/ld.so.conf"
[ -f ${ldconf}.bak ] && cp ${ldconf}.bak ${ldconf} || cp ${ldconf} ${ldconf}.bak

cat << EOF > /etc/ld.so.conf
include /etc/ld.so.conf.d/*.conf
include /lib
include /lib64

include /usr/lib
include /usr/lib64
include /usr/libexec

include /usr/local/lib
include /usr/local/lib64

include /usr/lib/gcc/x86_64-linux-gnu/
include /usr/libexec/gcc/x86_64-linux-gnu/
EOF

/sbin/ldconfig

# 安装到自定义目录中
# 设置成PREFIX="/usr/local"有些问题，不用
PREFIX="/usr"
export CFLAGS="-O2 -pipe"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/lib64/pkgconfig:$PKG_CONFIG_PATH"

echo "export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/lib64/pkgconfig:$PKG_CONFIG_PATH" >> /etc/profile

[ "$(echo $PKG_CONFIG_PATH)" == "" ] && source /etc/profile



# 安装编译环境
dnf install -y kernel kernel-devel dkms
dnf install -y gcc-c++ gcc-objc++  
dnf install -y make cmake automake autoconf intltool  
dnf install -y build rpm-build rpmdevtools bzip2
dnf install -y bash-completion

# python相关
dnf install -y python3-devel python3-pkgconfig
dnf install -y python2-devel python2-pkgconfig 

# 会替换openssh-server openssh-client
dnf install -y libnotify libnotify-devel

dnf install -y perl ruby

# gtk相关
dnf install -y gtk2 gtk2-devel  gtk-doc gtk2-help
dnf install -y gtk3-devel
dnf install -y gtkmm30

dnf install -y wxGTK3-devel compat-wxGTK3-gtk2-devel

# dnf命令(已安装)
dnf install -y dnf dnf-plugins-core python3-dnf python3-dnf-plugins-core

dnf install -y wqy*

# x11相关
dnf install -y Xorg 
dnf install -y xinit xorg-x11-xinit xorg-x11-utils xorg-x11-server-utils
dnf install -y xorg-x11-drv-{fbdev,vesa} 

#---------------------------------------------------------------------#
#                    下载源码文件
#---------------------------------------------------------------------#
# 主要文件
[ ! -f "xfce-4.16.tar.bz2" ] && wget -cN https://archive.xfce.org/xfce/4.16/fat_tarballs/xfce-4.16.tar.bz2

# 其他文件
mkdir apps
[ ! -f "apps/xfce4-whiskermenu-plugin-2.5.3.tar.bz2" ] && wget -cN https://archive.xfce.org/src/panel-plugins/xfce4-whiskermenu-plugin/2.5/xfce4-whiskermenu-plugin-2.5.3.tar.bz2  -P apps

[ ! -f "apps/xfce4-battery-plugin-1.1.4.tar.bz2" ] && wget -cN https://archive.xfce.org/src/panel-plugins/xfce4-battery-plugin/1.1/xfce4-battery-plugin-1.1.4.tar.bz2  -P apps

[ ! -f "apps/xfce4-pulseaudio-plugin-0.4.3.tar.bz2" ] && wget -cN https://archive.xfce.org/src/panel-plugins/xfce4-pulseaudio-plugin/0.4/xfce4-pulseaudio-plugin-0.4.3.tar.bz2  -P apps

[ ! -f "apps/xfce4-fsguard-plugin-1.1.2.tar.bz2" ] && wget -cN https://archive.xfce.org/src/panel-plugins/xfce4-fsguard-plugin/1.1/xfce4-fsguard-plugin-1.1.2.tar.bz2  -P apps

[ ! -f "apps/xfce4-weather-plugin-0.11.0.tar.bz2" ] && wget -cN https://archive.xfce.org/src/panel-plugins/xfce4-weather-plugin/0.11/xfce4-weather-plugin-0.11.0.tar.bz2  -P apps

[ ! -f "apps/xfce4-sensors-plugin-1.3.95.tar.bz2" ] && wget -cN https://archive.xfce.org/src/panel-plugins/xfce4-sensors-plugin/1.3/xfce4-sensors-plugin-1.3.95.tar.bz2  -P apps

[ ! -f "apps/xfce4-notifyd-0.6.2.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/xfce4-notifyd/0.6/xfce4-notifyd-0.6.2.tar.bz2  -P apps

[ ! -f "apps/xfce4-panel-profiles-1.0.13.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/xfce4-panel-profiles/1.0/xfce4-panel-profiles-1.0.13.tar.bz2  -P apps

[ ! -f "apps/xfce4-screenshooter-1.9.8.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/xfce4-screenshooter/1.9/xfce4-screenshooter-1.9.8.tar.bz2  -P apps

[ ! -f "apps/xfce4-taskmanager-1.5.2.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/xfce4-taskmanager/1.5/xfce4-taskmanager-1.5.2.tar.bz2  -P apps

[ ! -f "apps/xfce4-terminal-0.8.9.2.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/xfce4-terminal/0.8/xfce4-terminal-0.8.9.2.tar.bz2  -P apps

[ ! -f "apps/xfce4-sensors-plugin-1.3.95.tar.bz2" ] && wget -cN https://archive.xfce.org/src/panel-plugins/xfce4-sensors-plugin/1.3/xfce4-sensors-plugin-1.3.95.tar.bz2  -P apps

[ ! -f "apps/gigolo-0.5.2.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/gigolo/0.5/gigolo-0.5.2.tar.bz2  -P apps

[ ! -f "apps/mousepad-0.5.4.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/mousepad/0.5/mousepad-0.5.4.tar.bz2  -P apps

[ ! -f "apps/ristretto-0.10.0.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/ristretto/0.10/ristretto-0.10.0.tar.bz2  -P apps

[ ! -f "apps/thunar-archive-plugin-0.4.0.tar.bz2" ] && wget -cN https://archive.xfce.org/src/thunar-plugins/thunar-archive-plugin/0.4/thunar-archive-plugin-0.4.0.tar.bz2  -P apps

[ ! -f "apps/thunar-shares-plugin-0.3.1.tar.bz2" ] && wget -cN https://archive.xfce.org/src/thunar-plugins/thunar-shares-plugin/0.3/thunar-shares-plugin-0.3.1.tar.bz2  -P apps

#[ ! -f "apps/xfce4-screensaver-4.16.0.tar.bz2" ] && wget -cN https://archive.xfce.org/src/apps/xfce4-screensaver/4.16/xfce4-screensaver-4.16.0.tar.bz2  -P apps

#---------------------------------------------------------------------#
#                    源码安装xfce4主要文件
#---------------------------------------------------------------------#
# xfce4源码
tar -xavf xfce-4.16.tar.bz2

# 解压文件
cd src/
find . -maxdepth 1 -name "*.tar.bz2" -print0 | sed 's/\.\///g' | sed 's/\s*//g'  | xargs -0 -I '{}' tar -xavf '{}'

#[ "$(echo $PKG_CONFIG_PATH)" == "" ] && source /etc/profile
# xfce4-dev-tools (如果从GIT构建，则需要先安装xfce4-dev-tools，否则则不需要)
cd xfce4-dev-tools-4.16.0/
dnf install -y autoconf automake intltool 
./configure --prefix=${PREFIX} && make -j2 && make install


# step1-step5要顺序安装，其他随意
cd ../libxfce4util-4.16.0/
dnf install -y gobject-introspection-devel libgudev-devel 
dnf install -y pygobject2-devel  pygobject3-devel
dnf install -y python2-gobject python3-gobject mvapich2-devel
./configure --prefix=${PREFIX} && make -j2 && make install


# step2：设置守护进程 xfconf依赖 libxfce4util, gdbus 
cd ../xfconf-4.16.0/
dnf install -y vala-devel dbus-glib-devel
./configure --prefix=${PREFIX} && make -j2 && make install
echo "include ${PREFIX}/lib/gio/modules" >> /etc/ld.so.conf  
ldconfig

# step3：libxfce4ui依赖 libxfce4util, gtk+, xfconf
#[ "$(echo $PKG_CONFIG_PATH)" == "" ] && source /etc/profile 
cd ../libxfce4ui-4.16.0/
dnf install -y libgtop2-devel
dnf install -y startup-notification-devel libglade2-devel glade-devel
./configure --prefix=${PREFIX} && make -j2 && make install

# 注：上面有可能不成功
# 编译libxfce4ui不成功，重新编译libxfce4util，然后再次编译libxfce4ui
cd ../libxfce4util-4.16.0/  &&  ./configure --prefix=${PREFIX} && make -j2 && make install
cd ../libxfce4ui-4.16.0/    &&  ./configure --prefix=${PREFIX} && make -j2 && make install


# step4：菜单库 garcon依赖 gio, libxfce4util 
cd ../garcon-0.8.0/
dnf install -y libwnck3-devel  
./configure --prefix=${PREFIX} && make -j2 && make install

# step5：exo依赖 libxfce4util, gtk+, perl-uri, libxfce4ui 
cd ../exo-4.16.0/
./configure --prefix=${PREFIX} && make -j2 && make install

# step6 面板
cd ../xfce4-panel-4.16.0/
./configure --prefix=${PREFIX} && make -j2 && make install

# step7 文件管理器
cd ../thunar-4.16.0/
dnf install -y libexif-devel  libnotify-devel libjpeg-devel libpng-devel libgudev-devel freetype-devel 
./configure --prefix=${PREFIX} && make -j2 && make install

# step8 卷管理器 thunar-volman
cd ../thunar-volman-4.16.0/
dnf install -y libgudev-devel gawk-devel
./configure --prefix=${PREFIX} && make -j2 && make install

# step9 设置系统 xfce4-settings
cd ../xfce4-settings-4.16.0/
dnf install -y libXcursor-devel upower-devel libxklavier-devel 
dnf install -y libinput-devel xorg-x11-drv-libinput-devel
dnf install -y libXrandr-devel libXi-devel colord-devel libell-devel
./configure --prefix=${PREFIX} && make -j2 && make install

# step10 会话管理器xfce4-session : startxfce4
cd ../xfce4-session-4.16.0/
dnf install -y polkit-devel perl-XML-Parser libSM-devel
./configure --prefix=${PREFIX} && make -j2 && make install

# step11 窗口管理器xfwm4
cd ../xfwm4-4.16.0/
./configure --prefix=${PREFIX} && make -j2 && make install

# step12 桌面管理器xfdesktop
cd ../xfdesktop-4.16.0/
./configure --prefix=${PREFIX} && make -j2 && make install

# step13 应用程序查找器xfce4-appfinder
cd ../xfce4-appfinder-4.16.0/
./configure --prefix=${PREFIX} && make -j2 && make install

# step14 缩略图服务tumbler
cd ../tumbler-4.16.0/
dnf install -y libgsf-devel poppler-glib-devel gstreamer
./configure --prefix=${PREFIX} && make -j2 && make install

# step15
cd ../xfce4-power-manager-1.6.6/
./configure --prefix=${PREFIX} && make -j2 && make install

#---------------------------------------------------------------------#
#                    源码安装xfce4其他文件  apps目录中
#---------------------------------------------------------------------#

cd ../../apps/

# 解压其他文件
find . -maxdepth 1 -name "*.tar.bz2" -print0 | sed 's/\.\///g' | sed 's/\s*//g'  | xargs -0 -I '{}' tar -xavf '{}'


# 安装 xfce4-whiskermenu-plugin(使用)
# 提示找不到exo
# cd xfce4-whiskermenu-plugin-2.5.3
# [ ! -d "build" ] && mkdir -v build 
# cd build
# cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
# make -j2 && make install
# cd .. 

# 安装 xfce4-terminal
cd xfce4-terminal-0.8.9.2/
dnf install -y vte291-devel
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 xfce4-weather-plugin(使用)
# 会删除libcurl
cd ../xfce4-weather-plugin-0.11.0/
dnf install -y libsoup-devel --allowerasing
./configure --prefix=${PREFIX} && make -j2 && make install
dnf install -y curl-devel

# 安装 xfce4-sensors-plugin()
cd ../xfce4-sensors-plugin-1.3.95/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 xfce4-battery-plugin(可选)
cd ../xfce4-battery-plugin-1.1.4/
./configure --prefix=${PREFIX} && make -j2 && make install


# 安装 xfce4-fsguard-plugin(可选)
cd ../xfce4-fsguard-plugin-1.1.2/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 xfce4-pulseaudio-plugin(使用)
cd ../xfce4-pulseaudio-plugin-0.4.3/
dnf install -y pulseaudio-dev pavucontrol keybinder3-devel
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 xfce4-notifyd
cd ../xfce4-notifyd-0.6.2/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 xfce4-screenshooter
cd ../xfce4-screenshooter-1.9.8/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 xfce4-taskmanager
cd ../xfce4-taskmanager-1.5.2/
dnf install -y libXmu-devel 
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 thunar-archive-plugin
cd ../thunar-archive-plugin-0.4.0/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 thunar-shares-plugin
cd ../thunar-shares-plugin-0.3.1/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装  gigolo
cd ../gigolo-0.5.2/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 mousepad 
cd ../mousepad-0.5.4/
dnf install -y gtksourceview3-devel
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 ristretto
cd ../ristretto-0.10.0/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 xfce4-panel-profiles
cd ../xfce4-panel-profiles-1.0.13/
./configure --prefix=${PREFIX} && make -j2 && make install

# 安装 xfce4-screensaver
#cd ../xfce4-screensaver-4.16.0/
#dnf install -y libXScrnSaver-devel pam-devel
#./configure --prefix=${PREFIX} && make -j2 && make install

# 登录管理器(可选)
#dnf install -y gdm
#systemctl enable gdm
#systemctl set-default graphical.target

# 安装主题(已安装)
dnf install -y adwaita-icon-theme

#---------------------------------------------------------------------#

echo "${User_Owner} ALL=(ALL) ALL" >> /etc/sudoers 

bashrc="/root/.bashrc"
[ -f ${bashrc}.bak ] && cp ${bashrc}.bak ${bashrc} || cp ${bashrc} ${bashrc}.bak

cat << "EOF" >> /root/.bashrc
alias dfls='df -Th'
alias top1='top -n 1'
alias psall='ps ux'
alias kill9='kill -9'
alias lns='ln -s'

alias dnfin='dnf install'
alias dnfse='dnf search'
EOF

# 中文化
#localectl  set-locale LANG=zh_CN.UTF8
#echo "LANG="zh_CN.UTF-8"" > /etc/locale.conf
echo "export LANG=zh_CN.UTF-8" >> /etc/profile
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#------------------------------------------------------------------------------------------------------#
#                                        计算耗时
#------------------------------------------------------------------------------------------------------#

# 等同于 date +"%F %T"
secondtime=`date +"%Y-%m-%d %H:%M:%S"`

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


