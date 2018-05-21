---
title: Emacs使用技巧
tags: emacs
---

## 重置大写锁定键

参考[Emacswiki](http://www.emacswiki.org/emacs/MovingTheCtrlKey)，在X Window下设置 `~/.xmodmap`，把<kbd>Caps Lock</kbd>设置成<kbd>Ctrl</kbd>键；如果需要交换按键，把注释取消：

    remove Lock = Caps_Lock
    ! remove Control = Control_L
    ! keysym Control_L = Caps_Lock
    keysym Caps_Lock = Control_L
    ! add Lock = Caps_Lock
    add Control = Control_L

然后，运行如下命令即可重新定义键位：

    $ xmodmap ~/.xmodmap

也可以把这段命令写入 `~/.xsessionrc` （Ubuntu）或者 `~/.xinitrc` 中，这样用户登录X界面时会自动运行这段命令来设置键位。

在Windows下可以使用 [RemapKey](https://sites.google.com/site/junist/RemapKey.zip) 这个小工具来重置键位。

## 针对不同mode进行设置

一般在emacs中绑定按键都使用 `global-set-key`，但是，很多时候某一个按键只在某种mode中才有意义，这时候我们应该避免污染全局按键设置，使用 `local-set-key`。某些minor-mode，比如auto-fill-mode、outline-minor-mode，我们希望它们只在某种mode中打开，这时候如果鲁莽的全局打开这些minor-mode也不是很合适。所以，应该习惯于使用 mode-hook 来针对不同mode进行个性化的设置。

例如，我只在text-mode和org-mode里打开flyspell的功能，并且绑定了<kbd>Ctrl</kbd>+<kbd>c</kbd> <kbd>Ctrl</kbd>+<kbd>v</kbd>按键，这里用到了 `dolist` 函数来遍历需要设置的mode：

    (dolist (hook '(text-mode-hook org-mode-hook))
      (add-hook hook
                (lambda ()
                  (flyspell-mode 1)
                  (local-set-key (kbd "C-c C-v") flyspell-goto-next-error))))

## 设置文件编码等变量

<em>(Info Node) Emacs  → Customization  → Variables  → File Variables</em>

想要设置local variable，在文末的3000bytes内，起始行包含 `Local Variable`，最后行包含 `End`。要是想设置mode的话，放在第一项。每行的格式为 `Variable: Value`。

    ;;; Local Variables: ***
    ;;; mode:lisp ***
    ;;; comment-column:0 ***
    ;;; comment-start: ";;; "  ***
    ;;; comment-end:"***" ***
    ;;; End: ***

比如指定该文件的mode和编码：

    Local Variables:
    mode: text
    coding: chinese-gbk
    End:

## 批量替换文本
使用命令`find-dired`。

第一个参数指定要批量处理的目录，第二个参数指定find命令的参数，比如 `-name "*.h" -o -name "*.cpp"`，回车，emacs会显示匹配的文件列表。

按<kbd>m</kbd>键选中要替换的文件，或按<kbd>t</kbd>选中全部；然后，按<kbd>Q</kbd>输入要替换的字符串或者正则式，比如匹配整个字符串 `\<DEBUG\>`；回车<kbd>RET</kbd>，逐一替换。

## 删除所有空行

使用命令`flush-lines`。

输入匹配空行的正则式 `^$`，回车<kbd>RET</kbd>。
