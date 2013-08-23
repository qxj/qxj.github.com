---
title: Python并发：线程和进程
tags: python
---

## multiprocessing

可以通过派生`multiprocessing.Process`来构造一个子进程：

```python
class MyProcess(multiprocessing.Process):
    def __init__(self, name):
        super(MyProcess, self).__init__(name=name)

    def run(self):
        // 进程实际的逻辑
        print 'Worker: %d. pid: %d' % (num, os.getpid())
```

再通过`p.start()`来启动子进程，然后通过`p.join()`方法来使得子进程运行结束后再执行父进程。

```python
jobs = [MyProcess(str(i)) for i in range(5)]
for p in jobs:
    p.start()
for p in jobs:
    p.join()
```

### multiprocessing.Pool

`Pool`对`Process`做了进一步封装，它默认按照CPU的数量创建子进程。

```python
p = multiprocessing.Pool()
for i in range(5):
    p.apply_async(worker, args=(i,))
p.close()       # 关闭pool，执行close()将不能再调用apply_async()添加子进程
p.join()
```

【注】如果使用了`Pool`，那么不能直接用`Queue.Queue()`在父子进程之间传递消息，必须使用multiprocessing里的Queue。
【注】同时使用`mamager.Queue()` 和 `multiprocessing.Lock()` 会有问题。

```python
import multiprocessing

def write(q):
    for value in range(10):
        print 'Put %s to queue...' % value
        q.put(value)
    # 需要有标识队列结束
    q.put(None)

def read(q):
    while True:
        value = q.get(False)
        if value is None:
            break
        print 'Get %s from queue.' % value

manager = multiprocessing.Manager()
# 父进程创建Queue，并传给各个子进程：
q = manager.Queue()
p = multiprocessing.Pool()
p.apply_async(write, args=(q, ))
p.apply_async(read, args=(q, ))
p.close()
p.join()

print '所有数据都写入并且读完'
```

## threading

`threading.Thread`和`multiprocessing.Process`类似，可以派生一个新类：

```python
logging.basicConfig(level=logging.DEBUG, format='(%(threadName)-10s) %(message)s')

class MyThread(threading.Thread):
    def __init__(self):
        super(MyThread, self).__init__(name='thread name')

    def run(self):  # 必须实现run()函数
        # do something
        logging.debug('print thread name')
```

使用的时候：

```python
thr = MyThread()
thr.start()
thr.join()
```

获取当前thread名字：`threading.current_thread.getName()`。

> 在使用threading的时候，和C++开发很大的差异是没法和signal混用。
> 只有main thread能够接收signal，其他线程是没法感知到signal的。
> 所以，如果需要接收signal，一定要保证main thread存活。

python thread（非daemon）通信建议的方法是：`threading.Event`。
`Event.wait()` 会一直block，直到调用`Event.set()`，返回`True`。

示例：

```python
class MyThread(threading.Thread):
    def __init__(self):
        super(MyThread, self).__init__()
        self.event = threading.Event()

    def run(self):
        while not self.event.is_set():
            print "something"
            self.event.wait(10)

thr = MyThread()
thr.start()

def stop():
    thr.event.set()

signal.signal(signal.SIGINT, stop)
signal.signal(signal.SIGTERM, stop)

# 注意需保证main thread能接收到signal，主线程不要退出。

thr.join()
```

## Queue.Queue

Python Queue既可以用在多线程也可以用在多进程中通信。

队列中常用的方法

- `Queue.qsize()` 返回队列的大小
- `Queue.empty()` 如果队列为空，返回`True`,反之`False`
- `Queue.full()` 如果队列满了，返回`True`,反之`False`
- `Queue.get([block[, timeout]])` 获取队列，timeout等待时间
- `Queue.get_nowait()` 相当`Queue.get(False)`
- `Queue.put(item)` 写入队列，timeout等待时间
- `Queue.put_nowait(item)` 相当`Queue.put(item, False)`
- `Queue.task_done()`  一般调用 `get()` 并处理完毕后，再调用一下`task_done()`
- `Queue.join()` 阻塞，直到队列元素全处理完毕

一定要调用 `Queue.task_done()`，否则queue不空最终join不会退出，可以这样idiom：

```python
def worker():
    while True:
        item = q.get()
        try:
            1/item
        except Exception as e:
            print e
        finally:
            q.task_done()
```

### 各种Queue

- `Queue.Queue`
- `multiprocessing.Queue`
- `multiprocessing.JoinableQueue`  需要调用task_done，保证队列里的任务全部处理完（感觉比`multiprocessing.Queue`慢很多）
- `multiprocessing.manager.Queue`

## concurrent.features

Future（类似还有Promise和Delay）用于一些并发语言中做同步proxy，它是一个对象，实际是未知结果的proxy（因为是异步处理，此时结果还没计算出来）。


把任务分解到多个进程去执行，可以绕过GIL：

```python
with concurrent.futures.ProcessPoolExecutor() as executor:
     result = executor.map(function, iterable)
```

如果瓶颈在IO的话，也可以使用`ThreadPoollExcutor`，此时也会有性能提升。


## 参考

- [Python Concurrency Cheatsheet](https://www.pythonsheets.com/notes/python-concurrency.html)
- [Communication Between Processes](https://pymotw.com/2/multiprocessing/communication.html)
- [threading – Manage concurrent threads](https://pymotw.com/2/threading/)
- [Queue – A thread-safe FIFO implementation](https://pymotw.com/2/Queue/)
