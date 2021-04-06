#!/bin/bash

# archlinux安装脚本，root执行,首次运行在有线网络中，无线安装过程中可能会断网
# 注：适用于系统安装后，第一次安装图形界面GUI

# -------------------------------------------------
# 配置文件：追加内容
# /etc/pacman.conf
# /etc/profile
# /etc/lightdm/lightdm-gtk-greeter.conf
# /root/.bashrc
# /etc/fstab

# 配置文件：替换内容
# /etc/ld.so.conf
# /etc/mpv/mpv.conf
# /etc/modprobe.d/blacklist-nouveau.conf
# -------------------------------------------------

# 使用该脚本顺序如下：
# 1.安装lftp，下载本脚本
# 2.最后Root执行该脚本 
# 注：中断操作(硬重启)后再次执行，会有问题，暂未解决

# ****************************************************************************************************************** #
echo ""
echo "**************************************************"
echo -e "\e[1;32m        Install GUI !      \e[0m"
echo "**************************************************"
echo ""
echo -e "---------------- First execution -----------------"
echo -e "\e[1;33m Root user installs this script ! \e[0m\n"
echo -e "\e[1;33m Desktop is LXDE + XFCE ! \e[0m\n"

#echo -e "----------- Multiple executions Warning!!!----------"
#echo -e "\e[1;31m Try installing the script again !  \e[0m\n"
#echo -e "\e[1;31m After the Multiple execution, the duplicate content of the configuration file needs to be deleted  \e[0m\n"
echo "**************************************************"

read -p "Press <Enter> to continue ..." < /dev/tty

# 等同于 firsttime=`date +"%Y-%m-%d %H:%M:%S"`
firsttime=`date +"%F %T"`

if [ $UID != "0" ]; then
   echo "Not Root!!! Please exit, and login as root again!"
   exit
fi

# 中断操作产生锁文件，删除
[ -f "/var/lib/pacman/db.lck" ] && echo "删除中断操作产生的锁文件!" && rm -f /var/lib/pacman/db.lck
#LANG= pacman -Qkk 2>&1 | grep "^warning: .*: .*Size mismatch" | cut -d: -f2 | uniq | xargs pacman -S --noconfirm
#/sbin/ldconfig 

echo ""
read -p "Enter Normal-User: " User_Owner
read -p "Enter HostName: " ArchHostname

echo ""
mirror="mirrors.ustc.edu.cn"

# ------------------------------------------------------------------ #
#                       准备工作
# ------------------------------------------------------------------ #

# 设置locale
sed 's|#en_US.UTF-8|en_US.UTF-8|g' -i /etc/locale.gen
sed 's|#en_US ISO-8859-1|en_US ISO-8859-1|g' -i /etc/locale.gen
sed 's|#zh_CN.GBK|zh_CN.GBK|g' -i /etc/locale.gen
sed 's|#zh_CN.GB18030|zh_CN.GB18030|g' -i /etc/locale.gen
sed 's|#zh_CN.UTF-8|zh_CN.UTF-8|g' -i /etc/locale.gen
sed 's|#zh_TW.UTF-8|zh_TW.UTF-8|g' -i /etc/locale.gen
locale-gen

#locale.conf默认不存在需要创建,在此设置任何中文locale，或导致tty乱码 (安装好后在更改回来)
echo LANG=en_US.UTF-8  > /etc/locale.conf

#4.设置时区：
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 设置主机名：
echo ${ArchHostname} > /etc/hostname

# 防止iso文件太旧
pacman -S --noconfirm archlinux-keyring 
pacman -Syy 

# 安装工具
pacman -S --noconfirm axel curl wget

# ---------------------------------------------------------------------------------- #
#                   /etc/pacman.conf 的修改
# ---------------------------------------------------------------------------------- #
# 添加Arch Linux中文社区仓库
pacmanconf="/etc/pacman.conf"
[ -f ${pacmanconf}.bak ] && cp ${pacmanconf}.bak ${pacmanconf} || cp ${pacmanconf} ${pacmanconf}.bak

cat >> /etc/pacman.conf << EOF 

