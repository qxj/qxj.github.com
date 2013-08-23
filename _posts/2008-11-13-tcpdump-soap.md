---
title: tcpdump分析soap包
tags: Linux 工具
---

[Tcpdump](http://www.tcpdump.org)是个异常强大的网络包抓取和分析工具，最近又把它翻出来了。因为在写一个[Web Service](http://en.wikipedia.org/wiki/Web_service)相关的程序，嫌原来的脚本性能太差，准备用[Web Service][gSoap](http://www.cs.fsu.edu/~engelen/soap.html)重写一遍。这台服务器是需要身份验证的，可是服务器应答我身份验证成功后，RPC调用依然失败，怀疑是否[soap](http://www.w3.org/TR/soap/)包的结构有错误呢。因为不清楚具体原因，所以想抓包看看。

我们知道一般使用tcpdump可以这样，这会打印出你所要抓取的包的详细内容，其中`-X`选项会同时打印出hex和ASCII格式的内容，特别适合分析新协议；`-s0`表示完整抓取所有数据包，如果你想过滤一些包，可以把数字0改成你所关注的数据包的最大字节数：

    # tcpdump -X -s0 host 192.168.0.1 and tcp and port 80

如果你在本机做实验，比如侦听本机apache的数据包，那么可以用参数`-i`指定侦听的设备：

    # tcpdump -i lo port 80

如果要抓取的内容太多，不希望打印到标准输出，那么可以通过`-w`和`-r`选项，写入到文件，然后再从文件中读出分析：

    $ tcpdump -w tcpdump.log host 192.168.0.1

    $ tcpdump -r tcpdump.log

而soap其实是架设在http之上的，tcpdump有专门打印出数据包ASCII形式的参数，所以我们过滤所有包含endpoint的ip地址（如192.168.1.111）的数据包，然后打印出来，我们就能直观的看出soap交互的详细内容。

    $ tcpdump -Ai wlan0 -s0 host 192.168.1.111

比如对这次身份验证调用`Login`打印出了如下内容，相当直观吧，也有助于理解http协议的具体工作流程。

    [lancer@Poseidon ~]$ tcpdump -A -s0 host 192.168.1.111
    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
    13:03:51.220047 IP 192.168.0.21.57595 > 192.168.1.111.8016: S 1229105945:1229105945(0) win 5840 <mss 1460,sackOK,timestamp 2946173663 0,nop,wscale 7>
    E..<..@.@..c.=.........PIB..........h{.........
    ..
    .........
    13:03:51.232748 IP 192.168.1.111.8016 > 192.168.0.21.57595: S 476571269:476571269(0) ack 1229105946 win 16384 <mss 1380,nop,wscale 0,nop,nop,timestamp 0 0,nop,nop,sackOK>
    E..@E...z..'.....=...P...g..IB....@........d.......
    ............
    13:03:51.232764 IP 192.168.0.21.57595 > 192.168.1.111.8016: . ack 1 win 46 <nop,nop,timestamp 2946173676 0>
    E..4..@.@..j.=.........PIB...g.............
    ..
    .....
    13:03:51.232819 IP 192.168.0.21.57595 > 192.168.1.111.8016: P 1:676(675) ack 1 win 46 <nop,nop,timestamp 2946173676 0>
    E.....@.@.|..=.........PIB...g.......\.....
    ..
    .....POST /esms/WebService/EsmsService.asmx HTTP/1.1
    Host: 192.168.1.111:8016
    User-Agent: gSOAP/2.7
    Content-Type: text/xml; charset=utf-8
    Content-Length: 451
    Connection: keep-alive
    SOAPAction: "http://tempuri.org/Login"

    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="http://tempuri.org/"><SOAP-ENV:Body><ns1:Login><ns1:userName>BJYTXY</ns1:userName><ns1:password>123456</ns1:password></ns1:Login></SOAP-ENV:Body></SOAP-ENV:Envelope>
    13:03:51.250921 IP 192.168.1.111.8016 > 192.168.0.21.57595: P 1:627(626) ack 676 win 64860 <nop,nop,timestamp 17343616 2946173663>
    E...F.@.z........=...P...g..IB.....\.......
    ......
    .HTTP/1.1 200 OK
    Date: Wed, 12 Nov 2008 05:06:46 GMT
    Server: Microsoft-IIS/6.0
    X-Powered-By: ASP.NET
    X-AspNet-Version: 1.1.4322
    Set-Cookie: ASP.NET_SessionId=rphtdr550eung2ulhucyydao; path=/
    Cache-Control: private, max-age=0
    Content-Type: text/xml; charset=utf-8
    Content-Length: 333

    <?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><LoginResponse xmlns="http://tempuri.org/"><LoginResult>0</LoginResult></LoginResponse></soap:Body></soap:Envelope>

## 具体分析一下这些数据包

首先，HTTP是可靠的TCP协议，所以开头要三次握手。一般捕获TCP协议的包的输出格式是这样的：

    src > dst: flags data-seqno ack window urgent options

各自的含义如下：

- `src > dst` 表明从源地址到目的地址
- `flags` TCP包中的标志信息：
    - `S` SYN
    - `F` FIN- `P` PUSH
    - `R` RST
    - `.` 没有标记
- `data-seqno` 数据包中的数据的顺序号
- `ack` 下次期望的顺序号
- `window` 接收缓存的窗口大小
- `urgent` 表明数据包中是否有紧急指针
- `options`是选项

具体看一看上边例子的封包头：

    13:03:51.220047 IP 192.168.0.21.57595 > 192.168.1.111.8016: S 1229105945:1229105945(0) win 5840

- `13:03:51.220047` 抓取时间
- `IP` 数据包的类型
- `192.168.0.21.57595` 发送方地址和端口，如`send()` `write()`
- `192.168.1.111.8016` 接收方地址和端口，如`recv()` `read()`
- `S` 发送`SYN`同步信号
- `1229105945:1229105945(0)` 数据量大小为0
- `win 5840` 滑动窗口的大小

不过这些包头内容对分析soap包关系不大，我们只关注数据包的内容，一段Web Service调用只有两部分，一问一答。先请求了一个soap包过去，远端服务器再回应一个soap包过来，这段会话结束。仔细一看HTTP头，发觉远端原来是用的IIS，估计是台Windows 2003 server :)

剩下的内容就很简单了，你可以对照[wsdl](http://en.wikipedia.org/wiki/WSDL)的格式，确认一下你的soap包构造，或者参数请求之类，然后调整你的代码。

## 本文的问题

比如本文的问题在于Cookie设置，gSoap默认在client端是不支持Cookie的。可是这台服务器却需要借助客户端的Cookie来完成身份验证，所以就出错了。首先服务器会给你一个Session ID要求客户端放到Cookie里，例如最后一段：

    Set-Cookie: ASP.NET_SessionId=rphtdr550eung2ulhucyydao; path=/

可是由于客户端程序不支持Cookie，在接下来被我省略掉的封包里，其实就和第一个客户端请求的封包内容一样，请求的soap包头里没有包含这个Session ID，所以即使你上一次`Login`请求成功了，服务器依然不认识你，认为你是个陌生人。于是发现问题了，代码写的并没错，只需要把gSoap重新编译一把就OK了。

查询[gSoap的文档](http://www.cs.fsu.edu/~engelen/soapdoc2.html#tth_sEc18.26)，发觉如果要客户端支持Cookies，只需要修改头文件 `stdsoap2.h`，在开头加一个定义 `#define WITH_COOKIES`，重新编译，生成链接库文件。再使用`-DWITH_COOKIES`重新链接自己写的程序就可以了。再使用tcpdump抓包，发觉已经成功验证身份了，在`Login`后续请求的调用里都能正确提供Session ID了，服务器也就认为你是个熟客了，因为在后续请求soap包头里多了一项：

    Cookie: ASP.NET_SessionId=r2hwo055nsupd54514l3bvbp;$Domain="192.168.1.111"

## 结语

如果你要分析的请求流程过长，你也可以用`-w`把数据包写入文件再慢慢分析。tcpdump是个异常强大的网络分析工具，有很多细致的规则可以定义，抓包对它来说只是小菜一碟了。比如你还可以方便的用它嗅探局域网中的FTP、MSN消息之类的，因为它们都是明文传输的 :P 或者如果发现网络延迟，用来分析一下数据包流量，看看是否有蠕虫或者木马在活动，都很好玩。
