---
title: 在mac上使用开源软件包
tags: 工具
---

虽然mac os x是基于BSD系统的，但是少了一些常用的开源软件包，比如lftp/wget之类的，用起来还是不那么顺手。这两天尝试了一个mac下的开源软件包管理系统[fink](http://www.finkproject.org/)，感觉还不错，用来安装和维护软件包很方便，就像在用debian或者是gentoo，因为它既支持apt获取二进制包，也能维护源码包。

跟mac下边的其他软件包一样，fink安装十分方便，只是装完后需要

- 运行 `open /sw/bin/pathsetup.sh`，建立PATH环境变量；
- 运行 `fink scanpackages && fink index`，建立软件包索引。

如果想更新软件包索引，运行 `fink selfupdate`；
如果想安装二进制包，直接使用类似debian的apt命令；
如果想使用源码包，使用fink系列命令，类似emerge :)
