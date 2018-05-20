---
title: gnus的烦人提示
tags: emacs
---

最近发觉gnus使用过程中总是有些烦人的提示。

> Gnus auto-save file exists. Do you want to read it?</blockquote>

在 gnus [FAQ](http://www.gnus.org/manual/gnus_396.html#SEC417) 里有提到，具体参见  *(info "(gnus)Auto Save")*。主要是退出 `*Group*` buffer 之前，直接退出emacs导致的，我的解决办法是避免直接 `kill-this-buffer`，另外加入hook：

    (define-key gnus-group-mode-map "\C-x\C-k" 'undefined)          ; avoid kill *Group* manually
    (add-hook 'kill-emacs-hook 'gnus-group-exit)

> Buffer has a running process; kill it?

这是因为如果使用了 `nnimap`，那么进入邮箱的时候，会调用 `gnutls-cli`。而我的机器上没有安装 gnutls 相关的工具，emacs调用一个不存在的程序时进程状态会标志为run，所以出现这样的提示。这个 [bug](http://debbugs.gnu.org/cgi/bugreport.cgi?bug=7021) 提交在emacs24里，所以目前的workaround就是装上gnutls工具，让emacs找到它。
