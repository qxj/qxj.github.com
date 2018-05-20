---
title: 赞一下ubuntu的Windows免CD安装法
---

一直习惯了远程ssh工作, 所以好久没有遭遇到装系统这样的麻烦事了. 不过最近期望在本地部署一个系统, 所以打算安装一个ubuntu试试. 下载完ISO, 才懊恼的发觉手头没有空光盘可以刻录. 我想可能大家都遭遇过这样的事情, 再想起以前的那些硬盘安装方法也很头疼, 比如用vmware之类的. 不过可能我对Linux安装的印象太古老了, 上网查了一下, 才发觉ubuntu已然替用户考虑了这些繁琐的问题, 开发了一个[wubi.exe](http://wubi-installer.org/)的安装程序, 可以让用户异常方便的在Windows下免CD安装上ubuntu. 简单的几个步骤:

-   挂载上ubuntu的安装ISO.

    如果你没有虚拟光驱程序, 直接解压ISO, 把其中的 `.disk`, `casper`, `umenu.exe`和`wubi.exe` 这四个文件和目录复制到某个盘的**根目录**下也行. 如果你想最终安装一个真正的Ubuntu系统到某个盘比如E:盘, 那不要复制到E:\上, 因为待会你会把它格式化掉. 如果只是想装个跑在Windows上的demo版本,那就无所谓.

-   运行 `umenu.exe`
-   在出现的对话框上选择 demo and full installation, 然后选中 help me to boot from CD, 安装并重启即可.

    当然也不要安装到E:\. 这个步骤结束后会在你的系统盘, 比如C盘下生成wubildr和wubildr.mbr这两个引导文件, 同时修改 boot.ini, 加入Ububtu的启动选项.

-   重启后, 选择进入Ubuntu, 将进入一个虚拟的demo版本, 登录后运行桌面的安装程序, 安装真实的ubuntu程系统.

之所以选择先安装Demo, 是为了保险起见, 而在运行umenu.exe的另外一个直接安装的菜单时候, 老是出错. 总之, 这个过程对于Windows用户来说已然变得非常傻瓜方便了. 一直以来我认为Gentoo是最容易装的, 因为只要一张liveCD就能干所有的事情了, 现在看来Ubuntu在安装程序上的确为用户考虑得很细致, 直接把这张LiveCD变成了LiveDisk.

前段时间Linux论坛对Ubuntu掀起一阵口诛笔伐, 因为它擅自变动bash, 更改/etc下的配置文件结构, 也没提交几个内核补丁, 这些的确让资深Linux用户不爽. 不过在对于桌面系统的安装和易用上ubuntu的确做的不错, 比如这次装在thinkpad T400上, 音量和亮度调节键全都配合得不错, 并且待机基本都没问题, 这就节省了用户很多时间, 适合不愿意在系统上多做折腾的人们.
