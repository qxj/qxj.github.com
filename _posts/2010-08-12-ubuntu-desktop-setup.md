---
title: Ubuntu桌面配置记录
tags: Linux 工具
---

Ubuntu 10.04 LTS

## Locale设置

编辑文件 `/etc/default/locale`，加入：

    LC_CTYPE="zh_CN.UTF-8"

编辑文件 `/var/lib/locales/supported.d/local`，加入：

    zh_CN GB2312
    zh_CN.GBK GBK
    zh_CN.UTF-8 UTF-8
    zh_CN.GB18030 GB18030
    zh_TW.BIG5 BIG5

然后手动生成中文相关的 locales：

    $ sudo locale-gen

## iBus输入法

默认的m17n的拼音输入模块不是很好用，可以选择安装iBus Pinyin：

    $ sudo aptitude install ibus-pinyin

## Global menu (OS X Style)

参考[这里](http://code.google.com/p/gnome2-globalmenu/wiki/InstallingonUbuntu)，加入源：

    deb http://ppa.launchpad.net/globalmenu-team/ppa/ubuntu lucid main
    deb-src http://ppa.launchpad.net/globalmenu-team/ppa/ubuntu lucid main

然后安装：

    $ sudo aptitude install gnome-applet-globalmenu

安装后在 Top Panel 中选择 "Global Menu Panel"。

## 配置[SK-8855键盘](http://www-307.ibm.com/pc/support/site.wss/MIGR-73183.html)

- 交换Cap Lock和左边的Control
- 利用[TrackPoint替代](http://www.thinkwiki.org/wiki/How_to_configure_the_TrackPoint#Example:_openSUSE_11.2_and_ThinkPad_USB_Keyboard_with_TrackPoint)鼠标滚轮操作

编辑 `~/.xsessionrc` ：

    #!/bin/sh
    xinput list | sed -ne 's/^[^ ][^V].*id=\([0-9]*\).*/\1/p' | while read id
    do
            case `xinput list-props $id` in
            *"Middle Button Emulation"*)
                    xinput set-int-prop $id "Evdev Wheel Emulation" 8 1
                    xinput set-int-prop $id "Evdev Wheel Emulation Button" 8 2
                    xinput set-int-prop $id "Evdev Wheel Emulation Timeout" 8 200
                    xinput set-int-prop $id "Evdev Wheel Emulation Axes" 8 6 7 4 5
                    xinput set-int-prop $id "Evdev Middle Button Emulation" 8 0
                    ;;
            esac
    done

    # disable middle button
    # xmodmap -e "pointer = 1 9 3 4 5 6 7 8 2"

## xterm显示中文

设置 `~/.Xdefaults` 即可：

    XTerm*locale: true
    XTerm*utf8Title: true
    XTerm*fontMenu*fontdefault*Label: Default
    XTerm*faceName: DejaVu Sans Mono:pixelsize=14
    XTerm*faceNameDoublesize: WenQuanYi Micro Hei
    XTerm*cjkWidth:true
    ! XTerm*background: black
    ! XTerm*foreground: white
    XTerm*scrollBar: true
    XTerm*rightScrollBar: true
    XTerm*jumpScroll:  true
    XTerm*SaveLines: 5000

加载设置看看效果：

    $ xrdb -load ~/.Xdefaults
