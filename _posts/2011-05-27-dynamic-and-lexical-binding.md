---
title: 静态绑定和动态绑定
tags: emacs lisp 技术
---

在今年4月1日，Emacs24[合并](http://comments.gmane.org/gmane.emacs.devel/138010)了*lexbind*分支，elisp终于也开始支持*词法绑定*(lexical binding，即静态绑定)了。其实词法绑定对于我们今天的人来说是再熟悉不过了，因为目前多数语言都是词法绑定，包括我们熟悉C、C++、Python、Java等等，这导致*动态绑定*(dynamic binding)现在看起来反而比较奇怪。

所谓绑定([binding](http://en.wikipedia.org/wiki/Name_binding))即变量在运行期的存在，即是变量名字和它的实际内存位置的映射关系。存在，是个时空概念，变量同样有它的作用域([scope](http://en.wikipedia.org/wiki/Scope_(computer_science)))和生存期(extent)。对词法变量而已，它具有词法作用域和不确定的(indefinite)的生存期，这表示一个词法变量只能在一个函数或一个block内存在，它的绑定只在一段代码区域内有效，但从时间上来讲，它可以在任意的时间里持续存在，只是取决于该变量需要使用(reference)多久；而动态变量正好相反，它具有不确定的作用域，这表示一个动态变量可以在任意地方出现，只是取决于你在什么地方绑定它，同时它有着动态(dynamic)的生存期，这表示当绑定该变量的代码执行完毕，该绑定就失效了，也就意味着该变量失效了。这两种截然不同的绑定方式，即被称作静态绑定(lexical binding)和动态绑定(dynamic binding)。

这里介绍一下动态变量和动态绑定，elisp里的变量有三种：全局变量(比如`defvar`)、buffer-local变量(比如`make-local-variable`)和局部变量(比如`let`、`let*`)，前两者的作用域和生存期是伴随着Emacs和buffer全局存在的，采用的是动态绑定的方式。

需要额外说明的是局部变量，局部变量分两种：函数参数和`let`表达式里绑定的变量，由于`let`也可以展开成lambda表达式，所以后者也可以认为是一种函数参数。下边考察一下局部变量的作用域和生存期，看一下info里的一个例子：

    (defun binder (x)   ; `x' is bound in `binder'.
      (foo 5))          ; `foo' is some other function.

    (defun user ()      ; `x' is used "free" in `user'.
      (list x))

如果你只接触过词法绑定的语言，你能想象到函数`user`可以访问函数`binder`的参数`x`吗？这完全不可能嘛。但是在elisp里这却是可能的，如果你定义了这样一个函数：

    (defun foo (lose)
      (user))

当你调用`binder`的时候，`user`是能够访问`x`的，这就是所谓的[不确定的作用域](http://www.gnu.org/software/emacs/elisp/html_node/Scope.html#Scope)，也就是说在任何位置都**可能**访问一个变量名。

再看一个lambda表达式的例子：

    (defun make-add (n)                ; Return a function.
      (function (lambda (m) (+ n m)))) ; => make-add
    (fset 'add2 (make-add 2))          ; Define function `add2'
                                       ; => (lambda (m) (+ n m))
    (add2 4)                           ; Try to add 2 to 4.

这里用lambda定义了一个高阶函数`make-add`，但是很不幸，这段代码无法正确运行，因为elisp里局部变量的生存期是动态的，只有当绑定了这个变量的表达式运行时该绑定才是有效的；当脱离了创建它的环境，它的生命周期也就结束了。所以，当`make-add`函数返回的时候，变量`n`也就同时失效了。这就是所谓的[动态的生存期](http://www.gnu.org/software/emacs/elisp/html_node/Extent.html#Extent)，也就是说绑定只在**运行时**有效。

从上面这个例子也可以看出来，动态的生存期最糟糕的一点，就是不支持闭包。所谓闭包，必须在函数和局部变量之间保持关联，这些局部变量的作用域仅限于函数之内，但它不确定的生存期却可以使其跨越函数的运行边界。确切的说，只要该变量被引用，它就会一直存在，最后，没有引用的变量将被[垃圾回收](http://en.wikipedia.org/wiki/Garbage_collection_(computer_science))。

在目前的release版本里，你只能用一些[辅助办法](http://www.emacswiki.org/emacs/FakeClosures)模拟闭包：

    (defun make-add (n)
      (lexical-let ((nn n))
        #'(lambda (m) (+ m nn))))

`lexical-let`这个辅助函数作用就是把模拟闭包内的局部变量生成一个唯一变量名(`make-symbol`)添加到一个全局列表(`cl-closure-vars`)里去，这样该局部变量的生存期将伴随整个Emacs进程，而且由于是唯一变量名，它也不会在别处绑定，这样看起来该变量就可以脱离函数运行时环境存在了。

而最近被合并的lexbind分支，由于支持了词法绑定，则可以真正提供闭包支持了，具体做法是在文件头声明：

    ;; -*- lexical-binding: t -*-

那么dynamic binding和lexical binding分别有什么应用场景呢？

想象这样一个场景：

    (let ((b (generate-new-buffer-name "*string-output*")))
         (let ((standard-output b))
           (foo))
         (set-buffer b)
         ;; do stuff with the output of foo
         (kill-buffer b))

你生成一个名为 "*string-output*" 的临时buffer，然后你调用foo函数，它会向buffer里输出一些内容，然后你再对输出内容做一些处理。

借助于变量名的动态绑定，你可以直接在`foo`里操作`standard-output`，甚至是在所有`foo`调用的函数里。而在仅支持lexical binding的语言里，你将不得不把`standard-output`作为一个参数传递给`foo`，甚至所有调用的函数。

当然，这样做也有风险。手册[建议](http://www.gnu.org/software/emacs/elisp/html_node/Using-Scoping.html#Using-Scoping)不要滥用动态绑定的能力，否则，最后也许自己都弄不懂你目前修改的这个局部变量引用自哪里，会对哪些函数造成影响了。

在实现方面，动态绑定的缺点很明显，它的[实现](http://www.gnu.org/software/emacs/elisp/html_node/Impl-of-Scope.html#Impl-of-Scope)有两种深绑定(deep binding)和浅绑定(shallow binding)：

- 深绑定在传参的时候绑定变量，变量和值作为一个pair，保存到一个关联数组里。
- 浅绑定在函数被实际调用的时候绑定变量，当前的变量和值对保存在一个cell里，而老的值会push到一个栈里维护。

两种方式都需要维护全局的状态，当进入和脱离作用域的时候，都需要查询这些变量的状态，以确定绑定关系。另外，不确定的作用域对多线程设计和中断设计都增加了复杂度。

而静态绑定的优点却有很多：

- 便于用户书写，因为不用考虑不确定的作用域带来的运行时环境的影响；
- 便于编译器优化，因为变量存在于一个确定的词法上下文，而不用判断更多的可能性；
- 词法作用域在编译期就可以确定的，避免了更多的运行时开销。

所有这些原因，导致了越来越多的现代语言摒弃了动态绑定而转向了静态绑定。
