# debinstall

#### 介绍
所有脚本均在 virtualbox + debain10 中测试


debain基本安装步骤：

Advanced options 

 -->Graphical expert install 
 
    （十几分钟就安装好，内核选择linux-image-amd64,不下载更新）


#### 安装教程
注：适用于挂载光盘源后，第一次安装图形界面GUI

注：二次执行前，必须先注释ISO外的所有源 


使用该脚本顺序如下：

1.终端先英文化"dpke-reconfigure locales"，退出，重新root登陆

2.添加光盘源 "mount /dev/sr0 /media/cdrom && apt-cdrom add -m -d /media/cdrom"

3.注释除光盘源外的其他源

4.最后执行该脚本 


## 温馨提示
所有脚本均为自用脚本，学习使用，不保证实体机无错误运行，切勿用于生产机器！



