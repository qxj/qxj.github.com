---
title: 使用wget整站下载
tags: Linux 工具
---

开源软件里有不少很无敌的工具，比如看电影通吃的mplayer，非交互下载的wget，版本控制的GNU Make，现在用的GNU Emacs，VIM，哎哟――打住打住，先今天用到的 wget。

在win下下载整个网站一般用webzip，不过trail版只能用30d，而且会插入晃眼的大广告，而用wget完全可以替代我需要的整站下载功能，而且加入到cron里边还能做一个web或者ftp站的mirror。

比如，今天下载freebsd developer handbook，可以这样：

    wget -q -r -k -Pdevbook -nd -o wget.log http://cnsnap.cn.freebsd.org/doc/zh_CN.GB2312/books/developers-handbook/

其中几个option和argument的含义详细见 man wget，简要记录一下用到的几个：


- `r`    对于链接循环下载
- `k`    修复下载html文档中的内部绝对链接链接为相对链接，便于阅读
- `P`    指定下载目录为当前目录下的devbook目录
- `o`    指定log文件为wget.log

另外还有几个常用的：

- `nc`    当你下载被中断后，可以断点续传  `wget -nc -r http://website`
- `p`    下载一个html页面中显示的所有文件，不单是内部链接
- `l`    跟r一起使用，指定循环的层次
- `i`    从一个文件中读取链接下载，有些类似flashget的下载本页面全部链接的功能，但更强大
- `nd`    很有用的选项，不要下载的当前目录的上层目录，否则就会在本例的 devbook下边建立层次目录 cnsnap.cn.freebsd.org/doc/zh_CN.GB2312/books/developers-handbook
