---
title: 简单的cvs使用指南
tags: 工具 Linux
---

客户端的cvs使用很简单，一般按照下边的顺序即可

## 设置CVSROOT

首先设置变量 $CVSROOT，可以直接用export或者setenv命令，或者直接写到.bashrc或者.cshrc中

    export CVSROOT=:pserver:username@192.168.0.143:/cvs_appl
    setenv CVSROOT :pserver:username@192.168.0.143:/cvs_appl

CVSROOT的格式是

    :连接类型pserver:登陆用户名@cvs服务器地址:/cvs项目

## 登陆CVS服务器

设置了CVSROOT就可以登陆cvs服务器了，首先在用户目录下创建 .cvspass 文件，保存登陆密码

    touch ~/.cvspass

然后，登陆，输入密码

    cvs login

这样就完成了登陆cvs服务器

## CVS常用命令

CVS的命令大多都需要在相应的项目目录下运行

### cvs checkout

第一次使用cvs需要导出整个项目，也就是checkout命令，简写做co；跑到你想保存cvs项目的目录，然后运行

    cvs co

如果你只是想导出该项目（比如上边的cvs_appl）的一个工程，叫做policy，那么

    cvs co policy

如果你需要导出该工程的某个分支branch,则用-r参数,比如导出policy工程下的一个目录

    cvs co -r branch-name policy/onedir

要是没有在.bashrc或者.cshrc里边设置CVSROOT，第二次想check co项目的时候，也可以运行

    cvs -d :pserver:username@192.168.0.143:/cvs_appl checkout policy

### cvs update

每次工作或提交修改之前，应该运行update命令，防止冲突

    cvs update

### cvs add和import

当想把新的文件加入cvs仓库的时候使用add命令；跑到你想加入文件的目录

    cvs add /path/to/file

要是你想新加入一个工程；跑到该工程所在的目录里

    cvs import &lt;projname&gt; &lt;vendortag&gt; &lt;releasetag&gt;

### cvs commit
当你修改、添加、删除了文件，想提交到cvs仓库，最后都必须运行commit命令，才能使得修改生效

    cvs commit
