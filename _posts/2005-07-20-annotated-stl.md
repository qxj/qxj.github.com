---
title: 阅读《STL源码剖析》
tags: c++
---

师兄说使用C++标准库应该了解其数据结构和内存分配方式，所以趁暑假拜读了侯捷老师的《STL源码剖析》。这本书详解了标准库代码实现背后的原理，让人感叹设计者的精妙巧思。

## 迭代器(iterator)

迭代器可谓范型编程的典范，这套方法是说只要对象符合一定的特征(traits)，那么就能用iterator遍历。

默认的`iterator_traits`萃取如下特征：

```c++
template<typename _Iterator>
struct iterator_traits {
    typedef typename _Iterator::iterator_category iterator_category;
    typedef typename _Iterator::value_type value_type;
    typedef typename _Iterator::difference_type difference_type;
    typedef typename _Iterator::pointer pointer;
    typedef typename _Iterator::reference reference;
};
```

### std::copy

`std::copy`是模板特化(template specialization)的代表之作：根据不同的type traits和trivial/non-trivial assign operator，使用`memmove()`来提高效率。

### std::string

`std::string`的采用写时复制（cow, copy-on-write）技术保证效率。具体做法是使用一个额外的计数器来记录内存被共享的次数。

- 当调用*构造函数*时，分配内存，计数器置0；
- 当调用*拷贝构造*或*赋值构造函数*时，仅把指针指向原内存地址，计数器增1；
- 当发生修改操作时，比如`push_back()`、`operator[]`，检查计数器，若大于0，表示有其他string对象在使用这块内存，复制这块内存，同时原计数器减1，再在新的内存上做修改，即copy-on-write。

参考 `std::basic_string`

## 容器(container)

### vector

`std::vector`每次allocator重新分配内存空间为原来的两倍。

### list

`std::list` 双向循环链表，为了保证迭代器维护前开后闭区间，一个trick是尾节点是一个空节点，同时该节点的next指向头节点。

![list结构](http://image.jqian.net/annotated-stl-list.jpg)

### deque

`std::deque` 实际内存分配由*分段*连续线性空间组成，对比vector的内存分配中间增加了一层map，其实是转化成了二维结构。map的元素指向实际的内存空间。当map两端需要增长的时候，会重新realloc这个map数组，而实际使用的内存空间不受影响。所以，deque的关键在于边界处理。

![deque结构](http://image.jqian.net/annotated-stl-deque.jpg)

### map

`std::map` 是按照key排序的红黑树，所以map的key必须是重载过`operator<`的类型，比如`string`或者内置类型。

默认map按照key排序，如果想按照value排序，可以考虑重新放入`priority_queue`或者`vector`中手动排序。

例如，一个常见的统计词频，输出top单词问题：

```c++
typedef std::pair<std::string, int> WordStat;
typedef std::priority_queue<WordStat, std::deque<WordStat>, greater_second<WordStat> > StatQueue;
StatQueue sq(word_map.begin(), word_map.end());
```

## 算法(algorithm)

### 排序函数

- `std::sort` 快速排序  n*log(n)  -> n*n
- `std::stable_sort` 归并排序 n*log(n)  -> n*log(n)*log(n)
- `std::partial_sort` 堆排序 n*log(n)
- `std::nth_element` 找到前n个元素，但和partial_sort不同的是，并不对前n个元素排序，所以速度更快一些 （寻找K大的算法）

排序函数只能作用于 Random Iterator，所以只适用容器`vector`、`string`和`deque`，以及数组。比如，对`list`排序只能使用`list::sort()`，这是个稳定排序函数。

其中，`sort`、`partial_sort`、`nth_element`是不稳定的排序函数，相等的元素可能错位；`stable_sort`是稳定的排序函数。

`std::sort` 如果使用第三个cmp参数，则需要实现 `operator<`。示例：

```c++
struct RuleCount
{
    RuleCount(uint32_t r, int c): ruleid(r), count(c){}
    bool operator<(const RuleCount& cmp_rc) const
    {
        return count > cmp_rc.count;         // order by desc, instead of asc
    }
    uint32_t ruleid;
    int count;
};
std::vector<RuleCount> rcnts;
std::sort(rcnts.begin(), rcnts.end());
```

### 查找函数

使用 `std::find`，需要实现 `operator==`；否则需要使用`std::find_if`。示例：

```c++
struct RuleCountPred
{
    explicit RuleCountPred(uint32_t rid): ruleid(rid){}
    bool operator()(const RuleCount& pred_rc) const
    {
        return ruleid == pred_rc.ruleid;
    }
private:
    uint32_t ruleid;
};
std::vector<RuleCount>::iterator ritr = std::find_if(rcnts.begin(), rcnts.end(), RuleCountPred(ruleid));
```

### 分桶函数

- `std::partition`
- `std::stable_partition`

按照某种标准，把容器分成两部分，返回第二部分开头的迭代器。分桶函数只需要双向迭代器即可。
