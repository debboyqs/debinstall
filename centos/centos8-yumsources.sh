#!/bin/bash
# centos8-yumsources.sh
# CentOS8更换源，使用ustc源
# OS：CentOS-8.1.1911-x86_64-dvd1.iso

echo "**************************************************"
echo -e "\e[1;32m    CentOS8 Change Sources !      \e[0m"
echo "**************************************************"

read -p "Press <Enter> to continue ..." < /dev/tty

#firsttime=`date +%T`
firsttime=`date +"%F %T"`

if [ $UID != "0" ]; then
   echo "Not Root!!! Please exit, and login as root again!"
   exit
fi


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


