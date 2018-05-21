---
title: Kindle DX的一些增强
tags: kindle Hack
---

## 基本常识
第二代Kindle DX的全称是[Kindle DX Graphite](http://www.amazon.com/Kindle-DX-Wireless-Reader-3G-Global/dp/B002GYWHSQ)，简称Kindle dxg。简述几个值得注意的地方：


- dxg都是黑色的
- dxg不再有美国版和国际版之分，编号都是*B009*打头，都是Free 3G版本，所以你可以全球漫游
- dxg没有wifi，所以你只能使用*@kindle.com*而没法使用*@free.kindle.com*邮箱在instapaper或者kindle.im之类的网站上订阅，这意味着你没法享用[Whispernet](http://www.amazon.com/gp/help/customer/display.html?nodeId=200375890)的免费推送服务，而3G推送费用[$.99/MB](http://www.amazon.com/gp/help/customer/display.html?nodeId=200505520&#fees) T_T
- dxg的内置浏览器NetFront，不是WebKit，速度慢且不稳定，所以即使有Free 3G基本也是残废；不过内置浏览器支持下载mobi文件格式。
- dxg重量535g，个人建议平时使用不要额外配皮套，否则比iPad还要重，拿来读书太累了；当然，鉴于E-ink屏的脆弱性，携带外出的话可以考虑增加一些保护
- 如果你没有读扫描版pdf或者图文混排文献的强烈需求，强烈建议不要购买dxg……


## jailbreak、字体和usbNetwork
[越狱](http://www.mobileread.com/forums/showthread.php?t=88004)、[字体](http://www.conanblog.me/it/kindle-dxg-perfect-font-hack/)这些不用赘述，网上很多相关的资料。MobileRead还有一个[合集](http://www.mobileread.com/forums/showthread.php?t=128704#1)，整理了所有kindle相关的增强。

而如果想对系统做进一步的hack，安装usbNetwork是必不可少的，它给予你访问系统根目录的能力。不过usbNetwork安装包的README关于安装部分我觉得有一点不是很清楚，说明一下：

- `HOST_IP` 是本机的IP，即新增加的那个usb0设备的IP地址
- `KINDLE_IP` 是kindle的IP

所以，实际上配置文件是无需修改的，全部使用默认设置即可（除非你的局域网恰好是192.168.2.0）；通过USB接上kindle后，可能需要手动打开usbnet支持（按回车键调出search栏，输入`;debugOn`回车，然后输入`usbNetwork`回车即可）；等待设备*usb0*就绪，也许在电脑上你唯一需要做的就是给该设备绑定上相应的IP地址：

    $ sudo ifconfig usb0 192.168.2.1

然后，即可以ssh到你的kindle了（没有密码，直接回车）：

    $ ssh root@192.168.2.2

建议连接usbnet之前先关闭kindle的3g网络，等待ssh到kindle上后，再打开3g网络做相关调试工作。

## 山寨一个推送系统

就像我前面说的那样，dxg空有Free 3G，却没法享受便捷的免费推送系统，这简直就是暴殄天物，令人发指，令人如坐针毡；遂研究了一下，发觉可以山寨一个推送系统给自己使用。我没有看到Amazon的用户协议上禁止用户这么做，也许这尚属灰色地带。

### 获取Amazon proxy的web token

下载或者自己编译一个arm版本的[tcpdump](http://www.eecs.umich.edu/~timuralp/tcpdump-arm)，可以很容易的侦听HTTP header，获取`x-fsn`的值：

    # tcpdump-arm -nAi ppp0 -s0

不过有个坑爹的地方，Amazon自己的三个header不是按照[HTTP RFC](http://www.ietf.org/rfc/rfc2616.txt)里规定的用CRLF分隔，而只用一个换行符分隔。

### 模拟浏览器程序

整体思路就是编个程序[kindlepull](https://github.com/qxj/Kindle-Pull)，模拟内置浏览器的请求来通过3G访问互联网资源。本来想借助[libcurl](http://curl.haxx.se/libcurl/c/)来封装HTTP协议，可惜只能通过[CURLOPT_URL](http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTURL)来指定访问的URL；而在这里需要通过Amazon proxy，待访问的url和请求的socket得分离开，所以没法偷懒了，只能去读HTTP协议，然后写socket程序了。

不过HTTP协议当然也不用全部实现，只需根据返回的header处理两种情况：

- 压缩过的消息体 `Content-Encoding: gzip` proxy返回的内容都是压缩过的
- 分隔开的消息体 `Transfer-Encoding: chunked` 通过proxy下载附件都是分块传输的

由于以前没有写过类似arm这样的嵌入式程序，发觉linux下基本的一些库都不知道去哪里找 :( 比如要处理`Content-Encoding: gzip`，一般直接用[zlib](http://en.wikipedia.org/wiki/Zlib)就行了，这里我是找了份gunzip源码处理了 @@

### 交叉编译arm程序

我找了两份arm编译器[Code Sourcery](http://www.codesourcery.com/sgpp/lite/arm)和[ScratchBox](http://scratchbox.org/)，都可以用来编译arm程序。不过为了避免kindle上的libstdc++.so过老，最后链接程序的时候，我还是加了`-static`做静态链接，发觉可以正确运行。

这里有我编译好的[程序](https://github.com/downloads/qxj/Kindle-Pull/kindlepull_0.1.tgz)，建议放到`/mnt/us/kindlepull/`目录，便于维护。

### 运行程序

*kindlepull*有两种运行方式，一是作为一个daemon去定时下载文档，二是使用[launchpad](http://www.mobileread.com/forums/showthread.php?t=97636)调用*kindlepull*下载文档，这样也许会省点电 :D

### 在vps上搭建mobi服务程序

除了dxg上运行的*kindlepull*外，还得一个外部服务[FakeWhisper](https://github.com/qxj/Fake-Whisper)来协助生成mobi文档，这个随便用PHP或者Python编写一个Web服务就行了；而mobi转换程序可以直接调用Amazon提供的[kindlegen](http://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000234621)。

目前我的这个*FakeWhisper*是这样设计的，整个流程超简单：

- 只对外暴露一个接口给*kindlepull*使用，该接口返回所有待下载的mobi链接，用`\n`分隔；
- *kindlepull*获取这些链接后将开始逐个下载，而服务器将标识下载过的mobi资源。

而这些mobi资源的产生也可以模拟现有的几种玩法：

- 发送邮件到某个特定邮箱，然后*FakeWhisper*从这个邮箱抓取文档并转换，
- *FakeWhisper*定时抓取一些rss文档并转换。

## 项目

两个项目在我Github上：

- [KindlePull](https://github.com/qxj/Kindle-Pull)
- [FakeWhisper](https://github.com/qxj/Fake-Whisper)
