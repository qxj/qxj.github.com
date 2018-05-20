---
title: MAC学习笔记
tags: 学习
---

## Setup
Firstly, MAC Framework must be built into the kernel with adding one line into the kernel configuration file:" option MAC".

When MAC Framework is built into the kernel, administrator can choose which security policy modules shoud be loaded. There are such MAC modules: mac_portacl, mac_ifoff, mac_biba, mac_bsdextended, mac_mls, which are loaded for the different demand. Unlike MAC Framework, these modules need not to be built into the kernel, which are able to loaded by updating some boot options into loader.conf.

##  Implementation
### Components of MAC Framework
six logical components
*reference: 7.1*

### Framework startup

### Policy Registration
Modules are distinguished from policies: kernel modules may contain a number of code objects.

### Entry Point Invocation, Composition
Three kind of entry points:

- MAC_PERFORM: no return value, is used to post an event to interested policies.
- MAC_CHECK: used to an access control entry point or an entry point supporting detecting and classification of failure modes. a function named 'error_select' can encode an ordering of various failure classes.
- MAC_BOOLEAN: implements a call-out to decision function, and composes the return values using an arbitrary boolean operator.


### Access Control Entry Point
'error_select' will select one of the errors based on precedence if a check fails.
*reference: 7.5*

### Label Management
A number of access control policies rely on security labels maintained on objects for the purpose of performing access control decisions, and various labels contain the different contents from each other.

There are several kinds of labeled objects ( Figure 4. Labeled objects ), and each such structure holds one or more instances of a policy-agnostic label structre for per-policy data: each policy reserving label state is allocated a slot in the label structure, and each slot holds either a void pointer and an integer.

Labels are initialized, allocated and destroyed along with their objects.
The kernel distinguishes two types of object allocation: permit blocking and not tolerate blocking.

Label association and creation.

### Pre-Object Behavior
Association and creation events depend on the availability of context.

MAC Framework-maintained labels must be protected against unsynchronized parallel access by means of locking primitives and access protocols.

A native locking protection: objects to protect the corrosponding labels.

### Process Credentials
Process credential structures contain identity and authorization information associated with the UNIX security model. The credential label was protected by an 'immutable once shared' policy, which may be changed only while one reference exists, such as immediately after
creation.

### VFS Objects
VFS object, exposed via /dev.

- Single-label: derived from the FS mountpoint by the framework. labels may not be modified.
- Multi-label: responsible for it.

## Summary
有不对的地方请指正～

### 内核框架设计
内核设计的要求是：

- 实现一个模块化的框架，提供通用的策略平台（标签）
- 增加重要安全决策的能力
- 未来的模块可以很容易的兼容

应用程序设计的要求：

- 允许与策略独立的安全应用程序，而不仅仅是策略安全程序，可以应用于系统
- 可以从框架输出相关信息，以便监视策略以及通用管理项。

策略独立（policy-independent）的意思是，这些应用程序不需要理解具体的策略和标签含义，它们使用的时候只是通过一个mac_check函数来使用标签。比如"ls -lZ"，当修改策略或标签的时候对它的返回结果并没有影响。

策略相关（policy-aware）的意思是，这些应用程序并不一定以系统用户的身份执行，或者它们要执行与特定策略相关的应用，比如数据库、邮件服务器之类。该应用程序就是与Biba或者mls挂钩的当修改了策略，该应用程序会受到影响。

### 内核框架实现

MAC框架管理有三种接口：sysctl, loader.conf, system calls .

内核服务结合MAC框架有两种方式：

- 调用API；
- 提供一个与策略无关的（policy-agnostic）的标签结构指针，指向安全相关的对象。这些指针由MAC框架通过标签管理入口点（lable management entry point）维护，并且允许框架对策略模块提供一种标签服务，使得可以对维护这些安全对象的内核子系统作无关入侵（non-invasive）的修改。
——例如，指针可以指向process credentials, sockets, pipes, vnodes, Mbufs, network interfaces等等安全相关的对象。

MAC框架在启动的早期初始化，紧接在内核内存分配、终端启动和锁机制启动之后，但在高层设备检测和其他内核与用户进程启动之前模块载入同时相应的策略就注册了。策略有一个load-time flag，表明是否可以在启动后载入（loader.conf）或载出，策略注册由busy count和lock保持同步和互斥，不允许两个进程同时修改策略列表。

静态入口（static entry）就是在系统启动之前载入，但不能再载出的策略。

策略的同步一般都是使用BSD中已有的互斥机制，同步原语。

*Note* : 当写入策略使用同步原语时，需要小心——需要注意已存在的内核锁顺序——有些入口点是不允许睡眠的。

当策略模块调用其他内核子系统时，需要释放in-policy locks，避免死锁。

模块将维持一个锁的树，以避免死锁。

一共三种策略入口点：

- 无返回值，一般用于传送事件消息到相关策略，事件内容有可能是修改该策略，标签管理之类；
- 有返回值，一般用于访问控制，会返回每个策略结果，或组合结果到变量errno，返回错误值被error_select选择，按优先级选取其中一个，再送给内核服务（kernel services）；
- 返回布尔值，一般用于某些特定情况，策略增加某已存在内核服务决策，而不是要得到访问控制的结果。


用于登记标签存储的策略被分配给一个"slot??"标识，它被用于撤销标签存储。存储方式完全受策略模块控制：模块由一些与内核对象生命周期相关的入口点来提供——包括initialization, association/creation, and destruction。使用这些接口，有可能执行引用计数和其他存储模块。直接存取对象结构的话，一般不需要模块再去取标签（？），而是像MAC框架那样通过一个指向对象的指针和指向标签的指针来获得。一大例外是process credential（？），但这应该会在未来的MAC版本中改正过来。

- Association: 当对象已经存在，它的标签已经初始化时。
- Creation: 当绑定一个内核对象结构到一个全新的对象实例时候。

### 策略设计与实现

FreeBSD 5.0 includes a number of kernel modules that provide a diverse set of kernel access control extension. Extensions are also available from third parties.

FreeBSD 5.0 内置一些策略模块提供各种不同的内核访问控制扩展，它是开放的，允许第三方的策略模块。

- Biba是一个固定标签策略，对主体客体的标签改变都是确定明显的；
- Lomac是一个浮动标签策略，它跟Biba类似，但它允许高级客体（process）任意访问低级对象（files），但是将会降低该客体的完整性级别，从而阻止完整性规则被破坏。


客体标签包括三部分：标签种类，活动标签和可用标签集。集合用两个有序的Biba标签元素表示，设置在进程上，允许进程可以改变自己的活动标签的完整性值到比该范围最低点更高或者无关的完整性值，或者改变自己的活动标签的完整性值到比该范围最高点更低或者无关的完整性值。

## Slides download
[An overview about MAC Framework & Policies](http://sites.google.com/site/junist/MAC_Framwork_design_and_policies.pdf)

## Reference

- Robert Watson, Brian Feldman, Adam Migus, Chris Vance, Design and Implementation of the TrustedBSD MAC Framework.
- FreeBSD Architecture HandBook
