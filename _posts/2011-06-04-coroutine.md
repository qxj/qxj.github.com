---
title: 协程的简单理解
tags: coroutine Linux
---

最近看到有人讨论[stackless python](http://www.stackless.com/)，看到有部分讲协程在python中的实现，结合Linux的相关知识我这里小结一下。

从函数的角度看，

- 协程避免了传统的函数调用栈，几乎可以无限递归。

从线程的角度看，

- 协程没有上下文切换，几乎可以无线并发；
- 协程在用户态进行显式的任务调度，可以把异步操作转换成同步操作，也意味着无需额外的加锁。

所谓的“微线程”、纤程、协程，甚至用户态线程，都可以理解为一码事，只是实现和概念的区别。

## 调用栈

我们传统上理解的函数，概念上也叫做[子例程](http://en.wikipedia.org/wiki/Subroutine)，是通过[调用栈](http://en.wikipedia.org/wiki/Call_stack)来传递调用关系的。[协程](http://en.wikipedia.org/wiki/Coroutine)则是比子例程更一般化的概念。子例程的调用是LIFO，它的启动位置是唯一入口，且只能返回一次；而协程允许有多个入口，且可以返回多次(yield)，你可以在特定的地方暂停和重新执行它。

## 上下文切换

上下文切换最早是指进程的上下文切换([context switch](http://en.wikipedia.org/wiki/Context_switch))，它发生在内核态。内核调度器会对每个CPU上执行的进程进行调度([scheduling](http://en.wikipedia.org/wiki/Scheduling_(computing)))，以保证每个进程都能分到CPU时间片。当一个进程的时间片用完，或被中断后，内核将保存该进程的运行状态(即上下文)，将其存入运行队列([run queue](http://en.wikipedia.org/wiki/Run_queue))，同时让新的进程占用CPU。进程的上下文切换包括内存地址空间、内核态堆栈和硬件上下文(CPU寄存器)的切换，所以代价很高(具体参阅UTLK进程一章)。

由于进程切换开销大，所以设计了线程。Linux 2.6内核的`clone()`系统调用已经支持创建内核级线程，且发布了内核线程库[pthread](http://en.wikipedia.org/wiki/Pthread)。在同一进程内的线程可以共享进程的地址空间，线程仅需要维护自己的寄存器、栈和线程相关的变量。不过内核线程的调度仍然需要由内核完成，这需要进行用户态和内核态的模式切换，至少包括堆栈和内存映射的切换。而且，不同进程之间的线程切换，有可能会还会导致进程切换，所以代价还是不小。

而协程始终运行在一个线程之内，完全没有上下文切换，因为它的上下文是维护在用户态开辟的一块内存里，而它的任务调度是在代码里显式处理的。目前Linux上可选用的纤程库是GNU Portable Threads(Pth)。

## 任务调度

进程、线程和协程的设计，都是为了并发任务能够更好的利用CPU资源，他们最大的区别即在于对CPU的使用上(任务调度)：如前文所述，进程和线程的任务调度由内核控制，是抢占式的；而协程的任务调度在用户态完成，需要在代码里显式的把CPU交给其他协程，是协作式的。

由于我们可以在用户态调度协程任务，所以，我们可以把一组互相依赖的任务设计成协程。这样，当一个协程任务完成之后，可以手动进行任务调度，把自己挂起(yield)，切换到另外一个协程执行。这样，由于我们可以控制程序主动让出资源，很多情况下将不需要对资源加锁。

## 示例

最后，引用一个stackless里的例子，文中给了个[python的写法](http://www.grant-olson.net/files/why_stackless.html#pingpong-stackless-py-stackless-ping-pong-example)，我照猫画虎写了个c风格的：

    #include <stdio.h>

    void ping();
    void pong();

    void ping(){
        printf("ping\n");
        pong();
    }

    void pong(){
        printf("pong\n");
        ping();
    }

    int main(int argc, char *argv[]){
        ping();
        return 0;
    }

很明显，这是一个循环调用，运行后很快就会把调用栈耗尽，抛出Segmental Fault。 但是，我们可以用协程的风格把它修改一下，主要是试一下`ucontext.h`里的这几个函数，据说Pth也是用它们实现的：

    #include <ucontext.h>
    #include <stdio.h>

    #define MAX_COUNT (1<<30)

    static ucontext_t uc[3];
    static int count = 0;

    void ping();
    void pong();

    void ping(){
        while(count < MAX_COUNT){
            printf("ping %d\n", ++count);
            // yield to pong
            swapcontext(&uc[1], &uc[2]);
        }
    }

    void pong(){
        while(count < MAX_COUNT){
            printf("pong %d\n", ++count);
            // yield to ping
            swapcontext(&uc[2], &uc[1]);
        }
    }

    int main(int argc, char *argv[]){
        char st1[8192];
        char st2[8192];

        // initialize context
        getcontext( &uc[1] );
        getcontext( &uc[2] );

        uc[1].uc_link = &uc[0];
        uc[1].uc_stack.ss_sp = st1;
        uc[1].uc_stack.ss_size = sizeof st1;
        makecontext (&uc[1], ping, 0);

        uc[2].uc_link = &uc[0];
        uc[2].uc_stack.ss_sp = st2;
        uc[2].uc_stack.ss_size = sizeof st2;
        makecontext (&uc[2], pong, 0);

        // start ping-pong
        swapcontext(&uc[0], &uc[1]);

        return 0;
    }

这时候，ping pong的循环调用并不依赖于调用栈，所以也就不会有调用栈溢出的风险了。而且手工调度协程，静态变量也可以无锁访问。不过manual上说`getcontext`, `setcontext`, `makecontext`, `swapcontext`这系列函数并没有被posix接受，为了兼容性考虑，推荐使用pthread库……我想大概一般能够用coroutine解决的问题，用pthread也能解决，至多就是多加一些锁呗。而如果要使用coroutine的话，代码编写者必须自己理清所有的调度逻辑，可能容易滋生bug，就跟`setjmp`和`longjump`似的，虽然威力强大，但一般人不推荐 :)

## 参考

- [Implementing a Thread Library on Linux](http://www.evanjones.ca/software/threading.html)
- [libc info: System V contexts](http://www.gnu.org/s/hello/manual/libc/System-V-contexts.html#System-V-contexts)
