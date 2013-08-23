---
title: Emacs笔记
tags: emacs 技术
---

虽然大一时就接触了Emacs，但却一直没有好好的去用过它。在linux下一直习惯用vim，因为它开始入手简单，而且一直觉得够用了——不过现在终于找到一个学习Emacs的动力了——就是发觉EmacsWiki编写Wiki很方便，而且生成的页面很漂亮，这里收集了一些Emacs学习资料。Emacs入门其实也不难，早先因为繁杂的指令望而却步的想法，其实很愚蠢的；Emacs指令上的合理设计会让你感觉非常自然。

## 资料

- O' reilly的《[学习GNU Emacs](http://www.china-pub.com/computers/common/info.asp?id=13395)》
- smth的Emacs精华区
- stid的[Emacs资料](http://learn.tsinghua.edu.cn/homepage/981852/gnu/emacs.html)
- [Emacs User's Guide](http://www.cbi.pku.edu.cn/chinese/documents/csdoc/emacs/)（中文 推荐）
- 这里有[很多manual](http://hepg.sdu.edu.cn/Chinese_2003/service/computer/users_guide/linux/emacs/users_guide.htm)
- 李宇的[EmacsWiki资料](http://liyu2000.nease.net/webpage/EmacsWikiZh.html)（很漂亮）
- 薛瑞尼的[EmacsWiki技巧](http://learn.tsinghua.edu.cn/homepage/2003214890/publish/GNU/emacs.html)
- wangyin老师的[Elisp介绍](http://learn.tsinghua.edu.cn/homepage/2001315450/emacs_elisp.html)，内容很丰富
- [LaTex, Emacs, etc. for your PC](http://www.math.aau.dk/~dethlef/Tips/download.html)


win32下可以用Emacs移植版21.3 [[链接](http://www.math.pku.edu.cn/teachers/lidf/download/emacs/)]

入门的最好学习资料就是Emacs自带的Tutorial，即 <kbd>Ctrl</kbd>+<kbd>h</kbd> <kbd>t</kbd>，学习时间大概2~3小时。

## FAQ
*Q:* 如何使用el文件？
*A:* 首先，确保el文件在load-path中；然后，`(require 'package-name)`或者`(load "/path/to/package.el")`。比如：

    (add-to-list 'load-path "/path/to/site-lisp/auctex/")
    (add-to-list 'Info-default-directory-list "emacs-path/site-lisp/auctex/doc/")
    (load "tex-site")

*Q:* 如何复制/粘贴一片区域？
*A:* 首先，理解point和mark的概念，它们都是表示位置。point是当前所在的编辑位置，mark是point以外的任一个位置；mark可以有很多，保存在`mark-ring`之中。

- <kbd>Ctrl</kbd>+<kbd>@</kbd>  设置mark
- <kbd>Ctrl</kbd>+<kbd>x</kbd> <kbd>Ctrl</kbd>+<kbd>x</kbd>  交换mark和point位置
- <kbd>Ctrl</kbd>+<kbd>w</kbd>  剪切，又称作kill
- <kbd>Meta</kbd>+<kbd>w</kbd>  复制，复制的内容放置到`kill-ring`中
- <kbd>Ctrl</kbd>+<kbd>y</kbd>  粘贴，又称作yank
- <kbd>Meta</kbd>+<kbd>y</kbd>  从`kill-ring`中选择一份内容粘贴


*Q:* 如何显示字的属性？
*A:* 移动到该字符上，然后 <kbd>Ctrl</kbd>+<kbd>u</kbd> <kbd>Ctrl</kbd>+<kbd>x</kbd> <kbd>=</kbd>。

*Q:* 如何改变默认字体大小？
*A:* 确认系统有这样的字体

    (setq default-frame-alist
      '((font . "-*-courier new-normal-r-*-*-22-*-*-*-*-*-*-gb2312-*")))

*Q:* 如何在X下边让backspace发挥作用，而被认为是C-h？
*A:* 这里有完整的关于Emacs keyboard设置[说明文档](http://tiny-tools.sourceforge.net/emacs-keys.html)。

    (global-set-key [backspace] 'delete-backward-char)
    (global-set-key [deletechar] 'delete-char)

*Q:* 如何显示所有字体 [[在X11中使用字体](http://www.freebsd.org.cn/snap/doc/zh_CN.GB2312/books/handbook/x-fonts.html)]？
*A:* 运行命令 `xlsfonts`

## Emacs 常用的线上辅助说明

- <kbd>Ctrl</kbd>+<kbd>h</kbd> <kbd>c</kbd>  查询键位说明
- <kbd>Ctrl</kbd>+<kbd>h</kbd> <kbd>k</kbd>  查询键位的详细说明
- <kbd>Ctrl</kbd>+<kbd>h</kbd> <kbd>w</kbd>  查询指令对应的键位
- <kbd>Ctrl</kbd>+<kbd>h</kbd> <kbd>a</kbd>  根据输入字符串搜索所有对应的指令
- <kbd>Ctrl</kbd>+<kbd>h</kbd> <kbd>v</kbd>  查询变量信息
- <kbd>Ctrl</kbd>+<kbd>h</kbd> <kbd>i</kbd>  列出所有Info档
