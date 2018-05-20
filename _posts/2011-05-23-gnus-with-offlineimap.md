---
title: 在gnus里阅读Gmail邮件(续)
tags: emacs Linux
---

在[前文](http://blog.jqian.net/gnus-with-gmail.html)里讲了如何用gnus搭配一些工具收发Gmail，不过fetchmail用来收取POP3邮件，的确有很多缺陷，最重要的是它只能抓取Gmail INBOX里的邮件，对label无能为力，这很让人头疼。不过还好有[offlineimap](https://github.com/nicolas33/offlineimap)这个小工具，而且其中有一部分功能就是专门为Gmail定制的。

具体可以参考[Sacha Chua](http://twitter.com/sachac)的这篇文章[Geek: How to use offlineimap and the dovecot mail server to read your Gmail in Emacs efficiently](http://sachachua.com/blog/2008/05/geek-how-to-use-offlineimap-and-the-dovecot-mail-server-to-read-your-gmail-in-emacs-efficiently/)，文中使用[dovecot](http://wiki.dovecot.org/)在本地架设一个imapd，而offlineimap作为一个桥梁，默默地在后台把远端的Gmail邮件同步到本地imapd里去。这样gnus直接连接本地imapd即可。这篇文章的回复里，有人质疑为啥还需要本地imapd呢？让offlineimap直接同步Gmail到一个Maildir，然后gnus访问这个Maildir不也可以么？Sacha Chua没有直接答复，我试了一下的确也可行。

只是使用 *nnmaildir* 直接访问 Maildir 目录有个[缺憾](http://groups.google.com/group/linux.debian.user/msg/7594165a2b6d1c49)，对于已读标记，gnus维护自己的flags，而不是使用标准的Maildir flags，这导致offlineimap没法把已读标记同步回Gmail :-( 不过也有人给出个[workaround](http://nakkaya.com/2010/04/10/using-offlineimap-with-gnus/)，就是利用offlineimap的 `presynchook` 和 `postsynchook` 再额外同步gnus和Maildir的flags……

所以，目前看来比较理想的方式还是使用dovecot在本地架设imapd，然后gnus通过*nnimap* 的方式访问本地imapd，这样就不会有已读标记丢失的问题。gnus 对本地imapd所做的修改再由offlineimap同步到远端的Gmail，所以基本是这个流程：

- 同步邮件到本地： Gmail → offlineimap → dovecot
- gnus管理邮件： gnus ↔ dovecot
- 同步邮件到远端： dovecot → offlineimap → Gmail


## offlineimap

配置offlineimap，让它可以同步你的Gmail账户。可以查看offlineimap源码包下的示例配置，其中对每个参数都有详细说明。默认配置文件位于 `~/.offlineimaprc`：

    [general]
    ui = Basic
    accounts = GMail
    maxsyncaccounts = 3
    socktimeout = 30

    [Account GMail]
    localrepository = Local
    remoterepository = Remote
    autorefresh = 5
    quick = 10
    maxage = 7

    [Repository Local]
    type = IMAP
    remotehost = localhost
    port = 143
    remoteuser = jqian
    remotepass = login password

    [Repository Remote]
    type = Gmail
    remoteuser = junist@gmail.com
    remotepass = gmail's password
    maxconnections = 2
    readonly = False

    # Setting realdelete = yes will Really Delete email from the server.
    # Otherwise "deleting" a message will just remove any labels and
    # retain the message in the All Mail folder.
    realdelete = no

    idlefolders = ['INBOX']
    folderfilter = lambda folder: folder not in ['[Gmail]/All Mail', '[Gmail]/Trash']

如果你的邮件过多，而且有很多archive过的，那可以通过设置 `maxage` 来避免同步很老的邮件。设置 `autorefresh` 可以让offlineimap定期同步。设置 `idlefolders` 使用 `IDLE` 指令将保持长连接，可以有push mail的效果。运行offlineimap默认是一个ncurse的交互界面，如果你要让offlineimap在后台执行，应该设置 `ui = Basic`。

此外，在 `[Repository Remote]` 这个section里，如果设置 `type = Gmail`，那么当删除邮件时，实际邮件将被移动到 `[Gmail]/Trash`，这是[Gmail的特性](http://mail.google.com/support/bin/answer.py?answer=77657&topic=12815)。

offlineimap是用python的[ConfigParser](http://docs.python.org/library/configparser.html)来解析 `~/.offlineimaprc`，所有的注释符 `#` 需顶格，注意。

最后，可以让offlineimap登录后即在后台运行，它就会默默的帮你去同步Gmail邮件了。

## dovecot imapd

dovecot基本无需额外配置，默认使用系统的用户名密码就能登录。不过你可以指定离线邮件的保存位置，ubuntu下编辑 `/etc/dovecot/conf.d/10-mail.conf`：

    mail_location = maildir:%h/Maildir

其中，Sacha文章提及的 `default_mail_env` 已经过时了，使用 `mail_location` 替代。

## gnus

在本地架设imapd的话，给gnus指定 *nnimap* 类型的访问方式即可：

    (setq gnus-select-method
          '(nnimap ""
                   (nnimap-address "localhost")
                   (nnimap-authenticator login)
                   (nnimap-authinfo-file "~/.authinfo")))

其中，你可以把登录本地imapd的用户名密码保存到 `~/.authinfo`，这样就不需要每次打开gnus还需要手工录入密码了。如果使用 `~/.authinfo.gpg` 则可以通过 gpg 加密。

然后，运行gnus，怎么样？所有的Gmail标签都能看到了吧？

## 一些补充

Gmail的label尽量不要用中文，offlineimap处理中文标签似乎有bug，遇到过同步失败的情况。

这里有一份[我的配置](http://jqian.googlecode.com/svn/trunk/emacsconf/config/70-gnus.el)，其中详细介绍了使用gnus收取Gmail的多种办法。
