# debinstall

#### 介绍
所有脚本均在 virtualbox + debain10 中测试

测试ISO:FreeBSD-12.2-RELEASE-amd64-dvd1.iso

freebsd分区参考（vbox）：

   ada0        600G  GPT
   
      ada0p1   200M  efi                   //大小看“auto”选项
      
      ada0p2   512K  freebsd-boot          //vbox中必须要，否则引导不了
      
      ada0p3   100G  freebsd-ufs    /
      
      ada0p4   4.0G  freebsd-swap   swap   // 不能放在第一个分区，否则会找不到系统
      
      ada0p5   200G  freebsd-ufs    /home
      
      ada0p6   296G  freebsd-ufs           //其他


#### 安装教程
脚本1：freebsd-pkg_modify.sh

脚本2：freebsd-GUI_install.sh

脚本3：freebsd-normal_user-install.sh



脚本1说明：替换FreeBSD更新源

脚本2说明：适用于第一次安装图形界面GUI（软件可根据需要删减）

脚本3说明：执行完脚本2，重启后再中文化处理



## 温馨提示
所有脚本均为自用脚本，学习使用，不保证实体机无错误运行，切勿用于生产机器！



