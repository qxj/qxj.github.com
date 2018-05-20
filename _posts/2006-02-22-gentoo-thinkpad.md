---
title: 在笔记本上安装Gentoo系统
tags: Linux
---

以前用Emacs写的一篇Wiki，记录在Thinkpad T40p上安装Gentoo的经验，现在转到blog上来，另有一份留在[GooglePage](http://junist.googlepages.com/wiki%3Agentooinstallationtutorial)上，当然在Gentoo[官方Wiki](http://gentoo-wiki.com)上有更详尽的说明。

## 下载
下载 livecd 和 stage3，到 这里 找个mirror站点下载即可，最近的是在 [ftp://ftp3.tsinghua.edu.cn/mirror/gentoo](ftp://ftp3.tsinghua.edu.cn/mirror/gentoo) 或者 [http://gentoo.osuosl.org/releases/x86/](http://gentoo.osuosl.org/releases/x86/)

## 分区
从livecd 启动，给硬盘分区。硬盘分为4个区，linux可以完全安装在扩展分区上, 可以用 cfdisk 或者 fdisk 这样强大的工具来分区，分区结果如下：

挂载点 | 格式 | 大小 | 备注
--|--|--|--
/boot | ext2 | 50M | 放置 vmImage 和 grub
/swap | swap | 1.1G | 如果想实现supsend2( supsend to disk)，分区大小最好是ram大小的1.2
/ | reiserfs4 | 8G | 为了提高速度，可以选择reiserfs，因为 /var/tmp 是用来 编译软件包的，所以分8G是必须的
/home | ext3 | 16G | 这里主要放置用户数据和一些自行编译的软件，以稳定为主，故使用ext3


    Disk /dev/hda: 80.0 GB, 80026361856 bytes
    255 heads, 63 sectors/track, 9729 cylinders
    Units = cylinders of 16065 * 512 = 8225280 bytes

    Device Boot Start End Blocks Id System
    /dev/hda1 1 1460 11727418+ af Unknown
    Partition 1 does not end on cylinder boundary.
    /dev/hda2 * 1461 1947 3900960 7 HPFS/NTFS
    Partition 2 does not end on cylinder boundary.
    /dev/hda3 1948 9729 62508915 f W95 Ext'd (LBA)
    Partition 3 does not end on cylinder boundary.
    /dev/hda5 1948 3407 11727418+ 7 HPFS/NTFS
    /dev/hda6 3408 6569 25394481 b W95 FAT32
    /dev/hda7 6569 6575 52416 83 Linux
    /dev/hda8 6576 6710 1084356 83 Linux
    /dev/hda9 6711 7684 7823623+ 83 Linux
    /dev/hda10 7685 9729 16426431 83 Linux

### 挂载分区

打开硬盘的DMA，装完系统后，下边这句可以写到 `/etc/conf.d/local.start` 中。

    # hdparm -c 1 -d 1 /dev/hda

先格式化，然后挂载分区

    # mke2fs /dev/hda7
    # mkswap /dev/hda8
    # swapon /dev/hda8
    # mkfs.reiser4 /dev/hda9
    # mke2fs -j /dev/hda10

    # mount /dev/hda9 /mnt/gentoo
    # mkdir /mnt/gentoo/boot
    # mount /dev/hda7 /mnt/gentoo/boot
    # mkdir /mnt/gentoo/home
    # mount /dev/hda10 /mnt/gentoo/home
    # mkdir /mnt/gentoo/proc
    # mount -t proc none /mnt/gentoo/proc
    # mkdir /mnt/gentoo/dev
    # mount -o bind /dev /mnt/gentoo/dev

### 分区表

-   备份分区表信息：

        # dd if=/dev/(your_disk) of=mbr.save count=1 bs=512
        # sfdisk -d /dev/(your_disk) > partitions.save

    The first of those saves the mbr and the second will store all partition info (including logical partitions, which aren't part of the mbr).

-   还原分区信息：

        # dd if=mbr.save of=/dev/(your_disk)
        # sfdisk /dev/(your_disk) &lt; partitions.save

## 从stage3安装

把stage3 压缩包解压到 `/mnt/gentoo`，使用参数 <strong>p</strong>，保证不修改原来压缩包中的文件权限位。

    # tar xvjpf /mnt/cdrom/stages/stage3-&lt;subarch&gt;-2006.0.tar.bz2

### 安装 portage

下载 portage 压缩包，解压到 `/mnt/gentoo/`

    # tar xvjf /mnt/gentoo/portage-&lt;date&gt;.tar.bz2 -C /mnt/gentoo/

### 设置make.conf

根据T40p的硬件条件，几个主要的变量设置如下，USE 变量中必须的是 " `cjk nls ntpl ntplonly` "，强烈推荐使用稳定版本，也就是 `x86`：

    CFLAGS="-march=pentium-m -O3 -pipe -fomit-frame-pointer"
    #CFLAGS="-O3 -march=pentium-m -mtune=pentium-m -pipe -ftracer -fomit-frame-pointer -ffast-math -momit-leaf-frame-pointers"
    CHOST="i686-pc-linux-gnu"
    CXXFLAGS="${CFLAGS} -fvisibility-inlines-hidden"
    LDFLAGS="-Wl,-O1"
    #LDFLAGS="-Wl,-O1 -Wl,--enable-new-dtags -Wl,--sort-common -s"

    MAKEOPTS="-j3"
    ACCEPT_KEYWORDS="x86"
    USE="-fortran -arts -eds -ipv6 -qt -qt3 -qt4 -kde python -vorbis acpi X \
     bash-completion cjk cups esd gtk2 imlib mime mmx mmxext nls aiglx alsa \
     nptl nptlonly opengl oss posix readline sse sse-filters sse2 \
     truetype unicode xft ati dri apm -apache -apache2 -xmms -ldap "
    FEATURES="ccache parallel-fetch"
    CCACHE_SIZE="2G"
    CCACHE_DIR="/var/tmp/ccache"

    VIDEO_CARDS=" radeon vesa vga"
    INPUT_DEVICES=" keyboard mouse void synaptic"
    LINGUAS="zh_CN"
    GENTOO_MIRRORS="ftp://ftp3.tsinghua.edu.cn/mirror/gentoo"
    #GENTOO_MIRRORS="http://gentoo.139pay.com"
    #PORTDIR_OVERLAY="/usr/local/overlays/xgl-coffee"
    PORTAGE_BINHOST="https://e.ututo.org.ar/i686/"
    PORTAGE_BINHOST="http://gentoopackages.net/packages/i686/"

### 设置package.use

一个示例，该文件定制Gentoo软件包的编译参数。

    sys-libs/glibc userlocales
    x11-terms/rxvt-unicode xft -iso14755
    net-dialup/rp-pppoe -X
    net-dialup/ppp -gtk
    x11-base/xorg-x11 -3dfx -3dnow -bitmap-fonts -font-server -hardened -insecure-drivers -ipv6 -minimal mmx nls opengl pam -sdk sse sse2 -static truetype-fonts xv -type1-fonts -xprint
    media-video/mplayer rtc avi encode esd mpeg quicktime real cdparanoia dvd dvdread ati win32codecs xvid -xmms cpudetection
    mail-client/mutt imap pop mbox smime
    dev-util/subversion -nowebdav
    net-print/cups samba

## 安装准备

先复制`resolv.conf` 到新系统

    cp /etc/resolv.conf /mnt/gentoo/etc/

然后，`chroot` 到gentoo的系统，开始安装

    # chroot /mnt/gentoo /bin/bash
    # env-update && source /etc/profile

### 更新portage

    # emerge --sync

### 设置locale

根据 `/usr/share/i18n/SUPPORTED`，编辑文件 `/etc/locale.gen`

    en_US.UTF-8 UTF-8
    en_US ISO-8859-1
    zh_CN GB2312
    zh_CN.GBK GBK
    zh_CN.UTF-8 UTF-8
    zh_CN.GB18030 GB18030

### 设置时区

    # ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

修改 `/etc/conf.d/clock`，设置

    CLOCK="local"

设置正确的系统时间

    # date MMDDhhmmYYYY
    # hwclock --systohc

## 安装内核

从portage获取最新内核

    # USE="-doc" emerge gentoo-sources

### 编译内核

    # cd /usr/src/linux
    # make menuconfig
    # make && make modules_install
    # cp arch/i386/boot/bzImage /boot/&lt;kernel-version&gt;

### 安装grub

-   使用命令 `grub-install` 脚本，把grub的stage等文件复制到 `/boot/grub` 中去（grub-install只是一个shell脚本，通过调用grub命令来完成安装任务）：

        # grub-install /dev/hda

-   如果 `/boot` 为单独的分区，需要执行下边的命令：

        # grub-install --root-directory=/boot /dev/hda`

- 如果是mbr被损坏，要重新安装grub到mbr，在grub命令提示符下先用find寻找 stage1的位置，然后安装。

        # grub
        grub> find /boot/grub/stage1
        (hd0,6)
        grub> root (hd0,6)
        grub> setup (hd0)
        grub> quit

### 修改grub

比如刚才的取名为linux-2.6.16-r9，则在 `/boot/grub/menu.lst` 中添加：

    default saved
    timeout 3
    hiddenmenu

    title=Gentoo Linux
    root (hd0,6)
    kernel /linux-2.6.17-r8 root=/dev/hda9 ro
    savedefault

    title=Microsoft Windows XP Professional
    rootnoverify	(hd0,1)
    savedefault
    makeactive
    chainloader	+1

    title=Mac OS X
    root (hd0,0)
    savedefault
    makeactive
    chainloader	+1
    boot

### NT Loader

如果要跟windows到NT Loader配合，可以这样做:

-   先取得grub到引导扇区内容

        # dd if=/dev/hda7 of=bootsect.lin bs=512 count=1

-   把bootsect.lin 复制到windows所在分区，比如 c:\，修改`c:\boot.ini`

        [boot loader]
        timeout=10
        default=C:\BOOTSECT.LIN
        [operating systems]
        C:\BOOTSECT.LIN="Gentoo Linux GRUB Bootloader"
        multi(0)disk(0)rdisk(0)partition(0)\WINDOWS="Microsoft Windows XP Professional" /fastdetect /NoExecute=OptIn

## 安装软件包
### 必要的包

- dbus 新型ipc，进程间新的通信协议
- udev 比较新的系统，这个包已经包括在system中了
- hotplug 管理USB和PCI热拔插的工具
- coldplug 自动加载模块，比如插入u盘，则加载 usb_storage 等
- syslog-ng  用于syslogd的日志工具
- vixie-cron 用于cron的工具
- ccache 增加编译效率，结合FEATURES变量使用

### 显卡3D

首先需要内核支持agp，如果要编译非内核自带的drm，那么 一定 要取消掉内核的 drm支持，编译内核时候`make menuconfig`如下：

    Device Drivers --->
     Character devices --->

     <M> /dev/agpgart (AGP Support)
     <M> Intel 440LX/BX/GX, I8xx and E7x05 chipset support
     < > Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)
     < > ATI Radeon

因为drm是mesa必须依赖的包，则另外编译drm如下：

    # emerge -av libdrm x11-drm mesa mesa-progs

在启动模块中加入显卡相关模块 `/etc/modules.autoload.d/kernel-2.6`，如果不添加的话，那么装了coldplug后，估计也可以自动识别。

    intel-agp # your AGP chipset
    agpgart
    radeon

#### 安装mesa驱动

如果要启动Aiglx的话，它已经内置到xorg-x11-7.1中了，编译之：

    # emerge -av xorg-x11 xorg-server xf86-input-evdev xf86-input-mouse xf86-input-keyboard xf86-video-vga xf86-video-vesa xf86-video-ati

然后修改xorg.conf在对应处添加如下项目：

    Section "Module"
     Load "dri"
    	Load	"drm"
    # Load "GLcore"
    EndSection

    Section "DRI"
     Group 0
     Mode 0666
    EndSection

    Section "ServerLayout"
     Option "AIGLX" "true"
    EndSection

    Section "Device"
     Identifier "ATI FireGL 9000 Mobile[M9]"
     Driver "ati"
     VideoRam 65536
     # Insert Clocks lines here if appropriate
    	BusID		"PCI:1:0:0"
    	Option		"BusType"		"AGP"
    	Option		"AGPMode"			"4"
    	Option		"EnablePageFlip"		"true"
    	Option		"RenderAccel"			"on"
    	Option		"UseInternalAGPGART"	"no"
    	Option		"mtrr"					"on"
    	Option		"ColorTiling"			"on"
    	Option		"OpenGLOverlay"			"off"
    	Option		"VideoOverlay"			"on"
    #	Option		"ReducedBlanking"
     # This two lines are needed to prevent fonts from being scrambled
     Option "XaaNoScanlineImageWriteRect"
     Option "XaaNoScanlineCPUToScreenColorExpandFill"
    	Option "XAANoOffscreenPixmaps" "true"
    	Option "DRI" "true"
    	Screen 0
    EndSection

    Section "Extensions"
     Option "Composite" "Enable"
    EndSection

    Section "Screen"
     DefaultDepth 24
    EndSection

修改 `/etc/env.d/03opengl`，使用命令

    # eselect opengl set xorg-x11

#### 安装ati-drivers

此为闭源驱动，无法使用Aiglx。

注意安装完成之后：

-   修改 `/etc/X11/xorg.conf`，设置

        Section "Device"
        Identifier "fglrx"
       	Driver "fglrx"
       	VideoRam 65536
       	BusID		"PCI:1:0:0"
        ...

-   修改 `/etc/env.d/03opengl`，使用命令

        # eselect opengl set ati

    或者直接修改该文件

        LDPATH="/usr/lib/opengl/ati/lib"
        OPENGL_PROFILE="ati"

### 安装无线网卡

T40p不是迅驰机，采用的是Dual无线网卡，`lspci` 可以看到：

> 02:02.0 Ethernet controller: Atheros Communications, Inc. AR5211 802.11ab NIC (rev 01)

所以安装<strong>madwifi-ng</strong>驱动支持，辅助的工具安装wireless-tools和 wpa_supplication，前者提供iwconfig，后者提供wpa加密网络的便捷支持。推荐的 GUI设置工具为network-admin，此工具包含在gnome-system-tools包中，我在安装过程中发觉唯独丢掉了network-admin这个工具，可以修改 gnome-system-tools-2.14.0.ebuild中第35行为：

    G2CONF="${G2CONF} --enable-boot --enable-services --enable-network"

另外值得推荐的工具是networkmanager，不过在-x86中是被mask的，因为还不稳定，事实使用过程中也常常crash :P

    # emerge -av madwifi-ng wpa_supplication gnome-system-tools networkmanager

如果启用NetworkManager来管理网络设备的话，需要先把 `net.*` 从runlevel里边删除，然后添加NetworkManager到default的runlevel。

    # rc-update delete net.eth0 net.lo
    # rc-update add NetworkManager default

#### 无线网卡的配置

使用GUI工具的话配置很简单，需要知道的东西是无线网络的ESSID和加密方式，加密方式包括是否加密和加密的用户名密码。

##### pam_keyring

使用NetworkManager来管理的话，有一个令人厌烦的地方是，每次启动后 gnome-keyring会提醒你输入密码，可以安装pam_keyring来解决；装完 pam_keyring后，编辑文件 `/etc/pam.d/gdm`，加入如下内容：

    auth optional pam_keyring.so try_first_pass
    session optional pam_keyring.so

如果不幸你曾经输入的keyring密码和你的登录密码不一致，因为当前的 gnome-keyring没有机制修改密码，所以你需要首先杀死gnome-keyring-daemon进程，然后删除keyring文件 `~/.gnome2/keyrings`，然后重新登录设置匹配的密码。

### world软件包记录
自行使用emerge命令安装过的软件包名都记录在 `/var/lib/portage/world` 中了:

#### Beryl+Gnome-light构建桌面
##### Gnome中常用的工具有

- evince 阅读pdf,dvi
- eog 看图
- rhythmbox 音乐播放
- nautilus 资源管理器
- gnome-applets 包含network, battery monitor，放在工具栏很方便
- gnome-cups-manager 打印机管理
- gnome-volume-manager 磁盘卷管理器，记得 把用户加入 plugdev 组
- gnome-system-tools 其中的network-admin比较方便
- networkmanager 网络管理，方便切换wired和wireless，用来替代baselayout
