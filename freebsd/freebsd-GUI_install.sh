#!/bin/sh
# ****************************************************************************************************************** #
# freebsd安装
# vbox中替换pkg源，然后安装lftp，然后下载安装脚本
#  耗时1个小时

#  中文化需要在 $HOME/.profile 加入才可以

# 注：适用于第一次安装图形界面GUI
# 1.先安装freebsd-GUI_install.sh（本脚本）
# 2.再安装freebsd-normal_user-install.sh（中文化）

# ****************************************************************************************************************** #

# 等同于 firsttime=`date +"%Y-%m-%d %H:%M:%S"`
firsttime=`date +"%F %T"`

echo "Shell is sh before install!!"

# 自定义用户
# 如果和开始创建的用户不一样，案子完毕后要使用"adduser"命令新建用户
#User_Owner=pang
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
portsnap fetch extract
portsnap fetch update

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
printf "\n${User_Owner}    ALL=(ALL) ALL" >> /usr/local/etc/sudoers

# 安装配置xorg
# pkg安装：
pkg install -y xorg
# ports安装：
#cd /usr/ports/x11/xorg && make BATCH=YES install clean

pkg install -y hal
# 注意：执行% pkg info xorg-server | grep HAL
# 如果显示的是输入是on,则要在rc.d中添加hald_enable="YES"和dbus_enable="YES",反之则不需要。
# 在/etc/rc.conf内加入
cat >> /etc/rc.conf << "EOF"
moused_enable="YES"
moused_nodefault_enable="YES"
dbus_enable="YES"
hald_enable="YES"
devd_enable="YES"
# 开启linux兼容模式
linux_enable="YES"
EOF

# 有些插件需要linprocfs和linsysfs
mkdir -p /compat/linux/proc
mkdir -p /compat/linux/sys
mkdir -p /compat/linux/dev
cat >> /etc/fstab << "EOF"
linproc /compat/linux/proc  linprocfs rw  0  0
linsys  /compat/linux/sys   linsysfs  rw  0  0
# openjdk需要
fdesc   /dev/fd             fdescfs   rw  0  0
proc    /proc               procfs    rw  0  0
EOF

# 安装lxde桌面
pkg install -y lxde-meta
#echo "/usr/local/bin/startlxde" >> ~/.xinitrc

# 安装Lumina桌面
# pkg install -y lumina
# echo "exec start-lumina-desktop" >> ~/.xinitrc

# 安装xfce4桌面
# ports安装：
# cd /usr/ports/x11-wm/xfce4 && make install clean
pkg install -y xfce
pkg install -y xfce4-power-manager xfce4-whiskermenu-plugin xfce4-pulseaudio-plugin 
pkg install -y xfce4-volumed-pulse xscreensaver


# 出现"pkg: cached package libcdio-paranoia-10.2+2.0.1: size mismatch cannot continue"
# 原因： 缓存中的数据跟实际数据不一样，清空一下缓存数据即可，或者更新一下pkg的数据：如果再不行，关掉pkg源，只保留一个
# pkg clean                      # cleans /var/cache/pkg/
# rm -rf /var/cache/pkg/*        # just remove it all
# rm /var/db/pkg/repo-*.sqlite   # removes all remote repository catalogs
# pkg update -f                  # forces update of repository catalog
    

#==========================================================
#         安装登陆管理器
#==========================================================
# 安装登陆管理器slim(安装好后，才能启动lxde,否则启动不来)，先不安装
# 配置文件：/usr/local/etc/slim.conf
# 主题目录：/usr/local/share/slim/themes
#pkg install -y slim slim-themes slim-freebsd-themes
#echo 'slim_enable="YES"' >> /etc/rc.conf
# 执行下面，才能使用slim,单桌面
#echo "/usr/local/bin/startxfce4" >> ~/.xinitrc

# 安装登陆管理器lightdm 
pkg install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings 
echo 'lightdm_enable="YES"' >> /etc/rc.conf

# freebsd下 root 登录 lightdm 
pam_securetty=`cat /usr/local/etc/pam.d/lightdm | grep pam_securetty`
gsed "s/${pam_securetty}/#${pam_securetty}/" -i /usr/local/etc/pam.d/lightdm

# vbox中有可能黑屏
#grep  -i '' -e 's/memorylocked=128M/memorylocked=256M/' /etc/login.conf
#cap_mkdb /etc/login.conf

# lightdm主题配置
cp /usr/local/etc/lightdm/lightdm-gtk-greeter.conf /usr/local/etc/lightdm/lightdm-gtk-greeter.conf.bak
ln -sf /usr/local/share/backgrounds/xfce/xfce-blue.jpg /usr/local/share/backgrounds/lightdm_user_pic.jpg

