---
title: 利用ls -Ri查找avc denied文件
tags: Linux
---

sebsd里边的avc报错只会指出inode节点，源类型和目的类型，并不会指示出到底是哪个文件出现acv错误。所以现在有一个方法，可以利用 `ls -Ri` 查询到底哪个inode出错，然后定位到具体的文件。

比如出现一个avc denied信息：

    avc: denied { execute_no_trans } for pid=709 comm=tcsh inode=94653,
    mountpoint=/usr, scontext=user_u:user_r:user_t
    tcontext=system_u:object_r:unlabeled_t tclass=file

发现错误是在 /usr 这个文件系统下，运行命令

    ls -Ri /usr | grep 94653

根据文件系统的大小，漫长等待之后，提示

    94653 cvs
    494653 kon.cfg

于是

    # where cvs
    /usr/bin/cvs

然后

    # ls -i /usr/bin/cvs
    94653 /usr/bin/cvs

则，文件 /usr/bin/cvs 就是我们要找的文件，运气不错。

要是无法用 where 命令找到，

则，到 /usr 目录，然后

    ls -i

会打印出子目录的inode，然后再进一步排查。
