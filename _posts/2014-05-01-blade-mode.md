---
title: blade语法高亮插件
tags: emacs
---

转到广点通后，开始使用陈老师(@RoachCock)开发的[blade](https://code.google.com/p/typhoon-blade/wiki/Documentation)工具来统一构建程序代码，可惜在Emacs里暂时还没有相关的mode可以使用，所以就临时开发了一个。这里刚好也对如何去开发一个语言的语法高亮插件做个小结。

## 关键词语法高亮

关键词语法高亮使用 `font-lock-defaults` 定义，例如：

    (set (make-local-variable 'font-lock-defaults) '(...))

## 设置语法描述表

这是关键步骤，告知emacs如何理解一些语法词汇，比如

    (defvar blade-mode-syntax-table
      (let ((st (make-syntax-table)))
        (modify-syntax-entry ?_  "w     " st)        ;; 把下划线当作变量名的一部分
        (modify-syntax-entry ?\' "\"    " st)        ;; 用单引号表示字符串
        ;; bash style comment
        (modify-syntax-entry ?#  "<     " st)        ;; 使用井号表示注释开始
        (modify-syntax-entry ?\n ">     " st)        ;; 注释到行末
        st)
      "Syntax table for blade-mode")

可以使用 <kbd>C-h s</kbd> 来查看当前mode的syntax table，只有正确的表达了 `string`, `comment`, `endcomment` 这几个语法描述，才能正确的语法高亮`font-lock-string-face`和`font-lock-comment-face`。

具体的语法描述定义，可以查看 [Syntax Descriptors](http://www.gnu.org/software/emacs/manual/html_node/elisp/Syntax-Descriptors.html)

## 设置注释格式

例如 sh-scripts.el 里定义的bash注释格式：

    (set (make-local-variable 'comment-start) "# ")
    (set (make-local-variable 'comment-end) "")
    (set (make-local-variable 'comment-start-skip) "#+[ \t]*")

## 定义缩进函数

所有的缩进细节都需要自己用一个函数来实现。这里应该是最复杂的一步，需要你去观察语言的语法结构，逐行缩进。

最后，给blade BUILD实现的[blade-mode.el](https://jqian.googlecode.com/svn/branches/emacsconf/site-lisp/progmodes/blade-mode.el)

## 参考

- [An Emacs language mode creation tutorial](http://www.emacswiki.org/emacs/ModeTutorial)
- [font-lock support for OCaml files](http://caml.inria.fr/svn/ocaml/branches/sse2/emacs/caml-font.el)
