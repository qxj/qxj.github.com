---
title: Google的几个开源库：leveldb、protobuf、gflags
tags: google db Programming
---

[TOC]

## leveldb

leveldb文档里给出了详细的[实现机制](http://leveldb.googlecode.com/svn/trunk/doc/impl.html)，这里概括一下最重要的合并(compaction)机制。为了提升写性能，数据先写到log files，此时只会更新memtable，默认到4MB后才写入level-0的sstable，这就把随机写转化成了顺序写。当默认超过4个level-0的sstable后，数据会被归并(merge)到level-1层的sstable(.sst文件默认2MB大小)。同时，leveldb有单独的后台进程对sstable进行compact，条件是level-L层的数据超过(10^L)MB之后。

compact过程产生的sstable都是有序文件，在查询的时候leveldb按照数据的key从低层到高层搜索，可以保证很高的读性能。不过compact本身还是比较耗IO的，因为归并排序需要把整个sstable读入内存，所以在导入数据的时候应该尽量避免写入速度超过compact的速度。

leveldb的性能可以参考其[benchmark文档](http://leveldb.googlecode.com/svn/trunk/doc/benchmark.html)，具体使用的过程中，导入数据的确很快，主流服务器磁盘上几乎可以达到网卡上限；读数据时，并且只要在table cache里的数据延迟只要10ms左右，当然如果不在table cache里，这意味着需要打开sstable文件，最多大概要近1s左右的延迟。

### 注意事项

leveldb 可以用于多线程，但不能用于多进程。可以多线程同时读写，但不能有两个进程同时打开同一个leveldb数据库。

leveldb 数据库对应一个目录。使用leveldb需要注意系统默认单进程内fd数量限制，因为leveldb一个数据库由很多sst文件构成，最大打开文件数量由 `options.max_open_files`设置，但不应该超过`ulimit -n`的限制，一般是1024。sst文件大小默认是2MB，可以由`options.write_buffer_size`设置。

可以使用 `ls /proc/<pid>/fd` 来查询leveldb进程所打开的文件。

### leveldb::Slice

读操作的函数声明

`Status Get(const ReadOptions& options, const Slice& key, std::string* value)`

其中，`Slice`有如下三种构造函数：

```c++
// Create a slice that refers to d[0,n-1].
Slice(const char* d, size_t n) : data_(d), size_(n) { }

// Create a slice that refers to the contents of "s"
Slice(const std::string& s) : data_(s.data()), size_(s.size()) { }

// Create a slice that refers to s[0,strlen(s)-1]
Slice(const char* s) : data_(s), size_(strlen(s)) { }
```

`Slice` 不会分配内存去管理key，而是直接复用你的赋值。
如下的用法是错误的（因为`string`是个临时变量，它的作用域仅在这行赋值语句中）：

```c++
Slice key(std::string("haha"));
Slice key(boost::lexical_cast<std::string>(12345));
```

如果用`WriteBatch`，则`WriteBach::Put`会拷贝`Slice`指向的数据结构，所以可以这样使用：

```c++
leveldb::WriteBatch batch;
for (int i = 0; i < 10; ++i) {
    leveldb::Slice key((const char*)&i, sizeof(int));
    leveldb::Slice value((const char*)&i, sizeof(int));
    batch.Put(key, value);
}
status = db->Write(leveldb::WriteOptions(), &batch);
```


### 优化性能

性能优化主要从cache和buffer两部分入手。

leveldb的cache分为两种：

-   table cache 缓存的是sstable的索引数据，类似于文件系统中对inode的缓存。

    可以使用`options.max_open_files`设置，即打开的.sst文件fd的最大数目。需要注意不要超过系统`ulimit -n`，即单进程最大fd数目的限制，Linux系统默认为1024，可以修改配置文件 `/etc/security/limits.conf` 或者 运行命令 `ulimit -SHn 65535`。

-   block cache 缓存的block数据，block是sstable文件内组织数据的单位，也是从磁盘中读取和写入的单位。

    sstable是有序文件，因此block里的数据也是按key有序排列，类似于Linux中的page cache。block默认大小为4KB，可以使用`options.block_size`设置，最小1KB，最大4MB。对于频繁做scan操作的应用，可适当调大此参数，对大量小value随机读取的应用，也可尝试调小该参数；

    block cache默认实现是一个8MB大小的LRU cache，可以使用`options.block_cache`设置。

跟导入数据性能相关是write buffer的大小，上面提到leveldb是先写logfile，其对应着一个memtable，默认写满4MB会写入到level-0 sstable文件，这就是默认write buffer的大小，可以通过`options.write_buffer_size`设置。比如，设置到64MB，则写满64MB内存，才会进行IO操作。

另外，还可以通过`leveldb::WriteBatch`这个类来做批量写入操作，也可以很明显的提升写入性能。

这里有段性能优化的示例：

```c++
#include "leveldb/cache.h"
#include "leveldb/filter_policy.h"

leveldb::Options options;
options.write_buffer_size = 128*1024*1024; // write buffer size
options.max_open_files    = 10000;         // 调整table cache大小 ，即打开的sst文件数量
options.block_cache = leveldb::NewLRUCache(100 * 1048576);  // 调整block cache大小
options.filter_policy = leveldb::NewBloomFilterPolicy(10);  // 使用布隆过滤器

delete db;
// 使用完都需要释放资源
delete options.cache;
delete options.filter_policy;
```


## protobuf

### 声明类型

- `required` 必须赋值的字段。一旦设置将不能更改，有同事建议不使用`required`，而仅使用`optional`和`repeated`，更方便协议兼容。
- `optional` 可选赋值的字段。可以搭配`default`使用，修改缺省默认值，但不建议把`default`和`required`搭配使用。
- `repeated` 重复字段。建议加上 `[packed=true]` 可以节省编码空间。

### 数据类型

- 浮点型 `double`、`float`
- 整数型 `int32`、`int64`、`uint32`、`uint64`、`sint32`、`sint64`、`fixed32`、`fixed64`、`sfixed32`、`sfixed64`，如果有负数，应该使用 `sint32`、`sint64`
- 布尔型 `bool`
- 字符型 `string`，字符串UTF-8编码或者是ASCII码，对应C++ `std::string`
- 任意二进制 `bytes`，任意二进制字节，对应C++ `std::string`

参考：https://developers.google.com/protocol-buffers/docs/proto#scalar

### 使用

#### 文本格式

借助`google::protobuf::TextFormat::ParseFromString`，protobuf可以读取[protobuf文本格式](https://developers.google.com/protocol-buffers/docs/reference/cpp/google.protobuf.text_format#TextFormat)的文件。

#### 流式读取

protobuf没法解析自身的长度，所以如果要在socket中读写protobuf，需要自己判断一个protobuf封包的起始和终止位置，参考：[Streaming Multiple Messages](https://developers.google.com/protocol-buffers/docs/techniques#streaming)。

示例：在protobuf数据包之前先写入protobuf长度，参考[Length-prefix framing for protocol buffers](http://eli.thegreenplace.net/2011/08/02/length-prefix-framing-for-protocol-buffers/)。

### 示例

```
protoc --cpp_out=DST_DIR --python_out=DST_DIR /path/to/file.proto
```

#### 定义

[tutorial示例](https://developers.google.com/protocol-buffers/docs/cpptutorial)

```protobuf
package tutorial;

message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    required string number = 1;
    optional PhoneType type = 2 [default = HOME];
  }

  repeated PhoneNumber phone = 4;
}
```

#### 操作函数

```c++
// name
inline bool has_name() const;
inline void clear_name();
inline const ::std::string& name() const;
inline void set_name(const ::std::string& value);
inline void set_name(const char* value);
inline ::std::string* mutable_name();

// id (int32)
inline bool has_id() const;
inline void clear_id();
inline int32_t id() const;
inline void set_id(int32_t value);

// email (string)
inline bool has_email() const;
inline void clear_email();
inline const ::std::string& email() const;
inline void set_email(const ::std::string& value);
inline void set_email(const char* value);
inline ::std::string* mutable_email();

// phone (repeated)
inline int phone_size() const;  // 解包
inline void clear_phone();
inline const ::google::protobuf::RepeatedPtrField< ::tutorial::Person_PhoneNumber >& phone() const;
inline ::google::protobuf::RepeatedPtrField< ::tutorial::Person_PhoneNumber >* mutable_phone();
inline const ::tutorial::Person_PhoneNumber& phone(int index) const;  // 解包
inline ::tutorial::Person_PhoneNumber* mutable_phone(int index);
inline ::tutorial::Person_PhoneNumber* add_phone();  // 封包

int main(int argc, char* argv[]) {
  GOOGLE_PROTOBUF_VERIFY_VERSION;  // 验证protobuf版本
  // ...
  google::protobuf::ShutdownProtobufLibrary();  // 手动释放内存，一般不需要。
  return 0;
}
```

#### 管理函数

```c++
bool IsInitialized() const;  // 检查是否所以的required项都设置了
string DebugString() const; // 返回可读的包信息
void CopyFrom(const Person& from); // 覆盖包
void Clear(); // 清除所有项
```

#### 解包封包

```c++
bool SerializeToString(string* output) const; // message_lite.h
bool ParseFromString(const string& data);
bool SerializeToOstream(ostream* output) const; // message.h
bool ParseFromIstream(istream* input);
bool ParseFromArray(const void* data, int size); // message_lite.h
bool SerializeToArray(void * data, int size) const;
bool AppendToString(string * output) const; // message_lite.h

int ByteSize() const;  // 得到serialize之后的消息长度
```

#### 打印封包

```c++
string DebugString() const;
string ShortDebugString() const;
string Utf8DebugString() const;
void PrintDebugString() const;
```

【注】int类型的字段没有`mutable_xxx`函数，message类型的字段没有`set_xxx`函数。


## gflags

[gflags](https://gflags.googlecode.com/svn/trunk/doc/gflags.html)的精髓：分散定义，集中解析。

支持这几种类型：`bool`、`int32`、`int64`、`uint64`、`double`、`std::string`。

比如，在需要用到该flag的.cpp文件里定义：

```c++
#include <gflags/gflags.h>

DEFINE_bool(big_menu, true, "Include 'advanced' options in the menu listing");
DEFINE_string(languages, "english,french,german", "comma-separated list of languages to offer in the 'lang' menu");

if (FLAGS_consider_made_up_languages) FLAGS_languages += ",klingon";   // implied by --consider_made_up_languages
if (FLAGS_languages.find("finnish") != string::npos) HandleFinnish();
```

在main函数里集中解析flag：

```c++
int main(int argc, char** argv) {
    google::ParseCommandLineFlags(&argc, &argv, true);
}
```

## 参考

- [leveldb notes](http://dirlt.com/leveldb.html)