cat >> /usr/local/etc/lightdm/lightdm-gtk-greeter.conf << "EOF"
background=/usr/local/share/backgrounds/lightdm_user_pic.jpg
theme-name=Adwaita
show-indicators=~language;~session;~power
show-clock=true
clock-format=%F %A %T
# 设置 position，这个设置接受 x 和 y 变量，可以使用绝对值(pixels)或相对值(percent). 每个变量都可以增加一个额外的锚定位置 start, center 和 end，数值间用 comma 分隔
position=200,start 50%,center
EOF



# # 替换 lightdm 背景图片
# cat >> /usr/local/bin/chlightdmpic << "EOF"
# #!/bin/sh
# #替换登陆背景
# lightdm_user_pic=/usr/local/share/backgrounds/lightdm_user_pic.jpg
# cp  -f  "$1"  ${lightdm_user_pic}
# chmod  755   ${lightdm_user_pic}
# EOF
#
# chmod  755 /usr/local/bin/chlightdmpic

#==========================================================
#   设置本地化（中文）
#==========================================================
# 安装文泉驿字库 /usr/local/share/fonts/
# pkg安装：
pkg install -y wqy-fonts freefont-ttf  ubuntu-font 

# 中文说明文档
pkg install -y zh_cn-freebsd-doc

cat >> /etc/login.conf << "EOF"
chinese|Chinese Users Account:\
        :charset=UTF-8:\
        :lang=zh_CN.UTF-8:\
        :tc=default:
EOF

cap_mkdb /etc/login.conf
pw user mod ${User_Owner} -L chinese
#pw user mod root -L chinese

# FreeBSD系统下su:sorry的解决办法
pw group mod wheel -m  ${User_Owner}
pw user mod ${User_Owner} -g wheel
      
# 输入法
pkg install -y zh-fcitx zh-fcitx-sunpinyin fcitx-m17n zh-fcitx-configtool

# 在/etc/profile加入（貌似没用）
# 需要在 $HOME/.profile 加入才可以
cat  >> /etc/profile << "EOF"
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN.GB18030

export GTK_IM_MODULE=fcitx
export GTK3_IM_MODULE=xim
export XMODIFIERS='@im=fcitx'

#setenv GTK_IM_MODULE fcitx
#setenv GTK3_IM_MODULE xim
#setenv XMODIFIERS @im=fcitx
EOF

#pkg install -y zh-gcin-gtk3

# 主题相关
pkg install -y adwaita-icon-theme

#------------------------------------------------------------------------
#                    安装编译环境
#------------------------------------------------------------------------
pkg install -y gcc cmake autoconf automake git cvs subversion
pkg install -y fusefs-ntfs fusefs-ntfs-compression libfsntfs

# gtk相关
pkg install -y gtk2 gtk3 gtk-doc p5-Gtk2 p5-Gtk3 webkit2-gtk3 
pkg install -y wx28-gtk2 wx31-gtk3
pkg install -y firmware-utils

#------------------------------------------------------------------------
#                     软件包管理器
#------------------------------------------------------------------------

pkg install -y octopkg pkg_tree pkg_search  
#pkg install -y gksu

# 不能在root和 pang下同时使用gksu-properties，否则会登陆不了root
# gksu-properties

# portmaster是一套仅使用系统软件，而不依赖其他ports的工具。其作用相当于Gentoo的emerge –depclean，或者Debian的orphaner（deborphan这个包）
# cd /usr/ports/ports-mgmt/portmaster && make install clean
pkg install -y portmaster

##portmaster是ports的升级工具，使用基本上就用(全部安装好后看情况再升级) 10分左右
#portmaster -a

pkg install -y pkg_cutleaves   
#echo 'WITH_PKGNG=YES' >> /etc/make.conf
 

# ------------------------------------------------------------------ #
#                     安装网络工具
# ------------------------------------------------------------------ #
pkg install -y networkmgr
echo 'networkmgr_enable="YES"' >> /etc/rc.conf
#echo 'networkmgr_load="YES"' >> /boot/loader.conf

pkg install -y firefox-esr falkon chromium

pkg install -y pidgin aria2 filezilla 

# ktorrent kget
pkg install -y deluge lftp 
pkg install -y qbittorrent uget  quiterss liferea akregator


# linux光盘刻录软件：
pkg install -y k3b brasero xfburn



# 网络测试软件合集
pkg install -y nethogs medusa nmap hydra awstats  
pkg install -y htop moreutils 

