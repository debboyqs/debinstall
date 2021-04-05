#!/bin/bash 
# ****************************************************************************************************************** #
# debian10.2安装脚本，root执行,首次运行在有线网络中，无线安装过程中可能会断网
# 注：选择高级安装，防止安装过程中要下载文件，很费时间 
# Advanced options--> Graphical expert install （十几分钟就安装好，内核选择linux-image-amd64,不下载更新）

# 屏幕尺寸：1920x1080
# vbox+mbr 中grub要用1024x768，vbox+uefi安装后导入需要先设置
# 所有配置文件必须先备份 ！！！
# 10.8执行后，wine可能要重新安装

# -------------------------------------------------
# 配置文件：追加内容
# /etc/apt/sources.list   //二次执行前，必须先注释ISO外的所以源  !!! Warning !!!
# /etc/profile
# /etc/mpv/mpv.conf
# /etc/lightdm/lightdm-gtk-greeter.conf
# /root/.bashrc
# /etc/fstab

# 配置文件：替换内容
# /etc/ld.so.conf
# /etc/modprobe.d/blacklist-nouveau.conf
# /usr/local/bin/update-usbids
# /etc/grub.d/40_custom

# -------------------------------------------------
# 注：适用于挂载光盘源后，第一次安装图形界面GUI
# 使用该脚本顺序如下：
# 1.终端先英文化"dpke-reconfigure locales"，退出，重新root登陆
# 2.添加光盘源 "mount /dev/sr0 /media/cdrom && apt-cdrom add -m -d /media/cdrom"
# 3.注释除光盘源外的其他源
# 4.最后执行该脚本 

# ****************************************************************************************************************** #

echo "**************************************************"
echo -e "\e[1;32m        Install GUI !      \e[0m"
echo "**************************************************"
echo ""
echo -e "---------------- First execution -----------------"
echo -e "\e[1;33m 1.Change locales is en_US.UTF-8 in the terminal, exit, and login as root again ! \e[0m\n"
echo -e "\e[1;33m 2.Add CD/ISO source ! \e[0m"
echo -e "\e[1;32m   mount /dev/sr0 /media/cdrom && apt-cdrom add -m -d /media/cdrom \e[0m\n"
echo -e "\e[1;33m 3.Annotate other sources except CD source ! \e[0m\n"
echo -e "\e[1;33m 4.Finally install the script ! \e[0m\n"

echo -e "----------- Multiple executions Warning!!!----------"
echo -e "\e[1;31m Before the Multiple execution, Annotate other sources except CD source. \e[0m\n"
#echo -e "\e[1;31m After the Multiple execution, the duplicate content of the configuration file needs to be deleted  \e[0m\n"
echo "**************************************************"

read -p "Press <Enter> to continue ..." < /dev/tty

# 等同于 firsttime=`date +"%Y-%m-%d %H:%M:%S"`
firsttime=`date +"%F %T"`

if [ $UID != "0" ]; then
   echo "Not Root!!! Please exit, and login as root again!"
   exit
fi

# 删除中断操作产生的锁文件
[ -f "/var/lib/apt/lists/lock" ] && rm -f /var/lib/apt/lists/lock 
[ -f "/var/cache/apt/archives/lock" ] && rm -f /var/cache/apt/archives/lock 
dpkg --configure -a
apt -y --fix-broken install

# 自定义用户
# 如果和开始创建的用户不一样，案子完毕后要使用“adduser”命令新建用户

echo ""
read -p "Enter Normal-User: " User_Owner

sed 's|# en_US.UTF-8|en_US.UTF-8|g' -i /etc/locale.gen
sed 's|# en_US ISO-8859-1|en_US ISO-8859-1|g' -i /etc/locale.gen
sed 's|# zh_CN.GBK|zh_CN.GBK|g' -i /etc/locale.gen
sed 's|# zh_CN.GB18030|zh_CN.GB18030|g' -i /etc/locale.gen
sed 's|# zh_CN.UTF-8|zh_CN.UTF-8|g' -i /etc/locale.gen
sed 's|# zh_TW.UTF-8|zh_TW.UTF-8|g' -i /etc/locale.gen
#echo "zh_CN GB2312" >> /etc/locale.gen

# 终端先英文好处理，安装好后在中文化
dpkg-reconfigure locales

# 终端先英文化，安装好后在中文化
#echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# 修改终端显示字体大小 16x32,安装好后再用
consolesetup="/etc/default/console-setup"
[ -f ${consolesetup}.bak ] && cp ${consolesetup}.bak ${consolesetup} || cp ${consolesetup} ${consolesetup}.bak
dpkg-reconfigure console-setup

#-------------------------------------------------------------------------------------------------------------#
# 显示器分辨率
#-------------------------------------------------------------------------------------------------------------#
resolution="1280x800"
echo "1.Screen Resolutions : 1024x768 (VBox+MBR)"
echo "2.Screen Resolutions : 1280x800 (Default)"
echo "3.Screen Resolutions : 1280x1024"
echo "4.Screen Resolutions : 1366x768"
echo "5.Screen Resolutions : 1440x900"
echo "6.Screen Resolutions : 1600x900"
echo "7.Screen Resolutions : 1920x1080"
read -p "Please Slelect Screen Resolutions: " choice
case $choice in 
    "1")
    echo "Screen Resolutions(VBox+MBR) : 1024x768"
    resolution="1024x768"
    ;;
    "2")
    echo "Screen Resolutions : 1280x800"
    resolution="1280x800"
    ;;
    "3")
    echo "Screen Resolutions : 1280x1024"
    resolution="1280x1024"
    ;;
    "4")
    echo "Screen Resolutions : 1366x768"
    resolution="1366x768"
    ;;
    "5")
    echo "Screen Resolutions : 1440x900"
    resolution="1440x900"
    ;;
    "6")
    echo "Screen Resolutions : 1600x900"
    resolution="1600x900"
    ;;
    "7")
    echo "Screen Resolutions : 1920x1080"
    resolution="1920x1080"
    ;;
    *)
    echo "Other Screen Resolutions, Use default:1280x800"
    ;;
esac

# ------------------------------------------------------------------ #
#                       准备工作
# ------------------------------------------------------------------ #

sourceslist="/etc/apt/sources.list"
[ -f ${sourceslist}.bak ] && cp ${sourceslist}.bak ${sourceslist} || cp ${sourceslist} ${sourceslist}.bak

# ping源
lists="http://mirrors.tuna.tsinghua.edu.cn http://mirrors.ustc.edu.cn http://mirrors.sohu.com/"
debversion=`cat /etc/os-release | grep VERSION_CODENAME | cut -d "=" -f2`

echo ""
echo -e "\e[1;36m===========================================================\e[0m" 
for mirror in ${lists}
do 
  echo -e "\e[1;32m [${mirror}] \e[0m"
  ping $(echo ${mirror} | cut -d'/' -f3) -c2 | head -n2 | tail -n1 | cut -d ":" -f2 
  echo ""
