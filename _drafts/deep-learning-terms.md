---
title: 深度学习术语汇总
tags: DeepLearning
---

本文整理了一些深度学习领域的专业名词及其简单释义，同时还附加了一些相关的论文或文章链接。本文编译自 wildml，作者仍在继续更新该表，编译如有错漏之处请指正。文章中的论文与 PPT 读者可点击阅读原文下载。

[TOC]

###激活函数（Activation Function）

为了让神经网络能够学习复杂的决策边界（decision boundary），我们在其一些层应用一个非线性激活函数。最常用的函数包括  sigmoid、tanh、ReLU（Rectified Linear Unit 线性修正单元） 以及这些函数的变体。

###Adadelta

Adadelta 是一个基于梯度下降的学习算法，可以随时间调整适应每个参数的学习率。它是作为 Adagrad 的改进版提出的，它比超参数（hyperparameter）更敏感而且可能会太过严重地降低学习率。Adadelta 类似于 rmsprop，而且可被用来替代 vanilla SGD。

论文：Adadelta：一种自适应学习率方法（ADADELTA: An Adaptive Learning Rate Method）
技术博客：斯坦福 CS231n：优化算法（http://cs231n.github.io/neural-networks-3/）
技术博客：梯度下降优化算法概述（http://sebastianruder.com/optimizing-gradient-descent/）

###Adagrad

