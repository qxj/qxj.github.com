---
title: windows server的双网卡问题
tags: Windows
---

## 问题

快疯了，自从服务器配上两张网卡之后，就出现了一堆的问题，一直没消停过。到处咨询，也没得到什么解答。

首先是因为服务器安装的 win2003server这个破系统，买来花了五六千RMB，可是连首选网卡的设置也没有。因为其中一张网卡只是开通了国内端口，可是windows升级或者mcafee病毒库升级，还都从这张网卡上走，结果弄得每次都没法成功。只有把这张网卡先disable掉，才能成功升级，弄得极其郁闷。

另外自从第二张网卡启动之后，原来工作得好好得rmserver总是报这些错误：

    事件类型:    错误
    事件来源:    RmaServer
    事件种类:    (16389)
    事件 ID:    3
    日期:        2005-5-17
    事件:        10:06:35
    用户:        N/A
    计算机:    XXXX
    描述:
    用户:        N/A
    计算机:    XXXX
    描述:
    RMA Error Occured : 3761: Error retrieving URL `broad/200502/2020050513.mp3' (Invalid path); For More Information see: (N/A)

最后最糟糕的问题是，这两张网卡被搞得时断时续。不一会其中一张网卡外部就访问不了了，而点击网卡选项上的“修复”按钮，清空netbt缓存，刷新netbt，清空arp缓存，清除dns缓存，重新注册dns之后——就又恢复正常了。可是不一会就断掉了：真是焦头烂额。

系统是2003server，web服务器使用的iis6，除了iis6之外，就开了一个rmserver，其他没有运行什么服务和额外程序了，防病毒用的mcafee8i，防火墙使用打完sp1自带的? 下边是一个拓扑图：

![Windows双网卡拓扑图](/assets/blog-images/daul_eth_conflict.jpg)

## 解决

首选网卡是打开 “网络连接 → 高级 → 高级设置 → 适配器和绑定”，然后调整两个网卡的优先次序。
rmaserver不知道怎么回事！最后一个问题用了个笨方法，写了个批处理，然后设定它3分钟工作一次：

    arp -d *
    arp -s 10.0.0.1 00-e0-00-37-c4-fa 10.0.0.2
    arp -s 10.0.0.1 00-e0-00-37-c4-fa 10.0.0.3
    nbtstat -R
    ipconfig /flushdns
    ipconfig /registerdns
