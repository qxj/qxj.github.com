---
title: TensorFlow学习
tags: DeepLearning
---


[TOC]

$\newcommand{\R}{\mathbb{R}}$

## 基本概念

A computational graph is a series of TensorFlow operations arranged into a graph of nodes. Each node takes zero or more tensors as inputs and produces a tensor as an output.

`tf.constant` it takes no inputs, and it outputs a value it stores internally.
`tf.Variable` 可以tf.assign()赋值，且需要初始化
`tf.placeholder` a promise to provide a value later.

几个概念：

- graph：图，表示具体的计算任务
- session：会话，图需要在会话中执行，一个会话可以包含很多图
- tensor：张量，在此表示数据，类型是`numpy::ndarray`
- variable：变量、参数，需要初始化，图的重要组成部分
- operation：简称op，是图中计算节点，输入tensor计算后产生tensor
- feed、fetch：意思是给图添加数据和获取图中的数据，因为训练过程中有些数据需要动态获得、临时给予数据

可以使用默认graph或创建新的graph，op在graph上增加节点，由session启动graph。`Session.run(..)`  执行对应graph里的op。

一个自增计数器：

```python
state = tf.Variable(0.0, tf.float32)
add_op = tf.assign(state, state+1)

sess.run(tf.global_variables_initializer())
print 'init state ', sess.run(state)
for _ in xrange(3):
    sess.run(add_op)
    print sess.run(state)
```

为了便于使用诸如 IPython 之类的 Python 交互环境，可以使用 `InteractiveSession` 代替 `Session` 类，使用 `Tensor.eval()` 和 `Operation.run()` 方法代替 `Session.run()`，这样可以避免使用一个变量来持有会话。


### 参数初始化

`tf.initialize_all_variables()` DEPRECATED

变量 `tf.Variable` 需要初始化后才能使用，`tf.global_variables_initializer()` 返回一个op用于初始化所有变量。

```python
init = tf.global_variables_initializer()
sess.run(init)  # init.run()
```

利用已经初始化的参数给其他变量赋值

```python
# 原始的变量
weights = tf.Variable(tf.random_normal([784, 200], stddev=0.35),name="weights")
# 创造相同内容的变量
w2 = tf.Variable(weights.initialized_value(), name="w2")
# 也可以直接乘以比例
w_twice = tf.Variable(weights.initialized_value() * 0.2, name="w_twice")
```

生成tensor：

```python
tf.zeros(shape, dtype=tf.float32, name=None)
tf.zeros_like(tensor, dtype=None, name=None)
tf.constant(value, dtype=None, shape=None, name='Const')
tf.fill(dims, value, name=None)
tf.ones_like(tensor, dtype=None, name=None)
tf.ones(shape, dtype=tf.float32, name=None)
```

生成序列

```python
tf.range(start, limit, delta=1, name='range')
tf.linspace(start, stop, num, name=None)
```

生成随机数

```python
tf.random_normal(shape, mean=0.0, stddev=1.0, dtype=tf.float32, seed=None, name=None)
tf.truncated_normal(shape, mean=0.0, stddev=1.0, dtype=tf.float32, seed=None, name=None)
tf.random_uniform(shape, minval=0.0, maxval=1.0, dtype=tf.float32, seed=None, name=None)
tf.random_shuffle(value, seed=None, name=None)
```


常用的一些变量初始化方法：

- `tf.constant_initializer`
- `tf.truncated_normal_initializer`
- `tf.random_normal_initializer`
- `tf.random_uniform_initializer`

```python
value = [1, 1, 1, 1, -8, 1, 1, 1, 1]
init = tf.constant_initializer(value)
W= tf.get_variable('W', shape=[3, 3], initializer=init)
```

### name/variable scope

参考：https://morvanzhou.github.io/tutorials/machine-learning/tensorflow/5-12-scope/

`tf.name_scope` 搭配 `tf.Variable()` 使用，会在变量名之前加上namespace，让模型看起来更有条理（optional）。

