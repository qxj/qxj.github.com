---
title: WordPress按分类显示blog文章
tags: Web wordpress
---

Wordpress 诞生已久，目前大多独立blog都是用其搭建，但是目前为止我发觉居然没有谁有这样的需求，在主页上按照category显示文章，而不是一股脑的把所有文章全部显示出来。也许对于严谨的bloger来说，一个blog所发表的内容基本都是专注于同一类型的；但是对于像我这样完全不严谨的blogger来说，却经常这天写篇游记，改天又写点技术文字，过些天又贴点照片，结果这样弄下来，blog就乱了套，自己看起来都很别扭。

因此，我觉得如果能够让wordpress在主页上能够按照分类来显示blog，并且建立基于category的导航栏，对于随便写点blog的人来说会比较友好一些。而默认的基于pages的导航，我觉得基本也是个鸡肋。

要完成这个任务比较简单，只需要定制一个theme就可以了。主要是在 header.php 中改categories导航：

```php
<?php
if(is_home()){
    $default_category = "&current_category=1"; //  default category
}else if(is_single() || is_category()){
    $categories = get_the_category();
    if($categories[0]->category_parent){ // wordaround for two level categories
        $curr_cid = $categories[0]->category_parent;
    } else {
        $curr_cid = $categories[0]->cat_ID;
    }
    $default_category = "&current_category=" . $curr_cid;
}else{
    $default_category = "";
}
wp_list_categories('title_li=&depth=1&orderby=slug' . $default_category);
?>
```

另外，为了使得每篇文章下边的[上下篇文章导航连接](http://codex.wordpress.org/Template_Tags/next_post_link) 也更加合理，需要修改一下 single.php，比如：

```php
<?php previous_post_link('%link', '%title', TRUE); ?>
<?php next_post_link('%link', '%title', TRUE); ?>
```

然后，顺便修改一下 index.php，简单的改法是直接重定向到其中一个category，比如：

```php
<?php header("Location: http://blog.erera.net/c/tech"); ?>
```

基本上，这个新的theme就不会再把所有的文章混到一起了。如果需要专门定制category的显示页面，根据wordpress 框架中规定的[模板载入优先级](http://codex.wordpress.org/Category_Templates)，可以增加一个模板文件 category.php，这样会覆盖 archive.php 的设定，优先采用前者作为显示模板。
