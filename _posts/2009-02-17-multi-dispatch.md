---
title: C++ Multi-dispatch方法
tags: c++ Programming
---

Dispatch是运行时多态，是latter-binding技术。

Multi-Dispatch就是在一个函数调用里同时有多个变量类型需要在运行时确定。

C++、Java等这些OOP风格语言仅支持Single-Dispatch（虚函数），考虑虚函数运行时的动态绑定（RTTI），实际上是由调用函数的对象所决定的（即调用`->`或`.`之前的那个对象）。如果要支持Double-Dispatch或Multi-Dispatch，则需要由调用的对象类型+参数类型一起决定，甚至全部由参数类型决定（全局函数）。

关于C++的Multi-Dispatch参考BS的这篇论文《[Open Multi-Methods for C++](http://www.stroustrup.com/multimethods.pdf)》。


看一个实际的例子。

假设：不同级别的销售卖不同级别的车会有不同的策略或价格，这里有SalesA, SalesB, CarA, CarB。

对于支持multi-dispatch的Common Lisp来说，解决这个问题就很trivial，四个函数搞定。

```lisp
(defmethod strategy ((x SalesA) (y CarA)) ... )
(defmethod strategy ((x SalesA) (y CarB)) ... )
(defmethod strategy ((x SalesB) (y CarA)) ... )
(defmethod strategy ((x SalesB) (y CarB)) ... )
```

但对于single-dispatch的C++来说，这样做是不行的：

```c++
struct Sales;
struct SalesA: public Sales {...};
struct SalesB: public Sales {...};
struct Car;
struct CarA: public Car {...};
struct CarB: public Car {...};

Sales& s = ...;
Car& c= ...;
s.strategy(c);    // 因为s和c这两个变量类型都是运行时才能确定，所以直接double-dispatch是行不通的。
```

解决办法有几种：

1. 利用`dynamic_cast`，搭配条件判断进行dispatch。
2. 利用`typeid`函数，搭配条件判断进行dispatch。
3. 把multi-dispatch转换成多次single-dispatch（虚函数）解决。比如visitor模式。


```c++
// 解决问题：不同级别的销售卖不同级别的车会有不同的策略或价格，这里有SalesA, SalesB, CarA, CarB。

// 比如，这里有销售SalesA和SalesB，车型CarA和CarB，因为涉及到两种类型的动态绑定，
// 是double-dispatch问题，所以没法用虚函数（single-dispatch）一次解决，而需要在确
// 定两种动态类型的地方各借助虚函数把double-dispath转换成两次single-dispatch来解
// 决。

#include <iostream>

struct Sales;
struct SalesA;
struct SalesB;

struct Car {
  // visitor模式的缺陷，需要显式处理所有的Sales情况，这导致添加新的节点会比较麻烦，
  // 需要重新编译代码。
  virtual void visit(SalesA&) = 0;
  virtual void visit(SalesB&) = 0;
};

struct CarA: public Car {
  virtual void visit(SalesA&) {
    std::cout << "Sales A -> Car A\n";
  }
  virtual void visit(SalesB&) {
    std::cout << "Sales B -> Car A\n";
  }
};

struct CarB: public Car {
  virtual void visit(SalesA&) {
    std::cout << "Sales A -> Car B\n";
  }
  virtual void visit(SalesB&) {
    std::cout << "Sales B -> Car B\n";
  }
};

struct Sales {
  virtual void accept(Car& v) = 0;
};

struct SalesA: public Sales {
  virtual void accept(Car& v) {
    // 这是一个技巧，把自己的运行时状态传递出去。
    v.visit(*this);
  }
};

struct SalesB: public Sales {
  virtual void accept(Car& v) {
    v.visit(*this);
  }
};

int main(int argc, char *argv[]) {
  SalesA a;
  CarB b;
  Sales &s = a;
  Car &c = b;
  // Sales和Car的类型都是在运行时确定的，一个是调用对象的类型，一个是参数类型，所
  // 以称作double-dispatch。
  s.accept(c);
  return 0;
}
```