`tf.variable_scope` 搭配 `tf.get_variable()` 使用，用于[reuse变量](https://gist.github.com/qxj/4f159d2a9c0bfb137480cc69331c2906#file-variable_scope-py)。

可以参考MultiRNNCell和Bidirectional LSTM[代码](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/rnn/python/ops/core_rnn_cell_impl.py)学习。

> 我们要确立一种 Graph 的思想。在 TensorFlow 中，我们定义一个变量，相当于往 Graph 中添加了一个节点。和普通的 python 函数不一样，在一般的函数中，我们对输入进行处理，然后返回一个结果，而函数里边定义的一些局部变量我们就不管了。但是在 TensorFlow 中，我们在函数里边创建了一个变量，就是往 Graph 中添加了一个节点。出了这个函数后，这个节点还是存在于 Graph 中的。

如下三种方式所定义的变量具有相同的类型。而且只有 `tf.get_variable()` 创建的变量之间会发生命名冲突。其中，

- `tf.placeholder()` 定义的变量 `trainable==False`
- `tf.get_variable()` 定义的变量 `trainable == True`
- `tf.Variable()` 可以选择 `trainable` 类型

通过函数`tf.trainable_variables()` 可以取得所有 `trainable=True` 的变量。

## tf.nn

### tf.nn.conv2d

http://blog.csdn.net/mao_xiao_feng/article/details/78004522

```python
tf.nn.conv2d(input, filter, strides, padding, use_cudnn_on_gpu=None, name=None)
```

- input：输入图像`[batch, in_height, in_width, in_channels]` 具体含义是 `[训练时一个batch的图片数量, 图片高度, 图片宽度, 图像通道数]`
- filter：卷积核 `[filter_height, filter_width, in_channels, out_channels]`具体含义是 `[卷积核的高度，卷积核的宽度，图像通道数，卷积核个数]`
- strides：卷积时在图像每一维的步长，长度4的一维向量。一般在`batch`和`in_channels`步长都是1，只会在图像2d平面上改变步长，所以该向量一般是 `[1, strides, strides, 1]`
- padding：`SAME` 或者 `VALID`

结果返回一个Tensor，即 **feature map**。

示例，在一张5x5图上以步长2应用7个卷积核输出7张3x3 feature map：

```python
input = tf.Variable(tf.random_normal([1,5,5,5]))
filter = tf.Variable(tf.random_normal([3,3,5,7]))
op = tf.nn.conv2d(input, filter, strides=[1, 2, 2, 1], padding='SAME')
```

### tf.nn.embedding_lookup

本质是一次线性变换，$X$经过一次矩阵乘法从$n\times k$维变成$m\times k$维度（tensor角度可以是更高维度）：

$$
Z = WX + b
$$

直观解释是一个查表操作。
http://stackoverflow.com/a/41922877/647878

```python
tf.InteractiveSession()
params = tf.constant([10,20,30,40])
ids = tf.constant([1,1,3])
print tf.nn.embedding_lookup(params,ids).eval()
# print [20 20 40]
```

就是根据ids里的index，寻找params里对应元素，组成一个tensor返回。等价于：

```python
params = np.array([10,20,30,40])
ids = np.array([1,1,3])
print matrix[ids]
```

如果params是二维矩阵，则每行元素组成一个矩阵返回。可见返回shape是 `shape(ids) + shape(params)[1:]`。

如果len(params)>1，则按照partition_strategy分配。

#### 词向量应用

在实际使用时，可以结合[word2vec示例](https://groups.google.com/a/tensorflow.org/forum/#!topic/discuss/DuegPtQw_JI)来理解。params类型是`tf.Variable`即要求解的参数矩阵，ids是one-hot的词向量，返回是embedding词向量。

```python
state_size = 128
embedding_params = tf.Variable(tf.random_uniform([10000, state_size], -0.02, 0.02))
words = tf.placeholder(tf.int64, name='words')
for _ in range(10):
    # Get the embedding for words
    embedding = tf.nn.embedding_lookup(embedding_params, words[:, i])
    # ...
```

#### 数学解释
https://www.zhihu.com/question/52250059

假设一共有$m$个物体，每个物体有自己唯一的id，那么从物体的集合到$\R^m$有一个trivial的嵌入，就是把它映射到$\R^m$中的标准基，这种嵌入叫做 **One-hot embedding/encoding**。

应用中一般将物体嵌入到一个低维空间$\R^n(n\ll m)$ ，只需要再compose上一个从$\R^m$到$\R^n$的线性映射就好了。每一个$n\times m$的矩阵都定义了$\R^m$到$\R^n$的一个线性映射: $x\mapsto Mx$。当$x$ 是一个标准基向量的时候，$Mx$对应矩阵$M$中的一列，这就是对应id的向量表示。这个概念用神经网络图来表示如下：
![Tensorflow embedding](http://image.jqian.net/tensorflow_embedding_lookup.png)


从id(索引)找到对应的One-hot encoding，然后红色的weight就直接对应了输出节点的值(注意这里没有activation function)，也就是对应的embedding向量。

### tf.nn.embedding_lookup_sparse
http://stackoverflow.com/a/39209361/647878

tf.nn.embedding_lookup_sparse和tf.nn.embedding_lookup最大区别是使用Segmentation来组合embeddings，所以sp_id作为SparseTensor的indices必须是从0开始并且只能以1递增，每个segment映射params里的元素由combiner指定的操作进行计算。

```python
tf.InteractiveSession()
params = tf.constant([10,20,30,40])
sp_ids = tf.SparseTensor(indices=[[0], [0], [1]], values=[1, 0, 3], dense_shape=[3])
print tf.nn.embedding_lookup_sparse(params, sp_ids, None, combiner='sum').eval()
# print [30, 40]
```

## 其他API

### tf.segment_sum
https://www.tensorflow.org/versions/master/api_docs/python/math_ops/segmentation

Segmentation是tf用来给tensor分块，并执行统一的sum、prod、mean、max、min等数学操作。
segment_ids维度必须和tensor第一维相等，而且是从0开始递增的自然数，其中id相等的被分到同一个segment做计算。

![Tensorflow segment]((http://image.jqian.net/tensorflow_segment_sum.png))

### tf.random_uniform

生成指定shape的随机数。