done


# 选择最快的源
# 清华源   1.http://mirrors.tuna.tsinghua.edu.cn               
# 中科大源 2.http://mirrors.ustc.edu.cn               
# 搜狐源   3.http://mirrors.sohu.com   

mirrorlist="http://mirrors.ustc.edu.cn"
echo -e "\e[1;34m===========================================================\e[0m" 
echo -e "\e[1;35m Some Mirrors! Please select it! \e[0m"
echo -e "\e[1;32m 1.http://mirrors.tuna.tsinghua.edu.cn \e[0m"    # 清华源          
echo -e "\e[1;32m 2.http://mirrors.ustc.edu.cn \e[0m"             # 中科大源
echo -e "\e[1;32m 3.http://mirrors.sohu.com \e[0m"                # 搜狐源
# 下面的也可以
# i=1
# for url in ${lists}
# do 
#   echo -e "\e[1;32m ${i}.${url} \e[0m"
#   let i++
# done
echo -e "\e[1;34m===========================================================\e[0m" 

read -p "Please Select Mirror: " number
case $number in 
    "1")
    echo -e "\e[1;32m [http://mirrors.tuna.tsinghua.edu.cn] \e[0m"
    mirrorlist="http://mirrors.tuna.tsinghua.edu.cn"
    ;;
    "2")
    echo -e "\e[1;32m [http://mirrors.ustc.edu.cn] \e[0m"
    mirrorlist="http://mirrors.ustc.edu.cn"
    ;;
    "3")
    echo -e "\e[1;32m [http://mirrors.sohu.com] \e[0m"
    mirrorlist="http://mirrors.sohu.com"
    ;;
    *)
    echo -e "\e[1;33m Other mirror, Use default mirror: \e[0m" 
    echo -e "\e[1;32m [${mirrorlist}] \e[0m" 
    ;;
esac


# 添加光盘源，并安装linux-headers (先安装)
# linux-headers-`uname -r` 在10.2到10.4中（版本更改后）提示找不到该文件
# 解决方法1：apt upgrade 重启后再安装
# 解决方法2：添加光盘源，然后安装
#mount  /dev/sr0 /media/cdrom
#apt-cdrom add -m -d /media/cdrom 
#apt update -y  
apt install -y  linux-headers-$(uname -r) 

# 先安装https支持 (注：EOF不加“”则读取值 ，加""则为字符串)
#apt update
#apt upgrade -y
apt install -y  debian-keyring debian-archive-keyring 
apt install -y  apt-transport-https  dirmngr


# stable-proposed-updates(不建议使用)
# stable-backports 这个库中存放了一些为稳定版重新编译的新版本包
# Security Updates 该库中包含了最新的安全更新包

# 更换完整更新源buster (注：EOF不加“”则读取值 ，加""则为字符串)
cat  >> /etc/apt/sources.list << EOF
deb ${mirrorlist}/debian/ ${debversion} main non-free contrib
deb-src  ${mirrorlist}/debian/ ${debversion} main non-free contrib

deb ${mirrorlist}/debian/ ${debversion}-updates  main non-free contrib
deb-src ${mirrorlist}/debian/ ${debversion}-updates main non-free contrib

deb ${mirrorlist}/debian/ ${debversion}-backports   main non-free contrib
deb-src ${mirrorlist}/debian/ ${debversion}-backports main non-free contrib

#deb ${mirrorlist}/debian/ ${debversion}-proposed-updates main non-free contrib
#deb-src ${mirrorlist}/debian/ ${debversion}-proposed-updates main non-free contrib

# debian-security
deb ${mirrorlist}/debian-security/ ${debversion}/updates main non-free contrib
deb-src ${mirrorlist}/debian-security/ ${debversion}/updates main non-free contrib

# debian-multimedia
deb ${mirrorlist}/debian-multimedia/ ${debversion} main  non-free
deb-src ${mirrorlist}/debian-multimedia/ ${debversion} main  non-free
EOF

# 添加debian-multimedia支持
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C808C2B65558117

# 添加debian-multimedia支持(上述不成功，再次执行)
if [ $? -ne 0 ];then
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C808C2B65558117
fi

# http切换成https，防止劫持 (可以后期更改)
#apt install -y  apt-transport-https dirmngr
#sed 's/http/https/g' -i /etc/apt/sources.list

# 增加多架构支持
dpkg --add-architecture i386
apt update

