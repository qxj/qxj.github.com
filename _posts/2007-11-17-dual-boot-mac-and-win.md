---
title: pc上mac os x和windows双启动
tags: macOS
---

以前在t40p上尝试装过mac os x for x86，不过当时没有支持firegl 9000的驱动；最近又在t60上尝试了一下，发觉jas版本对新显卡都支持得不错，leopard还有不少小毛病，tiger基本很稳定，系统可用。记录一下遇到的双启动的问题。

双启动的办法有很多，枚举几个：

- windows nt loader
- darwin bootloader
- wingrub (grub)
- acronis os selector

而对于有系统洁癖的人来说，前两者不需要任何其他软件，是最佳选择。而grub是定制功能最强，os selector 最是易用。

## windows nt loader

在说明双启动问题之前，先回顾一下几点安装细节。如果已经安装了windows了，那么需要先为mac os x准备一个hfs主分区，可以使用acronis disk director suite来作，其中的分区类型选择`0AFh`，并且需要是主分区。如果需要双启动的话，最好不要把这个主分区放在1024个柱面，大概8.4GB之后。

为什么最好把mac的主分区放在开始扇区呢？因为双启动如果使用nt loader的话，需使用chain0。其中chain0文件位于tiger的安装盘上，把它复制到windows的C:盘上，然后在boot.ini里边添加一句`C:\chain0="Mac OS X - Tiger"`，则在nt loader的启动界面中就有mac os x的启动选项了。而如果mac的主分区太靠后的话，chain0会失效，导致找不到mac os x系统。

## darwin bootloader

由于chain0并不是太好用，所以我推荐直接使用mac os x自带的 darwin bootloader 来启动多系统。这个时候需要留意的是，必须把mac os x所在分区激活(active)。激活的方法有很多，windows下可以使用acronis disk director suite或者pqmagic这样的工具；或者直接使用你的tiger安装盘，它类似一个livecd，进入安装界面后，调出终端程序(Terminal)。直接使用pdisk来激活分区，比如你的硬盘名是rdisk，用`diskutil list`查找一下hfs分区，结果可能看到你的mac os x分区位于第一个分区，也就是rdisk0s1。

    # pdisk -e /dev/rdisk0

然后使用`p`命令，可以看到当前激活分区前有一个星号(*)，果然mac主分区没有被激活，则使用`flag 1`，其中数字1是分区号，代表现在要激活的设备是rdisk0s1，然后命令`w`，写入更新后，命令`exit`退出。

然后重启系统，在重新进入系统时候按住键F8，可以列出所有的分区，选择windows主分区，确定，即可启动windows系统。

如果你觉得来不及按F8，可以增加选择延时。编辑文件 `/Library/Preferences/SystemConfiguration/com.apple.Boot.plist`，在其中增加一项即可：

    <key>Timeout</key>
    <string>8</string>

## wingrub (grub)

当使用wingrub的时候，最好可以保留一个fat32的分区，否则没法将wingrub装入mbr，也就没法开机即启动wingrub。这样只有先启动windows nt loader，在nt loader中启动wingrub，然后再由wingrub启动mac os x，看起来似乎还可行，但是有个关键问题，看下边启动mac os x的menu.lst部分：

    title=Mac OS X - Tiger
    root (hd0,0)
    makeactive
    chainloader +1

其中用到了makeactive命令，这样就导致mac主分区成为了活动分区，重启系统之后，将不会再启动nt loader进而启动wingrub，而是直接进入了mac os x。

如果有linux系统需要双启动，那就很推荐linux下的grub工具了，把它直接写入mbr，用它来进行多系统启动同样游刃有余，而且它的自动补全功能也很强大。

## acronis os loader

另外还有种傻瓜方法就是使用acronis公司的os selector，这个软件很强大，基本上所有硬盘上存在的可以启动的系统它都能检测出来，如果想省事，又没有软件洁癖的，推荐使用。不过某次mac分区在60G之后时候，它似乎失效了 :( 其他就不赘述了。

此外据说还有种在扩展分区上使用tboot的办法，不过我没有尝试过。

如果是在一块新硬盘上安装mac os x就很简单了，不需要预先分hfs分区，用mac的disk utility就能擦除出一个hfs分区了。

另外，就是无线网卡的问题，除了broadcom的卡其他都不支持，遗憾。还好其他硬件均工作正常。

最后推荐关于在pc上折腾mac os x内容很全的wiki：[osx86project](http://wiki.osx86project.org)