# Hashcat 是世界上最快的密码破解程序，是一个支持多平台、多算法的开源的分布式工具
pkg install -y hashcat



# 特效合成管理器,选用xcompmgr，compton会卡
pkg install -y xcompmgr compton compton-conf

# qt主题（可选）
pkg install -y qtcurve 


======================================================================================
                                 安装音频/视频:
======================================================================================
# 没有声音，安装
pkg install -y alsa-utils alsa-lib alsa-plugins

pkg install -y audacious audacious-plugins audacious-skins  
pkg install -y gmpc ario ncmpc ncmpcpp
pkg install -y deadbeef 

pkg install -y ffmpeg   


pkg install -y mpv vlc smplayer mencoder gxine   
# mpv配置
cat >> /usr/local/etc/mpv/mpv.conf << "EOF"
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

gsed "s/^Exec=mpv/Exec=mpv --profile=mympv-gui/g" -i /usr/local/share/applications/mpv.desktop
#echo -e "Exec=mpv --profile=mympv-gui" >> /usr/local/share/applications/mpv.desktop


# mp3乱码解决(两种使用后都无效，使用easytag)：
# easytag:先清除标签，然后写入修改好后的标签
pkg install -y easytag
pkg install -y id3ren id3tool id3v2


# 音视频编辑软件
pkg install -y openshot audacity imagination handbrake

# 高清解码器
pkg install -y x264 libx264 x265 gstreamer1-plugins-x265
pkg install -y gstreamer gstreamer-plugins 
pkg install -y gstreamer-plugins-good gstreamer-plugins-bad 
pkg install -y gstreamer-plugins-x264  gstreamer-plugins-ugly 

pkg install -y gstreamer1 gstreamer-plugins 
pkg install -y gstreamer1-plugins-good gstreamer1-plugins-bad 
pkg install -y gstreamer1-plugins-x264  gstreamer1-plugins-ugly gstreamer1-plugins-x265



pkg install -y cheese


======================================================================================================
# 安装gnome图形：
pkg install -y gthumb gpicview ristretto  gprename xfce4-screenshooter-plugin  gthumb shotwell gimp 

# 安装kde图形：
pkg install -y krename gwenview gwenview kipi-plugins

# 安装压缩工具:
pkg install -y file-roller unace unrar rzip p7zip  minizip  fuse-zip fcrackzip arj  


# PDF工具
pkg install -y  evince okular wkhtmltopdf  pdfcrack man2html pdftk
# 如果wkhtmltopdf中文显示空白或者乱码方框
# 打开windows c:\Windows\fonts\simsun.ttc拷贝到linux服务器/usr/share/fonts/目录下,再次生成pdf中文显示正常

# chm工具
pkg install -y kchmviewer xchm 


# traceroute 2.0
pkg install -y mtr

# 录制并播放终端会话工具
# 通过SSH保持文件系统同步
pkg install -y ttyrec rsync curl

# 日历系统
pkg install -y calcurse remind 


# 计算代码行数
pkg install -y cloc

# 编码转换
# enca 查看文件内容是什么编码
pkg install -y convmv enca uni2ascii

# 2/16进制/编辑/查看软件hexdump(bsdmainutils)
pkg install -y hexedit 


# keepass2(密码管理工具)
# gpa 隐私助理(GPA)是 GnuPG 的一个图形前端，可用于加密、解密、文件签名、管理公钥、私钥等
pkg install -y keepass gpa

# screenfetch 终端中显示图标和其他信息
# most 彩色man界面 
pkg install -y screenfetch neofetch most

# 终端下使用鼠标,配置文件/usr/local/etc/gpm.conf
pkg install -y gpm

# gcolor2 简单的 GTK2 颜色选择拾取器
pkg install -y gcolor2 


# 面板（plank轻量级，cairo-dock重量级）(可选)
#pkg install -y plank cairo-dock tint2 wbar 

# 文件管理器
pkg install -y pcmanfm thunar caja  caja-extensions nemo  konqueror 
#dolphin 

# 文本编辑器
pkg install -y leafpad mousepad kate gedit gedit-plugins pluma
pkg install -y kakoune  
pkg install -y vim

# medit采用ports编译，pkg有问题，内存溢出
#cd /usr/ports/science/medit && sudo make install clean

#-------------------------------------------------------------------
# 文件系统支持
pkg install -y zfstools xfsprogs ufs_copy fusefs-ext2
echo 'fusefs_load="YES"' >> /boot/loader.conf 

