---
title: bblean取代explorer.exe
tags: Windows 工具
---

*基于bblean 1.16*

## 简介

bblean 是blackbox在win32下的一个port，跟古老的fluxbox是同宗的。这是一个简洁而稳定的shell，并且是free的。现在win下我用过的shell也就三种

- winxp default shell
- aston
- bblean

对比起来，它比前两者更少占用资源，更加具备定制性，用它来作为shell太合适不过。自由的定义快捷键，多个虚拟工作区，细节的控制wm的各个尺寸和式样，加上n多plugin的支持，没有理由不选择它。

然而它也有些缺陷，最严重的是plugin的站点根本链接不上，不知道是封锁了国内ip，还是给盾住了 T_T。直接导致很多plugin找不到，而且很多plugin的introduction也看不到，许多发布的plugin是光秃秃的dll，没有说明文档，没有配置文件。比如bbInterface, bbIcons，于是很多设置不知道什么含义，比如 bbWinTranz 有些配置我就是看完源码才知道的。

## 目录结构

    bblean
    │  blackbox.exe
    │  blackbox.rc         主配置文件
    │  bsetroot.exe        设置墙纸的程序，功能类似linux下的xloadimage
    │  bsetroot.rc         bsetroot配置文件
    │  extensions.rc       一些杂项设置，比如编辑配置文件的编辑器，全局的式样设置
    │  INSTALL.bat         把bblean安装成默认shell
    │  menu.rc             bblean系统菜单
    │  plugins.rc          插件的开关文件
    │  shellfolders.rc     定义了系统路径的别名，比如 C:\Windows 等
    │  stickywindows.ini   设置可以跨越工作区的程序名称
    │  UNINSTALL.bat       取消bblean成为默认shell
    ├─backgrounds          墙纸可以搁这里
    ├─docs
    ├─fonts
    ├─plugins              插件目录
    │  ├─bbfoomp
    │  ├─bbGesture
    │  ├─bbIcons
    │  ├─bbInterface       功能强大的容器插件，可以在桌面方便的搁很多很多东西，替代bbSlit,bbSlider等
    │  ├─bbKeys            最必要的快捷键插件
    │  ├─bbKontroller      日本人写的一个proxy，作为控制bblean的桥梁，给bblean传递消息
    │  ├─bbLeanBar         类似win的任务栏，但是功能更多
    │  ├─bbLeanSkin        wm里边给窗口添加的附加内容，比如标题栏
    │  ├─bbMemShrink
    │  ├─bbNote
    │  ├─bbPager           多个工作区的分页器
    │  ├─BBRecycleBin      回收站的接口
    │  ├─BBSeekbar
    │  ├─bbSlider
    │  ├─bbSlit
    │  ├─BBSysmon          系统信息监视器，比如cpu,ram,ip,disc
    │  ├─bbSysmonPlus
    │  ├─bbTray            可以把tray栏提出来
    │  ├─bbWinTrans        很酷的透明化窗口功能，类似vista，但耗资源
    │  └─BroamTimer
    └─styles

## Reference
