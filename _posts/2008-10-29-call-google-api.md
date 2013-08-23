---
title: 用Google API创建主页搜索引擎
tags: google Web
---

[Wordpress](http://wordpress.org)本身的搜索功能不是很强, 虽然也有不少这方便的plugin, 但还是会增加服务器负担. 对Google的主页搜索的印象还停留在n年之前, 想用它也就是个 site:erera.net 之类的功能罢了. 这一不小心刚才就浏览到了[Google Ajax Search API](http://code.google.com/apis/ajaxsearch/), 才知道自己已经相当火星了. 在这个云计算的潮流里, 为了各种应用的mashup, Google已然为用户提供了一系列非常强大的远程调用接口. 于是立即心痒不已, 用 Google API 给主页带来了全新的搜索体验. 现火热分享如下:

由于 Google API 设计得非常简单易用, 而且有一系列的说明事例, 所以使用起来非常容易.

首先, 你要去申请一个 [Google AJAX Search API Key](http://code.google.com/apis/ajaxsearch/signup.html). 申请完之后, 还会给你一个简单sample.

然后...然后你就参考 Google API 给你的sample和reference, 再根据你的网页布局写了..

## 本站示例

下边给出的是本网站的例子, 那就按照wordpress的布局来说明吧. 主要就三个步骤:

1) 在html代码里嵌入两个元素, 分别用来放置 搜索框 和 搜索结果.

- 搜索框: `<div id="searchform"></div>`, 修改 header.php
- 搜索结果: `<div id="searchControl"></div>`, 修改 index.php, single.php 和 pages.php

2) 在 `<header>` 里面插入如下javascript代码, 修改 header.php.

把Google API封装在函数 `SolutionLoad()`, 并且在页面载入的时候调用.

```javascript
<script src="http://www.google.com/jsapi?key=XXXXX" type="text/javascript"></script>
<link href="http://www.google.com/uds/css/gsearch.css" rel="stylesheet" type="text/css"/>
<link href="http://www.google.com/uds/css/gsearch_darkgrey.css" rel="stylesheet" type="text/css"/>

<script language="Javascript" type="text/javascript">
//<![CDATA[
google.load("search","1");
var coreSearch;
function SolutionLoad() {

    var controlRoot = document.getElementById("searchControl");

    // create the search control
    coreSearch = new google.search.SearchControl();
    coreSearch.setLinkTarget(google.search.Search.LINK_TARGET_SELF);
    coreSearch.setResultSetSize(google.search.Search.LARGE_RESULTSET);

    // prep for decoupled search form
    var searchFormElement = document.getElementById("searchform");
    var drawOptions = new google.search.DrawOptions();
    drawOptions.setSearchFormRoot(searchFormElement);
    drawOptions.setDrawMode(google.search.SearchControl.DRAW_MODE_TABBED);

    // populate - web, this blog, all blogs
    var searcher = new google.search.WebSearch();
    searcher.setSiteRestriction("http://erera.net/");
    searcher.setUserDefinedLabel("Freeland");
    coreSearch.addSearcher(searcher);

    searcher = new google.search.WebSearch();
    searcher.setUserDefinedLabel("The Web");
    coreSearch.addSearcher(searcher);

    searcher = new google.search.BlogSearch();
    searcher.setUserDefinedLabel("Blogsphere");
    coreSearch.addSearcher(searcher);

    coreSearch.draw(controlRoot, drawOptions);
}

function doCoreSearch(q) {
    coreSearch.execute(q);
}

function registerLoadHandler(handler) {
    var node = window;
    if (node.addEventListener) {
        node.addEventListener("load", handler, false);
    } else if (node.attachEvent) {
        node.attachEvent("onload", handler);
    } else {
        node['onload'] = handler;
    }
    return true;
}

registerLoadHandler(SolutionLoad);
//]]>
</script>
```

3) 最后调整一下 div 的位置宽度

其中 `.gsc-control` 是生成搜索结果里一个class属性.

```css
#searchform { width : 15em; margin-left : 0.5em; overflow: visible;}
#searchControl { width : 98%; padding : 0 0 1em 5em;}
#searchControl .gsc-control { width : 95%; }
```

Over, enjoy~

## 参考文档

- [Google Ajax Search API Developer Guide](http://code.google.com/apis/ajaxsearch/documentation/)
