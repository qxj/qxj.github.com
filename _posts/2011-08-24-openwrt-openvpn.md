---
title: 在openwrt上部署openvpn客户端
tags: gfw Hack
---

<em>一般博文，包括openwrt的官方文档上大多在介绍如何部署openvpn的服务器端，对于客户端的部署大多语焉不详，这次经过摸索终于部署成功，且达到了[autoddvpn](http://code.google.com/p/autoddvpn/)的效果，做个小结。</em>

环境：

- 联通ADSL拨号网络
- 已有openvpn服务

软件：

- openwrt 开源的路由器固件
- openvpn VPN客户端
- obfsproxy 流量混淆工具
- pdnsd 域名解析服务

步骤：

## 配置firewall

配置文件 `/etc/firewall.user`，需要[伪装SNAT](http://linux.vbird.org/linux_server/0250simple_firewall.php#nat_what "鳥哥的 Linux 私房菜 - 第九章、防火牆與 NAT 伺服器")的包头：

    iptables -I FORWARD -o br-lan -j ACCEPT
    iptables -I FORWARD -o tun0 -j ACCEPT
    iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE

其中，`192.168.1.0/24` 是openwrt的默认子网。

## 配置openvpn

配置文件 `/etc/config/openvpn`，增加：

    config openvpn yourvpn_cfg
    	option enable 1
    	option config /etc/openvpn/yourvpn.conf

设置 `option enable 1`，表示路由器开机即启动`yourvpn_cfg`这个配置。

设置 `option config /path/to/ovpn.conf`，可以指定具体的openvpn配置文件。

示例：

    client
    dev tun
    proto tcp
    remote 127.0.0.1 12345
    resolv-retry infinite
    nobind
    user nobody
    group nogroup
    persist-key
    persist-tun
    ca /etc/openvpn/ca.crt
    cert /etc/openvpn/client.crt
    key /etc/openvpn/client.key
    ns-cert-type server
    tls-auth /etc/openvpn/ta.key 1
    comp-lzo
    verb 3
    #log /var/log/openvpn.log
    #redirect-gateway def1
    script-security 2
    up /root/gfw_route.sh

## 混淆流量

使用obfsproxy混淆流量很简单，可以在 `/etc/rc.local` 里增加下面的命令：

    /usr/bin/obfsproxy obfs2 --dest=<remote vpn ip>:<remote obfsproxy port> client 127.0.0.1:12345 &

如果使用obfsproxy，需要远端的VPN服务器上也要使用obfsproxy做同样的流量混淆。

## 配置路由

### 配置chnroutes

如果默认VPN作为网关，则可以把国内的流量自定义路由不走VPN，可以使用chnroutes这个项目。

虽然trunk里的openvpn版本大于2.1，但可能由于是嵌入式版本的openvpn，像`net_getway`这些特性支持得不是很好，而且`explicit-exit-notify` 参数也不支持；并且，在openwrt环境里默认没有`bash`和 `ip` 这两个命令，所以直接使用[chnroutes](http://chnroutes.googlecode.com/files/chnroutes.py)上的脚本是不行的，需要hack一下。

[这里](https://gist.github.com/2775611)提供一份可以运行的脚本供大家使用，运行之前确保安装了python2.6。 运行该脚本后，生成 `vpnup` 和 `vpndown` 这两个脚本。

然后，在 `yourvpn.conf` 最后添加如下脚本，表示当tun0设备启动之后，将额外设置自定义的路由规则：

    script-security 2
    up /etc/openvpn/vpnup
    down /etc/openvpn/vpndown

你也可以额外定义一些自己的路由到这两个脚本里去；此外，`up` 和 `down` 最好指定脚本的绝对路径。

### 自定义路由

如果不改变默认网关，那么只需要配置一些被墙的IP走VPN即可，[这里](https://gist.github.com/qxj/546f723138adb4a351c1#file-gfw_subnet-conf)是自己收集的被墙认证的IP。

## 解决dns污染

由于目前dns污染还只限于UDP请求，因此可以在本地搭建一个DNS用于解析被污染的域名。openwrt自带的dnsmasq不支持TCP请求，我们需要额外安装pdnsd，这里有份配置[示例](https://gist.github.com/qxj/546f723138adb4a351c1#file-pdnsd-conf)。

既然安装了pdnsd，由于DNS监听在众所周知的53端口，那就要要禁用掉dnsmasq的DNS功能，否则会端口冲突，导致pdnsd无法启动。不过dnsmasq不能完全停止，还需要它提供DHCP服务。

修改 `/etc/config/dhcp` 文件：

    config dnsmasq
        ....
        option resolvfile '/tmp/resolv.conf.auto'
        option port '0'                    # <--- 设置端口为0可以禁用dnsmasq的DNS功能

    config dhcp 'lan'
        ...
        option dhcp_option ‘6,192.168.1.1’ # <--- 设置dhcp client的dns (6表示dns，3表示gw)

同时建议修改网关路由器的nameserver指向自身。编辑 `/etc/resolv.conf` 或者 `/etc/resolv.conf.head`，后者会覆盖前者：

    search lan
    nameserver 127.0.0.1

配置妥当后，可以随便在局域网内的一台主机上测试：

    $ dig twitter.com

然后， 指定使用TCP方式连接google dns查询：

    $ dig +tcp @8.8.8.8 twitter.com

你应该能够得到一致的IP结果（当然也可能CDN导致返回结果不一致的情况，但确定是正确的即可）。

## 结束

现在你应该可以自由自在的google了，其实也就是为了更好的学习知识，我们容易么 -_-!!

**最最重要的是** 以上所有的一切技术都不可用公开使用，因为目前gfw已经进化到可以使用统计的方法来分析流量，所以只要你翻墙的流量上去，无论你采用哪种VPN或者混淆数据的方式都是没用的。所以，以上方法仅用于个人学习研究，想要推而广之是不可能的。
