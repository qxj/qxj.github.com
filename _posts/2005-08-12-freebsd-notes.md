---
title: FreeBSD手记
tags: 学习
---

*- 基于FreeBSD 5.4 -*

> 感谢FreeBSD文档的编写者和译者，他们使得我在学习使用FreeBSD的过程中有了极其完备和系统的资料可以参考，这点比起对其他操作系统的学习来说，是相当幸福的 *^_^*

## 设置中文环境

- [FreeBSD Chinese HowTo](http://netlab.cse.yzu.edu.tw/~statue/freebsd/zh-tut/index.html) [强烈推荐，基本能解决大多中文环境问题]
- [Linux 中文环境和中文化版FAQ](http://www.linuxforum.net/forum/showflat.php?Cat=&Board=chinese&Number=466043&page=0&view=collapsed&sb=5&o=&fpart=)
- [How to input Chinese?](http://www.freebsdchina.org/forum/viewtopic.php?t=20500&sid=5857118ac60124cda6f86a25a96ef394) [[forum](http://www.freebsdchina.org/forum/forum_57.html)]
- [打造简体中文环境的 FreeBSD 工作站(12.10.2004更新)](http://www.freebsdchina.org/forum/viewtopic.php?t=7686&sid=5857118ac60124cda6f86a25a96ef394)
- [添加typeture字体](http://www.lslnet.com/linux/docs/linux-3080.htm)
- [FreeBSD+xfce+fcitx+mozilla中文桌面安装过程](http://www.freebsdchina.org/forum/viewtopic.php?t=18568)


## 安装新的字体
freeBSD下安装gnome或者kde之后，不带win系统下常用的simun之类的字体。常常系统显示的字体很难看。安装字体文件首先获得字体，一种是从本地之外获得；要是本地主机安装了win系统，可以直接`mount`。先查看win系统所在分区：

    fdisk

也可以在`/dev`目录下找到：

    ls /dev/ad*

然后，使用`mount`命令，若win分区为ntfs，假设在ad0s1则：

    mount -t ntfs /dev/ad0s1 /mnt

或者，直接使用`mount_ntfs`命令。然后从 `%SystemRoot%/Fonts/` 下把simun.ttc拷贝到BSD下边，改名为simun.ttf，然后：

    umount -f /mnt

字体文件可以放到`/usr/X11R6/lib/X11/fonts`下边，并且把该目录添加到`/etc/X11/xorg.conf`的字体目录下边。或者直接放到`~/.fonts`下边，同样该目录也需要在xorg.conf中存在。下边的命令可以列出中文字体：

    fc-list :zh-CN

## 启动鼠标滚轮
往xorg.conf中关于mouse的section中加入：

    Option "ZAxisMapping" "4 5"

## 配置网络

- 配置网卡：/etc/rc.conf
- 配置dns：/etc/resolv.conf
- 配置hosts：/etc/hosts
- 重启以太网卡：

        ifconfig [ip-interface optional] down
        ifconfig [ip-interface optional] up



## 远程控制

在实验室一般是把实验室主机当作服务器，然后从自己的nb上远程登陆到自己的主机，这样就不用在两台机器之间忙碌就可以完成工作啦。所以介绍一下开设sshd服务。可能我们在安装freebsd的时候没有选择让自己的主机运行sshd daemon，那就按照下边的步骤来。

1. 生成主机密钥，会提示你输入passphrase，用于主机密钥的passphrase为空；

        #用于ssh1的rsa1密钥
        ssh-keygen -t rsa1 -f /etc/ssh/ssh_host_key
        #用于ssh2的dsa密钥
        ssh-keygen -d -f /etc/ssh/ssh_host_dsa_key

2. 生成所要登陆用户的密钥，此时需要输入一个复杂的passphrase，建议10-20个字符。密钥会保存在~/.sshd/目录下；

        #用于ssh1的rsa1密钥
        ssh-keygen -t rsa1
        #用于ssh2的dsa1密钥
        ssh-keygen -d

3. 设置sshd为守护进程，开机启动，在/usr/X11R6/etc/rc.d/目录下建立可执行文件sshd.sh


        #vi sshd.sh ↓
        #!/bin/sh
        /usr/sbin/sshd
        :wq
        #/etc/rc.d/sshd restart


4. 另外还有两种方法启动sshd，第一是，在/etc/rc.d中设置

        sshd_enable="YES"

    第二是，使用超级服务器inetd，在/etc/inetd.conf中设置取消如下一行前的注释

        ssh stream tcp nowait root /usr/sbin/sshd sshd -i -4

    然后重启inetd

        /etc/rc.d/inetd restart

    重启方法还可以是找到inetd的地址，然后

        kill -HUP [inetd pid]

5. 自此sshd服务器设置完毕，如果你不是在NAT之内使用sshd，而是暴露在internet上，那还需要安全配置：简单的可以设置`/etc/hosts.allow`，在最上边allow的行上添加远程ip地址。


        sshd : 192.168.0.1/255.255.255.0 : allow
        sshd : ALL : spawn (/bin/echo Security notice from host `/bin/hostname`; \
        /bin/echo; /usr/sbin/safe_finger @%h ) | \
        /bin/mail -s "%d -%h security" root@localhost & \
        : twist ( /bin/echo -e "\n\nWARNING connectin not allowed. Your attempt has been logged. \n\n\n". )


6. 要是只是在本地子网内使用sshd，可以在/etc/ssh/sshd_config中取消DNS解析，这样就不用在通过远程服务器，很大的提高了联网速度：

        UseDNS no

7. 客户端，在远程win32系统下可以使用PuTTY登陆，为了可以输入中文，需要选择中文字体。windows->appearance->font setting，具体说明见[FreeBSD Chinese HowTo](http://netlab.cse.yzu.edu.tw/~statue/freebsd/zh-tut/ssh.html)。然而现在另有对中文支持更加完美，功能更强大的[PeiTTY(pputty)](http://ntu.csie.org/~piaip/pietty/)可以选择。

8. 启动xdmcp，在Win32下启用XServer，比如Exceed。

## 远程X控制

## inetd, super service

## TCP Wrapper

## qmail安装与配置
参考 [qmailwithlife](http://www.lifewithqmail.org/)

架设webmail若是使用imap，可以选择courier-imap，注意的是php的imap extension却是需要imap-uw来编译的。从qmail到完整webmail的架设配置内容很多，需要另开一篇blog来写。

## 架设ftpd
直接使用FreeBSD自带的ftpd，或者ports的proftpd，都很好用
自带ftpd的具体配置 man ftpd, ftpchroot

相关文件：

- `/etc/ftpusers `拒绝的用户
- `/etc/ftpchroot` 允许的用户


## apache2 httpd中ssl的配置
apache从源码安装比较费劲些，尤其设计到跟ssl、ldap、php之类模块的编译；所以推荐还是从ports安装。


http://httpd.apache.org/docs/2.0/programs/configure.html#configurationoptions

    setenv LDFLAGS "-L/usr/local/lib"
    setenv CPPFLAGS "-I/usr/local/include"
    -----
    /tmp/httpd-2.0.54/modules/experimental/util_ldap.c:1448: warning: warning: tmpnam() possibly used unsafely; consider using mkstemp()
    -----
    ./configure --prefix=/usr/local/apache2 \
    --with-ldap \
    --with-gdbm \
    --enable-auth-dbm \
    --enable-auth-digest \
    --enable-auth-ldap \
    --enable-expires \
    --enable-cache \
    --enable-disk-cache \
    --enable-headers \
    --enable-ldap=shared \
    --enable-mime-magic \
    --enable-rewrite \
    --enable-mods-shared=most \
    --enable-ssl=shared \
    --enable-vhost-alias
    make
    make install


为你的Apache服务器创建一个RSA私用密钥(被Triple-DES加密并且进行PEM格式化)：

    penssl genrsa -des3 -out server.key 1024

用服务器RSA私用密钥生成一个证书签署请求（CSR-Certificate Signing Request）（输出将是PEM格式的）

    openssl req -new -key server.key -out server.csr

假定已经安装好了openssl，如果openssl安装时的prefix设置为/usr/local/ssl，那么把/usr/local/ssl/bin加入执行文件查找路径。还需要`MOD_SSL`源代码中的一个脚本，它在`MOD_SSL`的 源代码目录树下的pkg.contrib目录中，文件名为 `sign.sh`。将它拷贝到 /usr/local/openssl/bin 中。

先建立一个 CA 的证书，首先为 CA 创建一个 RSA 私用密钥，

    openssl genrsa -des3 -out ca.key 1024

系统提示输入 PEM pass phrase，也就是密码，输入后牢记它。生成 ca.key 文件，将文件属性改为400，并放在安全的地方。

    chmod 400 ca.key

你可以用下列命令查看它的内容，

    openssl rsa -noout -text -in ca.key

利用 CA 的 RSA 密钥创建一个自签署的 CA 证书（X.509结构）

    openssl req -new -x509 -days 3650 -key ca.key -out ca.crt

然后需要输入下列信息：

    Country Name: cn 两个字母的国家代号
    State or Province Name: Beijing 省份名称
    Locality Name: Beijing 城市名称
    Organization Name: Family Network: IOS 公司名称
    Organizational Unit Name: ERCIST 部门名称
    Common Name: Julian 你的姓名
    Email Address: ju11an-go@yahoo.com.cn Email地址

生成 ca.crt 文件，将文件属性改为400，并放在安全的地方。

    chmod 400 ca.crt

你可以用下列命令查看它的内容，

    openssl x509 -noout -text -in ca.crt

下面要创建服务器证书签署请求，
首先为你的 Apache 创建一个 RSA 私用密钥：

    openssl genrsa -des3 -out server.key 1024

这里也要设定pass phrase。 生成 server.key 文件，将文件属性改为400，并放在安全的地方。

    chmod 400 server.key

你可以用下列命令查看它的内容，

    openssl rsa -noout -text -in server.key

用 server.key 生成证书签署请求 CSR.

    openssl req -new -key server.key -out server.csr

这里也要输入一些信息，和[S-4]中的内容类似。 至于 'extra' attributes 不用输入。

你可以查看 CSR 的细节:

    openssl req -noout -text -in server.csr

下面可以签署证书了，需要用到脚本 sign.sh

    sign.sh server.csr

就可以得到server.crt。 将文件属性改为400，并放在安全的地方。

    chmod 400 server.crt

删除CSR

    rm server.csr

最后apache设置

如果你的apache编译参数prefix为/usr/local/apache， 那么拷贝server.crt 和 server.key 到 /usr/local/apache/conf .修改httpd.conf 将下面的参数改为：

    SSLCertificateFILE /usr/local/apache/conf/server.crt
    SSLCertificateKeyFile /usr/local/apache/conf/server.key

可以 apachectl startssl 试一下了。

## DNS配置

首先安装bind9，从/usr/ports/dns/bind9，然后在/etc/namedb目录使用make-localhost脚本，在master目录中生成localhost.rev和localhost-v6.rev文件

    sh make-localhost

主要的配置文件是/etc/namedb/named.conf，
配置完的named.conf文件见附录示例，下边解释一下一些修改的项：


- `forwarders` 里写入该dns请求上层dns的ip地址。
- `query-source address * port 53;` 要是该dns跟要对话的dns之间存在firewall，则设定请求固定请求端口。
- `key "rndc-key"`和`controls`是rndc请求密钥以及地址和端口限制
- 域名和反解

        zone "pd.fsc" {
                type master;
                file "/etc/namedb/hosts/pd.fsc.hosts";
        };
        zone "0.168.192.in-addr.arpa" {
                type master;
                file "/etc/namedb/rev/192.168.0.rev";
        };

- 然后新建目录hosts和rev，以及相应文件

pd.fsc.hosts主机文件

该文件用来设定域名，指明某个域名该对应的IP地址，下例上部分表示要查询的DNS主机是pd.fsc,192.168.0.3和159.226.5.65，下部分表示的RR为localhost对应127.0.0.1，www.pd.fsc和mail.pd.fsc都对应192.168.0.23地址。


    $TTL 3600

    @ IN SOA dns.pd.fsc. dns.root.pd.fsc. (
                                      20050906 ; Serial
                                      3600 ; Refresh
                                      900 ; Retry
                                      3600000 ; Expire
                                      3600 ) ; Minimum
    ; DNS Servers
    IN NS pd.fsc.
    IN NS 192.168.0.3
    IN NS 159.226.5.65

    ; Well know service
    IN MX 10 mail
    localhost IN A 127.0.0.1
    www IN A 192.168.0.23
    mail IN A 192.168.0.23


192.168.0.rev反解文件：

反解文件的作用是根据IP查询主机名字，下例定义了192.168.0.0这个网段的反查信息，比如反查192.168.0.23则是pd.fsc该域名。其中IN表示Internet地址，PTR代表一个指针。


    $TTL 3600

    @ IN SOA pd.fsc. root.pd.fsc. (
                                      20050906 ; Serial
                                      3600 ; Refresh
                                      900 ; Retry
                                      3600000 ; Expire
                                      3600 ) ; Minimum

    IN NS dns.pd.fsc.
    23 IN PTR pd.fsc.


利用rndc-keygen在/etc/namedb生成rndc.conf和rndc.key，并且把rndc.conf中提示copy到named.conf中的内容copy过去。

在rc.conf中加入named：

    named_enable="YES"

手工启动named，并在终端输出信息：

    named -g &

终端可以看到如下类似内容：


    08-Sep-2005 13:39:39.100 starting BIND 9.3.1 -g
    08-Sep-2005 13:39:39.100 found 1 CPU, using 1 worker thread
    08-Sep-2005 13:39:39.107 loading configuration from '/etc/namedb/named.conf'
    08-Sep-2005 13:39:39.109 no IPv6 interfaces found
    08-Sep-2005 13:39:39.109 listening on IPv4 interface rl0, 192.168.0.23#53
    08-Sep-2005 13:39:39.111 listening on IPv4 interface lo0, 127.0.0.1#53
    08-Sep-2005 13:39:39.127 command channel listening on 127.0.0.1#953
    08-Sep-2005 13:39:39.128 ignoring config file logging statement due to -g option
    08-Sep-2005 13:39:39.130 zone 0.0.127.IN-ADDR.ARPA/IN: loaded serial 20050908
    08-Sep-2005 13:39:39.132 zone 0.168.192.in-addr.arpa/IN: loaded serial 20050906
    08-Sep-2005 13:39:39.133 zone 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.IP6.ARPA/IN: loaded serial 20050908
    08-Sep-2005 13:39:39.135 zone pd.fsc/IN: loaded serial 20050906
    08-Sep-2005 13:39:39.137 zone 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.IP6.INT/IN: loaded serial 20050908
    08-Sep-2005 13:39:39.138 running
    08-Sep-2005 13:39:39.139 zone pd.fsc/IN: sending notifies (serial 20050906)
    08-Sep-2005 13:39:39.140 zone 0.168.192.in-addr.arpa/IN: sending notifies (serial 20050906)
    08-Sep-2005 13:39:39.155 client 192.168.0.23#50105: received notify for zone 'pd.fsc'
    ...


查看rndc状态：

    rndc status

可以看到如下类似内容：


    nini@pd$ rndc status
    number of zones: 5
    debug level: 0
    xfers running: 0
    xfers deferred: 0
    soa queries in progress: 0
    query logging is OFF
    recursive clients: 0/1000
    tcp clients: 0/100
    server is up and running


示例文件:

- [named.conf](http://jqian.googlecode.com/svn/trunk/freebsd/bind9/named.conf)
- [rev/192.168.0.rev](http://jqian.googlecode.com/svn/trunk/freebsd/bind9/192.168.0.rev)
- [hosts/appl.fsc.hosts](http://jqian.googlecode.com/svn/trunk/freebsd/bind9/appl.fsc.hosts)
- [hosts/pd.fsc.hosts](http://jqian.googlecode.com/svn/trunk/freebsd/bind9/pd.fsc.hosts)

最后十分推荐一本书《Pro DNS and Bind》，已经在附录列出。

## 编译内核
机器声卡不能出声，寻思着重新编译一下内核了。

首先安装内核源码，一是利用sysinstall从CDROM安装，而是利用CVSup安装。

进入/usr/src/sys/i386/conf目录，5BSD之后已经取消了LINT文件，改用NOTES来说明conf文件的详细内容。


    cd /sys/i386/conf
    cp GENERIC mykernel
    #修改内核配置文件，使得option适合自己的机器，并取消不必要的device，但是要注意其中的关联性，比如require scbus, da这样的提示。
    vim mykernel
    #修改完之后，利用config进行配置
    /usr/sbin/config mykernel
    #然后进入../compile/mykernel，检查关联性
    cd ../compile/mykernel
    make depend
    make
    #make可能会发生逻辑错误，这样还需要重新修改配置，重复如上步骤，直到编译成功
    make install
    #旧的kernel自动备份为/boot/kernel.old/
    reboot


贴上我最后的[mykernel](http://jqian.googlecode.com/svn/trunk/freebsd/mykernel)文件。原来内核是5.8M，新内核为2.7M。若是新内核无法加载成功，进入Boot Loader交互界面，然后unload kernel，载入旧内核load kernel.old。

## 安装声卡
首先确定声卡的类型，要是不知道声卡类型，也懒得开机箱盖子的话。可以先载入一个通用的声卡。

    kldload snd_driver

没有看到出错信息，则查看声卡类型

    cat /dev/sndstat

然后i386机器可以在<a href="http://www.freebsd.org/releases/5.4R/hardware-i386.html#AUDIO">FreeBSD Hardware Notes#i386-Audio</a>里边查看，有没有合适你的声卡驱动。找到了之后有两种方式载入，一是在/boot/loader.conf里边动态载入，比如我的机器声卡是Intel ICH2(82801BA)，则在loader.conf中写入

    snd_ich_load="YES"

二是重新编译内核，在内核配置文件中写入：


    device sound
    device "snd_ich"


并如上方法重新编译内核。在声卡加载成功后，可以通过

    cat /dev/sndstat

查看到具体信息。参考： <a href="http://www.freebsd.org/doc/handbook/sound-setup.html">Setting Up the Sound Card</a>

## Environment values
示例:

    PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/usr/X11R6/bin:$HOME/bin;
    EDITOR=vim
    LANG=zh_CN.eucCN
    LC_CTYPE=zh_CN.eucCN
    LC_ALL=zh_CN.eucCN


## Configure
### xorg.conf
在第一次启动X环境之前运行xorgcfg或者xorgconfig，根据你的机器，配置正确。然后

    mv ~/xorg.conf.new /etc/X11/xorg.conf

### make.conf
为了快捷的运行`pkg_add -r` 和`make install`，需要配置make.conf。例如：


    ##
    WITH_CJK=yes
    ##
    SUP_UPDATE= yes
    SUP= /usr/local/bin/cvsup
    SUPFLAGS= -g -L 2

    #SUPHOST= ftp.freebsdchina.org
    SUPHOST= cvsup5.cn.FreeBSD.org

    SUPFILE= /usr/share/examples/cvsup/stable-supfile
    PORTSSUPFILE= /usr/share/examples/cvsup/ports-supfile
    DOCSUPFILE= /usr/share/examples/cvsup/doc-supfile

    MASTER_SITE_BACKUP?=\
    ftp://192.168.0.135/pub/FreeBSD/ports/distfiles/${DIST_SUBDIR}/\
    ftp://ftp2.tsinghua.edu.cn/mirror/FreeBSD/ports/distfiles/${DIST_SUBDIR}/\
    ftp://ftp.freebsd.org.cn/pub/FreeBSD/ports/distfiles/${DIST_SUBDIR}/\
    ftp://ftp.freebsdchina.org/pub/FreeBSD/ports/distfiles/${DIST_SUBDIR}/

    MASTER_SITE_OVERRIDE?=${MASTER_SITE_BACKUP}


值得注意的是第一次make install的时候需要更新ports的信息，如此操作：


    cd /usr/ports/
    make update


在这之前你需要已经安装了cvsup，如果没有安装则先进入cvsup目录，make install。

### login.conf
配置中文环境，在default的 `:umask=022:` 之后加入：

    \
    :lang=zh_CN.GBK:\
    :charset=GBK:


### 配置文件说明

- /etc/X11/xorg.conf X环境配置文件
- /etc/make.conf make指令配置文件
- /etc/rc.conf 机器资源信息
- /etc/login.conf 登陆配置
- /etc/inetd.conf 超级服务器配置
- /etc/ssh/sshd_config sshd配置
- ~/.bashrc .cshrc .shrc shell配置
- ~/.profile 因为freebsd默认为csh，设置某个用户使用bash的话，常常login之后不去主动读取.bashrc，这时可以把.bashrc的内容移动到.profile中来。
- /usr/X11R6/lib/X11/fonts/fonts.config 安装fontsconfig之后字体配置


## FAQ
*Q:* 为什么Konqueror显示网页的时候不少汉字显示为方块？

*A:* fontconfig & libXfc patch [[url](http://www.freebsdchina.org/forum/viewtopic.php?t=7426&highlight=Konqueror+AND+%B7%BD%BF%E9)]，另：使用firefox :-)

*Q:* 如何加载cdrom？

*A:* mount /cdrom

*Q:* 如何打开vim语法高亮？

*A:*

syntax on
set cindent
set nocompatible
highlight Comment ctermfg=darkcyan


*Q:* 如何配置CVSup？

*A:* 请参考Handbook[附录A.6](http://cnsnap.cn.freebsd.org/doc/zh_CN.GB2312/books/handbook/cvsup.html)

*Q:* 如何查看一个目录占磁碟空间大小？
*A:* 单位KB：du -ks [directory]

*Q:* 编译内核时候，想去掉一些不需要的device，可是怎么才能知道哪些是该去掉的，哪些是该保留下来的呢？

*A:* 一开始机器使用的GENERIC内核配置，会有很多冗余的驱动。运行`dmesg`命令，然后查看计算机上所存在的device，抓住头几个特征字母。例如，GENERIC配置中有很多网卡可以选择，但是你不知道哪个是该为自己使用的，那么查看本机的`dmesg`输出。于是，可以看到应该使用rl所对应的网卡驱动。这样就可以保留device rl，其他的网卡驱动都可以注释掉了。

    ...
    agp0: mem 0xe0000000-0xe3ffffff at device 0.0 on pci0
    pcib1: at device 1.0 on pci0
    pci1: on pcib1
    pci1: at device 0.0 (no driver attached)
    pcib2: at device 30.0 on pci0
    pci3: on pcib2
    *rl0*: port 0xbc00-0xbcff mem 0xdfefff00-0xdfefffff irq 10 at device 5.0 on pci3
    miibus0: on rl0
    rlphy0: on miibus0
    rlphy0: 10baseT, 10baseT-FDX, 100baseTX, 100baseTX-FDX, auto
    rl0: Ethernet address: 00:e0:4c:f8:37:c9
    isab0: at device 31.0 on pci0
    isa0: on isab0
    ...

*Q:* 如何添加manual？

*A:* 在`/etc/manpath.conf`中加入manual的路径就可以了：

    echo OPTIONAL_MANPATH /path/to/man >> /etc/manpath.conf

*Q:* 如何不reboot使得/etc/rc.conf的修改生效？

*A:* /etc/netstart

## References

- [FreeBSD Handbook](http://www.freebsd.org/doc/handbook/) [[zh_CN](http://www.freebsd.org.cn/snap/doc/zh_CN.GB2312/books/handbook/index.html)]
- [FreeBSD Chinese HowTo](http://netlab.cse.yzu.edu.tw/~statue/freebsd/zh-tut/index.html)
- DNS/BIND9相关

	- [Pro DNS and Bind](http://www.zytrax.com/books/dns/)
	- [RFC 1034](http://www.ietf.org/rfc/rfc1034.txt), [1035](http://www.ietf.org/rfc/rfc1035.txt), [882](http://www.ietf.org/rfc/rfc882.txt)
