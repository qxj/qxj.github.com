---
title: mysql数据索引文件的修复
tags: mysql 技术
---

一般mysql数据库文件损坏都是因为写数据库文件的时候mysql进程退出，导致索引文件出了问题，也就是MYI文件。可以使用 `myisamchk` 或者 `isamchk` 修复。

不需要登陆到mysql，直接运行：

    myisamchk -r -q /mysql_data_directory/database/error.MYI

要是不奏效的话，会提示使用 `myisamchk -o` 或 `-f`。

参考：

- [mysql中文参考文档](http://doc.99net.net/doc/database/1076488199/index.html)
- [mysql reference manual](http://dev.mysql.com/doc/mysql/en/index.html)
