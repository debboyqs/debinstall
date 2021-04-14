#!/bin/sh
# freebsd 用户配置
# 执行freebsd-install.sh脚本后，重启进入桌面，再执行该脚本

# 等同于 firsttime=`date +"%Y-%m-%d %H:%M:%S"`
firsttime=`date +"%F %T"`


# ~/.xinitrc 登陆管理器slim有用
cat >> $HOME/.xinitrc << "EOF"
/usr/local/bin/startxfce4
#/usr/local/bin/startlxde
#exec start-lumina-desktop
#exec mate-session
EOF

# ~/.login.conf
cat >> $HOME/.login_conf << "EOF"
me:\
        :lang=zh_CN.UTF-8:\                     #LANG 语言显示
        :setenv=LC_ALL=zh_CN.UTF-8:\            #指定所有的 Locale
        :setenv=LC_CTYPE=zh_CN.UTF-8:\          #字元定义 (包含字元分类与转换规则)
        :setenv=LC_COLLATE=zh_CN.UTF-8:\        #字母順序与特殊字元比较
        :setenv=LC_TIME=zh_CN.UTF-8:\           #时间格式
        :setenv=LC_NUMERIC=zh_CN.UTF-8:\        #数字格式
        :setenv=LC_MONETARY=zh_CN.UTF-8:\       #货币格式
        :setenv=LC_MESSAGES=zh_CN.UTF-8:\       #信息显示
        :charset=UTF-8:\                        #
#        :xmodifiers="@im=fcitx":                 #所使用的输入方式
EOF
cap_mkdb $HOME/.login_conf

# ~/.profile
cat >> $HOME/.profile << "EOF"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN.GB18030
EOF


# ~/.shrc
cat >> $HOME/.shrc << "EOF"
# some more ls aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias la='ls -Al'
alias ls='ls -hF --color=tty'                 
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias grep='grep --color' 

alias pkgin='sudo pkg install'
alias pkgdel='sudo pkg remove'
alias pkgse='sudo pkg search'

alias dfls='df -Th'
alias top1='top -n 1'
alias psall='ps ux'
alias kill9='kill -9'
alias lns='ln -s'

alias killpic='killall gpicview'
alias duls='du -d 1 -h'
alias dusort='du -d1 -h | sort -k1 -h'
alias mountiso='sudo mount -o loop'

alias guanji='sudo shutdown -h now'
alias gnome-monitor='gnome-system-monitor'
alias mate-monitor='mate-system-monitor'

alias startxephyr='Xephyr -ac -screen 1600x900 :1'
alias startdisplay='DISPLAY=:1'

alias youget-default_dir='you-get -o ~/you-get/'
alias curlget='curl -O -C - '
alias rsync='rsync -vzhP'

#PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$'
#PS1='\u@\h:\w\$'
EOF

# ~/.bashrc
cat >> $HOME/.bashrc << "EOF"
complete -cf sudo

# some more ls aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ll='ls -l'
alias la='ls -Al'
alias l='ls -CF'
alias ls='ls -hF --color=tty'                 
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias grep='grep --color' 

alias pkgin='sudo pkg install'
alias pkgdel='sudo pkg remove'
alias pkgse='sudo pkg search'

alias dfls='df -Th'
alias top1='top -n 1'
alias psall='ps ux'
alias kill9='kill -9'
alias lns='ln -s'

alias killpic='killall gpicview'
alias duls='du -d 1 -h'
alias dusort='du -d1 -h | sort -k1 -h'
alias mountiso='sudo mount -o loop'

alias guanji='sudo shutdown -h now'
alias gnome-monitor='gnome-system-monitor'
alias mate-monitor='mate-system-monitor'

alias startxephyr='Xephyr -ac -screen 1600x900 :1'
alias startdisplay='DISPLAY=:1'

alias youget-default_dir='you-get -o ~/you-get/'
alias curlget='curl -O -C - '
alias rsync='rsync -vzhP'

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$'
#PS1='\u@\h:\w\$'
EOF


# ~/.cshrc
cat >> $HOME/.cshrc << "EOF"
complete -cf sudo

# some more ls aliases
alias rm  rm -i 
alias cp  cp -i 
alias mv  mv -i 

alias ls     ls -hF --color=tty                  
alias dir    ls --color=auto --format=vertical 
alias vdir   ls --color=auto --format=long 
alias grep   grep --color  

alias pkgin  sudo pkg install 
alias pkgdel sudo pkg remove 
alias pkgse  sudo pkg search 

alias dfls   df -Th 
alias top1   top -n 1 
alias psall  ps ux 
alias kill9  kill -9 
alias lns    ln -s 

alias killpic   killall gpicview 
alias duls      du -d 1 -h 
alias dusort    du -d1 -h | sort -k1 -h 
alias mountiso  sudo mount -o loop 

alias guanji        sudo shutdown -h now 
alias gnome-monitor gnome-system-monitor 
alias mate-monitor  mate-system-monitor 

alias startxephyr   Xephyr -ac -screen 1600x900 :1 
alias startdisplay  DISPLAY=:1 

alias youget-default_dir  you-get -o ~/you-get/ 
alias curlget             curl -O -C -  
alias rsync               rsync -vzhP 

setenv GTK_IM_MODULE fcitx
setenv GTK3_IM_MODULE xim
setenv XMODIFIERS @im=fcitx

setenv LANG zh_CN.UTF-8
setenv LC_CTYPE zh_CN.UTF-8
setenv LC_ALL zh_CN.UTF-8
EOF

#------------------------------------------------------------------------------------------------------#

# 等同于 date +"%Y-%m-%d %H:%M:%S"
secondtime=`date +"%F %T"`

echo " "
echo "#########################################################"
echo "FirstTime: ${firsttime} " 
echo "EndTime  : ${secondtime} "
echo "#########################################################"

