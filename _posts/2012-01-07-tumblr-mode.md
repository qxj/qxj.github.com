---
title: 在Emacs里使用tumblr
tags: emacs tumblr lisp
---

自从[tumblr.com](http://www.tumblr.com)开始支持[markdown语法](http://daringfireball.net/projects/markdown/syntax) 后，它在我眼里就从一只丑小鸭变成了白天鹅。在tumblr上你可以用markdown语法方便的书写；你无需自己去架设网站，搭个LAMP环境去跑wordpress；tumblr.com绑定域名是免费的，wordpress.com绑定域名价格不菲；tumblr有很多漂亮的模板可以选择；最棒的是，它提供了API，这样怎么玩都可以了。总之对比下来，对于个人blog来说，tumblr真是个不错的选择啊。于是我打算从wordpress转移到tumblr了。

加上前两天在[TL](http://groups.google.com/group/pongba/browse_thread/thread/e259e658d0774b0)上了解到octopress是个很棒的工具，于是我就想如果借助Emacs，把Emacs作为一个前端去管理tumblr的话，似乎也能达到类似的效果。可惜我去[Emacswiki](http://www.emacswiki.org)找了一下，发觉只有一个tumble.el，它仅能发布blog，没有提供管理功能，于是我就利用元旦时间自己写了一个[tumblr-mode.el](https://github.com/qxj/tumblr-mode)。目前有如下的功能：

- `tumblr-list-posts` 根据blog名、tag和状态信息列出已有的blog
- `tumblr-get-post` 打开已有的blog进行编辑
- `tumblr-new-post` 书写一篇新的blog
- `tumblr-save-post` 保存编辑的结果到tumblr.com

使用的时候，只需要下载[tumblr-mode.el](https://raw.github.com/qxj/tumblr-mode/master/tumblr-mode.el)，然后把它放到你的 `load-path` 里，在 `~/.emacs` 里加上这句：

    (require 'tumblr-mode)

当然，也可以做一些额外的设置，比如：

    (setq tumblr-email "xxx@gmail.com"
          tumblr-password "yyy"
          tumblr-hostnames '("zzz.tumblr.com"
                             "zzz.customize-domain.com"))

需要留意的是，无论版本1还是版本2的tumblr API居然不提供HTTPS连接，所以建议不要在不太安全的网络环境里使用tumblr API，另外需要保存好自己的密码。

最后，本篇blog就是用tumblr-mode.el书写的 :)
