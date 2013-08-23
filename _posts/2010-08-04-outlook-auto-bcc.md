---
title: 让Outlook自动bcc抄送邮件
tags: Windows 工具
---

使用outlook同时又喜欢thread看邮件的同学估计都有个烦恼，就是outlook中已经发送的邮件无法在thread中列出来，这样未免很不方便。而且，outlook中居然也没有这样的设置，所以只有采用一种折衷的办法，就是把这份邮件再Bcc给自己一份，不过outlook中也没有这样的设置可以让每封邮件自动Bcc。

所以，这里借用[一段vbs代码](http://www.outlookcode.com/article.aspx?id=72)来实现自动Bcc。在outlook的菜单栏中打开 Tools → Macro → Visual Basic Editor，打开VB编辑器，在 “ThisOutlookSession" 中输入如下代码后保存，这样就能够每次把发出的邮件再Bcc自己一份了，这段代码适用于outlook2003及以后的版本。其中，需要把 `someone@somewhere.dom` 替换成自己的邮箱地址，如图：

![Outlook AutoBcc Sample](http://lh5.ggpht.com/_AogbBxxzmC0/TFkPG6zQJsI/AAAAAAAAJiE/9kEia6Z8w-o/s800/outlook_autobcc.png)

<script src="https://gist.github.com/1477325.js?file=auto_bcc.vbs"></script>
