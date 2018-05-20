---
title: 在WMWare Workstation 5.0下安装redhat 9和hiweed debian
tags: Windows
---

## 网络
### 网卡不能激活的问题：

1. init 3; install vm tools; init 5; you will see a new eth0 card ;)
2. add below to eth0 config file /etc/sysconfig/network-scripts/ifcfg-eth0.

    ```
    check_link_down() {
        return 1;
    }
    ```

3. bring up eth0 interface

http://cnblogs.com/Hacker/archive/2004/08/03/29709.aspx

### 在WMWare里有三种安装virtual adapter的方法：

- bridge，直接桥接，一个MAC分配给两个ip地址，你虚拟机的会出现在物理的LAN里。
- nat，这个需要wmware自己的dhcp给你分配地址，我把wmware内建的4个服务全部disable掉了。
- host-only，它可以跟你的系统共享一个网卡。

http://www.chinaunix.net/jh/4/374483.html

使用host-only方法，先把外网网卡设置成可共享的。在网卡的高级选项里，把共享的checkbox打勾，选择VMnet1。注意这样做的时候不要启动wmware，否则会共享失败。然后打开VMnet的TCP/IP属性，发现已经分配到一个地址192.168.0.1。

进入虚拟机的linux系统，打开网络的设置卡片，填入静态地址，`192.168.0.*`，*代表你可以填入除了192.168.0.1之外的所有0段IP。填入你可用的dns，然后重新启动网络服务：

    /sbin/service network restart

发现可以上网了。

### 参考资料：

- vmware 配置实例一 [linux host + windows guest + firewall](http://bbs.chinaunix.net/forum/viewtopic.php?t=367907&amp;highlight=yunqing)
- vmware 网络设置三：[理解虚拟网络的类型](http://bbs.chinaunix.net/forum/viewtopic.php?t=376768&amp;highlight=yunqing)


另外需要说的是，安装vmware tools。安装完gxs之后，在安装目录里有好几个iso文件。这里选择linux.iso，在wmware里修改cdrom的属性，添加为 linux.iso。然后进入系统，mount后解压，运行install.pl安装。具体可以参考wmware tools上的那张help文档。

安装wmware不需要使用d-tools，同样跟上边一样，修改cdrom的属性，指向安装的iso文件即可。我原来印象中以为要用d-tools，然后自运行安装，后来发觉错了。而安装之前最好选择足够的磁盘空间，否则当建立一个虚拟机之后就无法修改分配的磁盘大小了。

## Speed Step导致虚拟机时钟出错

具体讨论[链接](http://www.vmware.com/info?id=97)：

This article applies to VMware Workstation 4.0 and higher, and VMware GSX Server 2.5.1 and higher, running on Windows hosts.

For Linux hosts running these product versions, see knowlege base article 1591 at http://www.vmware.com/support/kb/enduser/std_adp.php?p_faqid=1591 . For previous versions of these products see knowlege base article 708 at http://www.vmware.com/support/kb/enduser/std_adp.php?p_faqid=708 .

This problem occurs on some host computers that use Intel SpeedStep or other similar power-saving technologies that vary the processor speed.

To work around this problem, you can specify the correct maximum CPU speed in your global configuration file. On Windows hosts, this file is normally C:\Documents and Settings\All Users\Application Data\VMware\VMware Workstation\config.ini for VMware Workstation or C:\Documents and Settings\All Users\Application Data\VMware\VMware GSX Server\config.ini for GSX Server.

If this file exists, edit it with a text editor, adding the lines described below. The file may not exist. If it does not exist, create it as a plain text file.

On Windows, you can use Notepad, but be careful when you save the file that Notepad does not add an extra .txt extension to the filename. You can do that by selecting <strong>All files</strong> instead of <strong>Text files</strong> in the Save dialog box.

The example presented here assumes that the host computer has a maximum speed of 1700MHz. The first line is the most important one. It should be your host computer's maximum speed in KHz -- that is, its speed in MHz times 1000, or its speed in GHz times 1000000. Add the following lines to your global configuration file:

host.cpukHz = 1700000
host.noTSC = TRUE
ptsc.noTSC = TRUE

In addition, check the VMware Tools control panel in the guest operating system. On the Options tab, be sure <strong>Time synchronization between the virtual machine and the host operating system</strong> is selected.

## 文件夹共享

In a Linux virtual machine, shared folders appear under /mnt/hgfs.
To change the settings for a shared folder on the list, click the folder's name to highlight it, then click Properties. The Properties dialog box appears.
Change any settings you wish, then click OK.

## VMware Tool安装

- 在console界面下安装，不要启动xserver，deiban下使用<a href="http://wiki.linuxquestions.org/wiki/Rcconf">rcconf</a> 或者 sysv-rc-conf 命令，取消xdm。redhat下取消xserver。
- 当配置的时候可能会提示vmhgfs module缺乏，需要kernel-source进行编译，要是没有可以这样：
    ```
    apt-cache search "kernel-source"
    apt-get install "查询到的跟内核编码一致的source"
    ```
注：apt-get的用法，若手动下载deb文件，则使用dpkg命令安装。当有的包删除有问题时候，尝试apt-get remove package --purge。
- 编译完vmxnet module，后
    ```
    /etc/init.d/networking stop
    rmmod pcnet32
    rmmod vmxnet
    depmod -a
    modprobe vmxnet
    /etc/init.d/networking start
    ```

## 安装j2sdk
方法1：
先安装 java-package
apt-get install java-package
然后下载 JRE 或 JDK 的 bin 安装包
再用 java-package 工具把 bin 包转换为 deb 包
make-jpkg *.bin
然后安装 deb 包
dpkg -i *.deb

- 方法2：
添加源
deb http://debian.ustc.edu.cn/debian-uo sid ustc
然后
apt-get install sun-j2sdk1.5

## sources-list
[linuxfans](http://www.linuxfans.org/nuke/modules.php?name=Forums&amp;file=viewtopic&amp;t=84203&amp;postdays=0&amp;postorder=asc&amp;start=0) [download](http://juni.blogchina.com/inc/sources.list.txt)

## 推荐包管理器
### debian
aptitude 可以查看package之间的关联

### redhat

- 安装 rpm -ivh rpmfile.rpm
- 删除 rpm -e foo
- 升级 rpm -Uvh rpmfile.rpm
- 查询 rpm -q foo
- 校验 rpm -V foo

## 参考：
- [vmware support](http://www.vmware.com/support/ws5/doc/ws_newguest_tools_linux.html#wp1009291)
- [linusir](http://www.linuxsir.org/bbs/forumdisplay.php?f=49)
- [hiweed desktop](http://linux.hiweed.com/forum/1)
