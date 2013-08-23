---
title: 《POSIX多线程程序设计》读书笔记
tags: linux Programming
---

Amdahl法则

    speedup = 1/(1 - p + p/n)

并行工作的整个延时时间等于非并行工作（1-p）的延续时间加上每个CPU执行并行工作（p/n）的延续时间。

其中，

- p 代表可执行代码与执行时间的比率
- n 代表可以使用的CPU数目

Amdahl法则显示了串行限制并行的简单关系。需要同步的越多，则并行带来的好处越少。

适合多线程的应用：

- 计算密集型应用，将计算任务分解到多个CPU上执行。
- I/O密集型应用，可以使用多个线程等待不同的I/O操作。

## 线程

### pthread与errno

pthread系列函数出错不会设置errno变量（而大部分其他POSIX函数会这么做）

- pthread函数通过返回值表示错误状态，而不是errno变量；不过错误代码仍然包含在 <errno.h>。
- 可以像errno那样，使用 `strerror` 获得pthread错误代码的具体描述。

pthread也提供了一个线程安全的errno变量，当线程调用使用errno报错时，保证errno值不会被其他线程重写或读取。

### 主线程

主线程（初始线程）的特殊性在于主线程退出不会等待其他线程结束。

`pthread_detach`的唯一作用就是通知系统，当该线程结束的时候，所属资源（包括虚拟内存、堆栈等）可以被回收，否则你需要调用 `pthread_join` 回收资源。

## 同步

### 互斥量

互斥量mutex的初始化

- 静态初始化 `PTHREAD_MUTEX_INITIALIZER`
- 动态初始化 `pthread_init` 对应使用 `pthread_destroy` 来释放

`pthread_mutex_trylock`  加锁已经锁住的互斥量 -> `EBUSY`

### 条件变量

条件变量的作用是发信号/广播，而不是互斥。

- `pthread_signal`： 一个条件变量对应一个谓词
- `pthread_broadcast`:  一个条件变量对应多个谓词

谓词，即判断条件。

### 线程间的内存可视性

pthread内存可视性基本规则

#### 内存一致性和内存屏障

内存一致性问题源于CPU的高速缓存和内存总线。

比如，使用write-back cache策略的话，数据先写到CPU的cache，然后再通过总线写入内存。在不保证顺序读写的体系里，cache的数据会在CPU认为方便的时候再写入内存（类似于写磁盘的时候，也是先写到内核cache，然后内存再在合适的时机自动fsync到磁盘）。这样在多CPU的情况下，如果两个CPU往同一个内存地址写不同的数据，则数据其实是保存在CPU cache里；虽然最终数据会写入内存，但是在随机的时刻写入的，与写入到相应的CPU cache的顺序无关。

即使同一CPU的两个写操作也不需要在内存中表现相同的顺序。内存控制器可能发现以相反的顺序写会更快或更方便。

同样的问题不仅出现在同时写，也会出现在同时读写的时候。线程1往某一地址写入数据，线程2同时读取该地址，在不保证内存一致性（或读写顺序）的体系里，将不一定能够读取线程1写入的数据。例如：

时间 |线程1                |线程2
----|---------------------|---
t   | 向地址1(cache)写入"1" |
t+1 | 向地址2(cache)写入"2" | 从地址1读出"0"
t+2 | cache系统刷新地址2    |
t+3 |                     | 从地址2读出"2"
t+4 | cache系统刷新地址1    |

很多计算机不再保证不同CPU之间内存访问的顺序，除非使用特殊的指令，即“内存屏障”（memory barrier）。

内存屏障确保：所有在设置屏障之前发起的内存访问，必须先于在内存屏障之后发起的内存访问之前完成。

> 内存屏障只是一堵移动的墙，隔开了需要顺序访问内存的指令，它并不是刷cache的命令。

