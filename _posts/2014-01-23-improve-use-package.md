---
title: 增强use-package包管理工具
tags: emacs lisp Programming
---

对于一个emacs重度用户，可能最频繁的操作就是去添加一些包，或者修改一些包的配置。那么如果可以很好的管理包的配置，或者能够快速的定位到包的配置，无疑可以很大程度的提高生产力。

以前是我自己写了一些包的管理函数，但最近发现了[use-package](https://github.com/jwiegley/use-package)这个非常优秀的包管理工具：

- 可以和package.el整合，自动下载安装需要的包；
- 可以把包相关的配置都定义在一个表达式里，非常整洁；
- 可以方便的定义包或者mode下的快捷键。

这些功能很好的解决了包的管理配置问题，但是还稍有缺憾，就是无法快速定位到某个包。如果你有多个配置文件，那么你想修改某个包的配置时，还需要在多个配置文件里去搜索的话，那效率就很差了。所以我在use-package之外advice了一层函数，用于辅助包的快速跳转，只要你输入想要配置的包的名字，可以自动跳转过去，非常方便快捷。

首先，必须要启用 `package`，如果没有 `use-package`，那么得先安装上：

```lisp
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("gnu"          . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("melpa"        . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
        ("org"          . "https://mirrors.tuna.tsinghua.edu.cn/elpa/org/")))
(package-initialize)

;;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
```

然后，定义`my/save-package-name`这个advice函数，当调用`use-package`的时候，会自动记录下包的名字及其所在文件名；定义`my/locate-package`函数用于在记录里查找相应的包。

```lisp
;;; A wrapper for `use-package'
(defvar my/packages nil)
(defun my/save-package-name (orig-func &rest args)
  (let ((name (symbol-name (car args))))
    (when (and (not (assoc-string name my/packages)) load-file-name)
      (add-to-list 'my/packages (cons name load-file-name))
      (apply orig-func args))))
(advice-add #'use-package :around #'my/save-package-name)

(defun my/locate-package (name)
  "Locate package configuration by NAME."
  (interactive
   (list (completing-read "Locate package: " (mapcar (lambda (s) (car s)) my/packages))))
  (let ((pkg (assoc-string name my/packages)) done)
    (if (and pkg (cdr pkg) (file-exists-p (cdr pkg)))
        (progn
          (find-file (cdr pkg)) (goto-char (point-min)) (setq done t)
          (re-search-forward
           (concat "(\\s-*\\use-package\\s-+" (regexp-quote  (car pkg))))
          (recenter-top-bottom 0)))
    (unless done (message "Failed to locate package %s." name))))
```

有这样一些features：

- 运行 <kbd>M-x</kbd> `my/locate-package`，可以通过包名自动跳转到这个包的配置；
- 使用 `use-package` 定义的同一个包的配置只有第一个生效，便于根据不同机器环境额外定制；