#配置 /etc/devfs.rules,要允许操作员组读取和写入设备
cat >> /etc/devfs.rules << "EOF"
[localrules=5]
add path 'da*' mode 0660 group operator
EOF

# 配置 /etc/rc.conf,要启用 devfs.rules 
echo 'devfs_system_ruleset="localrules"' >> /etc/rc.conf

# 配置 /etc/sysctl.conf,允许定期用户装载文件系统
echo "vfs.usermount=1" >> /etc/sysctl.conf

#-------------------------------------------------------------------


# osmo 日志提醒
pkg install -y logtools logcheck logwatch osmo 

# 电子保险柜 - 存放密码数据等
pkg install -y gringotts

# Calibre:电子书管理工具
# Scribus:具备了出版印刷等专业的排版功能，您可以通过预设的模板轻松地建立卡片、名片、小册子、海报等
pkg install -y calibre

# qrcodegen:二维码创建工具
pkg install -y qrcodegen

# OCR
# tesseract-ocr : 开源OCR引擎，它可以阅读各种各样的图像格式和转换他们用40多种语言发短信
pkg install -y tesseract tesseract-data gocr ocrad 

# 保持你的终端会话
pkg install -y screen dtach tmux byobu

# 打印机
pkg install -y system-config-printer

# sweethome3d免费的家装辅助设计软件，通过二维的家居平面图来设计和布置您的家具，还可以用三维的视角浏览整个装修布局的全貌。
pkg install -y sweethome3d


# 安装配置工具：	
pkg install -y gconf-editor dconf seahorse gnome-system-monitor
pkg install -y groff 
#kdeedu

# 安装字典
pkg install -y stardict goldendict 

# diffuse 用于合并和比较文本文件的图形界面工具
# meld (代码比对工具)
pkg install -y meld 

# Zim记事软件,基于维基(wiki)技术的图形化文本编辑器
pkg install -y zim 


# 安装游戏：
pkg install -y  kdiamond kmahjongg knetwalk kolf frozen-bubble  pipewalker supertuxkart gnome-games supertux gnome-mines kmines  foobillard  bzflag barrage briquolo kobodeluxe bovo

# 用于记录关于机器的系统运行时间和统计信息。
pkg install -y uptimed


# AMD显卡驱动,开源（使用此方法，开源驱动）
pkg install -y xf86-video-ati
pkg install -y radeontop radeontool

# 命令行工具dm-tool, 它可用来锁定当前 seat, 切换会话，等等。
pkg install -y xephyr

# 终端
pkg install -y xterm xtermset  xtermcontrol
pkg install -y rxvt-unicode mlterm
pkg install -y xfce4-terminal guake tilda terminator   

# 终端里的文件管理器,midnight控制工具的替代者
pkg install -y mc vifm

# 字符界面下的一些工具
pkg install -y sox cmus moc 
pkg install -y tmux finch 

pkg install -y sl cmatrix screenfetch figlet toilet pv cowsay xcowsay lolcat 


# 文本界面的网页浏览器
pkg install -y elinks links

pkg install -y ddate jp2a

pkg install -y gmtp 

# 安装打字软件
pkg install -y typespeed

# 安装minicom
pkg install -y minicom   


# xournal 可以通过手写板手写或者在笔记上涂鸦
pkg install -y xournal

# 其他
pkg install -y dfc scite tree gnome-system-monitor colordiff fping pwgen bmon

# ssh相关
pkg install -y openssh-portable zenity fusefs-sshfs
#echo 'openssh_enable="YES"' >> /etc/rc.conf

# mate相关
pkg install -y mate-system-monitor


# 免费会计软件
# GnuCash 为中小企业和个人提供了会计功能
pkg install -y gnucash homebank

# entr 是一个命令行工具，当每次更改一组指定文件中的任何一个时，都能运行一个任意命令
# redshift 根据时间自动地调整屏幕的色温
pkg install -y zsh zsh-completion 
pkg install -y redshift
pkg install -y entr

# 制图工具freecad
pkg install -y freecad 

# 实用程序 gPhoto2 备份手机存储
pkg install -y gphoto2

# 远程连接
pkg install -y remmina 
pkg install -y gigolo gvfs 
pkg install -y putty  

# 集成开发环境
pkg install -y anjuta 
pkg install -y sqlitebrowser sqlite3 
pkg install -y geany geany-plugins 
pkg install -y kdevelop  kdevelop-l10n

# clamav杀毒软件
pkg install -y clamav clamtk clamassassin 
echo 'clamav_freshclam_enable="YES"' >> /etc/rc.conf
echo 'DatabaseMirror db.cn.clamav.net' >> /usr/local/etc/freshclam.conf

