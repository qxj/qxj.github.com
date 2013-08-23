---
title: C/C++中的UB
tags: C++
---

一般而言的UB即未定义行为(Undefined Behavior)，区别于未指定行为(Unspecified Behavior)。简单来说，前者是对bad-formed的程序而言，该程序的写法违反了C/C++标准；后者对well-formed的程序而言，该程序写法没有违反标准，只是标准提供了多种可选方案，但具体实现看编译器。具体可参见C99标准中关于程序behavior的定义。UB对程序来说可能出现任意行为，轻则出现意料之外的结果，重则程序崩溃，应该极力避免。

C/C++中常见的UB有：

- 整数溢出
- 序列点(Sequence Points)
- 违反了著名的Strict Aliasing规则

## 序列点

所谓序列点，C99定义如下：

> At certain specified points in the execution sequence called sequence points, all side effects of previous evaluations shall be complete and no side effects of subsequent evaluations shall have taken place.

所谓副作用，C99定义如下：

> Accessing a volatile object, modifying an object, modifying a file, or calling a function that does any of those operations are all side effects, which are changes in the state of the execution environment.

序列点就是这样一些点：在该点之前，之前的语句已经执行完毕，之后的语句还完全没有执行。之所以有序列点这个概念，是因为C/C++是极其注重效率的语言，标准规定在两个序列点之间，程序可以任意顺序执行，这就给了编译器优化的空间。如果两个序列点之间的代码依赖执行顺序，也就是在后一个序列点之前，这点代码的的状态不能确定，即会产生不同的副作用，那么标准规定这样的代码Undefined Behavior。

C99和C++2003都详细列出了序列点列表，一般只要我们不有意写很“紧凑”的代码，比如`(a+=b)+=c`或者`a[i++]=i`这种，多用分号标识一个完整表达式，则可以避免序列点问题导致的UB。曾经网易有面试题考过这种问题，个人感觉意义不大。

## strict aliasing

Strict aliasing同样也是为了编译器优化带来的规则，C99标准中规定了type-based aliasing rule（也被称作 ANSI aliasing rule），该规则说明一个指针只能被dereferenced到相同或相兼容类型的对象上，也就是说不同类型的指针不会引用同一块内存区域（即aliasing）。如果禁用了该规则，编译器访问内存需要更加谨慎。

> Strict aliasing is an assumption, made by the C (or C++) compiler, that dereferencing pointers to objects of different types will never refer to the same memory location (i.e. alias eachother.)

从gcc3.x开始实现了strict aliasing，其中对于 `-fstrict-aliasing` 参数的说明如下：

> Allows the compiler to assume the strictest aliasing rules applicable to the language being compiled.  For C (and C++), this activates optimizations based on the type of expressions.  In particular, an object of one type is assumed never to reside at the same address as an object of a different type, unless the types are almost the same.  For example, an "unsigned int" can alias an "int", but not a "void*" or a "double".  A character type may alias any other type.

简而言之， 在该参数激活的情况下（gcc使用`-O2`参数默认激活该参数），编译器希望不同类型的指针不会指向同一个地址（除了`void*`和`char*`）。比如，如下这个函数意图交换一个`uint32_t`中的高低两位，但却导致了UB。

```c
uint32_t swap_words( uint32_t arg )
{
    uint16_t* const sp = (uint16_t*)&arg; /* Error: undefined behavior */
    uint16_t        hi = sp[0];
    uint16_t        lo = sp[1];

    sp[1] = hi;
    sp[0] = lo;

    return (arg);
}
```

当碰到这种不同类型cast的时候，最好的办法是使用`void*`或`char*`指针，并且借助于`memcpy`，比如我们可以这样，稍显麻烦，但是可以避免破坏strict aliasing rule：

```c
uint32_t swap_words( uint32_t arg )
{
    char* const sp = (char*)&arg;
    uint16_t tmp;
    memcpy(&tmp, sp, sizeof(uint16_t));
    memcpy(sp + sizeof(uint16_t), sp, sizeof(uint16_t));
    memcpy(sp, sp + sizeof(uint16_t), sizeof(uint16_t));

    return (arg);
}
```

当然，还有其他一些更高级的办法可以解决这个问题，比如gcc可以利用`union`，具体可参考[这里](http://cellperformance.beyond3d.com/articles/2006/06/understanding-strict-aliasing.html)。如果你希望禁用该优化规则，需要明确指定编译参数`-fno-string-aliasing`。
