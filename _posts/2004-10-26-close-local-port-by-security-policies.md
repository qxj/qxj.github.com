---
title: 利用安全策略关闭本地端口连接
tags: Windows
---

最近实验室在做 [SELinux](http://en.wikipedia.org/wiki/Security-Enhanced_Linux) 以及安全策略方面的事情，其实Windows下边也是有安全策略的，安全策略用来描述整个系统的安全目标，它是可以做很多事情的。Windows 2003 Server的本地安全策略分为五个部分，分别是：

- 用户策略 Account Policies
- 本地策略 Local Policies
- 公钥策略 Public Key Policies
- 软件限制策略 Software Restriction Policies
- IP安全策略 IP Security Policies on Local Computer

比如我们不需要防火墙，就直接使用“IP安全策略”关闭本地端口连接，下边是步骤。首先在“控制面板”→“管理员工具”里边打开”本地安全配置“，我截了一些图。“IP安全策略”可以认为由三个部分构成：IP过滤条件(IP Filter Lists)、IP过滤动作(IP Filter Actions)以及使用条件和动作组合而成的IP过滤规则(IP Filter Rules)。以关闭139端口为例，我们先建立“IP过滤条件”，如下图：

![step1](http://image.jqian.net/howto-deny-port-1.jpg)

点击下一步后，分别设置网络连接的源地址(Any IP Address)、目的地址(My IP Address)、协议类型(TCP)、IP端口(From any ports, To this port: 139)，然后点击完成，则结束了“IP过滤条件”的设置。

然后切换到“管理 IP 筛选器表和筛选器操作”(Manage Filter Actions)，类似如上的操作，注意动作选择“阻止”(block)：

![step2](http://image.jqian.net/howto-deny-port-action.jpg)

最后，新建IP安全规则，把已经定义好的条件和规则连接起来：

![step3](http://image.jqian.net/howto-deny-port-rule.jpg)

最后，把该规则分配(assign)一下即可生效，此时所有连接到139端口将被禁止。

![step4](http://image.jqian.net/howto-deny-port-14-end.jpg)