# ---------------------------------基本配置--------------------------------- #
# 编译相关环境设置
cp /etc/ld.so.conf  /etc/ld.so.conf.bak
cat  > /etc/ld.so.conf << "EOF"
include /etc/ld.so.conf.d/*.conf
include /lib
include /lib32
include /lib64
include /lib/x86_64-linux-gnu
include /lib/i386-linux-gnu
include /usr/lib
include /usr/lib32
include /usr/libx32
include /usr/lib64
include /usr/lib/x86_64-linux-gnu/
include /usr/lib/i386-linux-gnu/
include /usr/local/lib
EOF

/sbin/ldconfig

#echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/lib/pkgconfig" >> /etc/profile
#source /etc/profile

# ------------------------------------------------------------------ #
#                 安装基本系统和图形界面  lxde+xfce4
# ------------------------------------------------------------------ #
# 更新系统(建议全部安装之后再更新，否则下面的软件有可能失效，10.2 --> 10.4)
#apt upgrade -y 

# 最小安装的LXDE：不安装LXDE推荐的程序，在末尾添加参数“--no-install-recommends”，或者使用aptitude
apt install -y  lxde 
apt install -y  xfce4-terminal xfce4-screenshooter xfce4-power-manager

# 或者试用自定义桌面
apt install -y  openbox openbox-dev obmenu obconf openbox-menu 

# 安装xfce桌面（可选，一般选用）
apt install -y  xfce4 
apt install -y  xfce4-indicator-plugin xfce4-appmenu-plugin xfce4-equake-plugin xfce4-statusnotifier-plugin
apt install -y  gtk3-engines-xfce  

# xfce4-goodies包含下面,如果删除任一一个软件，会把goodies也删除，所以选择不安装goodies，单独安装下面插件
apt install -y  xfce4-whiskermenu-plugin
apt install -y  xfce4-battery-plugin  xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-fsguard-plugin 
apt install -y  xfce4-sensors-plugin xfce4-systemload-plugin xfce4-taskmanager
apt install -y  xfce4-diskperf-plugin  xfce4-mailwatch-plugin xfce4-netload-plugin 
apt install -y  xfce4-notes xfce4-notes-plugin xfce4-dict xfce4-places-plugin xfce4-smartbookmark-plugin
apt install -y  xfce4-datetime-plugin xfce4-timer-plugin 
apt install -y  xfce4-verve-plugin xfce4-wavelan-plugin xfce4-xkb-plugin

# 源码编译xfce4的一些插件需要用到
#apt install -y  libxfce4ui-1-dev libxfce4ui-2-dev orage xfce4-panel-dev libxfce4panel-2.0-dev

# 安装mate桌面(可选) 
#apt install -y  mate-desktop-environment-extras


# 安装工具
apt install -y  axel curl medit synaptic 

# 透明效果
apt install -y  compton compton-conf compton-conf-l10n

# 安装pcmanfm时，会把lxde一起安装。如果不安装lxde桌面，安装pcmanfm则添加参数“--no-install-recommends”
apt install -y  pcmanfm 
# 编译pcmanfm时用
apt install -y  libfm-dev libfm-data libfm4 libfm-extra4  libfm-tools  libfm-doc libfm-modules libfm-gtk4 libfm-gtk-dev libfm-gtk-data



# 安装编译环境 
# libghc-gi-gobject-dev 
apt install -y  gcc dkms make cmake cmake-extras build-essential module-assistant gdb git
apt install -y  autoconf automake autopoint autotools-dev
apt install -y  pkg-config python-pkgconfig python3-pkgconfig   
apt install -y  libgtk-3-dev libglib2.0-dev gtk-doc-tools libgtk3-perl
apt install -y  libgtk-3-doc libgtk2.0-doc libglib2.0-doc  devhelp
apt install -y  perl ruby

apt install -y  ntfs-3g ntfs-3g-dev fuse  
apt install -y  apt-file apt-doc apt-show-versions 
apt install -y  apt-rdepends apt-mirror apt-move autokey-gtk 
#local-apt-repository
apt install -y  apt-config-icons-large  apt-config-icons-large-hidpi  apt-config-icons-hidpi
apt-file update

# 可忽略
#apt install -y  linuxinfo linux-doc linuxdoc-tools

# qt4
apt install -y  pyqt4-dev-tools  libqt4-dev  qt4-qtconfig

#安装Qt5库
apt install -y  qtbase5-dev qttools5-dev-tools

apt install -y  gconf-editor dconf-editor

apt install -y  python3-pip python3-lxml python3-crypto python3-keyring python3-notify2
apt install -y  python-pip python-lxml python-crypto python-keyring python-notify2

# ---------------------------------安装软件--------------------------------- #

# 安装驱动
apt install -y  firmware-linux-nonfree  firmware-linux

# 安装无线网络和图形管理工具
apt install -y  firmware-iwlwifi  wireless-tools  firmware-realtek gnome-nettool inetutils-tools net-tools
apt install -y  network-manager  network-manager-gnome
sed 's/managed=false/managed=true/g' -i /etc/NetworkManager/NetworkManager.conf
# 有线连接未托管(ubuntu18.04使用,debian10不用)
#printf ",except:type:ethernet"  >> /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf
service network-manager restart
systemctl enable NetworkManager

# 网卡显示eth0
defaultgrub="/etc/default/grub"
[ -f ${defaultgrub}.bak ] && cp ${defaultgrub}.bak ${defaultgrub} || cp ${defaultgrub} ${defaultgrub}.bak
# virtualbox中不要使用，有可能出现无法连接网络的情况
sed 's/GRUB_CMDLINE_LINUX=/#GRUB_CMDLINE_LINUX=/g' -i /etc/default/grub
echo 'GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg 

# 没有声音，安装
apt install -y  alsa-utils alsa-tools alsa-tools-gui  pavucontrol jack

# 安装主题：/usr/share/themes/或者~/.themes
apt install -y  gtk2-engines-oxygen oxygen-icon-theme oxygencursors 
apt install -y  gtk2-engines-aurora gtk2-engines-cleanice
apt install -y  gtk2-engines-sugar sugar-icon-theme 
apt install -y  gtk3-engines-breeze breeze-gtk-theme breeze-icon-theme
apt install -y  adwaita-icon-theme clearlooks-phenix-theme human-icon-theme faenza-icon-theme
apt install -y  albatross-gtk-theme  murrine-themes xcursor-themes
apt install -y  gtk-chtheme gtk-theme-switch  


# 设置QT样式qtconfig-qt4
#apt-file search  qtconfig
apt install -y  qtcurve  qt4-qtconfig

# 修改grub
sed 's/GRUB_GFXMODE/#GRUB_GFXMODE/g' -i /etc/default/grub
echo "GRUB_GFXMODE=${resolution}" >> /etc/default/grub 
grub-mkconfig -o /boot/grub/grub.cfg 
 

# ------------------------------------------安装输入法-----------------------------------------
# 安装中文字体，避免出现方块字
apt install -y  ttf-wqy* 

# 字体编辑器
apt install -y  font-manager  fontforge fontforge-extras fontforge-doc  
apt install -y  gsfonts-x11 libfonts-java  ttf-unifont tv-fonts xfonts-unifont

# 放大系统字体
apt install -y  gconf-editor libglib2.0-bin
# 文本比例因子
gsettings set org.gnome.desktop.interface text-scaling-factor '1.2'  

apt install -y  ttf-arphic-* xfonts-wqy fonts-arphic-*  xfonts-intl-chinese  ttf-xfree86-nonfree 
apt install -y  fcitx fcitx-tools fcitx-m17n fcitx-sunpinyin fcitx-googlepinyin im-config ucimf-sunpinyin

# Fcitx 轻量的基于 xlibs 和 xft 的界面
apt install -y  fcitx-ui-light

# fcitx-pinyin　fcitx-libpinyin 这步可能会出问题
#apt install -y  fcitx-libpinyin  fcitx-pinyin
apt install -y  fcitx-libpinyin sunpinyin-utils fcitx-module-cloudpinyin fcitx5-module-xorg kde-config-fcitx

profileconf="/etc/profile"
[ -f ${profileconf}.bak ] && cp ${profileconf}.bak ${profileconf} || cp ${profileconf} ${profileconf}.bak

cat >> /etc/profile << "EOF"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/lib/pkgconfig
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
EOF

source /etc/profile
ln -sf /etc/X11/xinit/xinput.d/fcitx /etc/alternatives/xinputrc
 
# ------------------------------------------------------------------ #
#                     安装网络工具
# ------------------------------------------------------------------ #
apt install -y  firefox-esr firefox-esr-l10n-zh-cn fonts-stix
# chromium可能和baidunetdisk冲突，可能要二选一
apt install -y  chromium chromium-l10n 
# falkon (qupzilla)
apt install -y  falkon falkon-plugin-wallet
#apt install -y  epiphany-browser midori

apt install -y  pidgin uget aria2 iptux  filezilla amule amule-utils-gui amule-gnome-support
apt install -y  deluge deluge-gtk deluge-web  ktorrent lftp vsftpd
apt install -y  qbittorrent libboost-dev libboost-filesystem-dev libtorrent-rasterbar-dev
apt install -y  brag cl-base64
apt install -y  uget  kget quiterss  liferea  akregator 

# linux光盘刻录软件：
apt install -y  k3b k3b-i18n brasero xfburn  devede

apt install -y  linphone linssid  
apt install -y  owncloud-client owncloud-client-data owncloud-client-doc  

# 防火墙
# FireWallD（取代gufw）和iptables 只能二选一
# 检查 /etc/services文件，查看服务的名字及对应的端口和协议
apt install -y  firewalld firewall-config firewall-applet
systemctl enable firewalld

# Error: COMMAND_FAILED: '/usr/sbin/ip6tables-restore -w -n' failed: ip6tables-restore v1.8.2 (nf_tables):
# 解决办法：不要使用-restore组合呼叫，而要使用单个呼叫
sed 's|IndividualCalls=no|IndividualCalls=yes|g' -i /etc/firewalld/firewalld.conf

systemctl start firewalld
firewall-cmd --set-default-zone=public
# 端口20018给ssh测试用，可以修改
firewall-cmd --permanent --zone=public --add-port=20018/tcp
firewall-cmd --permanent --zone=public --add-service=ssh
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-service=vnc-server
firewall-cmd --permanent --zone=public --add-service=mysql
firewall-cmd --permanent --zone=public --add-service=postgresql
#firewall-cmd --permanent --zone=public --add-service=dhcp
#firewall-cmd --permanent --zone=public --add-service=dns
#firewall-cmd --permanent --zone=public --add-service=finger
firewall-cmd --permanent --zone=public --add-service=ntp
# firewall-cmd --permanent --remove-service=dns
firewall-cmd --reload 

# 开机启动ufw(关机会变慢)，设置默认策略，允许SSH连接
apt install -y  gufw python-ufw
ufw disable
systemctl disable ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow sftp
ufw allow vnc
# mysql端口3306
ufw allow mysql

#sftp -P 20018 192.168.2.89

# Shorewall 是 IPTables 的防火墙生成器，允许使用简单的配置文件进行高级配置
apt install -y  shorewall shorewall-doc shorewall-lite  shorewall6-lite pyroman
systemctl disable shorewall

# 文本界面的网页浏览器
apt install -y  w3m w3m-img  elinks elinks-data links2 links

# 网络测试软件合集
apt install -y  nethogs medusa  python-medusa  python-medusa-doc nmap zenmap  hydra awstats 
apt install -y  iftop  iptraf slurm speedometer nmon dstat saidar 
apt install -y  htop glances iotop moreutils 
systemctl disable glances
# 开放（客户端-服务器模式 CS模式）端口，监控远程 Linux 系统
firewall-cmd --permanent --zone=public --add-port=61209/tcp

# Hashcat 是世界上最快的密码破解程序，是一个支持多平台、多算法的开源的分布式工具
apt install -y  hashcat

# etherape ettercap-graphical ettercap-common安装包clamav提示有病毒
# ------------------------------------------------------------------ #
#                    安装音频/视频
# ------------------------------------------------------------------ #
# 安装音频/视频
apt install -y  smplayer  mpv libmpv-dev mencoder mplayer xvfb 

# mpv配置
mpvconf="/etc/mpv/mpv.conf"
[ -f ${mpvconf}.bak ] && cp ${mpvconf}.bak ${mpvconf} || cp ${mpvconf} ${mpvconf}.bak

cat >> /etc/mpv/mpv.conf << "EOF"
[mympv-gui]
# 终端=否
terminal=no
# 空闲=1次
idle=once
# 强制窗口=是
force-window=yes
# 限制窗口大小
geometry=90%x82%
#geometry=683x384
# 多长时间隐藏鼠标
#cursor-autohide=5

# 指定要使用的视频输出后端,默认使用GPU加速的视频输出
#vo=gpu
# 使用解码器（默认 no），软解码（no），硬解码（yes）[no,yes,auto]，避免使用硬件解码
#hwdec=no
# 顺时针旋转视频，以度为单位。<0-359 |否>
video-rotate=0
# 调整视频显示比例。不缩放:0，两倍:1，二分之一:-1，依此类推
video-zoom=0


# 默认选中中文字幕
# 指定要使用的字幕语言的优先级列表
slang=zh-CN,chi,sc,chs
# 指定要使用的音频语言的优先级列表
alang=zh-CN,chi,sc,chs
# 相当于--alang和--slang，用于视频轨道
vlang=zh-CN,chi,sc,chs

#将非utf8编码的字幕转换成utf8，解决所有乱码问题，依赖enca
#sub-codepage=zh_CN.UTF-8,zh_CN.GB18030,iso8859-1
sub-codepage=enca:zh:utf8,iso8859-1


# 会在播放音频文件时显示图像附件（例如专辑封面）（默认）,no 在播放音频文件时完全禁用视频显示,对具有正常视频轨道的文件没有影响
audio-display=no

# osd相关
osd-bar=
# osd level级别
# 0:OSD完全禁用（仅字幕）
# 1:启用（仅在用户交互时显示）
# 2:默认启用2个+当前时间
# 3:启用+ --osd-status-msg（默认为当前时间和状态）
osd-level=3
osd-msg3=
# 设置搜索期间OSD上显示的内容。默认值为bar <no，bar，msg，msg-bar>
#osd-on-seek=bar

#显示OSD时间（以秒为单位）（以毫秒为单位）。 有助于查看视频帧的确切时间戳，需要配合osd-level=3使用
osd-fractions=
# 以毫秒为单位设置OSD消息的持续时间（默认值：1000）
#osd-duration=
# 指定用于OSD的字体。缺省值为sans-serif
osd-font='sans-serif'
osd-font-size=30

#消息文件：后跟一个空格和当前播放的文件名
#osd-playing-msg='file：${filename}'

# loop-file = <N | inf | no>，-loop = <N | inf | no>循环单个文件N次。 inf表示永远，不表示正常播放
loop-file=no
# keep-open 会导致 smplayer playlist 在一个视频播放完成后无法自动播放下一个视频(可用于视频结束时间)
#keep-open=yes
# 如果设置为no，则在--keep-open处于活动状态时不会暂停，而只是在文件末尾停止，而在向后搜索时继续向前播放直到结束为止。默认值：是
#keep-open-pause=yes

[mpv-gui]
#player-operation-mode=pseudo-gui
EOF

sed -e "s/^Exec=mpv/#Exec=mpv/g" -i /usr/share/applications/mpv.desktop
sed -e '/#Exec=mpv/a\Exec=mpv --profile=mympv-gui' -i /usr/share/applications/mpv.desktop

#apt install -y  vlc libvlc-dev libvlccore-dev  
apt install -y  audacious  audacious-dev gnome-audio
apt install -y  mpd gmpc sonata ario ncmpc ncmpcpp
apt install -y  deadbeef deadbeef-infobar deadbeef-musical-spectrum deadbeef-plugins-dev deadbeef-rating deadbeef-spectrogram deadbeef-vu-meter deadbeef-waveform-seekbar
apt install -y  ffmpeg ffmpeg-doc  winff winff-doc

apt install -y  vokoscreen gtk-recordmydesktop  
apt install -y  python-mutagen  easytag exfalso 
apt install -y  id3 id3ren id3tool id3v2

# 高清解码器
apt install -y  x264 libx264-dev h264enc x265 libx265-dev libde265-dev libde265-0  mpeg3-utils libmpeg2-4-dev libmpeg3-2  libsmpeg-dev  mpg123
apt install -y  libgmp3-dev libsdl-mixer1.2-dev   libsdl2-mixer-dev libxine2 

# Crystal HD Video Decoder 
apt install -y  libcrystalhd-dev  gstreamer1.0-crystalhd 
apt install -y  faac gpac libgpac-dev  libbitstream-dev  gopchop

# gstreamer框架
apt install -y  gstreamer1.0-alsa  gstreamer1.0-pulseaudio
apt install -y  gstreamer1.0-libav  
apt install -y  gstreamer1.0-doc gstreamer1.0-tools 
apt install -y  gstreamer1.0-plugins-good  gstreamer1.0-plugins-good-doc 
apt install -y  gstreamer1.0-plugins-bad  gstreamer1.0-plugins-bad-doc
apt install -y  gstreamer1.0-plugins-base  gstreamer1.0-plugins-base-doc gstreamer1.0-plugins-ugly 

# 音视频编辑软件
apt install -y  openshot openshot-doc flowblade audacity imagination handbrake handbrake-gtk avidemux lives

apt install -y  cheese guvcview 

# ************************************************************************************************

# 安装gnome图形：
apt install -y  gthumb gpicview ristretto  shotwell gprename  gnome-screenshot  gnome-paint 

apt install -y  inkscape  gimp gimp-data-extras gimp-gutenprint gimp-help-common gimp-ufraw abr2gbr ufraw 

# 安装kde图形：
apt install -y  gwenview digikam kipi-plugins krename kde-l10n-zhcn showfoto   
  
# 安装压缩工具:
apt install -y  file-roller  unace unrar rzip p7zip  p7zip-rar  patool minizip libzip-dev fuse-zip rarcrack fcrackzip crack arj cabextract ark
apt install -y  engrampa lhasa sharutils ncompress lzip lzop unalz  rar

# PDF工具
apt install -y  evince okular okular-extra-backends pdfcrack wkhtmltopdf pdftk man2html chm2pdf 
# chm工具
apt install -y  kchmviewer xchm python-chm python3-chm

# 数学计算器
apt install -y  galculator gnome-genius genius genius-dev speedcrunch qalculate qalculate-gtk cantor

# 编码转换
apt install -y  convmv fuse-convmvfs enca uni2ascii ascii

apt install -y  acetoneiso  isomd5sum makefs

apt install -y  mtr ttyrec rsync curl calcurse remind wyrd cloc
apt install -y  keepass2 gpa bless hexedit 
apt install -y  hardinfo hwinfo lshw screenfetch neofetch most gpm 
systemctl enable gpm

# 代码比对工具
apt install -y  meld diffuse 

# 计算信息摘要或校验工具
apt install -y  gtkhash


#apt install -y  gcolor2 gnome-color-chooser
apt install -y  gnome-colors gnome-color-manager

apt install -y  logwatch osmo debian-faq-zh-cn syslog-summary 

apt install -y  spacefm-gtk3  


# 其他文件系统支持
apt install -y  xfsprogs xfsdump jfsutils btrfs-tools hfsprogs hfsutils hfsplus dosfstools mtools 
apt install -y  aufs-tools udftools zfs-fuse libzfs2linux libzfslinux-dev
# systemctl list-unit-files | grep zfs
systemctl disable zfs-fuse

apt install -y  gringotts sweethome3d
apt install -y  qtqr scribus calibre
#apt install -y  zint zint-qt
apt install -y  gimagereader yagf 
apt install -y  screen dtach tmux 

apt install -y  bash-completion command-not-found bash-builtins bash-doc 
update-command-not-found 

# 文本编辑器 
apt install -y  medit  mousepad  kate featherpad
# mousepad显示行号
gsettings set org.xfce.mousepad.preferences.view show-line-numbers 'true'

# Zim记事软件,基于维基(wiki)技术的图形化文本编辑器
apt install -y  zim zimwriterfs 
# zim插件
apt install -y  graphviz graphviz-doc libgtksourceview2.0-dev libgtkspell-dev dvipng python3-seqdiag python-seqdiag

# 配置工具
apt install -y  gconf-editor  dselect fbset  quota  tasksel  extra-xdg-menus  seahorse gnome-system-monitor

# 安装工具
apt install -y  alien  gip  gparted groff kdeedu system-config-printer  sysv-rc-conf uptimed whohas
apt install -y  gdebi  
# qapt-deb-installer(类似gdebi)
systemctl enable uptimed



# 安装字典
apt install -y  qstardict goldendict babiloo

# 显示传感器
apt install -y  python-keyring curl conky-all python-feedparser psensor psensor-server lm-sensors  hddtemp
chmod u+s /usr/sbin/hddtemp
sh -c "yes|sensors-detect"
/etc/init.d/kmod start 

# 清理工具
apt install -y  bleachbit fslint  

# 安装游戏：
apt install -y  kajongg kdiamond kmahjongg knetwalk kolf billard-gl dreamchess frozen-bubble mah-jong pipewalker snake4 supertuxkart gnome-games supertux  education-logic-games  gnome-mines kmines   extremetuxracer bzflag vodovod barrage briquolo kobodeluxe bovo 


# 在现有的图形界面中，还可以以窗口模式运行另外一个X Server，称为nested X Server。最常用的nested X Server是Xephyr
apt install -y  xserver-xephyr x11-utils

# 终端
apt install -y  aterm  aterm-ml kxterm  
apt install -y  xterm xtermset  xtermcontrol
apt install -y  rxvt-ml rxvt-unicode 
apt install -y  xfce4-terminal  guake guake-indicator tilda terminator terminology  
apt install -y  mlterm mlterm-im-fcitx mlterm-im-m17nlib

# 安装fbterm
apt install -y  fbterm  fcitx-frontend-fbterm fbterm-ucimf v86d
echo 'GRUB_GFXPAYLOAD_LINUX=keep' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
chmod 765 /dev/fb0 
chmod u+s /usr/bin/fbterm
gpasswd -a ${User_Owner}  video 

# 字符界面下的文件管理器
apt install -y  doublecmd-gtk tuxcmd tuxcmd-modules mc ranger vifm 

# 字符界面下的一些工具
apt install -y  sox libsox-fmt-all cmus moc 
apt install -y  fbi fim exiftran tmux fbcat finch 

apt install -y  sl cmatrix linuxlogo screenfetch figlet toilet pv cowsay xcowsay lolcat libaa-bin 
apt install -y  ddate ccal jp2a aview

apt install -y  gigolo gvfs gvfs-common 
apt install -y  putty putty-doc pterm 

apt install -y  tightvncserver gvncviewer vinagre

# 虚拟机管理kvm(暂时不需要)
#apt install -y  virt-manager imvirt libvirt-dev libvirt-doc virt-goodies virt-top virt-what
#apt install -y  virtinst virt-top virt-viewer libvirt-clients  bridge-utils
#apt install -y  qemu qemu-kvm qemu-block-extra qemu-guest-agent qemu-user-static qemuctl aqemu cpu-checker
#systemctl disable libvirtd

# 数学工具合集
apt install -y  geogebra geogebra-gnome kalzium avogadro gabedit kbruch kmplot kalgebra step octave  gnuplot  graphmonkey stellarium  avogadro

apt install -y  jmtpfs  libmtp-dev  mtp-tools  gmtp 
apt install -y  galternatives

# 安装打字软件
apt install -y  typespeed

# 从 DOS 格式转换为 Unix 格式
apt install -y  dos2unix

# 集成开发环境
apt install -y  anjuta anjuta-extras 
apt install -y  sqlitebrowser sqlite3 sqlite3-doc sqlsmith
apt install -y  geany geany-plugins
apt install -y  kdevelop  kdevelop-l10n

# 安装minicom
apt install -y  minicom  gtkterm 

# 屏幕保护程序
apt install -y  xscreensaver xscreensaver-data xscreensaver-data-extra xscreensaver-gl xscreensaver-gl-extra

# xournal 可以通过手写板手写或者在笔记上涂鸦
apt install -y  xournal


# 面板
apt install -y  plank libplank-dev libplank-doc pnmixer 

# 其他
apt install -y  dfc scite tree gnome-system-monitor colordiff fping pwgen locate mlocate bmon

# ssh相关
apt install -y  openssh-client openssh-server zenity xserver-xephyr sshfs


# extensible deep packet inspection library - ndpiReader
apt install -y  libndpi2.6 libndpi-dev libndpi-bin

# 设置屏幕DPI
# 如果你设置DPI是通过在/etc/X11/Xinit/Xserverrc中添加参数-dpi 96，那么设置在slim中是不起作用的
# 添加内容，红字部分为dpi，普通屏幕无需修改，高分辨率的请自行参考资料
#Debian/Ubuntu 下 X server 默认会使用 96 dpi,可以通过以下命令查看你的 X server 的 dpi 设置： xdpyinfo |grep resolution
# https://www.pxcalc.com/  输入分辨率和尺寸就计算出点距和dpi  1920x1080 15.6英寸1080P 的IPS屏幕
# 修改/etc/fonts/fonts.conf
#/etc/slim.conf
#xserver_arguments   -nolisten tcp vt02 -dpi 141
#xrandr --dpi 141

# mate相关
apt install -y  mate-system-monitor

# 免费会计软件
# GnuCash 为中小企业和个人提供了会计功能 ，提示libaqbanking35需要更新 apt upgrade libaqbanking35
# apt install -y  gnucash
apt install -y  homebank

# entr 是一个命令行工具，当每次更改一组指定文件中的任何一个时，都能运行一个任意命令
# redshift 根据时间自动地调整屏幕的色温
apt install -y  zsh zsh-doc  
apt install -y  redshift gtk-redshift 
apt install -y  entr checkinstall

# 制图工具freecad
apt install -y  freecad freecad-python3

# 实用程序 gPhoto2 备份手机存储
apt install -y  gphoto2

# 安装web服务器相关组件
apt install -y  apache2 
apt install -y  libapache2-mod-fcgid  libapache2-mod-php 

# 安装php7及相关模块
apt install -y  php-mysql php-pgsql php-sqlite3   
apt install -y  php-fpm  php-cgi php-cli php-ssh2 php-memcached php-gd php-all-dev
apt install -y  php-apcu php-mbstring

# 蓝牙(先禁止，需要时再开启服务)
apt install -y  blueman  bluez-firmware bluez-tools  bluez-hcidump rfkill


# 安装Flatpak  https://flatpak.org/
apt install -y  flatpak libflatpak-dev libflatpak-doc

# 一个高级的菜单编辑器
apt install -y  menulibre 

# 安装缺少依赖(make menuconfig)
apt install -y  libncurses5-dev libelf-dev libssl-dev flex bison

# 安装remmina，如果不行使用buster-backports源
#apt install -y  -t buster-backports  remmina remmina-dev remmina-plugin-nx remmina-plugin-xdmcp remmina-plugin-exec remmina-plugin-rdp remmina-plugin-secret remmina-plugin-vnc 
apt install -y  remmina remmina-dev remmina-plugin-nx remmina-plugin-xdmcp remmina-plugin-exec remmina-plugin-rdp remmina-plugin-secret remmina-plugin-vnc 

# clamav杀毒软件
apt install -y  clamav clamtk clamav-docs clamav-daemon  clamassassin libclamunrar
systemctl disable clamav-daemon
echo 'DatabaseMirror db.cn.clamav.net' >> /etc/clamav/freshclam.conf
echo 'DatabaseMirror database.clamav.net' >> /etc/clamav/freshclam.conf


# Mu，Python 编辑器
# sudo apt-file find mu-editor | cut -d ":" -f1 | uniq
apt install -y  mu-editor mu-editor-doc

# 文件转换工具
apt install -y  pandoc

# 恢复 Linux 上已删除的文件
# foremost	命令行	formost 是一个基于文件头和尾部信息以及文件的内建数据结构恢复文件的命令行工具
# extundelete	命令行	Extundelete 是 ext3、ext4 文件系统的恢复工具
# scalpel	命令行	scalpel 是一种快速文件恢复工具，它通过读取文件系统的数据库来恢复文件。它是独立于文件系统的
# testdisk	字符终端	Testdisk 支持分区表恢复、raid 恢复、分区恢复
# phtorec	字符终端	photorec 用来恢复硬盘、光盘中丢失的视频、文档、压缩包等文件，或从数码相机存储卡中恢复丢失的图片
apt install -y  foremost extundelete scalpel testdisk 

# 使用 S.M.A.R.T. 控制和监视存储系统
apt install -y  smartmontools smart-notifier
systemctl start smartd    

# 加密工具(另外veracrypt)
#apt install -y  cryptsetup keyutils
apt install -y  bcrypt mcrypt
apt install -y  zulucrypt-gui  zulumount-gui  libzulucryptpluginmanager-dev  libzulucrypt-plugins libzulucrypt-dev

# 安全审计工具lynis(最好使用最新版本,git下载)
# git clone https://github.com/CISOfy/lynis.git
# 不安装tripwire 
# 不安装samhain，防止开机产生一堆信息
# 不安装libpam-tmpdir ，使用veracrypt时有问题，无法显示挂载盘，但能使用，相当于隐藏
# 要审计你的系统的安全态势，运行以下命令：
# lynis audit system
apt install -y  lynis 
apt install -y  apt-listbugs debsecan debsums aide 
#needrestart

# jigdo下载 jigdo-lite
#http://cdimage.debian.org/cdimage/archive/  debian历史版本下载
#sudo apt install jigdo-file
#wget -cN http://cdimage.debian.org/cdimage/archive/8.9.0/amd64/jigdo-cd/debian-8.9.0-amd64-CD-1.jigdo
#wget -cN http://cdimage.debian.org/cdimage/archive/8.9.0/amd64/jigdo-cd/debian-8.9.0-amd64-CD-1.template
#jigdo-lite debian-8.9.0-amd64-CD-1.jigdo
apt install -y  jigdo-file



# 文本编辑器
apt install -y  kakoune  
apt install -y  vim vim-doc vim-gtk vim-gtk3 vim-editorconfig 

# exa 是一个 Linux ls 命令的现代替代品，是用 Rust 编写的
apt install -y  exa

#-------------------------------------------------------------------------#
#                           需要互动的
#-------------------------------------------------------------------------#

# 安装wine：
apt install -y  wine 
apt install -y  q4wine playonlinux 
apt install -y  gnome-exe-thumbnailer


# 登录管理器（slim,lightdm,lxdm），lxdm配合lxde使用(不用)，使用slim/lightdm+桌面
apt install -y  slim 

apt install -y  lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings liblightdm-qt-dev  lightdm-vala 

# lightdm主题配置
greeterconf="/etc/lightdm/lightdm-gtk-greeter.conf"
[ -f ${greeterconf}.bak ] && cp ${greeterconf}.bak ${greeterconf} || cp ${greeterconf} ${greeterconf}.bak

ln -sf /usr/share/images/desktop-base/desktop-background /usr/share/images/desktop-base/lightdm_user_pic.jpg

cat >> /etc/lightdm/lightdm-gtk-greeter.conf << "EOF"
background=/usr/share/images/desktop-base/lightdm_user_pic.jpg
theme-name=Adwaita
show-indicators=~language;~session;~power
show-clock=true
clock-format=%F %A %T
# 设置 position，这个设置接受 x 和 y 变量，可以使用绝对值(pixels)或相对值(percent). 每个变量都可以增加一个额外的锚定位置 start, center 和 end，数值间用 comma 分隔
position=200,start 50%,center
EOF
 

#apt install -y  linux-libc-dev-amd64-cross deepin-music
# Small toolbox-style utilities for Debian systems
apt install -y  debian-goodies

apt install -y  wireshark wireshark-qt  

# 不用，使用thunderbird
#apt install -y  claws-mail claws-mail-doc claws-mail-tools claws-mail-plugins

# ------------------------------------------------------------------ #
# systemctl相关配置
# ------------------------------------------------------------------ #
# 显示系统启动时间
#systemd-analyze time

# 禁止启动一些服务(需要的时候再开启，视情况而定)，加快启动速度 php7.3-fpm
# /var/lib/snapd/apparmor/profiles
systemctl disable snapd apparmor zfs 
systemctl disable postgresql mariadb
systemctl disable vsftpd apache2 
systemctl disable php7.3-fpm phpsessionclean.timer
systemctl disable bluetooth
#systemctl disable glances

systemctl disable anacron.timer anacron.service
# systemctl list-unit-files | grep apt-daily
systemctl disable apt-daily.timer  apt-daily-upgrade.timer
systemctl disable man-db.timer
# systemctl --all | grep not-found 查看有哪些服务挂掉了,然后再考虑disable

# 根分区安装在了 SSD 上，启用 TRIM 会帮助清理 SSD 中的块，从而延长 SSD 的使用寿命
#systemctl enable fstrim.timer
echo -e "\e[1;32mIf your OS install in SSD disk,please enable trim service!\e[0m"
echo "1.enable  trim service"
echo "2.disable trim service"
read -p "choice: " number
case $number in 
    "1")
    systemctl enable fstrim.timer
    ;;
    "2")
    systemctl disable fstrim.timer
    ;;
    *)
    systemctl disable fstrim.timer
    ;;
esac

# ------------------------------------------------------------------ #
# 删除不必要的程序
apt remove --purge wicd* lxmusic popularity-contest -y
# 删除reportbug工具，需要时再安装
apt remove --purge reportbug -y
apt autoremove -y
# ------------------------------------------------------------------ #

# 更换默认窗口管理器
# update-alternatives --config x-window-manager

# 更换默认桌面 xfce4
update-alternatives --config x-session-manager


#--------------------------------Caja文件管理器相关，非常耗内存，非mate桌面不建议使用--------------------------------#
#apt install -y  caja caja-admin caja-extensions-common caja-actions-dev caja-actions caja-rename caja-share python-caja caja-gtkhash caja-open-terminal caja-image-converter caja-seahorse caja-wallpaper caja-xattr-tags exe-thumbnailer 

#caja文件管理器显示路径
#gsettings set org.mate.caja.preferences always-use-location-entry  true

#caja设置默认缩略图大小[查看缩略图，默认64]
#gsettings set org.mate.caja.icon-view thumbnail-size 280

#caja文件属性高级权限设置
#gsettings set org.mate.caja.preferences show-advanced-permissions true

#caja显示左侧树形视图
#gsettings set org.mate.caja.window-state side-pane-view 'tree'

# mate桌面不显示图标
#gsettings set org.mate.background show-desktop-icons 'false'

# 设置字体DPI，默认0，高分屏使用
# https://www.pxcalc.com/  输入分辨率和尺寸就计算出点距和dpi  1920x1080 15.6英寸1080P 的IPS屏幕
#gsettings set org.mate.font-rendering dpi "141"

# ---------------------------------配置--------------------------------- #
# sudo 配置
# 不能在root和 user下同时使用gksu-properties，否则会登陆不了root
#apt install -y  libgksu2-0
#gksu-properties
# 将认证模式由su改为sudo,然后修改/etc/sudoers，添加一行：
printf "\n${User_Owner}    ALL=(ALL) ALL" >> /etc/sudoers

bashrc="/root/.bashrc"
[ -f ${bashrc}.bak ] && cp ${bashrc}.bak ${bashrc} || cp ${bashrc} ${bashrc}.bak

cat  >> /root/.bashrc << "EOF"
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ll='ls -l'
alias la='ls -Al'
alias l='ls -CF'

alias dfls='df -Th'
alias top1='top -n 1'
alias psall='ps aux'
alias kill9='kill -9'
alias lns='ln -s'
alias duls='du -d 1 -h'
alias dusort='du -d1 -h | sort -k1 -h'

alias aptin='apt install'
alias aptdel='apt remove'
alias aptclean='apt clean'

alias aptautoremove='apt autoremove'
alias aptupdate='apt update'
alias aptinstallf='apt install -f'

alias aptse='apt-file search'
alias aptfind='apt-file find'
alias mountiso='mount -o loop'

alias debin='dpkg -i'
alias debdel='dpkg -e'
alias deblist='dpkg -L'
alias debinfo='dpkg -l'

alias services_running='systemctl list-units  --type=service  --state=running'
alias rsync='rsync -vzhP'
alias curlget='curl -O -C -'

alias youget-default_dir='you-get -o ~/youget'

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/lib/pkgconfig
EOF


# 禁用自带的 nouveau nvidia驱动 ，防止开机出现黑屏，先在grub引导菜单中添加nomodeset（调用集显）
cat > /etc/modprobe.d/blacklist-nouveau.conf << "EOF" 
blacklist nouveau
options nouveau modeset=0
EOF
# 显卡相关
sed 's/GRUB_CMDLINE_LINUX_DEFAULT/#GRUB_CMDLINE_LINUX_DEFAULT/g' -i /etc/default/grub
echo 'GRUB_CMDLINE_LINUX_DEFAULT="panic=5 quiet acpi_osi=linux"' >> /etc/default/grub
update-grub
update-initramfs -u


# 根据实际分区修改(C盘,D盘,E盘,F盘)
# debian10下无法读写ntfs磁盘(突然断电)，先卸载，然后修复(ntfsfix)
cd /mnt && mkdir -p c d e f 

fstab="/etc/fstab"
[ -f ${fstab}.bak ] && cp ${fstab}.bak ${fstab} || cp ${fstab} ${fstab}.bak

cat >> /etc/fstab << "EOF"
#/dev/sdb3  /mnt/c  ntfs  defaults,auto,rw,uid=1000,gid=1000  0 0
#/dev/sdb4  /mnt/d  ntfs  defaults,auto,rw,uid=1000,gid=1000  0 0
#/dev/sda2  /mnt/e  ntfs  defaults,auto,rw,uid=1000,gid=1000  0 0
#/dev/sda3  /mnt/f  ntfs  defaults,auto,rw,uid=1000,gid=1000  0 0

#/dev/sda4  /mnt/g  ntfs defaults,auto,rw,uid=1000,gid=1000  0 0
#/swap/swapfile  swap swap defaults 0 0
EOF

# 更新 USB ID(debian需要手动下载 )
# 数据库文件位于 /var/lib/usbutils  
cp /var/lib/usbutils/usb.ids  /var/lib/usbutils/usb.ids.old
wget http://www.linux-usb.org/usb.ids -cN -P /var/lib/usbutils
cat > /usr/local/bin/update-usbids << "EOF"
#!/bin/bash
# Update USB ID
wget http://www.linux-usb.org/usb.ids -cN -P /var/lib/usbutils
EOF
chmod 755 /usr/local/bin/update-usbids

# updatedb时候报错"find: ‘/run/user/1000/gvfs’: Permission denied",解决方法：
# umount /run/user/1000/gvfs
# rm -rf /run/user/1000/gvfs


# 设置最大监控文件数量，默认值：8192 
# 8192(8M),16384(16M),32768(32M),65536(64M),131072(128M),262144(256M),524288(512M)
# 查看：cat /proc/sys/fs/inotify/max_user_watches    
echo "fs.inotify.max_user_watches=131072" >> /etc/sysctl.conf 


# ------------------------------------------------------------------ #
# 关机时间太长的调查和解决的方法
# ------------------------------------------------------------------ #
# 1.在systemd中启用并激活 journal 日志
# 检查 /etc/systemd/journald.conf 文件的内容，并确保 Storage 的值被设置为自动（auto）或持久（persistent）。
[ ! -d "/var/log/journal" ] &&  mkdir -pv /var/log/journal
journaldconf="/etc/systemd/journald.conf"
[ -f ${journaldconf}.bak ] && cp ${journaldconf}.bak ${journaldconf} || cp ${journaldconf} ${journaldconf}.bak
sed 's|#Storage=auto|Storage=auto|g' -i /etc/systemd/journald.conf

# 2.通过减少默认停止超时来加快 Linux 中的关机速度（快速修复）
systemconf="/etc/systemd/system.conf"
[ -f ${systemconf}.bak ] && cp ${systemconf}.bak ${systemconf} || cp ${systemconf} ${systemconf}.bak
sed 's|#DefaultTimeoutStopSec=90s|DefaultTimeoutStopSec=10s|g' -i /etc/systemd/system.conf

# 3.看门狗的模块(可选)
# 检查看门狗是否在运行：ps -af | grep watch*
# 修改配置文件 /etc/systemd/system.conf 中将 ShutdownWatchdogSec 的值从 10 分钟改为更低的值
#sed 's|#ShutdownWatchdogSec=10min|ShutdownWatchdogSec=1min|g' -i /etc/systemd/system.conf

# ------------------------------------------------------------------ #
# 中文化
dpkg-reconfigure locales

# 更改虚拟终端字体
# 所有虚拟终端字体 /usr/share/consolefonts/
echo -e "FONT='CyrSlav-TerminusBold22x11.psf.gz'" >> /etc/default/console-setup



# ------------------------------------------------------------------ #
# Virtualbox 下使用USB 
# ------------------------------------------------------------------ #
# 1.下载对应的 Extend pack
# 2.添加 usbfs 用户组（virtualbox 装完成后会有 vboxusers 和vboxsf ）
#groupadd usbfs 

# 将用户添加到vboxusers、usbfs这个两个组中
#gpasswd -a  ${User_Owner} vboxusers
#gpasswd -a  ${User_Owner} usbfs

# 查看添加是否成功
#cat /etc/group | egrep "vboxusers|vboxsf|usbfs"



# ------------------------------------------------------------------ #
# grub引导FreeBSD（win7+freebsd12.2+debian10三系统） 
# ------------------------------------------------------------------ #
apt install -y  aufs-tools udftools zfs-fuse libzfs2linux libzfslinux-dev
# 模板：需要的话，反注释一下
custom="/etc/grub.d/40_custom"
[ -f ${custom}.bak ] && cp ${custom}.bak ${custom} || cp ${custom} ${systemconf}.bak

cat > /etc/grub.d/40_custom << "EOF"
#!/bin/sh
exec tail -n +3 $0
# # FreeBSD模板，需要的话，反注释下面
# menuentry "FreeBSD-12.2" {
#    insmod ufs2
#    set root=(hd0,3)        # freebsd安装在/dev/sda3中
#    kfreebsd /boot/loader   # kfreebsd /boot/kernel/kernel  //和前面一样
#    kfreebsd_loadenv /boot/device.hints
#      # 下面可选，主要是上面
#     # set kFreeBSD.vfs.root.mountfrom=ufs:/dev/ada0
#     # set kFreeBSD.vfs.root.mountfrom.options=rw
#     # chainloader +1
# }
EOF

#mv /etc/grub.d/40_custom /etc/grub.d/40_custom.freebsd
update-grub


#------------------------------------------------------------------------------------------------------#
#                                        计算耗时
#------------------------------------------------------------------------------------------------------#

# 等同于 date +"%Y-%m-%d %H:%M:%S"
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
	echo "Run-Times: ${hour}hour ${min}min ${sec}sec "  
};

echo " "
echo "#########################################################"
echo "FirstTime: ${firsttime} " 
echo "EndTime  : ${secondtime} "
time_difference "${firsttime}"  "${secondtime}" ;
echo "#########################################################"
