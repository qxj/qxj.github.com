---
title: 使用skeleton自动输入
tags: emacs lisp
---

如果编辑器能够帮助我们输入，引导我们输入，这无疑是提高生产力的一个好方法。正基于此，Emacs里的自动输入方法有很多，查看Info的 *Autotype* 一节，可以看到有abbrev、skeleton、tempo、autoinsert等等，此外流行的还有yasnippets、template等。

大家一般认为skeleton比较弱，完全可以被tempo、yasnippet之类的替代了，不过经过使用，发觉skeleton做自动输入还是很强大的，而且可以搭配abbrev、autoinsert完成更多的工作。

## skeleton的定义

skeleton是一个内嵌的模板语言，可以通过 `define-skeleton` 函数来定义，语法非常简陋。这里根据函数的说明简单介绍一下如何定义一个skeleton：

    (define-skeleton COMMAND DOCUMENTATION &rest SKELETON)

参数说明：

- `COMMAND` 定义一个skeleton即定义了一个elisp函数，这就是函数名称。
- `DOCUMENTATION` skeleton说明
- `SKELETON` skeleton的具体定义

其中 `SKELETON` 由这样的列表构成： `(INTERACTOR ELEMENT ...)`

- `INTERACTOR` 可以是如下值：
    - `nil`
    - 字符串，用作输入提示
    - 一段elisp，用于读取信息，比如 `(read-string)`
- `ELEMENT` 可以是如下值：
    - 字符串
    - 一个字符
        - `\n` 回车到下一行，并且根据mode自动缩进
        - `_`  光标停留位置；如果你对一个region执行skeleton，那么该region会被放置到此处
        - `-`  光标停留位置
        - `>`  自动缩进
        - `@`  把当前光标位置保存到 `skeleton-position`，具体作用可参考[Wiki](http://www.emacswiki.org/emacs/SkeletonMode#toc14)
        - `&`  如果之前的 `ELEMENT` 移动了光标，则执行下一个 `ELEMENT`
        - `|`  如果之前的 `ELEMENT` 未移了光标，则执行下一个 `ELEMENT`
        - `-num` 往回删除 `num` 个字符
        - `resume:` 如果在执行skeleton过程中按`C-g`，则跳转到此处
    - 一段elisp，这个就可以让我们自由发挥了
        - elisp 返回字符串，插入到buffer里
        - quoted elisp 只是执行，但不用担心返回值

skeleton有如下一些local变量可供使用：

- `str` 读取 `INTERACTOR` 的返回值
- `help` 在交互时候可以显示帮助的内容
- `input` 当读取 `str` 的输入值，感觉一般没啥用
- `v`,`v2` 可以随意使用的local变量

不过因为你可以在skeleton中使用elisp，所以这些限制都不是必须的，我感觉它们的主要作用就是能帮你简化定义。

还是使用wiki上的一个例子，比如你想定义一个类似这样的注释：

    /* **************************************************************** */
    /* **                        Lirum larum                         ** */
    /* **************************************************************** */

可以使用这样一段skeleton函数：

    (define-skeleton insert-c-comment-header
      "Inserts a c comment in a rectangle into current buffer."
      ""
      '(setq str (read-string "Comment: "))
      '(when (string= str "") (setq str " - "))
      '(setq v1 (make-string (- fill-column 6) ?*))
      '(setq v2 (- fill-column 10 (length str)))
      "/* " v1 " */" \n
      "/* **"
      (make-string (floor v2 2) ?\ )
      str
      (make-string (ceiling v2 2) ?\ )
      "** */" \n
      "/* " v1 " */")

## 搭配abbrev使用

定义了skeleton函数后，如果要把它们都绑定到热键上，有时候感觉还是浪费了，我们可以放到abbrev里：

    (define-abbrev lisp-mode-abbrev-table "comment" "" 'insert-c-comment-header)

## 搭配autoinsert使用

autoinsert可以在你创建文件的时候，自动插入一些共用的信息，比如copyright、文件说明之类的，它也可以使用一个skeleton作为输入：

    (define-auto-insert '(c-mode . "C program") 'insert-c-comment-header)

这样当你创建一个c文件的时候，会自动提示你插入一段注释。

另外再举个我使用[template.el](http://www.emacswiki.org/emacs/TemplatesMode)时，发觉不容易完成的例子：当我们创建一个.h文件的时候，由于它可能是c-mode，也可能是c++-mode，Emacs不知道该使用哪种mode，这需要我们去告诉它，于是我们可以使用下边的一段skeleton：

    (define-skeleton insert-c-header
      "Determine which mode should be chosen (c/c++)."
      (ido-completing-read "C or C++ header? : " '("c" "c++") nil nil nil nil "c")
      "/* -*- mode: " str " -*- */" )

    (define-auto-insert '("\\.h$" . "C/C++ header") [insert-c-header set-auto-mode])
