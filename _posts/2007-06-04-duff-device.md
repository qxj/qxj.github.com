---
title: 达夫设备
tags: Programming c
---

看一段代码：

```c
void send1(int *to, int *from, int count)
{
    do {
        *to++ = *from++ ;
    } while( --count > 0);
}
```

很容易看出来这段代码的作用，把count个整型数据从from复制到to。不过，还有更快的写法吗？看下边这段代码：

```c
void send2(int *to, int *from, int count)
{
    int n = (count + 7 ) / 8 ;
    switch (count % 8 ) {
        case 0: do { *to++ = *from++;
        case 7:      *to++ = *from++;
        case 6:      *to++ = *from++;
        case 5:      *to++ = *from++;
        case 4:      *to++ = *from++;
        case 3:      *to++ = *from++;
        case 2:      *to++ = *from++;
        case 1:      *to++ = *from++;
                   } while(--n > 0);
    }
}
```

这段代码很神奇的把一个循环嵌到了一个 *switch-case* 里。首先，用 `count%8` 取得余下的int个数（这余数不是在分组的末尾，而是在开头），利用 *switch-case* 定位到这“剩下”的int个数，先复制这几个int。然后，这个 *switch-case* 就失去作用了。接着，就是 *do-while* 来发挥作用，每8个int为一组，批量复制数据。

这样对比看来，send1每复制一个int都要进行一次比较，而send2每复制8个int才进行一次比较，显然send2的复制效率更高一些。实际测试的结果也是这样。后一种复制技巧被称作[Duff's Device](http://en.wikipedia.org/wiki/Duff's_device)。

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

const size_t BUFLEN = 100000000;

#define TEST_START(TEST_NAME)                   \
    do {                                        \
    char* name = TEST_NAME;                     \
    clock_t start, finish;                      \
    start = clock();

#define TEST_END()                                      \
    finish = clock();                                   \
    printf("%s clock: %ld\n", name, finish - start);    \
    } while(0);

void send1(int *to, int *from, int count)
{
    do {
        *to++ = *from++ ;
    } while( --count > 0);
}

void send2(int *to, int *from, int count)
{
    int n = (count + 7 ) / 8 ;
    switch (count % 8 ) {
        case 0: do { *to++ = *from++;
        case 7:      *to++ = *from++;
        case 6:      *to++ = *from++;
        case 5:      *to++ = *from++;
        case 4:      *to++ = *from++;
        case 3:      *to++ = *from++;
        case 2:      *to++ = *from++;
        case 1:      *to++ = *from++;
                   } while(--n > 0);
    }
}

int main (int argc, char *argv[])
{
    char *from, *to;

    from = (char *) malloc(BUFLEN * sizeof(char));
    to = (char *) malloc(BUFLEN * sizeof(char));

    memset(from, 'a', (BUFLEN * sizeof(char)));

    TEST_START("send1");
    send1(to, from, BUFLEN);
    TEST_END();

    TEST_START("send2");
    send2(to, from, BUFLEN);
    TEST_END();

    free(from);
    free(to);
    return(0);
}
```

运行结果：

```
send1 clock: 110000
send2 clock: 60000
```
