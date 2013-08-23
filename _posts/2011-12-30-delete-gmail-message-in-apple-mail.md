---
title: 在Apple Mail里删除Gmail邮件
tags: mac gmail
---

Apple Mail和Gmail一直没有很好的搭配工作过。尤其Apple Mail里删除一封邮件的时候，其实在Gmail里只是Archive了这封邮件。这就很烦人，因为有时候你的确是想删除这封邮件，让它从你的视野里消失，而不是在将来搜索的时候，它又蹦到你眼睛里来了。

如果按照Gmail的[help文档](http://support.google.com/mail/bin/answer.py?hl=en&answer=78892)里设置，那是无法避免这个问题的。但是Apple Mail 5.0里的确可以通过设置实现上边的功能，需要三个步骤。

首先，在Gmail IMAP Settings里设置当删除一封邮件的时候把它移动到Trash里，而不是Archive。

![](http://lh3.googleusercontent.com/-ffOSVR2b3Ew/Tv3GkEjJ5wI/AAAAAAAAK8k/jb5SLh2NLWk/s800/gmail-apple-mail.jpg)

然后，在Apple Mail里把`[Gmail]/Trash`对应到“废纸篓”，其他的几个邮箱也应该做类似的对应。

![](http://lh5.googleusercontent.com/-TTVNpYatGf8/Tv3IRJbHpZI/AAAAAAAAK9E/FABIsOm6lOY/s800/%2525E5%2525B1%25258F%2525E5%2525B9%252595%2525E5%2525BF%2525AB%2525E7%252585%2525A7%2525202011-12-30%252520%2525E4%2525B8%25258B%2525E5%25258D%25258810.15.29.jpg)

最后，在Apple Mail的Setting里设置“将已删除的邮件移动到废纸篓”。

![](http://lh6.googleusercontent.com/-6C5_qXXFDgY/Tv3Go0ZtH5I/AAAAAAAAK8s/SGMkt0hXMVs/s800/gmail-apple-mail1.jpg)

设置完之后，Apple Mail的删除按钮的功能将和Gmail的删除按钮功能一致了。可能会有几秒到一分钟的延迟。

不过Apple Mail的归档按钮目前还是没法和Gmail的归档按钮一致。因为Apple Mail的归档会默认在Gmail里新建一个`[Gmail]/archive`标签，所有被归档的邮件会被打上这个标签；而Gmail的新邮件默认会有两个标签`[Gmail]/All Mail`和`[Gmail]/inbox`，Gmail的归档操作实际是删除了`[Gmail]/inbox`的标签。如果你想在Apple Mail做类似Gmail的归档操作，可以在邮件上右键，然后选择“移动到`[Gmail]/All Mail`”。
