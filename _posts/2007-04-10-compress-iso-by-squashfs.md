---
title: 用squashfs压缩ISO
tags: Linux 工具
---

texlive的ISO总是做得奇大，而且总是需要安装，真是浪费啊。于是就想把它定制一下，看看能不能做成一个免安装的ISO，直接mount就能使用了，那多好啊。在网上google一下，发觉还真有人[已经做出来](http://bbs.ctex.org/viewthread.php?tid=35714)了，但是发觉还是有点大，我想做一个只包含UTF-8字符集的包就够了，于是研究了一下制作办法。

首先需要知道一个目录做ISO可以这样：`mkisofs -U -R -D -o file.iso directory`，但是这样做成的ISO没有经过压缩，传播时未免有些臃肿，就像texlive似的 :P。在Windows下边没有通用的压缩CD格式，但是在Linux下边可以使用[squashfs](http://squashfs.sourceforge.net/)这样高压缩比且快速的压缩CD格式，官方默认采用GZIP算法，也可以使用LZMA算法；具体的使用它提供一份[HOWTO](http://www.artemio.net/projects/linuxdoc/squashfs/SquashFS-HOWTO.html)可以参考。

首先确保内核支持squashfs文件系统，然后利用工具mksquashfs来创建squashfs文件系统；为某个目录创建文件系统，绑定到一个文件（非一个设备），可执行如下命令：

    # mksquashfs /some/dir dir.sqsh
    # mkdir /mnt/dir
    # mount dir.sqsh /mnt/dir -t squashfs -o loop

这样把texlive所在的目录创建为squashfs文件系统，再挂载后mkisofs即可压缩很大的体积。
