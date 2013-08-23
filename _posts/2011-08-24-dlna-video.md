---
title: 通过DLNA播放视频
tags: Hack
---

由于家里有一台XBOX360，期待能够废物利用，让它来播放视频。经过研究，可行的方案是由主机转码（transcoding）通过DLNA输出视频流到游戏机，然后由游戏机通过HDMI输出视频到电视机，主机和游戏机可以分在两处，中间通过以太网或802.11n连接。

对比用HTPC播放视频来说，这样的优点是遥控器方便，不需要累赘的键盘；当然，如果有Apple TV的话，会是个更好的选择。

这个方案的关键在于主机转码，支持DLNA输出的[服务](http://superuser.com/questions/242986/what-is-the-best-dlna-server-for-ubuntu)很多，但支持实时转码的就少一些了。一般的实时转码服务底层都是使用ffmpeg和mencoder这两个工具来做视频转换。区别在于，ffmpeg的转码速度更快，但转码mov和wmv8格式的效果较差，而且rm和rmvb等私有格式的支持据说也有问题，只能使用mencoder来转码。经过研究，只有PS3 media server支持ffmpeg和mencoder两种工具，其他serviio之类仅支持ffmpeg。

在安装ffmpeg时，建议使用 [medibuntu源](http://ubuntuforums.org/showthread.php?t=1117283)，调整了编译参数，支持的格式会更多：

    $ sudo wget http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list --output-document=/etc/apt/sources.list.d/medibuntu.list && sudo apt-get -q update && sudo apt-get --yes -q --allow-unauthenticated install medibuntu-keyring && sudo apt-get -q update
    $ sudo apt-get install ffmpeg libavcodec-extra-52

此外，一般来讲ffmpeg转码的能力跟显卡 [没有关系](http://ffmpeg-users.933282.n4.nabble.com/Minimum-Graphics-Card-required-td3241808.html)，除非你有支持[VDPAU](http://en.wikipedia.org/wiki/VDPAU)的显卡和相应的驱动。目前ffmpeg解码基本是采用CPU的多媒体指令集来运算的，而显卡的硬件加速主要是用来播放的，所以，ffmpeg与显卡的硬件加速是两个层面的事情，ffplay才能与硬件加速有所关联。所以，输出DLNA的主机最好配个比较强劲的CPU。比如，至少Intel core i3。
