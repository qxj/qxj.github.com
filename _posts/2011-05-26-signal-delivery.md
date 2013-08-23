---
title: 信号的投递
tags: Linux signal Programming
---

逛BBS看到[有人](http://www.newsmth.net/bbscon.php?bid=69&id=253512)提到UNP 5.8节关于信号投递已经不与时俱进了，说记得信号是可以嵌套的。

> POSIX guarantees that the signal being caught is always blocked while its handler is executing.

翻阅了APUE2，找到这段话：

> What happens if a blocked signal is generated more than once before the process unblocks the signal? POSIX.1 allows the system to deliver the signal either once or more than once. If the system delivers the signal more than once, we say that the signals are queued. Most UNIX systems, however, do not queue signals unless they support the real-time extensions to POSIX.1. Instead, the UNIX kernel simply delivers the signal once.

我也写了个例子测试了一下：

```c
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

static int count = 0;

void sig_handler(int sig){
    fprintf(stderr, "I got signal %d times", ++count);
    sleep(5);
    fprintf(stderr, " here\n");
}

int main(void){
    struct sigaction act, oldact;
    act.sa_handler = sig_handler;
    sigemptyset(&act.sa_mask);
    /* act.sa_flags = SA_NODEFER; */
    act.sa_flags = 0;

    if(sigaction(SIGINT, &act, &oldact) <0){
        fprintf(stderr, "sigaction error!\n");
    }
    while(1) {
        pause();
    }
    return 0;
}
```

然后，不断给该进程发int信号：

    $ kill -int <pid>

事实证明，如果没有设置 `act.sa_flags = SA_NODEFER`，那么带处理的信号的确是[被阻塞](http://fxr.watson.org/fxr/source/arch/x86/kernel/signal_32.c?v=linux-2.6#L584)的，而且在Linux系统上并不会排队。在信号处理函数 `sig_handler` 执行过程中，无论int中断被触发多少次，就像APUE2说的那样，最终只会简单的投递一次。只有设置了 `SA_NODEFER`，信号处理过程才可以被中断，因为此时待处理的信号不会被默认加入 `act.sa_mask`。

所以，UNP和APUE都还是与时俱进的。

<del>PS：这只是测试代码，真实的信号处理函数应该是可重入的。因为，信号只是一种中断，信号处理函数并不会新开一个进程或者线程来处理异步事件，它只能粗暴的中断当前程序的执行，然后跳转到信号处理函数，执行完毕后，再跳转回被中断的程序，继续执行。所以，如果如果信号处理函数调用了不可重入函数的话——比如引用了共享资源——会导致死锁。理论上，这个例子就可能死锁，在printf处……</del>
