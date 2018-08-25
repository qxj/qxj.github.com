---
title: Transfer Learning
tags: MachineLearning
---

参考：https://www.zhihu.com/question/41979241

几种迁移学习：http://www.jianshu.com/p/c5aae401b63a

## Instance transfer

基于实例的迁移：主要思想就是在目标领域的训练中，虽然源数据域不能直 接使用，但是可以从中挑选部分，用于目标领域的学习。

TrAdaBoost 假设源数据域和目标数据域使用相同的特征和标签集合，但是分布不相同。有一些源数据对于目标领域的学习是有帮助的，但是还有一些是无帮助甚至是有害的。所以它迭代地指定源数据域每一个数据的权重，旨在训练当中减小“坏”数据的影响，加强“好”数据的作用。

## Feature transfer

基于特征表示的迁移：主要思想是寻找一个“好”的特征表示，最小化域间差异和分类回归的误差。可以分为有监督和无监督两种情况。

有监督特征构造的基本思想是学习一个低维的特征表示，使得特征可以在相 关的多个任务中共享，同时也要使分类回归的误差最小。此时目标函数如下：

$$
{\arg\min}_{A,U} \sum_{t\in\{T,S\}}\sum_{i=1}^{n_t} L\left(y_{t_i}, \langle a_t, U^Tx_{t_i}\rangle \right) + \gamma \|A\|_{2,1}^2
$$

其中 S 和 T 表示源域和目标域，U 是将高维的数据映射为低维表示的矩阵。

## Model transfer

基于参数的迁移：参数迁移方法假定在相关任务上的模型应该共享一些参数、先验分布或者超参数。

multi-task学习中多使用这种方法，通过将multi-task学习对于源域和目标域的权值做改变(增大目标域权值，减小源域权值)，即可将多任务学习转变成迁移学习。

----

https://github.com/mrgloom/Transfer-Learning

## Transfer Learning:
"How transferable are features in deep neural networks?"
https://github.com/yosinski/convnet_transfer
https://github.com/hycis/transfer_learning
Transfer learning    and embedding
https://courses.cs.ut.ee/MTAT.03.292/2015_spring/uploads/Main/FOTIS%20project%20amp%20face%20recognition%20using%20CNN.pdf

## Domain Adaptation:
"Unsupervised Domain Adaptation by Backpropagation"
https://github.com/ddtm/caffe/tree/grl
http://zhengrui.github.io/zerryland/transfer-learning-office-dataset.html

## One-Shot Learning and Zero-Shot Learning:
"One-Shot Learning of Object Categories"
http://vision.stanford.edu/documents/Fei-FeiFergusPerona2006.pdf
"Zero-Shot Learning with Semantic Output Codes"
http://www.cs.cmu.edu/afs/cs/project/theo-73/www/papers/zero-shot-learning.pdf
