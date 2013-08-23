---
title: python学习笔记
tags: Programming python
---

[TOC]

## Python Philosophy

> There should be one -- and preferably only one -- obvious way to do it.

    >>> import this

## 数据类型
### 基本类型

- 整型 integer，长整型末尾以 `L` 结尾
- 浮点数 float，转换字符串float(string)
- 几个等价的空值： `None` `""` `()` `[]` `{}`

python里的整形和长整型会自动转换。值得欣喜的是，python的长整型和lisp类似，可以无限大（仅受内存大小限制），这比PHP强大很多。

    >>> int(12901082323112)
    12901082323112L

char和integer互相转换

    >>> ord('a')
    97
    >>> chr(97)
    'a'

不同进制之间互相转换

    >>> bin(-37)
    '-0b100101'
    >>> hex(-37)
    '-0x25'

###  列表
例如：

    a = [0,1,2,3,4,5,6]

####  提取子串
包括起始位置元素，但不包括结束位置的元素!

    >>> a[1:4]
    [1,2,3]
    >>> a[1:-1]
    [1,2,3,4,5]

####  list comprehension

    [  for k in L if  ]

语义是这样的：

    returnList=[]
    for k in L:
        if : returnList.append()
    return returnList;

类似Perl中的grep用法, `@new_array = grep { /pattern/ } @orig_array;`，和map用法也有些类似，不过增加了filter语义

示例，取出数组a中的单词，并转化为大写：

    >>> [ k.upper() for k in a if k.isalpha() ]

###  字符串
可以把字符串看成包含很多字符的list

####  查找函数

`S.index(substring, [ start [, end]])` 和`find`一样，但会抛出`ValueError`异常

####  格式化字符串

    >>> print "%s's height is %dcm" % ("Jack", 175)
    Jack's height is 175cm

**mapping key** 的方式可读性比较好，例如：

    >>> print "%(name)s's height is %(height)dcm" % \
    ...     {"name":"Jack", "height":175}

####  str()与expr()

- `str()` 一般返回对象的字符串形式，由 `object.__str__()`返回
- `repr()` 一般返回合法的Python表达语句，可以交给`eval()`执行，由`object.__repr__()`返回

#### 编码问题

