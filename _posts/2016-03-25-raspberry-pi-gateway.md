---
title: 配置树莓派作为家庭网关
tags: Hack
---

硬件：[树莓派3-B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)

系统：ubuntu-mate

作用：

- 网关
- Airplay
- GFW
- 破解iptv


## 网关

### 配置网络

编辑 `/etc/network/interfaces` 来配置eth和wlan设备：

```
# The loopback network interface
auto lo
iface lo inet loopback


### eth
auto enxb827eb9e24e2
iface enxb827eb9e24e2 inet static
  address 192.168.1.2
  gateway 192.168.1.1
  netmask 255.255.255.0
  network 192.168.1.0
  broadcast 192.168.1.255


### wlan
auto wlan0
iface wlan0 inet dhcp
  wpa-conf /etc/wpa_supplicant/wpa.conf
```

对wifi网络，需要额外借助wpa工具来产生网络配置：

```
wpa_passphrase "YOUR_ESSID" | sudo tee /etc/wpa_supplicant/wpa.conf #and type your password
sudo wpa_supplicant -B -s -c /etc/wpa_supplicant/wpa.conf -i wlan0
sudo dhclient wlan0
```

此外，wlan0除了使用 `wpa-conf` 指定配置文件，也可以直接用 `wpa-ssid` 和 `wpa-psk` 在interfaces文件里直接配置SSID和密码。
https://wiki.debian.org/WiFi/HowToUse#WPA-PSK_and_WPA2-PSK

### 网关转发


打开IP转发功能：

```
echo 1 > /proc/sys/net/ipv4/ip_forward
```

或者，编辑 `/etc/sysctl.conf` 设置 `net.ipv4.ip_forward = 1`

```
sysctl -p
```

### 测速

