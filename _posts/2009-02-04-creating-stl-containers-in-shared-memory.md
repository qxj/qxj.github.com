---
title: 【译】把STL容器放入共享内存
tags: c++ Programming STL
---

昨天在上篇blog里描写了如何把STL容器放到共享内存里去，不过由于好久不写blog，发觉词汇组织能力差了很多，不少想写的东西写的很零散，今天刚好翻看自己的书签，看到一篇挺老的文章，不过从共享内存到STL容器讲述得蛮全面，还提供了学习的实例，所以顺便翻译过来，并附上[原文地址](http://www.ddj.com/cpp/184401639)。

共享内存(shm)是当前主流UNIX系统中的一种IPC方法，它允许多个进程把同一块物理内存段(segment)映射(map)到它们的地址空间中去。既然内存段对于各自附着(attach)的进程是共享的，这些进程可以很方便的通过这块共享内存上的共有数据进行通信。因此，顾名思义，共享内存就是进程之间共享的一组内存段。当一个进程附着到一块共享内存上后，它得到一个指向这块共享内存的指针；该进程可以像使用其他内存一样使用这块共享内存。当然，由于这块内存同样会被其他进程访问或写入，所以必须要注意进程同步问题。

参考如下代码，这是UNIX系统上使用共享内存的一般方法（注：本文调用的是POSIX函数）：

```c++
//Get shared memory id
//shared memory key
const key_t ipckey = 24568;
//shared memory permission; can be
//read and written by anybody
const int perm = 0666;
//shared memory segment size
size_t shmSize = 4096;
//Create shared memory if not
//already created with specified
//permission
int shmId = shmget
  (ipckey,shmSize,IPC_CREAT|perm);
if (shmId ==-1)
{
  //Error
}

//Attach the shared memory segment

void* shmPtr = shmat(shmId,NULL,0);

struct commonData* dp =  (struct commonData*)shmPtr;

//detach shared memory
shmdt(shmPtr);
```

## 存放在共享内存中的数据结构

当保存数据到共享内存中时需要留意，参考如下结构：

```c++
struct commonData
{
  int sharedInt;
  float  sharedFloat;
  char* name;
  Struct CommonData* next;
};
```


进程A把数据写入共享内存：


```c++
//Attach shared memory
struct commonData* dp =  (struct commonData*)shmat(shmId,NULL,0);

dp->sharedInt = 5;
.
.
dp->name = new char [20];
strcpy(dp->name,"My Name");

dp->next = new struct commonData();
```

稍后，进程B把数据读出：

```c++
struct commonData* dp =  (struct commonData*)shmat(shmId,NULL,0);

//count = 5;
int count = dp->sharedInt;
//problem
printf("name = [%s]\n",dp->name);
dp = dp->next;  //problem
```

结构 `commonData` 的成员 `name` 和指向下一个结构的 `next` 所指向的内存分别从进程A的地址空间中的堆上分配，显然 name 和 next 指向的内存也只有进程A可以访问。当进程B访问 `dp->name` 或者 `dp->next` 时候，由于它在访问自己地址空间以外的内存空间，所以这将是非法操作(memory violation)，它无法正确得到 `name`和 `next` 所指向的内存。因此，所有的共享内存中的指针必须同样指向共享内存中的地址。（这也是为什么包含虚函数继承的C++类对象不能放到共享内存中的原因——这是另外一个话题。注：因为虚函数的具体实现可能会在其他的内存空间中）由于这些条件限制，放入共享内存中的结构应该简单简单。（注：我觉得最好避免使用指针）

## 共享内存中的STL容器

想像一下把STL容器，例如map, vector, list等等，放入共享内存中，IPC一旦有了这些强大的通用数据结构做辅助，无疑进程间通信的能力一下子强大了很多。我们没必要再为共享内存设计其他额外的数据结构，另外，STL的高度可扩展性将为IPC所驱使。STL容器被良好的封装，默认情况下有它们自己的内存管理方案。当一个元素被插入到一个STL列表(list)中时，列表容器自动为其分配内存，保存数据。考虑到要将STL容器放到共享内存中，而容器却自己在堆上分配内存。一个最笨拙的办法是在堆上构造STL容器，然后把容器复制到共享内存，并且确保所有容器的内部分配的内存指向共享内存中的相应区域，这基本是个不可能完成的任务。例如下边进程A所做的事情：

```c++
//Attach to shared memory
void* rp = (void*)shmat(shmId,NULL,0);
//Construct the vector in shared
//memory using placement new
vector<int>* vpInA = new(rp) vector<int>*;
//The vector is allocating internal data
//from the heap in process A's address
//space to hold the integer value
(*vpInA)[0] = 22;
```

然后进程B希望从共享内存中取出数据：

```c++
vector<int>* vpInB =  (vector<int>*) shmat(shmId,NULL,0);

//problem - the vector contains internal
//pointers allocated in process A's address
//space and are invalid here
int i = *(vpInB)[0];
```

## 重用STL allocator

进一步考察STL容器，我们发现它的模板定义中有第二个默认参数，也就是allocator 类，该类实际是一个内存分配模型。默认的allocator是从堆上分配内存（注：这就是STL容器的默认表现，我们甚至可以改造它从一个网络数据库中分配空间，保存数据）。下边是 vector 类的一部分定义：

```c++
template<class T, class A = allocator<T> >
class vector
{
    //other stuff
};
```

考虑如下声明：

```c++
//User supplied allocator myAlloc
vector<int,myAlloc<int> > alocV;
```

假设 `myAlloc<int>` 从共享内存上分配内存，则 `alocV` 将完全在共享内存上被构造，所以进程A可以如下：

```c++
//Attach to shared memory
void* rp = (void*)shmat(shmId,NULL,0);
//Construct the vector in shared memory
//using placement new
vector<int>* vpInA =
  new(rp) vector<int,myAlloc<int> >*;
//The vector uses myAlloc<int> to allocate
//memory for its internal data structure
//from shared memory
(*v)[0] = 22;
```

进程B可以如下读出数据：

```c++
vector<int>* vpInB = (vector<int,myAlloc<int> >*) shmat(shmId,NULL,0);

//Okay since all of the vector is
//in shared memory
int i = *(vpInB)[0];
```

所有附着在共享内存上的进程都可以安全的使用该vector。在这个例子中，该类的所有内存都在共享内存上分配，同时可以被其他的进程访问。只要提供一个用户自定义的allocator，任何STL容器都可以安全的放置到共享内存上。

## 一个基于共享内存的STL Allocator

清单 shared_allocator.hh 是一个STL Allocator的实现，`SharedAllocator` 是一个模板类。而 `Pool` 类完成共享内存的分配与回收。

```c++
struct keyComp
{
    bool operator()(const char* key1,const char* key2)
    {
        return(strcmp(key1,key2) < 0);
    }
};

class containerMap: public map<char*,void*,keyComp,SharedAllocator<char* > > {};

class containerFactory
{
public:
    containerFactory():pool_(sizeof(containerMap)){}
    ~containerFactory() {}

    template<class Container>
    Container* createContainer (char* key,Container* c=NULL);

    template<class Container>
    Container* getContainer (char* key,Container* c=NULL);

    template<class Container>
    int removeContainer (char* key,Container* c=NULL);
private:
    Pool pool_;
    int lock_();
    int unlock_();
};
```

清单 pool.hh 是 `Pool` 类定义，其中静态成员`shm_` 是类型 `shmPool`，保证每个进程只有唯一的一个`shmPool` 实例。`shmPool` ctor 创建并附着所需大小的内存到共享内存上。共享内存的参数，比如 键值、段数目、段大小，都通过环境变量传递给 `shmPool` ctor。成员 `segs_` 是共享段的数目，`segSize_`是每个共享段的大小，成员`path_`和`key_` 用来创建唯一的 `ipckey`。`shmPool` 为每个共享段创建一个信号量(semaphore)用于同步。`shmPool` 还在为每个共享段构造了一个 `Chunk` 类，一个 `Chunk`代表一个共享段。每个共享段的标识是`shmId_`， 信号量 `semId_`控制该段的访问许可，一个指向 `Link` 结构的指针表明 `Chunk`类的剩余列表。

```c++
class Pool
{
private:
    class shmPool
    {
    private:
        struct Container
        {
            containerMap* cont;
        };
        class Chunk
        {
        public:
            Chunk()
            Chunk(Chunk&);
            ~Chunk() {}
            void* alloc(size_t size);
            void free (void* p,size_t size);
        private:
            int shmId_;
            int semId_;
            int lock_()
        };
        int key_;
        char* path_;
        Chunk** chunks_;
        size_t segs_;
        size_t segSize_;
        Container* contPtr_;
        int contSemId_;
    public:
        shmPool();
        ~shmPool();
        size_t maxSize();
        void* alloc(size_t size);
        void free(void* p, size_t size);
        int shmPool::lockContainer();
        int unLockContainer();
        containerMap* getContainer();
        void shmPool::setContainer(containerMap* container);
    };

private:
    static shmPool shm_;
    size_t elemSize_;
public:
    Pool(size_t elemSize);
    ~Pool() {}
    size_t maxSize();
    void* alloc(size_t size);
    void free(void* p, size_t size);
    int lockContainer();
    int unLockContainer();
    containerMap* getContainer();
    void setContainer(containerMap* container);
};
inline bool operator==(const Pool& a,const Pool& b)
{
    return(a.compare(b));
}
```

## 把STL容器放入共享内存

假设进程A在共享内存中放入了数个容器，进程B如何找到这些容器呢？一个方法就是进程A把容器放在共享内存中的确定地址上（fixed offsets），则进程B可以从该已知地址上获取容器。另外一个改进点的办法是，进程A先在共享内存某块确定地址上放置一个map容器，然后进程A再创建其他容器，然后给其取个名字和地址一并保存到这个map容器里。进程B知道如何获取该保存了地址映射的map容器，然后同样再根据名字取得其他容器的地址。清单container_factory.hh是一个容器工厂类。类`Pool`的方法`setContainer`把map容器放置在一个已知地址上，方法`getContainer`可以重新获取这个map。该工厂的方法用来在共享内存中创建、获取和删除容器。当然，传递给容器工厂的容器需要以`SharedAllocator`作为allocator。

```c++
template<class T>
class SharedAllocator
{
private:
    Pool pool_;    // pool of elements of sizeof(T)
public:
    typedef T value_type;
    typedef unsigned int  size_type;
    typedef ptrdiff_t difference_type;
    typedef T* pointer;
    typedef const T* const_pointer;
    typedef T& reference;
    typedef const T& const_reference;

    pointer address(reference r) const { return &r; }
    const_pointer address(const_reference r) const {return &r;}

    SharedAllocator() throw():pool_(sizeof(T)) {}

    template<class U>
    SharedAllocator (const SharedAllocator<U>& t) throw():
        pool_(sizeof(T)) {}
    ~SharedAllocator() throw() {};

    // space for n Ts
    pointer allocate(size_t n, const void* hint=0)
    {
        return(static_cast<pointer> (pool_.alloc(n)));
    }

    // deallocate n Ts, don't destroy
    void deallocate(pointer p,size_type n)
    {
        pool_.free((void*)p,n);
        return;
    }

    // initialize *p by val
    void construct(pointer p, const T& val) { new(p) T(val); }

    // destroy *p but don't deallocate
    void destroy(pointer p) { p->~T(); }

    size_type max_size() const throw()
    {
        pool_.maxSize();
    }

    template<class U>
    // in effect: typedef SharedAllocator<U> other
    struct rebind { typedef SharedAllocator<U> other; };
};

template<class T>
bool operator==(const SharedAllocator<T>& a,
                const SharedAllocator<T>& b) throw()
{
    return(a.pool_ == b.pool_);
}
template<class T>
bool operator!=(const SharedAllocator<T>& a,
                const SharedAllocator<T>& b) throw()
{
    return(!(a.pool_ == b.pool_));
}
```

## 结论

本文描述的方案可以在共享内存中创建STL容器，其中的一个缺陷是，在分配共享内存之前，应该保证共享内存的总大小(`segs_* segSize_`)大于你要保存STL容器的最大长度，因为一旦类`Pool` 超出了共享内存的，该类无法再分配新的共享内存。

完整的源代码可以从[这里](http://www.cuj.com/code)下载。

## 参考文献

- Bjarne Stroustrup. The C++ Programming Language, Third Edition (Addison-Wesley, 1997).
- Matthew H. Austern. Generic Programming and the STL: Using and Extending the C++ Standard Template Library (Addison-Wesley, 1999).

## 关于作者

Grum Ketema has Masters degrees in Electrical Engineering and Computer Science. With 17 years of experience in software development, he has been using C since 1985, C++ since 1988, and Java since 1997. He has worked at AT&T Bell Labs, TASC, Massachusetts Institute of Technology, SWIFT, BEA Systems, and Northrop.
