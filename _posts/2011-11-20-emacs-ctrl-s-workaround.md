---
title: 给终端下的Emacs找回ctrl-s键
tags: emacs Linux
---

经常在终端下工作的估计都遇到过烦人的<kbd>Ctrl</kbd>+<kbd>s</kbd>键的问题，虽然可能在从前网速很慢的情况下很有用，但是现在看来这类所谓的Flow Control已经没有什么意义了。更何况，它总是跟Emacs的`isearch-forward` 这个常用命令的默认键位冲突，所以如果<kbd>Ctrl</kbd>+<kbd>s</kbd>不好用，那真的太麻烦了。

所幸一般的终端下都能够处理这个问题，最不济的话也可以通过`stty`命令进行设置，比如：

    $ stty -xon
    $ stty stop undef

但是最近公司跳板机上的securecrt居然死活不放弃<kbd>Ctrl</kbd>+<kbd>s</kbd>，怎么设置都会吞掉，真是太恶心人了。于是在它的设置里翻了一下，发觉有个workaround。打开菜单 Session Options → Terminal → Emulation → Mapped Keys，可以利用它内置的键位映射功能，先把<kbd>Ctrl</kbd>+<kbd>s</kbd>绑定到另外一个键位上，可以选择一个Emacs里不常用的键位，比如<kbd>Ctrl</kbd>+<kbd>]</kbd>，发送的字节是 `\035`。如果偶尔要使用<kbd>Ctrl</kbd>+<kbd>]</kbd>，就直接 <kbd>Meta</kbd>+<kbd>x</kbd> `abort-recursive-edit` 吧。

然后，可以在Emacs里打开Flow Control的支持：

    (setq flow-control-c-s-replacement ?\035)
    (enable-flow-control)

这样你在securecrt里按<kbd>Ctrl</kbd>+<kbd>s</kbd>，发送出去的按键序列是<kbd>Ctrl</kbd>+<kbd>]</kbd>，而Emacs会把<kbd>Ctrl</kbd>+<kbd>]</kbd>当作<kbd>Ctrl</kbd>+<kbd>s</kbd>处理。

当然这是无奈之举，最好的办法还是直接放弃securecrt，如果可以的话。
