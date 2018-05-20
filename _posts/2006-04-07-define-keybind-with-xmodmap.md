---
title: 用xmodmap捕获键定义
tags: Linux
---

要想在fvwm或者icewm中使用某些快捷键，但是不知道键位的定义怎么办？

### 一般的特殊键
可用查看 /usr/X11R6/include/X11/keysymdef.h 中键位的定义

### 多媒体特殊键

使用xmodmap，需要两个程序 xev 和 xmodmap，先在终端中运行 xev 会弹出一个对话框，如果按一个键，会得到该键的 keycode，比如138，在启动脚本 ~/.xsession 或者 /etc/X11/Xsession.d/ 下的某个脚本中加入：

    xmodmap -e 'keycode 138 = Svolumedown'

然后在 /usr/X11R6/lib/X11/XKeysymDB 中让X知道该键的作用：

    Svolumedown :1100000D

最后在 .fvwm2c 中把按键映射到程序动作上：

    Key Svolumedown A A Exec exec amixer set PCM 2%-

现在，大多数的多媒体按键名称都在 `/usr/X11R6/lib/X11/XKeysymDB` 中定义了，所以上边第二个步骤一般也可以省略。