[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = http://${mirror}/archlinuxcn/\$arch
EOF

# ---------------------------------------------------------------------------------- #

pacman -Syy 
#arch系 自动确认安装有多个选项时，需要添加--noconfirm (默认)
# 如果还不行，前面加yes，多次安装最好加yes  "yes | pacman -Sy" 
pacman -S --noconfirm archlinux-keyring archlinuxcn-keyring


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
# 安装 X 窗口系统：
pacman -S --noconfirm xorg xorg-server xorg-xinit xterm

# 安装lxde
pacman -S --noconfirm lxde lxde-icon-theme

# 安装xfce
pacman -S --noconfirm xfce4 
pacman -S --noconfirm xfce4-terminal xfce4-screenshooter xfce4-power-manager

# xfce4 单独安装下面插件
pacman -S --noconfirm xfce4-whiskermenu-plugin
pacman -S --noconfirm xfce4-battery-plugin  xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-fsguard-plugin 
pacman -S --noconfirm xfce4-sensors-plugin xfce4-systemload-plugin xfce4-taskmanager
pacman -S --noconfirm xfce4-diskperf-plugin  xfce4-mailwatch-plugin xfce4-netload-plugin 
pacman -S --noconfirm xfce4-notes-plugin xfce4-dLict xfce4-smartbookmark-plugin
pacman -S --noconfirm xfce4-datetime-plugin xfce4-timer-plugin 
pacman -S --noconfirm xfce4-verve-plugin xfce4-wavelan-plugin xfce4-xkb-plugin


# 源码编译xfce4的一些插件需要用到
pacman -S --noconfirm libxfce4ui libxfce4util  

# 安装mate桌面(可选) 
#pacman -S --noconfirm mate-desktop



# 透明效果
pacman -S --noconfirm compton 

# 安装pcmanfm
pacman -S --noconfirm pcmanfm libfm

# 安装编译环境 
pacman -S --noconfirm linux-headers
pacman -S --noconfirm gcc dkms make cmake  gdb git
pacman -S --noconfirm autoconf automake 
pacman -S --noconfirm pkg-config python-pkgconfig     
pacman -S --noconfirm gtk2 gtk3
pacman -S --noconfirm perl ruby
pacman -S --noconfirm ntfs-3g fuse gvfs gvfs-mtp 

pacman -S --noconfirm python-gobject gobject-introspection-runtime


#安装Qt5库
pacman -S --noconfirm qt5-base qt5-tools


# 安装驱动
pacman -S --noconfirm linux-firmware

# ---------------------------------安装软件--------------------------------- #

# 安装无线网络和图形管理工具
pacman -S --noconfirm networkmanager network-manager-applet xfce4-notifyd  
systemctl enable NetworkManager

# 网卡显示eth0
defaultgrub="/etc/default/grub"
[ -f ${defaultgrub}.bak ] && cp ${defaultgrub}.bak ${defaultgrub} || cp ${defaultgrub} ${defaultgrub}.bak

# virtualbox中不要使用，有可能出现无法连接网络的情况
#sed 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' -i /etc/default/grub
#grub-mkconfig -o /boot/grub/grub.cfg 



# 添加3D支持 (和libglvnd冲突，安装好后再重新安装)
pacman -S --noconfirm mesa

# 添加触摸板支持
pacman -S --noconfirm xf86-input-synaptics


# 安装主题：/usr/share/themes/或者~/.themes
pacman -S --noconfirm gtk-engines gtk-chtheme gnome-icon-theme gnome-themes-extra kiconthemes 


# ------------------------------------------安装输入法-----------------------------------------

pacman -S --noconfirm wqy-microhei wqy-zenhei  ttf-dejavu ttf-arphic-ukai ttf-arphic-uming

# 安装输入法和配置
pacman -S --noconfirm fcitx fcitx-sunpinyin  fcitx-googlepinyin  fcitx-libpinyin  fcitx-configtool

# 放大系统字体
pacman -S --noconfirm gconf 
# 文本比例因子
gsettings set org.gnome.desktop.interface text-scaling-factor '1.2' 

profileconf="/etc/profile"
[ -f ${profileconf}.bak ] && cp ${profileconf}.bak ${profileconf} || cp ${profileconf} ${profileconf}.bak

cat >> /etc/profile << "EOF" 
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/lib/pkgconfig
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
EOF


# ------------------------------------------------------------------ #
#                     安装网络工具
# ------------------------------------------------------------------ #

pacman -S --noconfirm firefox-esr  
# chromium可能和baidunetdisk冲突，可能要二选一 
pacman -S --noconfirm chromium 
# falkon (qupzilla)
pacman -S --noconfirm falkon
#pacman -S --noconfirm epiphany midori

pacman -S --noconfirm pidgin uget aria2 filezilla lftp vsftpd
pacman -S --noconfirm deluge deluge-gtk  qbittorrent
pacman -S --noconfirm uget quiterss  liferea  akregator 

# linux光盘刻录软件：
pacman -S --noconfirm k3b brasero xfburn  devede

pacman -S --noconfirm linssid  
pacman -S --noconfirm owncloud-client  


# 防火墙
# FireWallD（取代gufw）和iptables 只能二选一
# 检查 /etc/services文件，查看服务的名字及对应的端口和协议
pacman -S --noconfirm firewalld  
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

# 开机禁止启动ufw(关机会变慢)，设置默认策略，允许SSH连接（选用FireWallD）
pacman -S --noconfirm gufw 
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
pacman -S --noconfirm shorewall 
systemctl disable shorewall


# 文本界面的网页浏览器
pacman -S --noconfirm w3m elinks links


# 网络测试软件合集
pacman -S --noconfirm nethogs medusa nmap hydra awstats 
pacman -S --noconfirm iftop nmon dstat  
pacman -S --noconfirm htop glances iotop moreutils 
systemctl disable glances
# 开放（客户端-服务器模式 CS模式）glances端口，监控远程 Linux 系统
firewall-cmd --permanent --zone=public --add-port=61209/tcp


# Hashcat 是世界上最快的密码破解程序，是一个支持多平台、多算法的开源的分布式工具
pacman -S --noconfirm hashcat

# etherape ettercap-graphical ettercap-common安装包clamav提示有病毒


# ------------------------------------------------------------------ #
#                    安装音频/视频
# ------------------------------------------------------------------ #
# 安装音频/视频
pacman -S --noconfirm alsa-utils alsa-tools pulseaudio pulseaudio-alsa  pavucontrol jack 

pacman -S --noconfirm audacious deadbeef 
pacman -S --noconfirm mpd ario ncmpc ncmpcpp
systemctl disable mpd

pacman -S --noconfirm mpv vlc smplayer smplayer-themes smplayer-skins

pacman -S --noconfirm easytag python-mutagen winff recordmydesktop  

pacman -S --noconfirm vokoscreen recordmydesktop  
pacman -S --noconfirm python-mutagen  easytag exfalso 

# mpv配置
[ -f /etc/mpv/mpv.conf ] && cp /etc/mpv/mpv.conf /etc/mpv/mpv.conf.bak
cat  > /etc/mpv/mpv.conf << "EOF"
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


# 高清解码器
pacman -S --noconfirm x265 x264 libx264 mpg123 lame faac ffmpegmencoder 

# gstreamer框架
pacman -S --noconfirm gstreamer
pacman -S --noconfirm gst-plugins-good  gst-plugins-base gst-plugin-gtk gst-plugins-base-libs  gst-libav 


# 音视频编辑软件
pacman -S --noconfirm openshot flowblade audacity handbrake 

pacman -S --noconfirm cheese guvcview 


# ************************************************************************************************

# 安装gnome图形：
pacman -S --noconfirm gthumb gpicview ristretto  shotwell gprename  gnome-screenshot  

# 安装kde图形(可选)：
pacman -S --noconfirm gwenview krename digikam kipi-plugins 



# 安装压缩工具:
pacman -S --noconfirm file-roller  unace unrar p7zip minizip fuse-zip  fcrackzip  arj cabextract 
pacman -S --noconfirm engrampa lhasa sharutils ncompress lzip lzop 

# PDF工具
pacman -S --noconfirm evince okular pdfcrack wkhtmltopdf pdftk man2html  

# chm工具
pacman -S --noconfirm kchmviewer xchm

# 数学计算器
pacman -S --noconfirm galculator genius speedcrunch  qalculate-gtk cantor



# 编码转换
pacman -S --noconfirm convmv enca ascii

pacman -S --noconfirm isomd5sum 

pacman -S --noconfirm mtr rsync curl calcurse remind  cloc
pacman -S --noconfirm gpa bless hexedit 
pacman -S --noconfirm hardinfo hwinfo lshw screenfetch neofetch most gpm 
systemctl enable gpm

# 代码比对工具
pacman -S --noconfirm meld diffuse 


pacman -S --noconfirm gcolor2 

pacman -S --noconfirm logwatch osmo 


# 其他文件系统支持
pacman -S --noconfirm xfsprogs xfsdump btrfs-progs jfsutils dosfstools mtools 


pacman -S --noconfirm sweethome3d
pacman -S --noconfirm qtqr scribus calibre
pacman -S --noconfirm zint zint-qt
 
pacman -S --noconfirm screen tmux 


# 文本编辑器
pacman -S --noconfirm  mousepad featherpad leafpad kate

# Zim记事软件,基于维基(wiki)技术的图形化文本编辑器
pacman -S --noconfirm zim zimwriterfs 

# 配置工具
pacman -S --noconfirm  xdg-utils seahorse mate-system-monitor

# 安装工具
pacman -S --noconfirm  gparted groff system-config-printer uptimed 
systemctl enable uptimed


# 安装字典
pacman -S --noconfirm qstardict goldendict 

# 显示传感器
pacman -S --noconfirm python-keyring python-feedparser psensor hddtemp
chmod u+s /usr/sbin/hddtemp
sh -c "yes|sensors-detect"


# 清理工具
pacman -S --noconfirm bleachbit  


# 安装游戏：
pacman -S --noconfirm kajongg kdiamond kmahjongg knetwalk kolf  frozen-bubble  supertuxkart gnome-games supertux   gnome-mines kmines   extremetuxracer bzflag  barrage  kobodeluxe bovo 



# 在现有的图形界面中，还可以以窗口模式运行另外一个X Server，称为nested X Server。最常用的nested X Server是Xephyr
pacman -S --noconfirm xorg-server-xephyr 

# 终端 
pacman -S --noconfirm xterm rxvt-unicode 
pacman -S --noconfirm xfce4-terminal  guake tilda terminator terminology  


# 字符界面下的文件管理器
pacman -S --noconfirm doublecmd tuxcmd tuxcmd-modules mc ranger vifm 

# 字符界面下的一些工具
pacman -S --noconfirm sox cmus moc 

pacman -S --noconfirm sl cmatrix screenfetch figlet toilet pv cowsay lolcat
pacman -S --noconfirm ccal jp2a 

pacman -S --noconfirm putty 

# 虚拟机管理kvm(可选)
#pacman -S --noconfirm virt-manager imvirt 
#pacman -S --noconfirm virt-viewer bridge-utils
#pacman -S --noconfirm qemu qemu-guest-agent qemu-user-static 
#systemctl disable libvirtd

# 数学工具合集
pacman -S --noconfirm geogebra kalzium kbruch kmplot kalgebra step octave gnuplot stellarium  

pacman -S --noconfirm gmtp 


# 从 DOS 格式转换为 Unix 格式
pacman -S --noconfirm dos2unix

# 集成开发环境
pacman -S --noconfirm anjuta anjuta-extras 
pacman -S --noconfirm sqlitebrowser sqlite3 sqlite3-doc 
pacman -S --noconfirm geany geany-plugins
pacman -S --noconfirm kdevelop  konsole 

# 安装minicom
pacman -S --noconfirm minicom  


# 屏幕保护程序
pacman -S --noconfirm xscreensaver


# 面板
pacman -S --noconfirm plank pnmixer tint2

# 其他
pacman -S --noconfirm dfc scite tree gnome-system-monitor colordiff fping pwgen mlocate bmon

# ssh相关
pacman -S --noconfirm openssh xorg-server-xephyr sshfs


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
pacman -S --noconfirm mate-system-monitor

# 免费会计软件
# GnuCash 为中小企业和个人提供了会计功能 
# pacman -S --noconfirm gnucash homebank


# entr 是一个命令行工具，当每次更改一组指定文件中的任何一个时，都能运行一个任意命令
# redshift 根据时间自动地调整屏幕的色温
pacman -S --noconfirm zsh zsh-doc  
pacman -S --noconfirm redshift 
pacman -S --noconfirm entr

# 制图工具freecad
pacman -S --noconfirm freecad

# 实用程序 gPhoto2 备份手机存储
pacman -S --noconfirm gphoto2




# 安装web服务器相关组件
pacman -S --noconfirm apache 

# 安装php7及相关模块
pacman -S --noconfirm php-mysql  
pacman -S --noconfirm php-fpm  php-cgi php-memcached php-gd 
pacman -S --noconfirm php-apcu 



# 蓝牙(先禁止，需要时再开启服务)
pacman -S --noconfirm blueman bluez-tools  bluez-hcidump rfkill

# 安装Flatpak  https://flatpak.org/
pacman -S --noconfirm flatpak 


# 安装缺少依赖(make menuconfig)
pacman -S --noconfirm ncurses libelf flex bison

# 安装remmina
pacman -S --noconfirm remmina

# clamav杀毒软件
pacman -S --noconfirm clamav clamtk 
systemctl disable clamav-daemon
echo 'DatabaseMirror db.cn.clamav.net' >> /etc/clamav/freshclam.conf
echo 'DatabaseMirror database.clamav.net' >> /etc/clamav/freshclam.conf


# 恢复 Linux 上已删除的文件
# foremost	命令行	formost 是一个基于文件头和尾部信息以及文件的内建数据结构恢复文件的命令行工具
# extundelete	命令行	Extundelete 是 ext3、ext4 文件系统的恢复工具
# scalpel	命令行	scalpel 是一种快速文件恢复工具，它通过读取文件系统的数据库来恢复文件。它是独立于文件系统的
# testdisk	字符终端	Testdisk 支持分区表恢复、raid 恢复、分区恢复
# phtorec	字符终端	photorec 用来恢复硬盘、光盘中丢失的视频、文档、压缩包等文件，或从数码相机存储卡中恢复丢失的图片
pacman -S --noconfirm foremost testdisk 

# 使用 S.M.A.R.T. 控制和监视存储系统
pacman -S --noconfirm smartmontools
systemctl diable smartd    

# 加密工具(另外veracrypt)
#pacman -S --noconfirm cryptsetup keyutils


# 安全审计工具lynis(最好使用最新版本,git下载)
# git clone https://github.com/CISOfy/lynis.git
# 不安装tripwire 
# 不安装samhain，防止开机产生一堆信息
# 不安装libpam-tmpdir ，使用veracrypt时有问题，无法显示挂载盘，但能使用，相当于隐藏
# 要审计你的系统的安全态势，运行以下命令：
# lynis audit system
pacman -S --noconfirm lynis 

# 文本编辑器
pacman -S --noconfirm kakoune aspell xorg-xmessage
pacman -S --noconfirm vim vim-editorconfig 

# exa 是一个 Linux ls 命令的现代替代品，是用 Rust 编写的
pacman -S --noconfirm exa


# pcurses : 基于 curses 的图形化软件包管理器
# pkgfile 相当于apt-file,查询
pacman -S --noconfirm pcurses packer
pacman -S --noconfirm pacmanlogviewer gist  pkgfile

pacman -S --noconfirm libpng12




#-------------------------------------------------------------------------#
#                           登录管理器
#-------------------------------------------------------------------------#

# 登录管理器（slim,lightdm,lxdm），lxdm配合lxde使用(不用)，使用slim/lightdm+桌面
pacman -S --noconfirm slim lxdm
systemctl disable lxdm slim

pacman -S --noconfirm lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
systemctl enable lightdm

# lightdm主题配置
#cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
greeterconf="/etc/lightdm/lightdm-gtk-greeter.conf"
[ -f ${greeterconf}.bak ] && cp ${greeterconf}.bak ${greeterconf} || cp ${greeterconf} ${greeterconf}.bak

mkdir -pv /usr/share/images/desktop-base/
ln -sf /usr/share/backgrounds/xfce/xfce-blue.jpg /usr/share/images/desktop-base/lightdm_user_pic.jpg

cat >> /etc/lightdm/lightdm-gtk-greeter.conf << "EOF"
background=/usr/share/images/desktop-base/lightdm_user_pic.jpg
theme-name=Adwaita
show-indicators=~language;~session;~power
show-clock=true
clock-format=%F %A %T
# 设置 position，这个设置接受 x 和 y 变量，可以使用绝对值(pixels)或相对值(percent). 每个变量都可以增加一个额外的锚定位置 start, center 和 end，数值间用 comma 分隔
position=200,start 50%,center
EOF


pacman -S --noconfirm wireshark-qt  

# 不用，使用thunderbird
#pacman -S --noconfirm claws-mail  


# ------------------------------------------------------------------ #
# systemctl相关配置
# ------------------------------------------------------------------ #
# 显示系统启动时间
#systemd-analyze time

# 禁止启动一些服务(需要的时候再开启，视情况而定)
# /var/lib/snapd/apparmor/profiles
#systemctl disable snapd apparmor zfs 
#systemctl disable postgresql mariadb apache
systemctl disable vsftpd  
systemctl disable php-fpm 
systemctl disable bluetooth
systemctl disable glances

systemctl disable man-db.timer
# systemctl --all | grep not-found 查看有哪些服务挂掉了,然后再考虑disable

# 根分区安装在了 SSD 上，启用 TRIM 会帮助清理 SSD 中的块，从而延长 SSD 的使用寿命
#systemctl enable fstrim.timer
echo ""
echo -e "\e[1;32mIf your OS install into SSD,please enable trim service!\e[0m"
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
pacman -R --noconfirm  lxmusic 


# ---------------------------------配置--------------------------------- #
# # 添加普通用户
pacman -S --noconfirm sudo bash-completion

useradd -m -G power,audio,video -s /bin/bash ${User_Owner}
# 普通用户已存在，则修改
if [ $? -ne 0 ];then
  usermod -G power,audio,video  ${User_Owner}
fi

#将允许获取 root 权限的用户加入 wheel 用户组
#gpasswd -a ${User_Owner} wheel
passwd ${User_Owner}

echo "${User_Owner} ALL=(ALL) ALL" >> /etc/sudoers

[ ! -f /root/.bashrc ] && touch /root/.bashrc  
bashrc="/root/.bashrc"
[ -f ${bashrc}.bak ] && cp ${bashrc}.bak ${bashrc} || cp ${bashrc} ${bashrc}.bak

cat >> /root/.bashrc << "EOF"
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

alias pacmanin='pacman -S'
alias pacmandel='pacman -R'
alias pacmanse='pacman -Qs'

alias services_running='systemctl list-units  --type=service  --state=running'
alias rsync='rsync -vzhP'
alias curlget='curl -O -C -'

alias youget-default_dir='you-get -o ~/youget'

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/lib/pkgconfig
EOF


# 禁用自带的 nouveau nvidia驱动 ，防止开机出现黑屏，先在grub引导菜单中添加nomodeset（调用集显）
cat  > /etc/modprobe.d/blacklist-nouveau.conf << "EOF"
blacklist nouveau
options nouveau modeset=0
EOF

# 显卡相关
sed 's/GRUB_CMDLINE_LINUX_DEFAULT/#GRUB_CMDLINE_LINUX_DEFAULT/g' -i /etc/default/grub
echo 'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet panic=5 acpi_osi=linux"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg 


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
systemconf="/etc/systemd//etc/systemd/system.conf"
[ -f ${systemconf}.bak ] && cp ${systemconf}.bak ${systemconf} || cp ${systemconf} ${systemconf}.bak
sed 's|#DefaultTimeoutStopSec=90s|DefaultTimeoutStopSec=10s|g' -i /etc/systemd/system.conf

# 3.看门狗的模块(可选)
# 检查看门狗是否在运行：ps -af | grep watch*
# 修改配置文件 /etc/systemd/system.conf 中将 ShutdownWatchdogSec 的值从 10 分钟改为更低的值
sed 's|#ShutdownWatchdogSec=10min|ShutdownWatchdogSec=1min|g' -i /etc/systemd/system.conf


# ************************************************************************************************


# 最后安装wine：需要32位支持
# 多线程下载支持(貌似有些问题，不用)
# 添加32位支持：删除[multilib]下一行
# 添加新行必须重新 sed，否则没效果
sed -e 's/#\[multilib\]/\[multilib\]/' \
    -e '/\[multilib\]/{n;d}' \
    -i /etc/pacman.conf
    
sed -e '/\[multilib\]/a\Include = /etc/pacman.d/mirrorlist' -i /etc/pacman.conf
pacman -Syy
pacman -S --noconfirm wine 
pacman -S --noconfirm playonlinux 

# ************************************************************************************************


# 在此设置任何中文locale
echo LANG=zh_CN.UTF-8 > /etc/locale.conf


# 创建初始 ramdisk 环境，防止重启可能进不了系统
mkinitcpio -p linux

#完全清理包缓存(/var/cache/pacman/pkg)：
#yes | pacman -Scc

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

