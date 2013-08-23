---
title: 使用gnu的hash_map实现
tags: c++ Programming stl
---

这两天写段程序, 想用`hash_map`, 于是跑到 [sgi](http://www.sgi.com/tech/stl/hash_map.html) 上学习了一下, 结果郁闷的发现给出的例子在Mac和Linux下都没法编译通过. 因为`hash_map`并没有进入C++的STL标准, 于是破费了点周折才发现`hash_map`位于 `/usr/include/c++/4.0.0/ext` 目录下, 并且在`__gnu_gxx`的名字空间中. 所以要在Mac或者Linux下使用`hash_map`, 需要加上该名字空间.

这里有个例子:

```c++
#include <iostream>
#include <ext/hash_map>

#define HASH __gnu_cxx
using namespace std;

HASH::hash_map <const char*,int> marks;

int main(void)
{
    marks["D"] = 65;
    marks["A"] = 24;
    marks["Z"] = 24;
    marks["B"] = 10;
    marks["X"] = 24;
    marks["Q"] = 59;

    HASH::hash_map <const char*,int>::iterator itr;

    // Remove all item whose value equals 24
    for(itr = marks.begin(); itr != marks.end();){
        if(itr->second == 24){
            cout<<"Remove item whose value eq 24:"<<itr->first<<endl;
            marks.erase(itr++);
        }else{
            itr++;
        }
    }

    // Travel hash table
    itr = marks.begin();
    while(itr != marks.end()){
        cout<<"Key: "<<itr->first<<" Value: "<<itr->second<<endl;
        itr++;
    }

    // Fetch a item, found B but not found A
    cout<<"Key B's value is "<<marks["B"]<<endl;
    cout<<"Key A's value is "<<marks["A"]<<endl;

    return 0;
}
```

编译

    $ make hash_map_demo
    g++ hash_map_demo.cc -o hash_map_demo

编译环境

    $ uname -a
    Darwin qian-julians-imac.local 9.5.0 Darwin Kernel Version 9.5.0: Wed Sep  3 11:29:43 PDT 2008; root:xnu-1228.7.58~1/RELEASE_I386 i386

另外，除了STL的hash_map, 另外还有 [google-sparsehash](http://code.google.com/p/google-sparsehash/)可以使用.
