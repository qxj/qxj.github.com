---
title: 使用global阅读代码
tags: emacs Linux 工具
---

由于使用了wordpress来架设blog，所以近期在阅读它的代码。先推荐一个免费工具[ZDE](http://www.zend.com/products/zend_studio)（Zend Development Environment），这个工具在windows下用起来还凑合，但是有IDE的通病，就是庞大而臃肿，找了半天没找到代码reference的功能，于是这就引出了今天的主角 [global](http://www.gnu.org/software/global/)。

用global一直只是读c和c++的，今天才留意到global还有分析PHP代码的功能，不过暂时只支持PHP4，但对我来说已经够用了，先说一下它的安装办法。在Windows下边我是结合cygwin和emacs一起使用的，安装很简单，分下边几个步骤：

-   如果使用cygwin，则解压global的zip包到/usr/local下边。如果不用cygwin的话，只要复制global中bin目录的内容到系统路径就可以了，比如c:/windows，不过这样就无法方便的阅读manual了。
-   如果使用emacs，复制gtags.el目录到emacs的load-path，然后在.emacs中设置:

        (autoload 'gtags-mode "gtags" "" t)
        (add-hook 'c-mode-hook ' (lambda () (gtags-mode)))

    这样在emacs中 M-x gtags-mode 就可以取代emacs中默认的etags进行工作了，按键是一致的。如果使用其他编辑器比如vim、nvi可以具体参考INSTALL进行。

在linux下的安装更加简单，我使用gentoo这个发行版，global已经在portage中了，不过最好设置 `USE="~x86"` 来emerge这包 :) 对于debian或者ubuntu的发行版估计也是有这个软件的，因为是gnu的产品嘛。如果自己编译也一样容易，对emacs的支持做类似上边的设置。

使用的时候直接在源码所在的根目录运行gtags生成索引文件GTAGS就可以了，global的配置文件位于 `/etc/gtags.conf` 和 $HOME/.globalrc`，比如你想把.inc的文件也当作php来解析，那么你就需要通过配置文件来解决了，设置common行，在php中添加.inc这个后缀：

    :langmap=c\:.c.h,yacc\:.y,asm\:.s.S,java\:.java,cpp\:.c++.cc.cpp.cxx.hxx.hpp.C.H,php\:.php.php3.phtml.inc:

下边说一点使用技巧，用global来查询code reference和grep，其中参数x可以打印出上下文，参数e可以进行正则匹配，参数i忽略大小写：

- 查询函数func的reference `global -rx func`
- 查询某个函数 `global -o func`
- 查询某个symbol `global -s symbol`
- 使用cscope格式打印 `global --result cscope -o func`

此外global还支持生成web样式的交叉索引，跟lxr差不多，并且你可以自己定制web模板。