str和unicode是python2.x里最容易让人混乱的部分，参考这篇[文章](http://nedbatchelder.com/text/unipain.html)，讲解很透彻。

str就是二进制字符串，其中存储的编码格式可以是utf8、utf16、gbk、latin1、iso-8859-1等等；你需要使用正确的编码格式把它[decode](http://docs.python.org/2/library/stdtypes.html#str.decode)到unicode。同样，unicode也可以通过指定明确的编码，把抽象字符串[encode](http://docs.python.org/2/library/stdtypes.html#str.encode)到相应编码的二进制字符串。这也意味着可以使用decode/encode函数转换任意编码。

简单来说，str和unicode都是python2.x的合法字符串，但str的存储单位是byte，用于实际IO；而unicode的存储单位是UNICODE编码，但并不单纯是我们平时所理解的[UNICODE编码标准](http://en.wikipedia.org/wiki/Unicode)，而是python内部的字符串抽象表示。这里几个概念交错容易让人混淆，在python3.x里做了纠正，给这两者赋予了更明确的意义:

- str → bytes
- unicode → str

一般来讲，和外围IO交互的字符串是二进制的str，python内部处理的的字符串是unicode，在代码的边界我们进行decode和encode操作，如果我们遵循这样的准则来编程会省却不少麻烦。

此外，str和unicode在python2.x最容易出错的地方在于implicit conversion。由于存在str和unicode这两种字符串，所以当组合两种字符串的时候，python2.x会默认以ascii进行编码或解码，但如果存在非ascii字符，则会出错。在python3.x里禁止了这种隐式转换，要求在代码编写时就要明确完成这两种字符串的转换。

**所以，在python2.x为了避免字符串异常，我们需要明确清楚每条字符串的类型和编码格式。**

Tips：

-   测试字符串的类型

    打印字符串类型：

        >>> print type(s)

    打印字符串的值：

        >>> print repr(s)
        u'\u9083\u7d98\u6fc2\u65a4\u7d1dPython'

    判断字符串类型：

        isinstance(s, str)
        isinstance(s, unicode)

-   指定额外参数，避免编码转换失败

    比如，经常一个str里包含无法转换成utf-8的字符，那么解码的时候会抛出异常，可以指定 `decode()` 函数的第二个参数为 `"replace"` 来避免：

        >>> a.decode("utf8", "replace")

### 元组(tuple)

tuple是常量list，用 `()` 表示，例如

    >>> t = (1,2)
    >>> a, b = t
    >>> print a,b
    1 2

`(1,)` VS 单独变量

tuple比list性能好，因为它不具备动态内存管理功能。

###  字典(dictionary)
####  associate array

字典就是一个associate array，即hash table，例如

    >>> dict = {"clock":12, "table": 15}

#### dict()

dictionary和list, tuple的转换 `dictionary = dict([tuple, ... ])`，例如

    >>> dict1 = dict([(k1,v1), (k2,v2)])
    >>> dict2 = dict([(x, 10*x) for x in [1,2,3]])
    >>> dict3 = dict([(str(x), x) for x in [1,2,3]])

#### 赋值

默认是引用赋值，这和PHP不一样，如果需要拷贝赋值应该用copy函数，或者是
update函数。

    >>> b = a.copy()
    >>> b.update(a)

`update()` 函数也可以用于合并a和b，如果a和b中有重复的key，则a会覆盖b的值。

合并a和b也可以使用 [下边的语句](http://stackoverflow.com/questions/38987/how-can-i-merge-two-python-dictionaries-as-a-single-expression)，但是不是每个python编译器都支持：

    >>> dict(a, **b)

#### collections.defaultdict

默认情况下，使用`[]`访问dict里一个不存在的key会抛出`KeyError`异常，而`collections.defaultdict`可以优雅的处理这种情况。你只需要在初始化的时候传给它一个函数`func`，当访问`key`不存在的时候，会调用该函数，类似于`dict[key]=func()`，例如：

    >>> model = collections.defaultdict(lambda: 1)
    >>> print model[0]
    1

### 集合(set)

集合在python2.6之后也成为了内置类型，可以很方便的判断子集，并求交集(`&`)、并集(`|`)、补集(`-`)、对称差分(异或`^`)。

### 空值

一共六种： `None`, `0`, `""`, `[]`, `{}`, `()`

## 函数
### 可变参数

使用`*`按照则该可变参数是tuple类型

```python
def printf(format, *arg):
    print format%arg
```

使用`**`按照则该可变参数是dict类型

```python
def printf(format, **keyword):
    for k in keyword.keys();
        print "keyword[%s] is %s" % (k, keyword[k])
```

### 函数描述

python可以在函数里编写函数描述(doc string)，并且可以通过`__doc__`内置成员获取，这点和lisp比较像。

### apply函数

    apply(function [, args [, kwargs ]])

apply函数在很多语言里都有，比如lisp里的同名函数，PHP里的 `call_user_func_array`，接受两种参数，可以是第二个参数args是tuple，也可以是第三个参数kwargs是dict。示例：

```python
def say(a=1,b=2):
    print a,b

def test(**kw):
    apply(say,(),kw)

print test(a='a',b='b')
```

###  map函数

    map(function, sequence[, sequence,...]) -> list

map函数可以同时作用于多个sequence序列，这比Perl的map要强一些。

### filter函数

    filter(function or None, sequence) -> list, tuple, or string

如果filter的第一个参数为 `None`，那么将过滤掉sequence中所有的假值。

### lambda函数

lambda函数必须是单行的简单函数，这个限制有些郁闷：

    >>> f = lambda a,b: a+b
    >>> f(1,2)
    3

### reduce函数

    reduce(function, sequence[, initial]) -> value

意思就是对sequence连续使用function，如果不给出initial，则第一次调用传递sequence的两个元素，以后把前一次调用的结果和sequence的下一个元素传递给function；如果给出initial，则第一次传递initial和sequence的第一个元素给function。

比如下边这个例子，合并多个dict，同时把他们的值也合并：

```python
rets = [{'x1':[('k1','a1'),('k2','a2')],
         'x2':[('k1','b1'),('k2','b2')]},
        {'x1':[('k3','c1')],
         'x2':[('k3','d1')]}]
for i in ['x1','x2']:
    print reduce(lambda x, y: x[i]+y[i], rets)
```

考虑一下如果rets有三个元素的情况（提示：需要对x的类型做判断 `type(x) == types.ListType`）

### yield函数

调用使用`yield`的函数会返回一个迭代器（Iterator），这种迭代器被称作生成器（Genrator），可以使用`next()`遍历。`yield`从Python2.5开始成为一个表达式，它与`return`的另外一个区别是，调用yield返回后会保存函数的上下文，当再次访问生成器时，会继续从yield处执行。每调一次 `next()` 会执行到下一个 `yield`处，如果没有`yield`将抛出`StopIteration`异常，当然`for`循环会处理这一切。

生成器的一大优势在于处理某些大批量计算时，可以无需一次计算出所有的数据，而是用一次计算一次，这样可以节省大量资源。当然这样做的代价是生成器每次计算都会依赖上一次的计算结果，这正是`yiled`的用武之地，因为`reture`后将丢弃函数堆栈。具体的示例可以参考`xrange()`和`range()`函数，在Python3.0里后者已被放弃。

一个产生Fibonacci数列的示例：

```python
def fib(max):
    a, b = 0, 1
    while a < max:
        yield a
        a, b = b, a + b

for n in fib(1000):
    print n
```

### decorators函数

decorators可以理解为操作函数的函数。在python里，函数是[一级对象](http://en.wikipedia.org/wiki/First-class_function)，这意味着可以像操作string、integer或者其他对象一样操作函数。

比如一段Fibonacci函数：

```python
def fib(n):
    "Recursively (i.e., dreadfully) calculate the nth Fibonacci number."
    return n if n in [0, 1] else fib(n - 2) + fib(n - 1)
```

如果我们要频繁调用这段函数，那么肯定会有效率问题；最好可以在每次计算之后保存一下对应参数结果，这样下次使用同样参数调用就不需要再做递归计算了。可以声明这样一个函数来暂存计算结果：

```python
def memoize(fn):
    stored_results = {}

    def memoized(*args):
        try:
            # try to get the cached result
            return stored_results[args]
        except KeyError:
            # nothing was cached for those args. let's fix that.
            result = stored_results[args] = fn(*args)
            return result

    return memoized
```

这样可以给出一个wrap过的fib新版本：

```python
def fib(n):
    return n if n in [0, 1] else fib(n - 2) + fib(n - 1)
fib = memoize(fib)
```

其中，`memoize()` 函数其实就是所谓的 *decorators*。在python2.2+给出了一个语法糖：

```python
@memoize
def fib(n):
    return n if n in [0, 1] else fib(n - 2) + fib(n - 1)
```

以上两段代码实际作用是完全一样的。decorators可以叠加，比如，再声明一个 decorator 用来打印所修饰函数的函数名：

```python
def make_verbose(fn):
    def verbose(*args):
        # will print (e.g.) fib(5)
        print '%s(%s)' % (fn.__name__, ', '.join(repr(arg) for arg in args))
        return fn(*args) # actually call the decorated function
    return verbose
```

下边两段代码的作用也是一样的：

```python
@memoize
@make_verbose
def fib(n):
    return n if n in [0, 1] else fib(n - 2) + fib(n - 1)

def fib(n):
    return n if n in [0, 1] else fib(n - 2) + fib(n - 1)
fib = memoize(make_verbose(fib))
```

参考： [A primer on Python decorators](http://www.thumbtack.com/engineering/a-primer-on-python-decorators/)

###  函数作用域scope

LGB规则：

locals() → globals() → buildin name space

关键字 `global`

    >>> def testfun():
    ...     global a
    ...     a = 2
    ...     print a

##  类
###  attribute

- 创建attribute的办法 `setattr(obj, "attr")`
- 删除attribute的办法 `delattr(obj, "attr")`
- 查询attribute的办法  `hasattr(obj, "attr")`
- 得到所有attribute的办法 `dir(obj)`
- 得到object的name space的办法 `vars(objs)`

python没有ctor & dtor，但是有初始化函数 `__init__()`，这和Java类似。

    >>> class Foo:
    ...     def __init__(self):
    ...         print "ok"

###  概念对比
####  module object VS. class object

- 调用方式: class object可以用函数调用的形式创建一个新的class instance
- 创建方式: py文件 `import`关键字 VS `class`关键字

####  property VS. method

- property: data attribute
- method: function attribute

####  bound method VS. unbound method

与class instance绑定与否，第一个参数都是一个class object

    >>> class A:
    ...     def h(self):
    ...         pass
    ... a= A()

a.h() & A.h(a)

#### class attribute VS. instance attribute

    >>> class A: foo = []
    >>> a, b = A(), A()
    >>> a.foo.append(5)
    >>> b.foo
    [5]
    >>> class A:
    ...  def __init__(self): self.foo = []
    >>> a, b = A(), A()
    >>> a.foo.append(5)
    >>> b.foo
    []

class attribute是由所有的instance共享的；而instance attribute每个instance单独一份，它应该在 `__init__` 中初始化，可以使用 `__class__` 这个静态成员变量访问class attribute。

    >>> class A(): count = 0
    ...
    >>> a, b = A(), A()
    >>> A.count
    0
    >>> print a.count, b.count
    0 0
    >>> a.count = 10
    >>> print A.count, a.count, b.count
    0 10 0
    >>> A.count = -1
    >>> print A.count, a.count, b.count
    -1 10 -1
    >>> a.__class__.count
    -1

###  private attribute: name mangle

python中没法实现真正的私有attribute

###  类中的特殊method

    __init__(self)
    __del__(self)
    __repr__(self)
    __str__(self)
    __cmp__(self, other)
    __hash__(self)
    __nozero__(self)
    __len__(self)
    __getitem__(self,key)
    __setitem__(self,key,value)
    __delitem__(self,key)
    __getslice__(self,i,j)
    __setslice__(self,i,j,value)
    __delslice__(self,i,j)
    __contains__(self,other)
    __call__(self,arg1,arg2,...)

### 函数重载

### 异常处理

使用finally子句：

    try:
        ... # statement 1
    finally:
        ... # statement 2

使用raise抛出异常

    raise Exception("what's wrong")

使用assert断言

    assert 1 == 0, "unmatch error"

with是一个语法糖，用来替换双层try-catch结构，显得非常简洁。比如，打开文件的操作：

```python
    def readFile():
        try:
            with open('/path/to/file', 'r') as f:
                process(f)
        except:
            print 'error occurs while reading file'

原理是 Python 虚拟机在 with 块退出时会去寻找对象的 `__exit__` 方法并调用它，把释放资源的动作放在这个 `__exit__` 函数中就可以了。另外，对象还需要一个 `__enter__` 函数，当进入 with 块时， 这个函数被调用。

`__exit__` 函数接受三个参数，分别是 异常对象类型, 异常对象和调用栈。如果 with 块正常退出，那么这些参数将都是 None。返回 True 表示发生的异常已被处理，不再继续向外抛出。详细的情况可以参考 [PEP 343](http://www.python.org/dev/peps/pep-0343/) 。

##  模块和包

###  module

testmodule.py 示例：

```python
"""
module description
"""
age = 0

def sayHello():
    print "Hello"

if __name__ == "__main__"
    sayHello()
```

#### 使用module

```python
import testmodule
from testmodule import age, sayHello
from testmodule import *
```

#### 查找module(sys.path)

- 当前路径
- 环境变量 `PYTHONPATH`
- 安装目录

        >>> import sys
        >>> print sys.path

使用 `sys.path.append("/path/to/lib")` 可以把某个路径加入 `PYTHONPATH`。

### package

package可以是一组module甚至一组package的集合

- 创建空目录package
- 目录中创建文件 `__init__.py`，可以在其中做一些整个包的初始化工作
- 目录中放入需要包含module文件

#### 使用package

除了类似 module 的使用办法，还可以把package打包成一个zip，然后使用 `zipimport` 调用它，示例：

这是GAE的一个例子，包 django.zip 里包含这些内容：

    django/forms/__init__.py
    django/forms/fields.py
    django/forms/forms.py
    ...

然后，可以这样使用这个zip包：

```python
    import sys
    sys.path.insert(0, "django.zip")
    import django.forms.fields


###  命名空间：LGB

name space就是从名称(name)到对象(object)上的映射(map)，当一个name映射到一个object上时，我们就说这个name和这个object有绑定(bind)关系。python的一切都是object，而如何找到这些object，就是通过name。每个name对应一个object，而一个object可以有多个名字。

    globals().get('__name__' ) == '__main__'

####  scope 作用域

作用域就是可以直接访问的名字集合

- 直接访问: 用unqualified reference name可以直接找到name所指的对象
- unqualified reference: unqualified reference就是不含有 `.` 的name，突然想起C++的cv-unqualified类型＠＠

####  bind

在name space中创建name和object的bind关系，所以一个object可以有多个name，用 `del` 可以删除bind关系。

    >>> del a

##  常用模块
### logging

python自带log模块非常好用。比如，设置把ERROR级别的日志输出到文件，把DEBUG级别的日志输出到标准输出：

```python
def getLogger():
    logger = logging.getLogger('foo')
    logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s %(name)s [%(levelname)s] <%(filename)s> %(funcName)s: %(message)s')
    ## append to file
    fh = logging.FileHandler('test.log')
    fh.setLevel(logging.ERROR)
    fh.setFormatter(formatter)
    logger.addHandler(fh)
    ## append to sys.stderr
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    return logger
logger = getLogger()
```

也可以限制日志数目，比如，定义一个`RotatingFileHandler`，最多备份5个日志文件，每个日志文件最大10M：

```python
from logging.handlers import RotatingFileHandler

rh = RotatingFileHandler('mytestlog.log', maxBytes=10*1024*1024, backupCount=5)
rh.setLevel(logging.INFO)
formatter=logging.Formatter('%(name)-12s:%(levelname)-8s %(message)s')
rh.setFormatter(formatter)
logger = logging.getLogger('foo').addHandler(rh)
```

###  regex
####  最小匹配

最小匹配是在 `*`,`+`,`?`,`{m,n}` 后加一个 `?`

    >>> re.compile("a*?").match("aaaa").end()
    0

####  原始字符串

原始字符串(raw string)，在字符串前面加 `r` 即可，表示无需对某些特殊字符转义，比如 `\`，在写正则表达式的时候比较有用。C#里是在字符串前面加 `@`。

    >>> '\x89'.encode('string-escape')
    '\\x89'
    >>> r'\x89'
    '\\x89'

比如，把所有非Latin1和CJK字符都清理掉：

    >>> re.compile(ur"[^\u0001-\u00ff\u3040-\u30ff\u4e00-\u9fbf]+", re.U).sub("", content)

#### RegxObject → MatchObject

- compile
- match/search/findall
- start/end/span/pos/endpos/re/string/finditer

### subprocess

如果想执行外部程序，subprocess模块是最佳选择。比如，可以让外部程序执行后的标准输出作为字符串返回：

    output = subprocess.Popen("/bin/ls -l", shell=True, stdout=subprocess.PIPE).communicate()[0]

这里 `communicate()`函数默认返回tuple `(stdout, stderr)`，如果只要标准输出，取第一项即可。或者，也可以直接读取管道：

    fp = subprocess.Popen("/bin/ls -l", shell=True, stdout=subprocess.PIPE).stdout
    for line in fp: ...

在python2.7+增加了新函数`check_output()`，使用更加方便了：

    output = subprocess.check_output("/bin/ls -l", shell=True)

### backtrace

可以搭配异常捕获使用，打印调用信息：

```python
import traceback

try:
    ...
except Exception, e:
    print e.args
    print e
    traceback.print_exc()
```

### profiling

性能优化(profiling)有两个模块：cProfile和profile，推荐前者，是基于C的扩展(lsprof)，后者是纯python实现，两者接口一样。可以这样使用：

    $ python -m cProfile myscript.py

还可以按照执行时间排序，并且输出结果到文件：

    $ python -m cProfile -o output.file myscript.py

直接在终端调用：

    >>> cProfile.run("for i in range(10000): pass")

### pdb

pdb模块用于调试python，使用`-m`选择pdb模块，运行待调试的脚本即可：

    python -m pdb myscript.py

pdb会自动停在第一行，等待调试，这时你可以看看 帮助

    (Pdb) h

断点设置

    (Pdb)b 10         # 断点设置在本py的第10行
    (Pdb)b ots.py:20  #断点设置到 ots.py第20行
    (Pdb)b            #查看断点编号
    (Pdb)cl 2         #删除第2个断点

运行

    (Pdb)n            #单步运行
    (Pdb)s            #细点运行 也就是会下到，方法
    (Pdb)c            #跳到下个断点

查看

    (Pdb)p param      #查看当前 变量值
    (Pdb)l            #查看运行到某处代码
    (Pdb)a            #查看全部栈内变量

更直接的调试办法是，在要断点的地方插入代码 `pdb.set_trace()`，示例：

```python
import pdb
def foo():
    pdb.set_trace()
    for i in range(1, 5):
        print i
```

### ctypes

当需要提升性能的地方，比如处理多重循环和递归调用，此时可以考虑使用C语言重构python代码。

示例，C文件fib.c：

```c
#include <stdint.h>

uint64_t fibonacci(int n)
{
    uint64_t x = 0, y = 1, i;
    for (i = 1; i < n; ++i){
        y = x + y;
        x = y - x;
    }
    return y;
}
```

首先，编译重构的c代码fib.c，把编译出的libfib.so放到任意lib目录：

    $ gcc -c fib.c -fPIC
    $ gcc –shared -o libfib.so fib.o

然后，在python里调用编译好的lib库：

```python
import ctypes

def foo(n):
     ctypes.cdll.LoadLibrary("libfib.so")
     lib = ctypes.CDLL("libfib.so")
     lib.fibonacci(ctypes.c_int(n))
```

不过需要注意，ctypes模块的加载本身很耗资源，应该合理使用之。
