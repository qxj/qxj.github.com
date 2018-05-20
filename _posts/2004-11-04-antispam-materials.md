---
title: Antispam资料收集
tags: AI 技术
---

## 调研: 基于bayesian的邮件分类

- 中國反垃圾郵件聯盟 [貝業斯算法介紹](http://anti-spam.org.cn/forums/index.php?showtopic=448&amp;st=0)
- Mailsofts論壇 [關于貝業斯的一些討論](http://bbs.mailsofts.com/index.php?showtopic=2331)
- better bayesian filter [【譯文】](http://people.brandeis.edu/~liji/_private/translation/better.htm)
- [A plan for spam](http://www.paulgraham.com/spam.html) [【譯文】](http://people.brandeis.edu/~liji/_private/translation/plan.htm)
- [SpamAssassin](http://spamassassin.apache.org/index.html)
- CMU 的作業題 [URL](http://www.andrew.cmu.edu/user/dvilla/Spam/)

一些例子：

- KillSpam [URL](http://www.bizeasy.cn/)

中文信息處理

- 語言學光標 [中文信息處理基礎...講義](http://icl.pku.edu.cn/doubtfire/Course/Chinese%20Information%20Processing/2002_2003_1.htm)

通用的spam分析素材

- PU系列语料 [URL](http://iit.demokritos.gr/skel/i-config/downloads/) [README](http://iit.demokritos.gr/skel/i-config/downloads/PU123ACorpora_readme.txt)
- Ling-Spam corpus [URL](http://www.aueb.gr/users/ion/publications.html)
- Spam Assassin语料 [URL](http://www.spamassassin.org/)
- Spambase语料 [URL](http://www.ics.uci.edu/~mlearn/MLRepository.html)
- mailsofts上的一些素材，不过含病毒 [URL](http://bbs.mailsofts.com/index.php?showtopic=2808)

## 一些思考

理想的是工作在server端，这样可以减轻网络的负担和减少mailserver的资源浪费。

- sendmail是通过一个filter的机制过滤邮件的，可以考虑自己编写这样的filter，让自己的antispam作为一个filter 工作。不过这样我们需要进一步了解sendmail的工作机制，目前时间有限。

另外一种方法就是工作在client端，在client端的解决方案：

- Outlook/Eudra客户端提供直接的插件API，所以可以直接写插件来Bayes一下。
- Outlook Express由于不直接提供插件的方式，但是也有一些变通的方法来实现。复杂一些而已。Norton/Lockspam等等产品都支持了。
- 还有一种方式就是不区分客户端种类的，可以采用本地代理/侦听等等方式。比如，采用了侦听SMTP协议和在Outlook/Outlook Express上添加插件的方式来实现。这样既可以支持所有POP3客户端，也可以对Outlook/OE这样的客户端进行更好的操作。


## 最终成果

- [12月6日答辩幻灯片](http://junist.googlepages.com/Email_spam_filtering-SLIDES.pdf)
- [论文初稿](http://junist.googlepages.com/Email_spam_filtering_with_Bayes_meth.pdf)
