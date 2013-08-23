---
title: 惊心动魄3小时——修复系统
tags: Linux 技术
---

在实验室待到8点多，打算回去了，这时候师兄跑过来告诉我vista的盘刻好了；于是突发奇想，想装起来玩玩，没想到一下子搞到12点。

我笔记本上原来装了三个系统：Gentoo，Win2k3Serv，还有一个Mac OS X 10.4.3，因为Mac OS X for x86版本里边的驱动有些问题，笔记本显卡还是FireGL 9k，支持不是很好，常常Aqua挂掉。于是就想把这部分format掉，转个Vista玩。

不知道是因为Mac分区的问题还是Vista本身磁盘管理工具的问题，格式化再创建新分区之后，当安装到大半的时候，Vista安装程序告诉我，硬盘引导部分出现问题，所有的安装过程就被Cancel掉了（汗，这里不得不说安装程序做的有些傻，一是最后才去尝试引导系统，二是没有恢复性操作，前面又是复制又是解压又是检索硬件的忙活半天了，跑这里断掉了）。虽然有些纳闷，但是心里还是比较坦然，商业系统的安装碟自带的分区和格式化工具都是剧弱无比，没有一次能够在新分区下发挥成功的，当年装Mac的时候也是这样——那次的粗心导致硬盘数据全挂，寒。

重启机器，发觉出现“disk error, please press ctrl+alt+del restart”如此的字样，我心想估计mbr由被抹掉了，还好我的mbr在linux分区有备份，于是用一张livecd启动，挂载上了linux备份分区，发觉我居然备份了两个mbr文件，一个叫mbr.sav，一个叫mbr.win。心里一愣，也没有多想，直接执行 `dd if=mbr.sav of=/dev/hda`，然后重启。没想到噩梦发生了，我是用grub引导多系统的，这时候发现启动后只提示grub1.5...之类的，然后就出现 error。心下一惊，怎么会这样？

再次用livecd启动，`fdisk -l`一看，大汗：extend分区居然丢失了（这事情很灵异，现在我也没搞清楚怎么回事，因为我后来发现mbr.sav是正确的）。我想难道应该是导入 mbr.win？但是我硬盘结构是两个primary分区，分别是Mac和Win系统，一个扩展分区中包括linux和数据。mbr文件保存在备份分区上，现在整个分区表丢失了，我也没法找到正确的mbr备份了。突然想到好多的资料还有没写好的学位论文都在扩展分区上，不由脑袋发麻。经验教训就是：冲动是魔鬼啊，大家进行底层磁盘操作的时候一定要慎重呀，而且一定要在头脑清醒的时候做。

不过万幸的是，我时不时喜欢备份总结。后来查找资料发觉，当年在系统分区完成之后，我写过一片 [wiki](http://junist.googlepages.com/GentooOnT40p.html)做小结，上边居然详细记录了分区表的扇区数值:

    Disk /dev/hda: 80.0 GB, 80026361856 bytes
    255 heads, 63 sectors/track, 9729 cylinders
    Units = cylinders of 16065 * 512 = 8225280 bytes

    Device Boot      Start         End      Blocks   Id  System
    /dev/hda1               1        1460    11727418+  af  Unknown
    Partition 1 does not end on cylinder boundary.
    /dev/hda2   *        1461        1947     3900960    7  HPFS/NTFS
    Partition 2 does not end on cylinder boundary.
    /dev/hda3            1948        9729    62508915    f  W95 Ext'd (LBA)
    Partition 3 does not end on cylinder boundary.
    /dev/hda5            1948        3407    11727418+   7  HPFS/NTFS
    /dev/hda6            3408        6569    25394481    b  W95 FAT32
    /dev/hda7            6569        6575       52416   83  Linux
    /dev/hda8            6576        6710     1084356   83  Linux
    /dev/hda9            6711        7684     7823623+  83  Linux
    /dev/hda10           7685        9729    16426431   83  Linux

心下大喜，终于找到一根救命稻草。于是重新启动livecd，运行 `fdisk /dev/hda`，然后手动添加分区表，把各个分区起始和结束的扇区位置写好。终于每个分区都正确的显示出来了。然后把linux分区逐一的mount上来，然后chroot进去，把grub重新安装一遍。这样终于可以进入Linux了，不过发觉进入Windows的时候还是有disk error错误。估计是Vista太蛮横了，以为整个硬盘上就应该装它一个系统，它的磁盘管理工具把其他分区的部分数据搞坏了（后来用Acronis Disk Suite查看的时候，发觉Vista的分区工具还保留了一个8M大小的未分配空间，相当于把hda1又分解了，可能导致了主从分区混乱）。还好我有 ghost，运行宝盘《深山红叶》，启动norton ghost 2003，恢复分区备份镜像。再重启系统，终于Windows也恢复了原貌。这样下来终于除了本来就打算删除的Mac系统，其他系统和数据没有丝毫损伤。当再次看到系统载入进度条的时候，我从椅子上蹦起来，狂舞一通，哈哈。

还是Linux玩起来比较透明，备份的话，直接tar出一个归档就行了，什么文件在什么地方，哪些是需要的，哪些是多余的，磁盘分区什么的，一清二楚，恢复起来极其方便；Windows2k3好在有一系列方便的工具，要不然只能两眼一抹黑。最可恨这个Vista，老是藏藏掖掖的，分区工具极其不透明，差点害惨了我啊。真是惊心动魄的3个小时啊，明天早上6点半就要去学车，先流水账记这么多了。

-----

Vista现在的crack激活的办法有两种：一种是针对msdn版本，采用stoptimer来中止timeerstop.sys这个驱动的加载，这是推延激活时间的权益之法；看起来似乎完美一些的办法是针对oem版本，利用vista loader在vista系统加载之前伪造BIOS信息，来欺骗oem版本的检查，达到激活的目的。