Adagrad 是一种自适应学习率算法，能够随时间跟踪平方梯度并自动适应每个参数的学习率。它可被用来替代vanilla SGD (http://www.wildml.com/deep-learning-glossary/#sgd)；而且在稀疏数据上更是特别有用，在其中它可以将更高的学习率分配给更新不频繁的参数。

论文：用于在线学习和随机优化的自适应次梯度方法（Adaptive Subgradient Methods for Online Learning and Stochastic Optimization）
技术博客：斯坦福 CS231n：优化算法（http://cs231n.github.io/neural-networks-3/）
技术博客：梯度下降优化算法概述（http://sebastianruder.com/optimizing-gradient-descent/）

###Adam

Adam 是一种类似于 rmsprop 的自适应学习率算法，但它的更新是通过使用梯度的第一和第二时刻的运行平均值（running average）直接估计的，而且还包括一个偏差校正项。

论文：Adam：一种随机优化方法（Adam: A Method for Stochastic Optimization）
技术博客：梯度下降优化算法概述（http://sebastianruder.com/optimizing-gradient-descent/）

###仿射层（Affine Layer）

神经网络中的一个全连接层。仿射（Affine）的意思是前面一层中的每一个神经元都连接到当前层中的每一个神经元。在许多方面，这是神经网络的「标准」层。仿射层通常被加在卷积神经网络或循环神经网络做出最终预测前的输出的顶层。仿射层的一般形式为 y = f(Wx + b)，其中 x 是层输入，w 是参数，b 是一个偏差矢量，f 是一个非线性激活函数。

###注意机制（Attention Mechanism）

注意机制是由人类视觉注意所启发的，是一种关注图像中特定部分的能力。注意机制可被整合到语言处理和图像识别的架构中以帮助网络学习在做出预测时应该「关注」什么。

技术博客：深度学习和自然语言处理中的注意和记忆（http://www.wildml.com/2016/01/attention-and-memory-in-deep-learning-and-nlp/）

###Alexnet

Alexnet 是一种卷积神经网络架构的名字，这种架构曾在 2012 年 ILSVRC 挑战赛中以巨大优势获胜，而且它还导致了人们对用于图像识别的卷积神经网络（CNN）的兴趣的复苏。它由 5 个卷积层组成。其中一些后面跟随着最大池化（max-pooling）层和带有最终 1000 条路径的 softmax (1000-way softmax)的 3个全连接层。Alexnet 被引入到了使用深度卷积神经网络的 ImageNet 分类中。

###自编码器（Autoencoder）

自编码器是一种神经网络模型，它的目标是预测输入自身，这通常通过网络中某个地方的「瓶颈（bottleneck）」实现。通过引入瓶颈，我们迫使网络学习输入更低维度的表征，从而有效地将输入压缩成一个好的表征。自编码器和 PCA 等降维技术相关，但因为它们的非线性本质，它们可以学习更为复杂的映射。目前已有一些范围涵盖较广的自编码器存在，包括 降噪自编码器（Denoising Autoencoders）、变自编码器（Variational Autoencoders）和序列自编码器（Sequence Autoencoders）。

降噪自编码器论文：Stacked Denoising Autoencoders: Learning Useful Representations in a Deep Network with a Local Denoising Criterion
变自编码器论文：Auto-Encoding Variational Bayes
序列自编码器论文：Semi-supervised Sequence Learning

###平均池化（Average-Pooling）

平均池化是一种在卷积神经网络中用于图像识别的池化（Pooling）技术。它的工作原理是在特征的局部区域上滑动窗口，比如像素，然后再取窗口中所有值的平均。它将输入表征压缩成一种更低维度的表征。

###反向传播（Backpropagation）

反向传播是一种在神经网络中用来有效地计算梯度的算法，或更一般而言，是一种前馈计算图（feedforward computational graph）。其可以归结成从网络输出开始应用分化的链式法则，然后向后传播梯度。反向传播的第一个应用可以追溯到 1960 年代的 Vapnik 等人，但论文 Learning representations by back-propagating errors常常被作为引用源。

技术博客：计算图上的微积分学：反向传播（http://colah.github.io/posts/2015-08-Backprop/）

###通过时间的反向传播（BPTT：Backpropagation Through Time）

通过时间的反向传播是应用于循环神经网络（RNN）的反向传播算法。BPTT 可被看作是应用于 RNN 的标准反向传播算法，其中的每一个时间步骤（time step）都代表一个计算层，而且它的参数是跨计算层共享的。因为 RNN 在所有的时间步骤中都共享了同样的参数，一个时间步骤的错误必然能「通过时间」反向到之前所有的时间步骤，该算法也因而得名。当处理长序列（数百个输入）时，为降低计算成本常常使用一种删节版的 BPTT。删节的 BPTT 会在固定数量的步骤之后停止反向传播错误。

论文：Backpropagation Through Time: What It Does and How to Do It

###分批标准化（BN：Batch Normalization）

分批标准化是一种按小批量的方式标准化层输入的技术。它能加速训练过程，允许使用更高的学习率，还可用作规范器（regularizer）。人们发现，分批标准化在卷积和前馈神经网络中应用时非常高效，但尚未被成功应用到循环神经网络上。

论文：分批标准化：通过减少内部协变量位移（Covariate Shift）加速深度网络训练（Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift）
论文：使用分批标准化的循环神经网络（Batch Normalized Recurrent Neural Networks）

###双向循环神经网络（Bidirectional RNN）

双向循环神经网络是一类包含两个方向不同的 RNN 的神经网络。其中的前向 RNN 从起点向终点读取输入序列，而反向 RNN 则从终点向起点读取。这两个 RNN 互相彼此堆叠，它们的状态通常通过附加两个矢量的方式进行组合。双向 RNN 常被用在自然语言问题中，因为在自然语言中我们需要同时考虑话语的前后上下文以做出预测。

论文：双向循环神经网络（Bidirectional Recurrent Neural Networks）

###Caffe

Caffe 是由伯克利大学视觉和学习中心开发的一种深度学习框架。在视觉任务和卷积神经网络模型中，Caffe 格外受欢迎且性能优异
.
###分类交叉熵损失（Categorical Cross-Entropy Loss）

分类交叉熵损失也被称为负对数似然（negative log likelihood）。这是一种用于解决分类问题的流行的损失函数，可用于测量两种概率分布（通常是真实标签和预测标签）之间的相似性。它可用 L = -sum(y * log(y_prediction)) 表示，其中 y 是真实标签的概率分布（通常是一个one-hot vector），y_prediction 是预测标签的概率分布，通常来自于一个 softmax。

###信道（Channel）

深度学习模型的输入数据可以有多个信道。图像就是个典型的例子，它有红、绿和蓝三个颜色信道。一个图像可以被表示成一个三维的张量（Tensor），其中的维度对应于信道、高度和宽度。自然语言数据也可以有多个信道，比如在不同类型的嵌入（embedding）形式中。

###卷积神经网络（CNN/ConvNet：Convolutional Neural Network）

CNN 使用卷积连接从输入的局部区域中提取的特征。大部分 CNN 都包含了卷积层、池化层和仿射层的组合。CNN 尤其凭借其在视觉识别任务的卓越性能表现而获得了普及，它已经在该领域保持了好几年的领先。

技术博客：斯坦福CS231n类——用于视觉识别的卷积神经网络（http://cs231n.github.io/neural-networks-3/）
技术博客：理解用于自然语言处理的卷积神经网络（http://www.wildml.com/2015/11/understanding-convolutional-neural-networks-for-nlp/）

###深度信念网络（DBN：Deep Belief Network）

DBN 是一类以无监督的方式学习数据的分层表征的概率图形模型。DBN 由多个隐藏层组成，这些隐藏层的每一对连续层之间的神经元是相互连接的。DBN 通过彼此堆叠多个 RBN（限制波尔兹曼机）并一个接一个地训练而创建。

论文：深度信念网络的一种快速学习算法（A fast learning algorithm for deep belief nets）

###Deep Dream

这是谷歌发明的一种试图用来提炼深度卷积神经网络获取的知识的技术。这种技术可以生成新的图像或转换已有的图片从而给它们一种幻梦般的感觉，尤其是递归地应用时。

代码：Github 上的 Deep Dream（https://github.com/google/deepdream）
技术博客：Inceptionism：向神经网络掘进更深（https://research.googleblog.com/2015/06/inceptionism-going-deeper-into-neural.html）

###Dropout

Dropout 是一种用于神经网络防止过拟合的正则化技术。它通过在每次训练迭代中随机地设置神经元中的一小部分为 0 来阻止神经元共适应（co-adapting），Dropout 可以通过多种方式进行解读，比如从不同网络的指数数字中随机取样。Dropout 层首先通过它们在卷积神经网络中的应用而得到普及，但自那以后也被应用到了其它层上，包括输入嵌入或循环网络。

论文：Dropout: 一种防止神经网络过拟合的简单方法（Dropout: A Simple Way to Prevent Neural Networks from Overfitting）
论文：循环神经网络正则化（Recurrent Neural Network Regularization）

###嵌入（Embedding）

一个嵌入映射到一个输入表征，比如一个词或一句话映射到一个矢量。一种流行的嵌入是词语嵌入（word embedding，国内常用的说法是：词向量），如 word2vec 或 GloVe。我们也可以嵌入句子、段落或图像。比如说，通过将图像和他们的文本描述映射到一个共同的嵌入空间中并最小化它们之间的距离，我们可以将标签和图像进行匹配。嵌入可以被明确地学习到，比如在 word2vec 中；嵌入也可作为监督任务的一部分例如情感分析（Sentiment Analysis）。通常一个网络的输入层是通过预先训练的嵌入进行初始化，然后再根据当前任务进行微调（fine-tuned）。

###梯度爆炸问题（Exploding Gradient Problem）

梯度爆炸问题是梯度消失问题（Vanishing Gradient Problem）的对立面。在深度神经网络中，梯度可能会在反向传播过程中爆炸，导致数字溢出。解决梯度爆炸的一个常见技术是执行梯度裁剪（Gradient Clipping）。

论文：训练循环神经网络的困难之处（On the difficulty of training Recurrent Neural Networks）

###微调（Fine-Tuning）

Fine-Tuning 这种技术是指使用来自另一个任务（例如一个无监督训练网络）的参数初始化网络，然后再基于当前任务更新这些参数。比如，自然语言处理架构通常使用 word2vec 这样的预训练的词向量（word embeddings），然后这些词向量会在训练过程中基于特定的任务（如情感分析）进行更新。

###梯度裁剪（Gradient Clipping）

梯度裁剪是一种在非常深度的网络（通常是循环神经网络）中用于防止梯度爆炸（exploding gradient）的技术。执行梯度裁剪的方法有很多，但常见的一种是当参数矢量的 L2 范数（L2 norm）超过一个特定阈值时对参数矢量的梯度进行标准化，这个特定阈值根据函数：新梯度=梯度*阈值/L2范数（梯度）{new_gradients = gradients * threshold / l2_norm(gradients)}确定。

论文：训练循环神经网络的困难之处（On the difficulty of training Recurrent Neural Networks）

###GloVe

Glove 是一种为话语获取矢量表征（嵌入）的无监督学习算法。GloVe 的使用目的和 word2vec 一样，但 GloVe 具有不同的矢量表征，因为它是在共现（co-occurrence）统计数据上训练的。

论文：GloVe：用于词汇表征（Word Representation）的全局矢量（Global Vector）（GloVe: Global Vectors for Word Representation ）

###GoogleLeNet

GoogleLeNet 是曾赢得了 2014 年 ILSVRC 挑战赛的一种卷积神经网络架构。这种网络使用 Inception 模块（Inception Module）以减少参数和提高网络中计算资源的利用率。

论文：使用卷积获得更深（Going Deeper with Convolutions）

###GRU

GRU（Gated Recurrent Unit：门控循环单元）是一种 LSTM 单元的简化版本，拥有更少的参数。和 LSTM 细胞（LSTM cell）一样，它使用门控机制，通过防止梯度消失问题（vanishing gradient problem）让循环神经网络可以有效学习长程依赖（long-range dependency）。GRU 包含一个复位和更新门，它们可以根据当前时间步骤的新值决定旧记忆中哪些部分需要保留或更新。

论文：为统计机器翻译使用 RNN 编码器-解码器学习短语表征（Learning Phrase Representations using RNN Encoder-Decoder for Statistical Machine Translation）
技术博客：循环神经网络教程，第 4 部分：用 Python 和 Theano 实现 GRU/LSTM RNN（http://www.wildml.com/2015/10/recurrent-neural-network-tutorial-part-4-implementing-a-grulstm-rnn-with-python-and-theano/）

###Highway Layer

Highway Layer　是使用门控机制控制通过层的信息流的一种神经网络层。堆叠多个 Highway Layer 层可让训练非常深的网络成为可能。Highway Layer 的工作原理是通过学习一个选择输入的哪部分通过和哪部分通过一个变换函数（如标准的仿射层）的门控函数来进行学习。Highway Layer 的基本公式是 T * h(x) + (1 - T) * x；其中 T 是学习过的门控函数，取值在 0 到 1 之间；h(x) 是一个任意的输入变换，x 是输入。注意所有这些都必须具有相同的大小。

论文：Highway Networks

###ICML

即国际机器学习大会（International Conference for Machine Learning），一个顶级的机器学习会议。

###ILSVRC

即 ImageNet 大型视觉识别挑战赛（ImageNet Large Scale Visual Recognition Challenge），该比赛用于评估大规模对象检测和图像分类的算法。它是计算机视觉领域最受欢迎的学术挑战赛。过去几年中，深度学习让错误率出现了显著下降，从 30% 降到了不到 5%，在许多分类任务中击败了人类。

###Inception模块（Inception Module）

Inception模块被用在卷积神经网络中，通过堆叠 1×1 卷积的降维（dimensionality reduction）带来更高效的计算和更深度的网络。

论文：使用卷积获得更深（Going Deeper with Convolutions）

###Keras

Kears 是一个基于 Python 的深度学习库，其中包括许多用于深度神经网络的高层次构建模块。它可以运行在 TensorFlow 或 Theano 上。

###LSTM

长短期记忆（Long Short-Term Memory）网络通过使用内存门控机制防止循环神经网络（RNN）中的梯度消失问题（vanishing gradient problem）。使用 LSTM 单元计算 RNN 中的隐藏状态可以帮助该网络有效地传播梯度和学习长程依赖（long-range dependency）。

论文：长短期记忆（LONG SHORT-TERM MEMORY）
技术博客：理解 LSTM 网络（http://colah.github.io/posts/2015-08-Understanding-LSTMs/）
技术博客：循环神经网络教程，第 4 部分：用 Python 和 Theano 实现 GRU/LSTM RNN（http://www.wildml.com/2015/10/recurrent-neural-network-tutorial-part-4-implementing-a-grulstm-rnn-with-python-and-theano/）

###最大池化（Max-Pooling）

池化（Pooling）操作通常被用在卷积神经网络中。一个最大池化层从一块特征中选取最大值。和卷积层一样，池化层也是通过窗口（块）大小和步幅尺寸进行参数化。比如，我们可能在一个 10×10 特征矩阵上以 2 的步幅滑动一个 2×2 的窗口，然后选取每个窗口的 4 个值中的最大值，得到一个 5×5 特征矩阵。池化层通过只保留最突出的信息来减少表征的维度；在这个图像输入的例子中，它们为转译提供了基本的不变性（即使图像偏移了几个像素，仍可选出同样的最大值）。池化层通常被安插在连续卷积层之间。

###MNIST

MNIST数据集可能是最常用的一个图像识别数据集。它包含 60,000 个手写数字的训练样本和 10,000 个测试样本。每一张图像的尺寸为 28×28像素。目前最先进的模型通常能在该测试集中达到 99.5% 或更高的准确度。

###动量（Momentum）

动量是梯度下降算法（Gradient Descent Algorithm）的扩展，可以加速和阻抑参数更新。在实际应用中，在梯度下降更新中包含一个动量项可在深度网络中得到更好的收敛速度（convergence rate）。

论文：通过反向传播（back-propagating error）错误学习表征

###多层感知器（MLP：Multilayer Perceptron）

多层感知器是一种带有多个全连接层的前馈神经网络，这些全连接层使用非线性激活函数（activation function）处理非线性可分的数据。MLP 是多层神经网络或有两层以上的深度神经网络的最基本形式。

###负对数似然（NLL：Negative Log Likelihood）

参见分类交叉熵损失（Categorical Cross-Entropy Loss）。

###神经网络机器翻译（NMT：Neural Machine Translation）

NMT 系统使用神经网络实现语言（如英语和法语）之间的翻译。NMT 系统可以使用双语语料库进行端到端的训练，这有别于需要手工打造特征和开发的传统机器翻译系统。NMT 系统通常使用编码器和解码器循环神经网络实现，它可以分别编码源句和生成目标句。

论文：使用神经网络的序列到序列学习（Sequence to Sequence Learning with Neural Networks）
论文：为统计机器翻译使用 RNN 编码器-解码器学习短语表征（Learning Phrase Representations using RNN Encoder-Decoder for Statistical Machine Translation）

###神经图灵机（NTM：Neural Turing Machine）

NTM 是可以从案例中推导简单算法的神经网络架构。比如，NTM 可以通过案例的输入和输出学习排序算法。NTM 通常学习记忆和注意机制的某些形式以处理程序执行过程中的状态。

论文：神经图灵机（Neural Turing Machines）

###非线性（Nonlinearity）

参见激活函数（Activation Function）。

###噪音对比估计（NCE：noise-contrastive estimation）

噪音对比估计是一种通常被用于训练带有大输出词汇的分类器的采样损失（sampling loss）。在大量的可能的类上计算 softmax 是异常昂贵的。使用 NCE，我们可以将问题降低成二元分类问题，这可以通过训练分类器区别对待取样和「真实」分布以及人工生成的噪声分布来实现。

论文：噪音对比估计：一种用于非标准化统计模型的新估计原理（Noise-contrastive estimation: A new estimation principle for unnormalized statistical models ）
论文：使用噪音对比估计有效地学习词向量（Learning word embeddings efficiently with noise-contrastive estimation）

###池化

参见最大池化（Max-Pooling）或平均池化（Average-Pooling）。

###受限玻尔兹曼机（RBN：Restricted Boltzmann Machine）

RBN 是一种可被解释为一个随机人工神经网络的概率图形模型。RBN 以无监督的形式学习数据的表征。RBN 由可见层和隐藏层以及每一个这些层中的二元神经元的连接所构成。RBN 可以使用对比散度（contrastive divergence）进行有效的训练，这是梯度下降的一种近似。

第六章：动态系统中的信息处理：和谐理论基础
论文：受限玻尔兹曼机简介（An Introduction to Restricted Boltzmann Machines）

###循环神经网络（RNN：Recurrent Neural Network）

RNN 模型通过隐藏状态（或称记忆）连续进行相互作用。它可以使用最多 N 个输入，并产生最多 N 个输出。比如，一个输入序列可能是一个句子，其输出为每个单词的词性标注（part-of-speech tag）（N 到 N）；一个输入可能是一个句子，其输出为该句子的情感分类（N 到 1）；一个输入可能是单个图像，其输出为描述该图像所对应一系列词语（1 到 N）。在每一个时间步骤中，RNN 会基于当前输入和之前的隐藏状态计算新的隐藏状态「记忆」。其中「循环（recurrent）」这个术语来自这个事实：在每一步中都是用了同样的参数，该网络根据不同的输入执行同样的计算。

技术博客：了解 LSTM 网络（http://colah.github.io/posts/2015-08-Understanding-LSTMs/）
技术博客：循环神经网络教程第1部分——介绍 RNN （http://www.wildml.com/2015/09/recurrent-neural-networks-tutorial-part-1-introduction-to-rnns/）

###递归神经网络（Recursive Neural Network）

递归神经网络是循环神经网络的树状结构的一种泛化（generalization）。每一次递归都使用相同的权重。就像 RNN 一样，递归神经网络可以使用向后传播（backpropagation）进行端到端的训练。尽管可以学习树结构以将其用作优化问题的一部分，但递归神经网络通常被用在已有预定义结构的问题中，如自然语言处理的解析树中。

论文：使用递归神经网络解析自然场景和自然语言（Parsing Natural Scenes and Natural Language with Recursive Neural Networks ）

###ReLU

即线性修正单元（Rectified Linear Unit）。ReLU 常在深度神经网络中被用作激活函数。它们的定义是 f(x) = max(0, x) 。ReLU 相对于 tanh 等函数的优势包括它们往往很稀疏（它们的活化可以很容易设置为 0），而且它们受到梯度消失问题的影响也更小。ReLU 主要被用在卷积神经网络中用作激活函数。ReLU 存在几种变体，如Leaky ReLUs、Parametric ReLU (PReLU) 或更为流畅的 softplus近似。

论文：深入研究修正器（Rectifiers）：在 ImageNet 分类上超越人类水平的性能（Delving Deep into Rectifiers: Surpassing Human-Level Performance on ImageNet Classification）
论文：修正非线性改进神经网络声学模型（Rectifier Nonlinearities Improve Neural Network Acoustic Models ）
论文：线性修正单元改进受限玻尔兹曼机（Rectified Linear Units Improve Restricted Boltzmann Machines  ）

###残差网络（ResNet）

深度残差网络（Deep Residual Network）赢得了 2015 年的 ILSVRC 挑战赛。这些网络的工作方式是引入跨层堆栈的快捷连接，让优化器可以学习更「容易」的残差映射（residual mapping）而非更为复杂的原映射（original mapping）。这些快捷连接和 Highway Layer 类似，但它们与数据无关且不会引入额外的参数或训练复杂度。ResNet 在 ImageNet 测试集中实现了 3.57% 的错误率。

论文：用于图像识别的深度残差网络（Deep Residual Learning for Image Recognition）

###RMSProp

RMSProp 是一种基于梯度的优化算法。它与 Adagrad 类似，但引入了一个额外的衰减项抵消 Adagrad 在学习率上的快速下降。

PPT：用于机器学习的神经网络 讲座6a
技术博客：斯坦福CS231n：优化算法（http://cs231n.github.io/neural-networks-3/）
技术博客：梯度下降优化算法概述（http://sebastianruder.com/optimizing-gradient-descent/）

###序列到序列（Seq2Seq）

序列到序列（Sequence-to-Sequence）模型读取一个序列（如一个句子）作为输入，然后产生另一个序列作为输出。它和标准的 RNN 不同；在标准的 RNN 中，输入序列会在网络开始产生任何输出之前被完整地读取。通常而言，Seq2Seq 通过两个分别作为编码器和解码器的 RNN 实现。神经网络机器翻译是一类典型的 Seq2Seq 模型。

论文：使用神经网络的序列到序列学习（Sequence to Sequence Learning with Neural Networks）

###随机梯度下降（SGD：Stochastic Gradient Descent）

随机梯度下降是一种被用在训练阶段学习网络参数的基于梯度的优化算法。梯度通常使用反向传播算法计算。在实际应用中，人们使用微小批量版本的 SGD，其中的参数更新基于批案例而非单个案例进行执行，这能增加计算效率。vanilla SGD 存在许多扩展，包括动量（Momentum）、Adagrad、rmsprop、Adadelta 或 Adam。

论文：用于在线学习和随机优化的自适应次梯度方法（Adaptive Subgradient Methods for Online Learning and Stochastic Optimization）
技术博客：斯坦福CS231n：优化算法（http://cs231n.github.io/neural-networks-3/）
技术博客：梯度下降优化算法概述（http://sebastianruder.com/optimizing-gradient-descent/）

###Softmax

Softmax 函数通常被用于将原始分数（raw score）的矢量转换成用于分类的神经网络的输出层上的类概率（class probability）。它通过对归一化常数（normalization constant）进行指数化和相除运算而对分数进行规范化。如果我们正在处理大量的类，例如机器翻译中的大量词汇，计算归一化常数是很昂贵的。有许多种可以让计算更高效的替代选择，包括分层 Softmax（Hierarchical Softmax）或使用基于取样的损失函数，如 NCE。

###TensorFlow

TensorFlow是一个开源 C ++ / Python 软件库，用于使用数据流图的数值计算，尤其是深度神经网络。它是由谷歌创建的。在设计方面，它最类似于 Theano，但比  Caffe 或 Keras 更低级。

###Theano

Theano 是一个让你可以定义、优化和评估数学表达式的 Python 库。它包含许多用于深度神经网络的构造模块。Theano 是类似于 TensorFlow 的低级别库。更高级别的库包括Keras 和 Caffe。

###梯度弥散问题（Vanishing Gradient Problem）

梯度消失问题出现在使用梯度很小（在 0 到 1 的范围内）的激活函数的非常深的神经网络中，通常是循环神经网络。因为这些小梯度会在反向传播中相乘，它们往往在这些层中传播时「消失」，从而让网络无法学习长程依赖。解决这一问题的常用方法是使用 ReLU 这样的不受小梯度影响的激活函数，或使用明确针对消失梯度问题的架构，如LSTM。这个问题的反面被称为梯度爆炸问题（exploding gradient problem）。

论文：训练循环神经网络的困难之处（On the difficulty of training Recurrent Neural Networks）
参考：http://neuralnetworksanddeeplearning.com/chap5.html#the_vanishing_gradient_problem

###VGG

VGG 是在 2014 年 ImageNet 定位和分类比赛中分别斩获第一和第二位置的卷积神经网络模型。这个 VGG 模型包含 16-19 个权重层，并使用了大小为 3×3 和 1×1 的小型卷积过滤器。

论文：用于大规模图像识别的非常深度的卷积网络（Very Deep Convolutional Networks for Large-Scale Image Recognition）

###word2vec

word2vec 是一种试图通过预测文档中话语的上下文来学习词向量（word embedding）的算法和工具 (https://code.google.com/p/word2vec/)。最终得到的词矢量（word vector）有一些有趣的性质，例如vector('queen') ~= vector('king') - vector('man') + vector('woman') （女王~=国王-男人+女人）。两个不同的目标函数可以用来学习这些嵌入：Skip-Gram 目标函数尝试预测一个词的上下文，CBOW  目标函数则尝试从词上下文预测这个词。

论文：向量空间中词汇表征的有效评估（Efficient Estimation of Word Representations in Vector Space）
论文：分布式词汇和短语表征以及他们的组合性（Distributed Representations of Words and Phrases and their Compositionality）
论文：解释 word2vec 参数学习（word2vec Parameter Learning Explained）