树莓派3是[百兆网口](http://askubuntu.com/questions/7976/how-do-you-test-the-network-speed-betwen-two-boxes)，性能有限。测速可以利用iperf工具：

- 服务端 `iperf -s`
- 客户端 `iperf -c <server-ip>`

## Airplay

Linux上可以使用 `shairport-sync` 这个软件来作为airplay服务器。

1）自带声卡：It is not HiFi – it is quite noisy and can't play anything above about 15kHz.

不出声
https://github.com/mikebrady/shairport-sync/issues/279

```
general {
    // drift = 1100;
    resync_threshold = 0;
}
alsa {
    audio_backend_buffer_desired_length = 22050;
    //disable_synchronization = "yes";
}
```

声音小

```
general {
    volume_range_db = 30;
}
```


2）插入USB声卡：
https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture

硬件驱动 -> ALSA -> PulseAudio

查看目前的声卡模块：
`aplay -l`  或者  `cat /proc/asound/modules`

测试声音：`speaker-test -D hw:Set -c 2`  表示用 `hw:Set` 设备（可以通过 `aplay -L` 列出可用设备），双声道。

配置：

```
alsa {
    output_device  = "hw:1";
}
```

## GFW

思路：

1. 代理: ss
2. 域名污染：使用dnsmasq搭建本地dns，然后被墙域名([gfwlist](https://github.com/gfwlist/gfwlist))通过ss代理发到[opendns](https://www.wikiwand.com/en/OpenDNS)解析
3. IPSET：dnsmasq同时把被污染域名解析到的IP写入ipset，iptables读取ipset建立转发规则。

相关文件：https://gist.github.com/qxj/4f0a8852980485a36f92b00501b8346d


### ipset

ipset需要kernel支持
https://wiki.gentoo.org/wiki/IPSet

```
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_IPPORT=y
CONFIG_IP_SET_HASH_IPPORTIP=y
CONFIG_IP_SET_HASH_IPPORTNET=y
CONFIG_IP_SET_HASH_NET=y
CONFIG_IP_SET_HASH_NETPORT=y
CONFIG_IP_SET_HASH_NETIFACE=y
CONFIG_IP_SET_LIST_SET=y
CONFIG_NETFILTER_XT_SET=y
CONFIG_NET_EMATCH_IPSET=y
```

建立ipset：

```
ipset create ss hash:ip
```

### dnsmasq

只用dnsmasq的DNS功能，一些不在gfwlist里的域名可以手动配置：

```
strict-order
no-resolv
no-poll
cache-size=10000

port=53
listen-address=127.0.0.1,192.168.1.2

server=114.114.114.114

## server=/<domain>/<opendns>#<port>
server=/.amazonaws.com/208.67.222.222#443
ipset=/.amazonaws.com/ss
server=/.ipython.org/208.67.222.222#443
ipset=/.ipython.org/ss
server=/.jupyter.org/208.67.222.222#443
ipset=/.jupyter.org/ss
server=/.google.com.sg/208.67.222.222#443
ipset=/.google.com.sg/ss
server=/.google.co.jp/208.67.222.222#443
ipset=/.google.co.jp/ss
server=/.bintray.com/208.67.222.222#443
ipset=/.bintray.com/ss
server=/.slideshare.net/208.67.222.222#443
ipset=/.slideshare.net/ss
```

验证一下：

```
dig +tcp @127.0.0.1 twitter.com
```

### iptables

假设ss侦听在1080端口

```
## clean iptables
iptables -F
iptables -F -t nat
iptables -X
iptables -X -t nat

## maquerade packages as gw, DONOT specify "-o wlan0"
iptables -t nat -A POSTROUTING -j MASQUERADE

## create a custom chain
iptables -t nat -N XGFW

## ignore VPS address (optional)
iptables -t nat -A XGFW -d ${VPS_IP} -j RETURN

## ignore LAN address (optional)
iptables -t nat -A XGFW -d 0.0.0.0/8 -j RETURN
iptables -t nat -A XGFW -d 10.0.0.0/8 -j RETURN
iptables -t nat -A XGFW -d 127.0.0.0/8 -j RETURN
iptables -t nat -A XGFW -d 169.254.0.0/16 -j RETURN
iptables -t nat -A XGFW -d 172.16.0.0/12 -j RETURN
iptables -t nat -A XGFW -d 192.168.0.0/16 -j RETURN
iptables -t nat -A XGFW -d 224.0.0.0/4 -j RETURN
iptables -t nat -A XGFW -d 240.0.0.0/4 -j RETURN

# ignore address not in ss ipset
iptables -t nat -A XGFW -m set ! --match-set ss dst -j RETURN

## redirect others to ss-redir port
iptables -t nat -A XGFW -p tcp -j REDIRECT --to-port 1080

## append XGFW chain after PREROUTING to apply it
iptables -t nat -A PREROUTING -p tcp -j XGFW
```

## 破解iptv Q1

联通iptv是数码视讯Q1，可以破解完安装沙发管家。

1.  正常启动到IPTV；
2.  打开WIFI或者用网线接入网络；
3.  在局域网内（比如网关 192.168.1.2）部署web服务器；
4.  在网关上运行如下脚本：

    ```
    echo 1> /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A PREROUTING -p tcp -d 210.13.0.184 --dport 80 -j DNAT --to 192.168.1.2:80
    ```

5.  嗅探下载地址，先打开网卡混杂模式：

    ```ifconfig wlan0 promisc```

    然后运行：

    ```tcpdump -s0 -Ann -i wlan0 "dst host 210.13.0.184 and tcp port 80"```

6.  回到IPTV，点击 *视频通话*，可以得到地址，如

    ```GET launcher/data/1464749365/videochat_1.1_signed.apk```

7.  将要安装的APP文件（如沙发管家）改名为 `videochat_1.1_signed.apk`，放入Web服务器的 `launcher/data/1464749365/` 目录下；
8.  回到IPTV，点击 *视频通话*，会自动下载安装该APP，安装完第三方APP，你就可以随便折腾IPTV了；
9.  由于IPTV的DNS被锁定为特定地址，所以无法通过路由器上网，通过下面步骤解决；

    ```
    iptables -t nat -A PREROUTING -p udp -d 210.13.31.253 --dport 53 -j DNAT --to 192.168.1.2:53
    iptables -t nat -A PREROUTING -p udp -d 210.13.31.254 --dport 53 -j DNAT --to 192.168.1.2:53
    ```
