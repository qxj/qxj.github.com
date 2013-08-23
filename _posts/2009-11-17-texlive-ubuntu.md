---
title: 在ubuntu上使用LaTeX
tags: Linux latex ubuntu
---

拜texlive、ubuntu的开发人员和apt所赐，现在在Linux上使用LaTeX已经变得非常方便了。只需要敲击如下命令就可以安装上latex环境和中文支持了：

    $ sudo aptitude install texlive latex-cjk-chinese texlive-latex-extra

默认会安装arphic的几种中文字体。如果觉得不够漂亮，我这里有一些已经生成的 [中文字体包](http://dl.dropbox.com/u/288200/texmf.tgz)（水木TeX版的某大侠制作，适合打印，应该是我06年从他发布的某个包里提取出来的 ~110MB；如果你喜欢自己生成字体，参考附录第二篇文章），可以直接解压到HOME目录使用，包括了7种常用的中文字体：仿宋 `fs`, 黑体 `hei`, 楷体 `kai`, 隶书 `li`, 宋体 `song`, 宋体粗体 `songb`, 幼圆 `you`。使用有问题请更新目录索引信息，运行如下命令：

    $ update-updmap

安装完后，测试是否可以正确输出UTF8中文文档：

    \documentclass{article}
    \usepackage{CJK}
    \begin{document}
    \begin{CJK*}{UTF8}{song}
    您好,texlive中文
    \end{CJK*}
    \end{document}

这里有几篇文章可以参考：

- [Ubuntu+Texlive+CJK](http://hi.baidu.com/tty0/blog/item/f9583603acab3fe408fa93d2.html)
- [TeXLive 2007 CJK Chinese Howto(zz)](http://junist.googlepages.com/wiki%3Atexlive2007cjkchinesehowto%28zz%29)
- [LaTeX字体说明](http://junist.googlepages.com/latex.html)
