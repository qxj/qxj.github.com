---
title: Boost.Asio的使用技巧
tags: c++ programming
---

[TOC]

最近尝试使用了一下Boost.Asio，不知道是否因为各大公司都有自己相对成熟的网络库的缘故，网络上Asio相关的资料实在不多，而且很多翻来覆去就是那几个简单的示例，所以打算自己小结一下。总的来说Boost.Asio是个非常易用的库，避免了你在各种系统底层API之间的挣扎，让你可以非常迅速的开发出高并发的网络服务器程序。

## 基本概念

asio基于两个概念：

- I/O服务，抽象了操作系统的异步接口 `boost::asio::io_service::service`：
    - `boost::asio::io_service`
- I/O对象，有多种对象 `boost::asio::basic_io_object`：
    - `boost::asio::ip::tcp::socket`
    - `boost::asio::ip::tcp::resolver`
    - `boost::asio::ip::tcp::acceptor`
    - `boost::asio::local::stream_protocol::socket` 本地连接
    - `boost::asio::posix::stream_descriptor`  面向流的文件描述符，比如`stdout`, `stdin`
    - `boost::asio::deadline_timer` 定时器
    - `boost::asio::signal_set` 信号处理

所有 I/O 对象通常都需要一个 I/O 服务作为它们的构造函数的第一个参数，比如：

    boost::asio::io_service io_service;
    boost::asio::deadline_timer timer(io_service, boost::posix_time::seconds(5));

在一定条件下使用多个 `io_service` 是有好处的，每个 `io_service` 有自己的线程，最好是运行在各自的处理器内核上，这样每一个异步操作连同它们的句柄就可以局部化执行。 如果没有远端的数据或函数需要访问，那么每一个 `io_service` 就象一个小的自主应用。 这里的局部和远端是指象高速缓存、内存页这样的资源。 由于在确定优化策略之前需要对底层硬件、操作系统、编译器以及潜在的瓶颈有专门的了解，所以应该仅在清楚这些好处的情况下使用多个 `io_service`。

### Asio proactor

和我们熟知的Reactor不同，Asio使用Proactor模型：