关于内存屏障也可以参考前文[UTLK笔记](http://blog.jqian.net/utlk.html)。

#### 互斥锁与内存屏障

- 互斥锁：锁住一个mutex，发布一个内存屏障。 这样任何互斥锁期间的内存操作，不能早于其他线程看到该互斥量被锁住之前完成。
- 解开互斥锁：发布一个内存屏障，解锁互斥量。这样任何互斥锁期间的内存操作，不能晚于其他线程看到该互斥量被解锁之后完成。

#### 读写内存的原子性

一般来说读写内存不是原子性，这是因为大部分计算机有一个天然的内存粒度，依赖于内存的组织和总线结构。一般是32b或者64b。

即使CPU读写8b内存，内存传输仍然以32b或64b为单位。如果两个线程同时写一段32b内存里不同的8b数据，此时将会出现“内存冲突”。(参考书里图3.8)

读写内存不是原子性的另一个原因是，一个变量可能跨越内存单元的边界（*非对齐内存访问*），此时计算机不得不在两次总线事务中传输数据。

如果两个线程同时写不对齐的一段32b数据，将可能导致“word tearing”。(参考书里图3.9)

对于非原子性的内存访问，同样必须使用互斥量来保证内存的读写同步。

## 线程高级编程

### 一次性初始化

编程时，某些代码应该只被初始化一次（singleton表示心有戚戚），那么多线程编程中可以遵循这样的一次性初始化步骤：

1. 控制变量 `pthread_once_t xxx = PTHREAD_ONCE_INIT` 静态初始化；
2. 调用 `pthread_once` 函数完成初始化任务。

如果一个线程正在调用`pthread_once`进行初始化，那么其他同时调用`pthread_once`的线程将等待，直到第一个`pthread_once`完成并返回。示例：

```c
pthread_once_t once_block  = PTHREAD_ONCE_INIT;

void once_init_routine(..) { .. }

int main() {
   pthread_once(&once_block, once_init_routine);
   ...
}
```

### 线程私有变量 vs TLS

POSIX线程私有变量（Thread-specific data）的类型是 `pthread_key_t`，相关函数是 `pthread_key_create`, `pthread_key_delete`, `pthread_setspecific`, `pthread_getspecific`， 不过由于需要确保 `pthread_key_t` *只被创建一次*，否则第二次创建会覆盖第一次的key，所以一般都会搭配 `pthread_once` 一起使用。

一个线程里最多只能创建128个私有key， why? thread数据结构定长array保存吗？

示例：

```c
typedef struct tsd_tag { .. } tsd_t;

pthread_key_t tsd_key;
pthread_once_t key_once = PTHREAD_ONCE_INIT;

void once_routine() {
    pthread_key_create(&tsd_key, NULL);
    ...
}

void thread_routine(void* arg) {
    pthread_once(&key_once, once_routine);
    val = (tsd_t*)malloc(sizeof(tsd_t));
    pthread_setspecific(tsd_key, value);
    ...
    val = pthread_getspecific(tsd_key);
    ...
}

int main() {
    ...
    pthread_create(&thread1, NULL, thread_routine, "thread 1");
    ...
    pthread_exit(NULL);
}
```

【注】TLS和线程私有变量的作用几乎是完全一样的（TLS是由SUN发明的）。

TLS优点有：

- TLS使用更加简单，不过它并非POSIX标准，实现依赖编译器，在gcc下只需要声明 `__thread` 变量即可。
- TLS在gcc里只能用于POD类型，并且需要使用常量初始化。
- TLS的效率更高，毕竟线程私有变量需要函数调用[^1]。

线程私有变量的优点有：

- Thread-specific data是POSIX标准，可以用于任意类型，而不仅是POD。
- 可以为 `pthread_key_create(key, dtor)` 指定一个dtor，可以在线程退出之前对私有变量做析构操作。

### 线程与核实体

POSIX thread标准特意没有规定实现细节，所以在不同的系统上有不同的pthread实现，这就有了所谓的*用户级线程* 和 *内核级线程* 的区别。

线程数和CPU数：

- many-to-1（用户级）
- 1-to-1（内核级）
- many-to-few（两级）

## POSIX针对线程的调整

### fork

避免在线程中运行`fork`，如果这样做了：

- 只有调用fork的线程在新进程中存在，其他线程全部消失。
- 所有的互斥量、条件变量、私有变量全部被复制到新进程。
- fork不会影响互斥量的状态，被锁住的互斥量依然被锁住。如果该互斥量原来由其他线程加锁，那么该锁将永远无法打开。
- 不会调用私有变量的dtor，所以有可能造成资源泄漏。

如果需要使用fork，可以考虑 `pthread_atfork` 在fork之前做一些额外清理工作。

### 信号 signal

应该使用`pthread_sigmask`而非`sigprocmask`来屏蔽信号。

当一个线程被创建时，它继承创建它的线程的信号掩码，所以如果你想要统一屏蔽某个信号，那应该先在主线程中屏蔽它。

应该使用`pthread_kill`而非`kill`向某个线程发信号。但无法用`pthread_kill`向该进程外的线程发信号。

在pthread里， `raise(SIGABRT)` 等于 `pthread_kill(pthread_self(), SIGABRT)` 。

使用 `sigwait` 同步处理异步信号。

pthread可以允许线程代码同步的处理异步信号，即不允许信号在任意点上打断一个线程，线程能够同步的接受信号。

调用`sigwait`等待的信号必须在调用线程，通常也包括所有线程中屏蔽。

示例：

```c
sigset_t signal_set;

void *signal_waiter( void* arg) {
    ...
    int sig_number;
    while(1) {
        sigwait(&signal_set, &sig_number);
        if(sig_number == SIGINT) { ... }
    }
    return NULL;
}

int main() {
    ...
    sigemptyset(&signal_set);
    sigaddset(&signal_set, SIGINT);
    pthread_sigmask(SIG_BLOCK, &signal_set, NULL);
    pthread_create(&thread_id, NULL, signal_waiter, NULL);
    ...
}
```

### 信号灯 semaphore

信号灯实际维护着一个计数器。

- 如果计数器>0， 则调用`sem_wait`将计数器减一，并立即返回；如果计数器=0，则调用`sem_wait`阻塞。
- 如果有`sem_wait`阻塞，则调用`sem_post`将唤醒其中之一；否则，计数器加一。

信号灯与互斥量和条件变量的区别在于：

- 不同于互斥量，信号灯没有属主的概念。任何线程都可以释放在信号灯上阻塞的线程。
- 不同于条件变量，信号灯独立于任何外部状态。而条件变量依赖于一个共享的谓词和等待互斥量。
`sem_init`, `sem_wait`,  `sem_trywait`, `sem_post`, `sem_destroy`, `sem_getvalue`


## 思考

如何把线程固定在某个或多个CPU上执行？

CPU affinity[^2] + 线程实时调度

----

[^1]: [Linkers](https://www.airs.com/blog/archives/44) part 7
[^2]: [管理处理器的亲和性（affinity）](https://www.ibm.com/developerworks/cn/linux/l-affinity.html)
