---
title: "[译]Joomla的MVC组件设计入门"
tags: php Web
---

译注:这两天在家闲坐无事,摆弄一些CMS系统,发觉这篇从模式设计的角度来讲解 Joomla的文章不错.因为我的php最早是从看phpbb源码学习过来的,并没有上升到软件工程的高度.而现在好多系统设计精妙, 比如drupal,wordpress和joomla,还是蕴含很多道理在里边的. 遂翻译了一下,提供给国内有相同需求的php玩家:) 原文似乎回复不多,作者蛮不爽 lol.

[原文链接](http://joomlaequipment.com/content/view/47/74/)

## 什么是MVC
模型视图控制器(Model-view-controller,[MVC](http://www.enode.com/x/markup/tutorial/mvc.html))是一种软件工程中使用的经典设计模式.在用来表现大量数据的复杂计算机应用中,人们希望可以分离数据(model)和相关的用户界面(view),以便于改变用户界面的时候不影响数据处理逻辑,或者改变数据的时候也不需要修改用户界面.MVC通过一个中间层,也就是所谓的控制器 (controller),来分离数据访问业务逻辑部分与表现数据的用户界面部分,从而解决了这个问题.通常使用的时候,MVC分解一个应用程序为三个层次:表现层(UI),域和数据访问.在表现层又进一步分离成为视图和控制器.对一个应用来说,MVC比一般的设计模式更加关注该应用的体系结构.

- *模型(model)*  该应用所操作的相关信息.在Joomla中,是指MySQL数据表.Joomla模型类基本包含表设计,以前是mosTable,现在是josTable.
- *视图(view)*  把模型转化成一种适合用户交互的形式,一般是某种用户界面元素.在 Joomla中,是指视图类的集合以及一个或多个web模板.
- *控制器(controller)*  针对事件的回应和过程,一般是用户动作,可以引起模型的改变.在Joomla中,一般是触发器任务,你唯一需要做的是在控制器类中创建与任务同名的方法函数.

## Joomla MVC工作如下

- 用户访问组件(不包括任何任务或者控制器变量)
- 构建默认控制类, 然后控制器调用默认视图,并且进行web显示.
- 用户点击来进行任务控制.一种控制需要在URL中包含相应任务名和控制器变量,  或者只有任务名.(例如: `index.php?option=com_mvc&controller=books&task=view`)
- 该控制器通过后,Joomla继续寻找新的控制器文件并且构建它,然后再调用响应的任务.

## 文件结构解释

- Component
    - Controllers
    	- Controller1.php
    	- Controller2.php
	- Views
        - View1
            - Tmpl
                - View1.php
                - View2.php
            - View.html.php
        - View2
            - Tmpl
                - View1.php
                - View2.php
            - View.html.php
    - Models
        - Model1.php
        - Model2.php
    - Admin.component.php
    - Controller.php

控制器目录包含控制器类.比如一个图书馆,就有书籍类别控制器,书籍控制器,书籍出版社控制器等等.

模型目录包含模型类.一个模型类对应于一个数据表.

视图目录包含视图类和模板.每个视图类可能有好多模板,分别保存在tmpl目录.每个试图类有相同名字 view.html.php .同时tmpl目录包含html模板文件. admin.component.php 是一个组件加载文件,而 controller.php 是默认的控制器文件.接下来,我们创建一个最简单的MVC组件.

## 创建一个叫mvc的组件

我们创建的组件可以从[这里](http://joomlaequipment.com/component/option,com_docman/task,cat_view/gid,24/Itemid,11/)下载。

- 创建目录 `administrator/components/com_mvc`.
- 创建文件  `administrator/components/com_mvc/admin.mvc.php`.这是标准的Joomla文件,它将被加载用来访问mvc组件.

        <?php
        defined( '_JEXEC' ) or die( 'Restricted access' );
        require_once (JPATH_COMPONENT.DS.'controller.php');
        if($controller = JRequest::getVar('controller')) {
        			   require_once (JPATH_COMPONENT.DS.'controllers'.DS.$controller.'.php');
        }
        $classname   = 'MvcController'.ucfirst($controller);
        $controller   = new $classname( );

        $controller->execute( JRequest::getVar('task'));
        $controller->redirect();
        ?>

第2行用来保护该文件不被直接访问.第4行包含默认控制器类.无论GET/POST变量有没有被设置,这个控制器将被调用.第6-8行包含另外一个控制器类,如果GET/POST 变量被设置,则会调用该控制器.第10-11行创建了一个新的控制器类.第13-14行根据任务值(task的值)执行控制器,并显示页面.

- 创建文件 `administrator/components/com_mvc/controller.php`. 这个控制器中的第 4行包含 admin.mvc.php. 如果没有任何GET/POST控制器变量,这个控制器将被加载.

        <?php
        jimport('joomla.application.component.controller');

        class MvcController extends JController {
        	function display() {
        		parent::display();
        	}
        }
        ?>

第二行包含Joomla API控制器类,用来扩展第4行的新类.函数display产生默认视图,这在后边将会讨论到.

基本上我们就只需要这些了.如果不用 `parent::display();`,而是 `echo "test this";`, 我们将在组件的主页面看到这些文字.但是如果要创建一个完备的MVC 组件,这样我们还需要为这个控制器创建视图.默认视图应该有和组件相同的名字.

- 创建目录 `administrator/components/com_mvc/views`.
- 创建目录 `administrator/components/com_mvc/views/mvc`. 为了创建默认视图,我们命名该目录和控制器相同的名字.
- 创建文件 `administrator/components/com_mvc/view/mvc/view.html.php`. 该文件将包含一个视图类.在这个文件中,我们不用 "mvc" 这样的字样.每个视图类有不同的目录,但有相同的名字,都叫 view.html.php.

        <?php
        jimport( 'joomla.application.component.view');

        class MvcViewMvc extends JView {
        	function display($tpl = null) {
        		JMenuBar::title( JText::_( 'MVC Main' ), 'generic.png' );
        		parent::display($tpl);
        	}
        }
        ?>

第2行,我们包行了joomla API视图类,用来扩展第3行中的新类.第5-10行创建函数 `display()`.如果没有任务被指定,该函数将被 MvcController 控制器类默认调用.我使用 `JMenuBar::title()` 来显示标题.这里你也可以使用其他 JMenuBar 方法.同样的,这里你也可以进行数据库检索和分析显示HTML元素等.请注意一下视图和控制器的区别.在视图类中,我们使用模型(也即是数据表)和SQL检索来或许信息,并创建HTML元素.但是在控制器中,我们只是进行SQL检索和对模型进行控制操作.比如删除,保存,发布等.

- 创建文件 `administrator/components/com_mvc/view/mvc/tmpl/default.php`.

        <h1>MVC Main</h1>
        <a href="index.php?option=com_mvc&amp;controller=list">List something</a>

这是个HTML文档.这个模板用来显示H1头并且链接到另外一个控制器.这就是一个最小的MVC组件.现在我们只是缺少模型而已.请保存所有的文件,并且尝试调用你的新组件.登录到Joomla管理台,把地址`/?index.php?option=com_mvc`放入地址栏.在你继续之前,请确认所有的代码工作正常.下边的所有内容只是解释一些遗留问题:怎样在一个控制器中控制不同的任务和不同的视图.对于这些,下边我们增加控制器list.第一个控制器链接示例没有任务,直接调用默认视图,下边我们创建一些有任务的控制器链接来调用其他视图.

- 让我们想象一下,我们点击链接 `index.php?option=com_mvc&controller=list`. 这意味着我们激活了 `admin.mvc.php` 中的如下代码.

        if($controller = JRequest::getVar('controller')) {
        			   require_once (JPATH_COMPONENT.DS.'controllers'.DS.$controller.'.php');
        }

这意味着我们需要创建文件 `administrator/components/com_mvc/controllers/list.php`.

- 创建list.php如下:

        <?php
        jimport('joomla.application.component.controller');

        class MvcControllerList extends JController {
        	function __construct() {
        		parent::__construct();
        	}
        	function display() {
        		JRequest::setVar('view', 'list');
        		parent::display();
        	}
        }
        ?>

`JRequest::setVar('view', 'list');` 说明这个控制器将在 views/list 目录寻找相应视图.如果我们跳过或者删除改行,这个控制器将在 views/mvc 这个默认目录中寻找视图. 所以如果我们告诉了控制器在 list 目录寻找视图,那我们需要创建该视图.

- 创建目录 `administrator/components/com_mvc/view/list`.
- 创建目录 `administrator/components/com_mvc/view/list/tmpl`.
- 创建文件 `administrator/components/com_mvc/view/list/view.html.php`.

        <?php
        jimport( 'joomla.application.component.view');

        class MvcViewList extends JView {
        	function display($tpl = null) {
        		JMenuBar::title( JText::_( 'List' ), 'generic.png' );
        		parent::display($tpl);
        	}
        }
        ?>

这个文件与上边的 views/mvc/view.html.php 文件类似,只是类名不同,具体将不做解释.

- 创建文件 `administrator/components/com_mvc/view/list/tmpl/default.php`.

        <a href="http://shokn.com/wordpress/wp-admin/index.php?option=com_mvc&amp;controller=list&amp;task=new_task"></a><h1>This is Default.php</h1>
        <P>This file launch automatically is nothing
        passed to JRequest::setVar('layout', 'something');</P>
        <a href="index.php?option=com_mvc&amp;controller=list&amp;task=test">
        test</a><BR>
        <a href="index.php?option=com_mvc&amp;controller=list&amp;task=new_task">
        new_task</a><BR>

- 这样,新的控制器将可以工作了.我的意思是,这里列出了控制器的清单,你将很容易的找到他们 :)这个文件将显示一些链接,它们在同一个控制器下执行不同的任务.你操作他们的办法就是,开始一个 `task=new_task` 这样的字符串.
- 在文件 controllers/list.php 创建函数 new_task.

        <?php
        jimport('joomla.application.component.controller');
        class MvcControllerList extends JController {
        	function __construct() {
        		parent::__construct();
        	}
        	function display() {
        		JRequest::setVar('view', 'list');
        		parent::display();
        	}
        	function new_task() {
        		JRequest::setVar('view', 'list');
        		JRequest::setVar('layout','newtask');
        		parent::display();
        	}
        }
        ?>

我们在第13-18行创建函数 `new_task()`, 当GET/POST变量 task 等于 new_task 的时候它将被调用. `JRequest::setVar('view', 'list');` 告诉控制器在目录 views/list 中寻找视图. `JRequest::setVar('layout','newtask');` 告诉控制器视图应该显示 newtask 模板或者就是 newtask.php. 下边我们创建它.

- 创建文件 `administrator/components/com_mvc/view/list/tmpl/newtask.php`.

        <h1>This is new task</h1>
        <P>This task1, task2, new_task triger the same function </P>
        <a href="index.php?option=com_mvc&controller=list">Go back</a>

这个文件显示了一些文字和退回到控制器主页的链接.保存所有文件,并测试.尝试到控制器主页并点击new_task链接.如果你看到上边列出的文字.恭喜你.你已经创建了一个新任务.

- 还有一点需要知道的是,我们有可能会在在不同的任务中调用相同的方法.例如,增加 $this->registerTask( 'test' , 'new_task' );` 到文件 controllers/list.php 中的构造函数.

        <?php
        jimport('joomla.application.component.controller');

        class MvcControllerList extends JController {
        	function __construct() {
        		parent::__construct();
        		$this->registerTask( 'test' , 'new_task' );
        	}
        	function display() {
        		JRequest::setVar('view', 'list');
        		parent::display();
        	}
        	function new_task() {
        		JRequest::setVar('view', 'list');
        		JRequest::setVar('layout','newtask');
        		parent::display();
        	}
        }
        ?>

保存所有文件,现在尝试点击控制器主页上的测试链接.

- 以后,我将会写一个课程,关于如何使用模型,并创建一个简单的留言簿组件.
