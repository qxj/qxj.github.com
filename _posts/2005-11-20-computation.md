---
title: 计算理论的一些基础知识
tags: 技术
---

## Lambda calculus

Lambda演算由数学家邱齐(Alonzo Church)发明，其基本语法(BNF)：

    <expr> ::= <identifier>
    <expr> ::= lambda <identifier-list>. <expr>
    <expr> ::= (<expr> <expr>)

前两条语法用于生成lambda表达式（lambda函数），如：

    lambda x y. x + y

函数定义出来了，怎么使用呢？最后一条规则就是用来调用一个lambda函数的：

    ((lambda x y. x + y) 2 3)

- α-变换公理：例如，`lambda x y. x + y` 转换为 `lambda a b. a + b`。α公理是关于函数定义的，即函数的参数名可以随意变换。
- β-规约公理：例如，`(lambda x y. x + y) 2 3`转换为`2 + 3`。β公理是关于函数调用的，即实参替换调用函数的形参。

### Y combinator

Y组合子的最大（唯一？）作用就是使得 lambda 表达式不需要名字（就能表达递归）。

Y combinator 是一种  Fixed-point combinator，即不动点组合子。

不动点组合子是一种**高阶函数**，设该函数`y`有这样的特性： `y f = f (y f)`，即作用到任意函数`f`上，能返回自身（不动点）。

假设 `x = y f`，则可以得到不动点： `x = y f = f (y f) = f x`

Y combinator 是 Curry 找到的一种不动点组合子，用于实现[Curry悖论](https://en.wikipedia.org/wiki/Curry%27s_paradox)：

    Y = λf.(λx.f(x x))(λx.f(x x))


### 解决lambda的递归问题

不动点：对函数F来说不动点x是这样一个点，F(x)=x，即不动点x在F的作用下是不变的。

Y-Combinator 可以算出lambda表达式的不动点。

    Y(F)=F(Y(F))       即得到函数F的不动点Y(F)

    let Y = lambda F.
        let f_gen = lambda self. F(self(self))
        return f_gen(f_gen)

用Javascript实现的Y：

    function Y(f){
        g = function(h){
            return function(x){
                return f(h(h))(x);
            }
        }
        return g(g);
    }

## 图灵机

解决希尔伯特第十问题，定义[可计算](https://www.wikipedia.com/wiki/Computability_theory)。

图灵机和lambda演算的计算能力等价，能够计算一切可计算问题。

证明方法：首先由Kleene范式定理得到递归函数和图灵机等价，然后把递归函数归约到lambda演算（这很显然，直接模拟即可），最后把lambda演算归约到图灵机（这更显然）。

## 哥德尔不完备定理

定理证明参考《皇帝新脑》P122

编码，程序即数据

可数无穷 vs 不可数无穷， 连续统

对角线方法

反证法：[康托尔、哥德尔、图灵——永恒的金色对角线](http://mindhacks.cn/2006/10/15/cantor-godel-turing-an-eternal-golden-diagonal/)

[图灵停机问题](https://mzhq1982.wordpress.com/2006/11/16/%E5%9B%BE%E7%81%B5%E6%9C%BA%E5%81%9C%E6%9C%BA%E9%97%AE%E9%A2%98%EF%BC%88%E4%B8%8D%E5%8F%AF%E5%88%A4%E5%AE%9A%E9%97%AE%E9%A2%98%E4%B9%8B%E4%B8%80%EF%BC%89/)：不可判定问题之一

## 参考

- THAT ABOUT WRAPS IT UP, BRUCE J. MCADAM, 1997 [函数不动点在编程中的应用](http://www.lfcs.inf.ed.ac.uk/reports/97/ECS-LFCS-97-375/ECS-LFCS-97-375.pdf)
- [Lambda算子5b：How of Y](http://blog.csdn.net/g9yuayon/article/details/1271319)
- [王垠解释Y组合子的幻灯片](http://www.slideshare.net/yinwang0/reinventing-the-ycombinator)
