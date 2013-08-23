---
title: 虚函数和bind性能对比
tags: c++ Programming
---

前几天水木上有人讨论虚函数和标准库tr1::bind的性能问题，一致认为虚函数性能比bind好得多；但我觉得可能有待商榷，于是做了个测试，结果发觉bind的性能也并非那么不堪。

使用g++的测试结果：

-   g++ 4.2.1, -O0

        virtual function :132833us
        bind :564099us

-   g++ 4.2.1, -O2

        virtual function :60687us
        bind :59534us

可以看出在关闭优化的情况下，bind的性能的确要差很多，时间开销是虚函数的四倍还多；然而，在打开优化的情况下，bind的性能和虚函数在伯仲之间，甚至还稍微好一些。

思考一下虚函数和bind的实现：

虚函数一般的实现都是基于vptr和vtbl。在运行时每个对象会有一个vptr，它由ctor、copy assignment等维护，指向该类的vtbl。vtbl是一个函数指针表，保存着该类所有虚函数的实现地址，该表独立于类对象存在，是在编译期就可以确定的。当调用一个虚函数时，经历这样的步骤：

1. 在类对象里通过偏移找到vptr
2. 根据vptr间接寻址找到vtbl
3. 在vptr里根据偏移找到虚函数的实际地址

可以看出虚函数的时间开销可谓微乎其微，不过多了一次指针跳转而已。

bind的实现代价就要高多了。因为bind实际会返回一个function对象，这意味着每一次bind调用返回就可能有一次拷贝构造，同时产生一个临时对象。这个时间开销是巨大的，所以可以看到当未打开优化的时候，bind的性能是如此糟糕。而打开了优化之后，bind的性能居然可以和虚函数并驾齐驱，这可能有两点原因。一方面，bind的实现可以使用内联函数，而通过指针调用虚函数是无法内联的。另一方面，bind返回一个function对象时，RVO可以优化掉多余的一次拷贝构造和那个临时对象的产生，这会大幅提升bind的性能。

考虑到C++0x里增加了move语义，专门能够优化拷贝构造和赋值时的临时对象问题，或许对bind性能有提升，所以我又测试了一下新标准下虚函数和bind的性能对比。

- g++ 4.6.1, -O2, -std=c++0x

        virtual function :28657us
        bind :32184us

- clang++ 3.0, -O2, -std=c++0x -stdlib=libc++

        virtual function :22382us
        bind :45002us

可以看出在g++里两者差距依然不大，因为move和RVO达到的效果应该是一样的；而clang++里两者依然又一倍的性能差距，而且我后来又测试了clang++无论是否打开C++0x支持，bind的性能都要比虚函数差不少。还是期待等C++0x的支持完备之后，再做比较。

最后要说的是，抛却性能以外，bind的最大优势在于程序设计上的*解耦*。继承是一种强耦合设计，如果你只想提供一个功能性的接口，那么虚函数是个别扭的选择，首先，它限制了类型，你必须从某个基类派生；其次，你会发觉你代码里渐渐多了很多类定义，但它们都是不必要的；而如果使用bind，那么限制的只有参数和返回值，这将灵活很多。考虑一下ACE的类设计，比如在一个event loop里，你只想处理数据的读取和写入，但你不得不先去派生出一个类型，才能去实现handle_input、handle_output等具体的读写逻辑，对比一下 [muduo](http://code.google.com/p/muduo/) 这个网络库的实现，后者使用function/bind接受回调函数作为接口，你会感觉一切好像更自然更有弹性了。

下边是测试代码：

```c++
// #define CPP0X

#include <sys/time.h>
#include <cstdio>

#ifdef CPP0X
#include <functional>
using std::bind;
using std::function;
#else
#include <tr1/functional>
using std::tr1::bind;
using std::tr1::function;
#endif

#define MAX_LOOP 10000000
#define CONST_NUM 17
#define TV2USEC(begin, end) ((end.tv_sec - start.tv_sec)*1000000 + (end.tv_usec - start.tv_usec))

typedef function<void()> task;

class VirtBase
{
public:
    virtual void test() {}
    virtual ~VirtBase(){}
};

class VirtChild:public VirtBase
{
public:
    VirtChild(int cnt) : count(cnt) {}
    void test()
    {
        this->count = this->count*CONST_NUM;
        this->count = this->count/CONST_NUM;
        this->count = this->count+CONST_NUM;
        this->count = this->count-CONST_NUM;
    }
private:
    int count;
};

class BindObject
{
public:
    BindObject(int cnt) : count(cnt) {}
    void test()
    {
        this->count = this->count*CONST_NUM;
        this->count = this->count/CONST_NUM;
        this->count = this->count+CONST_NUM;
        this->count = this->count-CONST_NUM;
    }
private:
    int count;
};

void runVirtTest(VirtBase *pObject)
{
    struct timeval start, end;
    gettimeofday(&start, NULL);
    for(int i=0 ; i < MAX_LOOP ;++i) {
        pObject->test();
    }
    gettimeofday(&end, NULL);
    printf("virtual function :%luus\n",TV2USEC(start, end));
}

void runBindTest(task func)
{
    struct timeval start, end;
    gettimeofday(&start, NULL);
    for(int i=0 ; i < MAX_LOOP ;++i) {
        func();
    }
    gettimeofday(&end, NULL);
    printf("bind :%luus\n",TV2USEC(start, end));
}

int main(void)
{
    VirtChild *vObj = new VirtChild(13);
    BindObject *bObj = new BindObject(13);
    runVirtTest(vObj);
    runBindTest(bind(&BindObject::test, bObj));
}
```
