---
title: 网络编程备忘
tags: network Programming reading
---

[TOC]

TCP状态转换图

![TCP状态转换图](http://image.jqian.net/network_tcp_state.png)

一次完整的TCP连接：连接建立、数据传输、连接终止。

![一次完整的TCP连接](http://image.jqian.net/network_tcp_process.png)

可以看出建立TCP连接需要经过3步，SYN、SYN+ACK、ACK；而关闭则需要4步，FIN、ACK、FIN、ACK。

## 数据结构

```c
#include <netinet/in.h>
```

数据结构`struct sockaddr`，为各种类型的套接字储存其地址信息：

```c
struct sockaddr
{
    unsigned short sa_family; /* 地址家族, AF_INET 等 */
    char sa_data[14];         /* 14字节协议地址 */
};
```

在网络编程中，为了更方便的处理如上通用结构，我们实际使用一个并列的结构 `struct sockaddr_in` ("in" 代表 "Internet")，这俩结构可以互相cast。

```c
struct sockaddr_in
{
    short int sin_family;        /* 通信类型 */
    unsigned short int sin_port; /* 端口 */
    struct in_addr sin_addr;     /* Internet 地址 */
    unsigned char sin_zero[8];   /* 补齐，与sockaddr结构的长度匹配 */
};
```

而对于结构体`struct in_addr`, 有这样一个联合 (union)：

```c
/* Internet 地址 (一个与历史有关的结构) */
struct in_addr
{
    unsigned long s_addr;
};
```

### IP地址之间的转换

IP地址的可读字符串形式和`struct in_addr`之间可以通过函数`inet_pton`和`inet_ntop`互相转换。

```c
struct sockaddr_in sa;

// 转换可读字符串到sockaddr_in
inet_pton(AF_INET, "10.0.1.123", &(sa.sin_addr));

// 转换sockaddr_in到可读字符串
char str[INET_ADDRSTRLEN];
inet_ntop(AF_INET, &(sa.sin_addr), str, INET_ADDRSTRLEN);
```

此外，如下三个函数都支持字符串形式到整数形式之间的转换，区别如下：

- `in_addr_t inet_addr(const char *cp);`  返回网络序，不支持`255.255.255.255`这个IP。
- `in_addr_t inet_network(const char *cp);`  返回主机序，不支持`255.255.255.255`这个IP。
- `int inet_aton(const char *cp, struct in_addr *inp);` 把字符串形式转换到`struct in_addr`结构，返回0表示字符串地址非法。用于替换上面的俩函数。

所以，类似如上`inet_pton`的转换也可以这样写：

```c
struct sockaddr_in sa;
sa.sin_addr.s_addr = inet_addr("10.0.1.123");
// or
inet_aton("10.0.1.123", &(sa.sin_addr));
```

## IO模型
单线程下的五种 IO 模型：

-   阻塞（blocking）
-   非阻塞（non-blocking）
    - `fcntl(...O_NONBLOCK...)`
-   IO 复用（IO multiplexing）
    - select、epoll、kqueue
-   信号驱动（signal-driven）
    - `SIGIO`
-    异步（asynchronous）
    - `aio_read`、`aio_write` and so forth

### IO复用

IO复用一般借助[select(2)](http://linux.die.net/man/2/select)/[epoll(7)](http://linux.die.net/man/7/epoll)采用事件驱动模型，实现一个reactor。

首先，需要把IO连接设置成非阻塞，有两种方法：

-   调用[open(2)](http://linux.die.net/man/2/open)获取该文件描述符，指定 `O_NONBLOCK`标志
-   对已经打开的文件描述符，使用`fcntl`设置 `O_NONBLOCK`标志

```c
int flags = fcntl(s, F_GETFL, 0));   // socket s
fcntl(s, F_SETFL, flags | O_NONBLOCK);
```

一般的事件驱动模型流程如下：

```
for(;;){
    epoll/select 等待可以读写的描述符
    错误处理
    if(read ready){
        if(tcp) {
            if(accepted) 调用 accept 创建新连接
            if(read) 调用 read 读取
        }
        if(udp) {
            调用 recvfrom 读取
        }
    }
    if(write ready){
        if(connect) 调用 connect 建立连接
        if(write) 调用 write 写入
    }
}
```

其中write ready部分仅用于tcp，如果是udp直接调用[sendto(2)](http://linux.die.net/man/2/sendto)即可。


## 参考

- 《UNIX网络编程》