# 恢复 Linux 上已删除的文件
# foremost	命令行	formost 是一个基于文件头和尾部信息以及文件的内建数据结构恢复文件的命令行工具
# extundelete	命令行	Extundelete 是 ext3、ext4 文件系统的恢复工具
# scalpel	命令行	scalpel 是一种快速文件恢复工具，它通过读取文件系统的数据库来恢复文件。它是独立于文件系统的
# testdisk	字符终端	Testdisk 支持分区表恢复、raid 恢复、分区恢复
# phtorec	字符终端	photorec 用来恢复硬盘、光盘中丢失的视频、文档、压缩包等文件，或从数码相机存储卡中恢复丢失的图片
pkg install -y foremost  scalpel testdisk 

# 使用 S.M.A.R.T. 控制和监视存储系统
pkg install -y smartmontools  
#echo 'smartd_enable="YES"' >> /etc/rc.conf

# 加密工具(另外veracrypt)
pkg install -y bcrypt mcrypt

# 安全审计工具lynis(最好使用最新版本,git下载)
# git clone https://github.com/CISOfy/lynis.git
# 不安装tripwire 
# 不安装samhain，防止开机产生一堆信息
# 不安装libpam-tmpdir ，使用veracrypt时有问题，无法显示挂载盘，但能使用，相当于隐藏
# 要审计你的系统的安全态势，运行以下命令：
# lynis audit system
pkg install -y lynis 
pkg install -y aide 
#needrestart

# jigdo下载 jigdo-lite
pkg install -y jigdo





==============================================================
                      数学工具
==============================================================
# GeoGebra数学 (需要下载 81.9 MB 的软件包)
# GeoGebra是一套适合中学及以上使用的动态数学教育软件，不但包含原本动态几何尺规作图、几何转换等功能，还加入函数绘图、代数运算和基本微积分等功能
pkg install -y geogebra 

# 数学计算器
pkg install -y galculator qalculate genius speedcrunch cantor

# Kalzium化学(需要下载 133 MB 的软件包)
#还记得化学课本里的元素周期表吗？开启Kalzium你会发现元素周期表进化了，不只有多种查看方式，还可以呈现物质状态以及其他更丰富的应用功能。
pkg install -y kalzium

# Avogadro(中文) 和 Gabedit 用于化学
pkg install -y gabedit

# 学习分子运算(需要下载 121 MB 的软件包)
pkg install -y kbruch

# 数学函数绘图器(需要下载 121 MB 的软件包)
pkg install -y kmplot 

#Gnuplot是一个命令行驱动的工具,用于创建2D和3D图形。
pkg install -y gnuplot 


# 解数学式和绘画的工具(需要下载 121 MB 的软件包)
pkg install -y kalgebra

# 交互式物理仿真模拟器(需要下载 123 MB 的软件包)
pkg install -y step

# 科学计算Octave,octave-forge不安装（全家桶，会卡住不动,太耗时）
# 一种高级语言，主要设计用来进行数值计算，多数语法与matlab兼容，qtoctave是它的一个与matlab相似的前端.
pkg install -y octave 

# Stellarium天文
pkg install -y stellarium 


#-------------------------------------------------------------------------#
#                           需要互动的
#-------------------------------------------------------------------------#

# 安装wine（可能要重新安装）：
pkg install -y wine 

pkg install -y wireshark 

#chgrp network /dev/bpf*
#chmod g+rw /dev/bpf*
#echo "pwn bpf* root:network" >> /etc/devfs.conf
#echo "perm bpf* 0600" >> /etc/devfs.conf

# plasma相关(KDE)，选择性安装
# dolphin kdeedu digikam ktorrent kget

# 解决xfce4普通用户关机按钮灰色的问题
# sudo chown -R polkitd /usr/local/etc/polkit-1 

#-------------------------------------------------------------------------#
#                      可能没安装，看情况再安装
#-------------------------------------------------------------------------#

# 主题相关(没安装) 会删除clearlooks，然后再次安装 二选一
#pkg install -y -f clearlooks-themes clearlooks-themes-extras

#第三方工具:portupgrade(没安装) 二选一
# portupgrade是一个强大全面的工具，但是依赖于ruby。
# pkg install -y -f portupgrade portupgrade-devel
pkg install -y portupgrade

# 文本界面的网页浏览器(没安装) 二选一
#pkg install -y -f w3m w3m-img 
pkg install -y w3m 

# 音视频编辑软件(可能没安装) 和imagemagick6冲突，需要先删除
#pkg install -y -f avidemux lives

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

