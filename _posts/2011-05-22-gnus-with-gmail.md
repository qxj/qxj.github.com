---
title: 在gnus里阅读Gmail邮件
tags: emacs Linux 工具
---

几年前曾经写过 [一篇blog](http://neverbow.blogspot.com/2006/09/gnus-works-with-fetchmail.html) ，讲gnus如何搭配fetchmail收取邮件。但是后来由于Gmail实在太好用了，所以完全投靠了web mail，而不再使用客户端。不过，最近由于gmail被墙得半身不遂，gnus又派上了用场。另外，我看到现在网络上关于gnus这个怪物的中文说明五花八门，而且不少无用的内容，遂把原来的blog再重新整理一下，补充一些内容。

gnus有很多的后端，可以上新闻组，也可以读邮件。由于国内网络阻尼太大，imap的方式经常会hang住emacs，因此，这里只讲述一种最传统的邮件管理风格：

- 收取邮件：fetchmail → procmail → gnus
- 发送邮件：gnus → msmtp

## fetchmail

虽然fetchmail支持imap，但是我认为它只适合做pop3的拍档，因为fetchmail收取imap会把邮箱的未读标记弄乱。这里给出一个适合gmail的 `~/.fetchmailrc`：

    poll pop.gmail.com with proto POP3 uidl no dns
        user 'username@gmail.com'
        password 'password' is jqian here
        options keep ssl
        sslcertck
        sslcertpath /etc/ssl/certs

    mda "/usr/bin/procmail -d %T"

其中， `uidl` 表示只收取新的邮件， `sslcertpath` 指向你系统上的证书位置（上面给出的是ubuntu里openssl证书的位置）。另外，你可以使用如下命令来检查你的设置：

    $ fetchmail --configdump

最后，在crontab里让fetchmail定时抓取邮件。

## procmail

一般这些古老的工具分工明确，fetchmail只管收取邮件，而procmail用来过滤邮件，把邮件保存到你所指定的位置去。而一般邮件有两种保存格式 [mbox](http://en.wikipedia.org/wiki/Mbox) 和 [Maildir](http://en.wikipedia.org/wiki/Maildir) ，前者保存到一个文件，后者为分级目录，这里我选择保存为Maildir：

    PATH     = /bin:/usr/bin:/usr/local/bin
    MAILDIR  = $HOME/Mail
    DEFAULT  = $MAILDIR/inbox
    LOCKFILE = $MAILDIR/.lock
    VERBOSE  = on

    :0:
    ${DEFAULT}

procmail的过滤规则可以非常复杂，这里我只是简单的让它把邮件全部保存到 `~/Mail/inbox` 目录里，到gnus里再按规则分类。

## gnus

由于任务分工了，所以这里gnus只是单纯作为一个邮件管理界面，并不管收发。这时候其实只需要一条elisp就可以让gnus工作起来：

    (setq gnus-select-method '(nnmaildir "" (directory "~/Mail/")))

不过，如果除了让gnus管理邮件，你还想管理新闻组，那最好不要这么霸道，请使用 `gnus-secondary-select-methods`，同样可以工作：

    (setq gnus-secondary-select-methods '((nntp "localhost") ; leafnode
                                          (nnmaildir "" (directory "~/Mail/"))))

然后，<kbd>M-x gnus</kbd>，你会看到类似这样的界面：

    File Options Buffers Tools Gnus Groups Group Agent Help
           0: nndraft:queue
           0: nndraft:drafts




    TU:---  *Group* {nnmaildir:} 2:2L 48(Group Plugged)-----------------------------

不是吧，什么也没有？……因为默认 `gnus-default-subscribed-newsgroups` 是空的，你需要订阅你所关心的group。先按<kbd>^</kbd> (`gnus-enter-server-mode`) 罗列出所有的server，就像下边这样：

    File Options Buffers Tools Connections Server Agent Help
         {nnmaildir:} (opened) (agent)





    TU:---  *Server*     1:1L 34(Server Plugged)------------------------------------

看到nnmaildir了吧，这就对应于邮件Maildir格式，<kbd>RET</kbd> 后进入，在 `inbox` 前按<kbd>u</kbd>订阅即可，回到group界面，你会看到多了一个group，那就是你收下来的邮件。另外，默认<kbd>RET</kbd>进入该group只会显示未读邮件，如果期望显示所有邮件使用<kbd>C-u RET</kbd>进入。

    File Options Buffers Tools Gnus Groups Group Agent Help
           0: nndraft:queue
           0: nndraft:drafts
          10:*inbox



    TU:---  *Group* {nnmaildir:} 2:2L 68(Group Plugged)-----------------------------

不过这还只是初步能用，更多的内容大家可以翻阅Info相关章节，包括 Group Parameters、Posting Styles、Splitting Mail、Article Buffer、Summary Buffer、Group Buffer、Expiring Mail等。

最后讲如何发送邮件，gnus里也只需要一条elisp即可：

    (setq message-send-mail-function 'message-send-mail-with-sendmail
          sendmail-program "msmtp")

把所有发送邮件的任务推给msmtp吧。

## msmtp
[msmtp](http://msmtp.sourceforge.net) 是个短小精悍的smtp客户端，顾名思义，它支持管理多个SMTP账户，这里我只给出Gmail的配置：

    account gmail
    host smtp.gmail.com
    tls on
    tls_certcheck off
    tls_starttls on
    auth on
    user username@gmail.com
    password gmail_password
    port 587

如果你期望在gnus里根据不同的邮件使用不同的smtp账户来发送邮件，通过 [设置](http://www.emacswiki.org/cgi-bin/wiki/GnusMSMTP) `message-sendmail-extra-arguments` 来实现。
