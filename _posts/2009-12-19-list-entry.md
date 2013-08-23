---
title: 链表宏list_entry
tags: c Programming
---

读[corosync](http://www.corosync.org)代码， 其中有一个list的实现， 用到了`list_entry`这个宏。 了解linux内核的同学估计会眼睛一亮， nod， 就是内核里的那个`list_entry`。 在内核里， 几乎所有的链表实现， 都用到了一个通用的`list_head`结构， 但读它的声明发现， 它与链表里保存的实际数据结构完全无关， 仅包含前后两个指针。 当需要访问实际的数据结构时候， 便使用这个`list_entry`计算出实际数据的地址。

下边是list_entry宏的定义（新版内核移到了[container_of](http://fxr.watson.org/fxr/source/include/linux/list.h?v=linux-2.6#L345)里）：

```c
#define list_entry(ptr, type, member)                            \
    ((type*)((char*)(ptr) - (unsigned long)(&((type*)0)->member)))
```

具体使用的时候是这样的：

```c
struct list_head {
    struct list_head *next;
    struct list_head *prev;
};

struct test_list {
    int data;                   /* other items */
    struct list_head list;
};

/* travel list with list head ptr. itr & head_ptr are both list_head pointers. */
for (itr = head_ptr->next; itr != head_ptr; itr = itr->next) {
    element = list_entry(itr, struct list_element, list);
    /* deal with element->data */
}
```

我们可以看到， 只需要知道 `list_head` 头指针， 就可以通过 `list_entry` 访问整个 `test_list`， 虽然 `list_head` 和 `test_list` 的具体数据结构没有任何关系。 是不是联想到了C++里的继承？ 所有的 list 都继承自 `list_head` 这个“基类”，可以通过这个基类指针和函数，访问实际的派生类对象。所有的关键就在于 `list_entry` 这个宏，我们来分析一下。这个宏分为两部分：

第一部分很简单， `(char*)(ptr)`， 获取 ptr 的地址。

第二部分是关键， `(&((type*)0)->member)`， 这是一个类型转换， 告诉编译器地址`0`处有一个类型为`type`的对象， 因为编译器知道`type`的类型声明， 所以它能够取得其对象成员`member`的地址， 又因为这个地址是从地址`0`开始的， 这样实际就获得了member成员在type结构中的相对偏移。 `unsigned long`类型转换表明这是一个偏移量， 并且保证在32位和64位机器上都正确。

两者相减就获取到了实际数据结构的地址。

这是指针的强大之处， 突然联想起为何C++中会限制指针。 POD类型， 简单， 直接， 而其他C++类型由于要实现OO、多态， 编译器会自动插入代码， 这导致指针的使用容易触碰到很多暗礁。 为了更强大的功能， 引入了更高的复杂度， 而这复杂度同时也限制了一部分功能。
