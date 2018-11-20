> bundle exec jekyll serve

## Jekyll优点

Github Pages原生支持Jekyll，包括若干plugins：https://pages.github.com/versions/ 。
可以直接在repo里保存markdown文件，并且可以用 [prose.io](http://prose.io) 这样的工具在线编辑。
而Hexo等需要把markdown离线转成html保存到repo，不够优雅。

Jekyll短板是在 liquid 模版，非常难用。

理解Jekyll的核心是[Front matter](https://jekyllrb.com/docs/frontmatter/)，Jekyll的处理逻辑很简单：

1. 带有front matter的文件会被jekyll重新render成为HTML文件；
2. 其他所有文件直接作为static文件。

## Github Pages

部署到Github Pages：https://jekyllrb.com/docs/github-pages/

有两种部署方式：

- **user/org page** `master` branch，`xxx.github.io` repo，部署在 `xxx.github.io`
- **project page** `gh-pages` branch 或者 `master` branch的 `doc` 目录，任意 repo，部署在 `xxx.github.io/project`

对project page有个trick：任意repo只要是在通过定制front matter或者`_config.yml`都可以部署到 `xxx.github.io` 上，例如：https://github.com/george-hawkins/basic-gfm-jekyll/blob/gh-pages/_config.yml

## Jekyll本地部署

https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/

Definition List

```
Definition
: Description
```

### tags支持

借助`jekyll_archives`插件

1. `_config.yml`


    ```
    jekyll-archives:
      enabled:
        -tags
      layout:'tag'
      permalinks:
        tag:'/tag/:name/'
    ```

2. `_layout`里添加 `tag.html`

参考：https://github.com/jekyll/jekyll-archives/blob/master/docs/layouts.md#tag-and-category-layout


## Markdown

https://help.github.com/articles/basic-writing-and-formatting-syntax/

### Mathjax渲染错误

关于嵌入Mathjax的Markdown渲染错误，包括HTML也会有这个问题。
https://github.com/mathjax/MathJax/issues/830#issuecomment-44508685

特殊符号：

- 字符 `|` 会被kramdown当作table符号，可以用 `\vert` 替代
- 符号 `{` 会被liquid当作模版，可以用 `\lbrace` 和 `\brace` 替代

【注】以上可以定义为宏，减少输入，参考`\Abs`和`\brace`宏。

不过如果用kramdown原生支持mathjax应该不会有这个问题，但 inline match也必须用 `$$` 才能正确识别，数学公式会包上script标签，例如：

```
<script type="math/tex; mode=display">a^2 + b^2 = c^2</script>
```

参考：https://jekyllrb.com/docs/extras/#math-support
