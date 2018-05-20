---
title: 程序的内存布局
tags: Linux memory Programming
---

一个32位系统的内存布局一般是这样的：

![内存布局](http://image.jqian.net/memory_layout.png)

由于 .bss 段都被初始化为0，所以对应可执行程序文件里是不存在 .bss 段的，只有数据段和代码段这两部分。可以用 `size` 命令查看文件的内存布局，比如：

    $ size /bin/sh
    __TEXT     __DATA     __OBJC     others     dec     hex
    638976     57344     0     4295004160     4295700480     1000b3000

## 虚拟内存

Linux虚拟内存（Virtual Memory）为2^32=4G Bytes（假设32bit x86 platform），其中分为两部分：

- 高位1GB，0xC0000000 ~ 0xFFFFFFFF，内核空间
- 地位3GB，0x00000000 ~ 0xBFFFFFFF，用户空间

由于每个进程可以通过系统调用进入内核，即高位1GB的内核空间是共享的，所以从用户进程角度来讲，每个进程拥有4GB虚拟内存——其中3GB的私有地址空间，1GB的共享地址空间。

任意时刻，每颗CPU上只有一个进程在运行，所以从CPU的角度来说，任意时刻整个系统只存在一个4GB的虚拟地址空间。当进程发生切换时，虚拟地址空间也发生切换（进程切换的开销）。

【注意】并非所有系统均如此划分用户空间和内核空间，Mac OS X的内核XNU会划分整个4GB地址空间。像Linux仅划分1GB内核地址空间，是一种性能hack，可以避免进程切换的时候内核地址空间的切换（在x86架构下，地址空间的转换会导致相应的TLB失效），而且这样从用户空间到内核空间看起来即是一个完整的线性空间。

## 虚拟地址

虚拟地址（Virtual Address）即程序运行在保护模式下，程序访问内存所使用的逻辑地址。Linux常见的可执行程序格式是ELF格式（Executable and Linkable Format），在ELF格式里，ld总是从0x08000000开始安排程序的代码段（假设32bit x86 platform）。可以直接用 `objdump` 这个命令查看一个可执行程序的虚拟地址，例如：

    $ objdump -d /path/to/exec
    print:     file format elf32-i386

    Disassembly of section .init:

    080482e0 <_init>:
     80482e0:       55                      push   %ebp
     80482e1:       89 e5                   mov    %esp,%ebp
     80482e3:       53                      push   %ebx

这里的 0x080482e0 即该可执行程序的虚拟地址，并且可以看出这和上图的内存布局是一致的。

## 堆栈

从内存布局上可以看出，堆栈完全是两码事：

- stack对应于函数、局部变量；
- heap对应于进程、共享内存（brk、mmap）。

栈有两个重要的寄存器：

- ebp 即帧指针（frame pointer），用于保存栈帧（stack frame）位置，即函数的活动记录。相关的编译选项是 `-fomit-frame-pointer`。
- esp 即栈寄存器，用于保存栈顶位置。

![stack](http://image.jqian.net/memory_stack.png)

其中，ebp是固定的，而esp是始终指向栈顶的，随着函数的执行，会不断移动。由于ebp是固定不变的，所以可以方便的定位栈帧（活动记录）里的各个数据。

基本上一个i386标准函数进入和退出的指令序列是这样的（已经根据calling convention压入了参数和返回值）：

```asm
push ebp           # 保存old ebp
mov ebp, esp       # 让ebp指向当前的栈顶
sub esp, x         # 在栈上为局部变量开辟空间
[push reg1]        # 保存必要的寄存器
...
[push regn]

... 函数主体

[pop regn]         # 恢复寄存器
...
[pop reg1]
mov esp, ebp       # 恢复进入函数之前的esp
pop ebp            # 恢复进入函数之前的ebp
ret                # 函数返回
```

其中，x是该函数在栈上开辟出来的临时空间的字节数，reg1..regn是要保存的寄存器。

## 参考

- 《程序员的自我修养》
