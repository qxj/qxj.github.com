---
title: 《深度学习》读书笔记
tags: DeepLearning
---

《[Deep Learning](http://www.deeplearningbook.org/)》Ian Goodfellow, Yoshua Bengio, Aaron Courville


## 3.8 期望、方差和协方差

独立变量和不相关变量：协方差为0，表示两变量不相关（没有线性关系）；但不一定互相独立（可能存在非线性关系）。

## 5.2 容量、拟合、过拟合

没有免费的午餐定理（no free lunch） 没有普遍优越的机器学习算法。

一个看似优越的算法都是在我们根据观察到的数据所给出相应假设的基础上。

## 6.4 结构设计

通用近似定理（universal approximation theorem） 前馈神经网络可以任意精度来近似任何一个有限维空间到另一个有限维空间的Borel可测函数。

这是使用神经网络表达非线性函数的理论基础。当然这只是理论，实际上最坏的情况下，可能需要指数数量的隐含单元。

深层模型比浅层模型的优势：大幅减少隐含单元的数量，提升模型的泛化能力（图6.6）。