![](http://image.jqian.net/asio_proactor.png)

1. Initiator使用Asynchronous Operation Processor发起异步I/O操作
2. 保存每个异步I/O操作的参数，包括回调函数的地址，并将其放入Completion Event Queue
3. Proactor调用Asynchronous Event Demultiplexer检测完成事件。
4. 当检测到I/O操作完成事件，从Completion Event Queue中取出对应的异步I/O操作，并且dispatch到相应的Completion Handler。
5. Completion Handler调用回调函数。

可以看出asio本质就是维护着一个任务队列，调用`post()`方法接收handler作为参数加入队列，或者调用`async_*()`方法接收handler作为参数和对应的I/O对象加入队列（handler实际借助boost::bind成为一个closure，可以复制到队列），在Linux系统下会在epoll空闲时或有I/O事件触发后执行。但是asio与Reactor不同的地方在于前者当事件到来时会自动读写缓冲区，等I/O操作完成后才调用原先注册的handler，把执行流交割；而Reactor当事件到来时，即交由调用者自己处理剩下的I/O操作。

## I/O服务

### work类

`work`类用于通知`io_service`是否可以结束，只要对象`work(io_service)`存在，`io_service`就不会结束。所以`work`类用起来更像是一个标识，比如：

    boost::asio::io_service io_service;
    boost::asio::io_service::work* work = new boost::asio::io_service::work( io_service );
    // delete work; // 如果不注释掉这一句，则run loop不会退出；一般用shared_ptr维护work对象，使用work.reset()来结束其生命周期。
    io_service.run()

### run() vs poll()

`run()`和`poll()`都循环执行I/O对象的事件，区别在于如果事件没有被触发（ready），`run()`会等待，但是`poll()`会立即返回。也就是说`poll()`只会执行已经触发的I/O事件。

比如I/O对象`socket1`, `socket2`, `socket3`都绑定了`socket.async_read_some()`事件，而此时`socket1`、`socket3`有数据过来。则调用`poll()`会执行`socket1`、`socket3`相应的handler，然后返回；而调用`run()`也会执行`socket1`和`socket3`的相应的handler，但会继续等待`socket2`的读事件。

### stop()

调用 `io_service.stop()` 会中止 run loop，一般在多线程中使用。

### post() vs dispatch()

`post()`和`dispatch()`都是要求`io_service`执行一个handler，但是`dispatch()`要求立即执行，而`post()`总是先把该handler加入事件队列。

什么时候需要使用`post()`？当不希望立即调用一个handler，而是异步调用该handler，则应该调用`post()`把该handler交由`io_service`放到事件队列里去执行。比如，Boost.Asio自带的[聊天室示例](http://www.boost.org/doc/libs/1_42_0/doc/html/boost_asio/example/chat/)，其中实现了一个支持异步IO的聊天室客户端，是个很好的例子。

[chat_client.cpp](http://www.boost.org/doc/libs/1_42_0/doc/html/boost_asio/example/chat/chat_client.cpp) 的`write()`函数之所以要使用`post()`，是为了避免临界区同步问题。`write()`调用和`do_write()`里`async_write()`的执行分别属于两个线程，前者会往`write_msgs_`里写数据，而后者会从`write_msgs_`里读数据，如果不使用`post()`，而直接调用`do_write()`，显然需要使用锁来同步`write_msgs_`。但是使用`post()`相当于由`io_service`来调度`write_msgs_`的读写，这就在一个线程内完成，无需额外的锁机制。

### buffer类

buffer类分`mutable_buffer`和`const_buffer`两个类，buffer类特别简单，仅有两个成员变量：指向数据的指针 和 相应的数据长度。buffer类本身并不申请内存，只是提供了一个对现有内存的封装。

需要注意的是，所有`async_write()`、`async_read()`之类函数接受的buffer类型是 `MutableBufferSequence` / `ConstBufferSequence`，这意味着它们既可以接受`boost::asio::buffer`，也可以接受 `std::vector<boost::asio::buffer>` 这样的类型。

### 缓冲区管理

*缓冲区的生命期*是使用asio最需要重视的两件事之一，缓冲区之所以需要重视的原因在于Asio异步调用[Reference](http://www.boost.org/doc/libs/1_42_0/doc/html/boost_asio/reference/basic_datagram_socket/async_receive_from/overload1.html)里的这段描述：

> Although the buffers object may be copied as necessary, ownership of the underlying memory blocks is retained by the caller, which must guarantee that they remain valid until the handler is called.

这意味着缓冲区从发起异步调用到handler被执行，这段时间内需要交由`io_service`控制，这个限制常常导致asio的某些代码变得可能比Reactor相应代码还要麻烦一些。

还是举上面聊天室的那个例子。[chat_client.cpp](http://www.boost.org/doc/libs/1_42_0/doc/html/boost_asio/example/chat/chat_client.cpp) 的`do_write()`函数收到用户输入数据后，之所以把该数据保存到`std::deque<std::string> write_msgs_` 队列，而不是存到类似`char data[]`的数组里，然后去调用`async_write(..data..)`发送数据，是为了避免这种情况：输入数据速度过快，当上一次`async_write()`调用的handler还没有来得及处理，又收到一份新的数据，如果直接保存到`data`，会导致覆盖上一次`async_write()`的缓冲区。`async_write()`要求这个缓冲区从调用`async_write()`开始，直到handler处理这个时间段是不变的。

同样的，在`do_write()`函数里调用`async_write()`函数之前，先判断`write_msgs_`队列是否为空，也是为了保证`async_write()`总是从`write_msgs_`队列头取得有效的数据，而在`handle_write()`里当数据发送完毕后，再`pop_front()`弹出已经发送的数据包。以此避免出现前一个`async_write()`的handler还没执行完毕，就把队列头弹出去，导致对应的缓冲区失效问题。

这里主要还是因为`async_write()`和`async_read()`的区别，前者是主动发起的，后者可以由`io_service`控制，所以后者不用担心这种缓冲区被覆盖问题。因为在同一个线程里，哪怕需要读取的事件触发得再快，也需要由`io_service`逐一处理。

在这个聊天室的例子里，如果不考虑把数据按用户输入顺序发送出去的话，可以使用更简单的办法来处理`do_write()`函数，例如：

```c++
void do_write(chat_message msg)
{
    chat_message* pmsg = new chat_message(msg); // implement copy ctor for chat_message firstly
    boost::asio::async_write(socket_,
            boost::asio::buffer(pmsg->data(), pmsg->length()),
            boost::bind(&chat_client::handle_write, this,
                    boost::asio::placeholders::error, pmsg));
}

void handle_write(const boost::system::error_code& error, chat_message* pmsg)
{
    if (!error) {

    }else{
        do_close();
    }
    delete pmsg;
}
```

这里相当于给每个异步调用分配一块属于自己的内存，异步调用完成即自动释放掉，有些类似于闭包了。如果不希望频繁new/delete内存，也可以考虑使用`boost::circular_buffer`一次性分配内存后逐项使用。

## I/O对象

### socket

Boost.Asio最常用的对象应该就是socket了，常用的函数一般有这几个：

- 读写TCP socket的时候，一般使用`read()`, `async_read()`, `write()`, `async_write()`，为了避免所谓的short reads and writes，一般不使用`receive()`, `async_receive()`, `send()`, `async_send()`。
- 读写有连接的UDP socket的时候，一般使用`receive()`, `async_receive()`, `send()`, `async_send()`。
- 读写无连接的UDP socket的时候，一般使用`receive_from()`, `async_receive_from()`, `send_to()`, `async_send_to()`。

而自由函数`boost::asio::async_write()`和类成员函数`socket.async_write_some()`的有什么区别呢（`boost::asio::async_read()`和`socket.async_read_some()`类似）：

- `boost::asio::async_write()` 异步写，立即返回。但它可以保证写完整个缓冲区的内容，否则将报错。
- `boost::asio::async_write()` 是通过调用n次`socket.async_write_some()` 来实现的，所以代码必须确保在`boost::asio::async_write()`执行的时候，没有其他的写操作在同一socket上执行。
- 在调用`boost::asio::async_write()`的时候，如果指定buffer的length没有写完或出错，是不会回调相应的handler的，它将一直在run loop中执行；直到buffer里所有的数据都写完或出错（此时handler里返回的长度肯定会小于buffer length），才会调用handler继续处理；而`socket.async_write_some()`不会有这样的问题，它只会尝试写一次，写完的长度会在handler的参数里返回。

所以，这里强调使用asio时第二件需要重视的事情，就是*handler的返回值*（一般可能声明为`boost::asio::placeholders::error`）。因为asio里所有的任务都由`io_service`异步执行，只有执行成功或者失败之后才会回调handler，所以返回值是你了解当前异步操作状况的唯一办法，记住不要忽略任何handler的返回值处理。

### 信号处理

Boost.Asio的信号处理非常简单，声明一个信号集合，然后把相应的异步handler绑上就可以了。如果你希望在一个信号集里处理所有的信号，那么你可以根据handler的第二个参数，来获取当前触发的是那个信号。比如：

```c++
boost::asio::signal_set signals(io_service, SIGINT, SIGTERM);
signals.add(SIGUSR1); // 也可以直接用add函数添加信号

signals.async_wait(boost::bind(handler, _1, _2));

void handler(
  const boost::system::error_code& error,
  int signal_number // 通过这个参数获取当前触发的信号值
);
```

### 定时器

Boost.Asio的定时器用起来根信号集一样简单，但由于它太过简单，也有不方便的地方。比如，在一个UDP伺服器里，一般收到的每个UDP包中都会包含一个sequence number，用于标识该UDP，以应对包处理超时情况。假设每个UDP包处理时间只有100ms，如果超时则直接给客户端返回超时标记。这种最简单的定时器常用的一些Reactor框架都有很完美的解决方案，一般是建一个定时器链表来实现，但是Asio中的定时器没法单独完成这个工作。

`boost::asio::deadline_timer` 只有两种状态：超时和未超时。所以，只能很土的对每个UDP包创建一个定时器，然后借助`std::map`和`boost::shared_ptr`保存sequence number到定时器的映射，根据定时器handler的返回值判断该定时器是超时，还是被主动cancel。

### strand

在多线程中，多个I/O对象的handler要访问同一块临界区，此时可以使用`strand`来保证这些handler之间的同步。

示例：

我们向定时器注册 func1  和 func2，它们可能会同时访问全局的对象(比如 std::cout )。这时我们希望对 func1 和 func2 的调用是同步的，即执行其中一个的时候，另一个要等待。

这时就可以用到 `boost::asio::strand` 类，它可以把几个cmd包装成同步执行的。例如，我们向定时器注册 func1 和 func2 时，可以改为：

```c++
boost::asio::strand  the_strand;
t1.async_wait(the_strand.wrap(func1));      //包装为同步执行的
t2.async_wait(the_strand.wrap(func2));
```

这样就保证了在任何时刻，func1 和 func2 都不会同时在执行。

还有就是如果你希望把一个`io_service`对象绑定到多个线程。此时需要`boost::asio::strand`来确保handler不会被同时执行，因为异步操作，比如`async_write`、`async_receive_from`之类会影响到临界区buffer。

具体可参考[asio examples](http://www.boost.org/doc/libs/1_42_0/doc/html/boost_asio/examples.html)里的示例：[HTTP Server 2](http://www.boost.org/doc/libs/1_42_0/doc/html/boost_asio/example/http/server2/connection.hpp)和[HTTP Server 3](http://www.boost.org/doc/libs/1_42_0/doc/html/boost_asio/example/http/server3/connection.hpp)的connection.hpp设计。

## 参考

关于boost asio最好的参考书当然就是[官方文档](http://www.boost.org/libs/asio/)和它的源码，此外还有两个不错的资料：

- [The Boost C++ Libraries, Chapter 7: Asynchronous Input and Output](http://en.highscore.de/cpp/boost/asio.html) 这本书已经有[中文翻译](http://zh.highscore.de/cpp/boost/)了
- [A guide to getting started with boost::asio](http://www.gamedev.net/blog/950/entry-2249317-a-guide-to-getting-started-with-boostasio/)
