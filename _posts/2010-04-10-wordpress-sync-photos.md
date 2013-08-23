---
title: 同步PicasaWeb照片到WordPress
tags: gfw Web wordpress
---

原先为了方便管理照片和备份Blog, 所以都是引用PicasaWeb的外链图片. 不过现在PicasaWeb被盾, 导致Blog里的图片也都看不到了, 被人抱怨. 如果再逐个post去重新链接图片也忒烦人了. 估计wordpress里也没这种插件, 因为只有国人才有这需求 :( 因此自己粗粗的写了一个, 可以直接从PicasaWeb抓取图片到Web服务器. 这样唯一需要的就是Active这个插件, 就可以在blog里重现以前的图片了.

- 自动抓取图片到Web服务器, 替换原来的图片链接 (以前的PicasaWeb是不支持外链的, 必须要嵌套一个 `<a>` 标签, 现在就直接把这个标签去掉了.)
- 使用了`curl_multi_select()`函数, 支持一定的并发, 适用于图片很多的情况.
- 已经抓取过来的图片不会被重新抓取.
- 图片直接使用wp里的附件管理函数保存, 因此可以在wp的后台里查看和管理这些图片.

目前不支持代理服务器, 所以墙内的Web服务器没法使用. 目前只支持PicasaWeb. 插件可以从下边直接下载, 然后保存到 `wp-content/plugins` 目录激活即可. 插件从[这里](http://jqian.googlecode.com/svn/trunk/wordpress/sync-photos.php)下载.

BTW: 写完没预料的一个问题是, Google的爬虫好快啊 , 没过一会发觉自己的图片已经全部被download到服务器上了, 哈哈


主要思路是在加载一个filter到`the_content`, `the_content_rss` 和 `the_excerpt_rss` 这几个和输出相关的hooks上。然后，在filter里利用正则表达式匹配picasaweb相关的链接，并替换成服务器的本地缓存图片的链接。如果本地缓存的图片不存在，则首先从picasaweb上抓取这些图片。这些图片缓存同时可以在wordpress的Media库中进行管理。

这样设计的好处是，使得插件的设计和配置都很简单，不用任何数据库操作；重新部署blog的时候无须关心缓存图片是否缺失；另外，由于是在输出hooks上增加filter，因此不会改写数据库。缺点是如果图片很多，会有较多的IO操作，且图片文件都放在同一目录不能重名。

该插件由于替换了img文件的url，所以可能和[Lightbox 2](http://wordpress.org/extend/plugins/lightbox-2/)之类的有冲突，尚未仔细确认，但应该可以通过调整filter的加载顺序来解决。

`PicasaWeb`类中主要使用 [curl](http://php.net/manual/en/book.curl.php) 库来进行图片抓取。

下边是大致的程序框架：

```php
class PicasaWeb
{
    // 定义正则表达式的匹配模式
	var $pattern = "|(<a\s+href=\"http://picasaweb\.google\.com/[^\"]+\">)?<img\s+src=\"(http://lh[0-9]\.ggpht\.[^\"]+)\"(\s+alt=\"([^\"]*)\")?\s*/?>(</a>)?|si";

	var $url_list = array();
	var $threads = 5;
	var $timeout = 10;             // seconds

    // filter函数
	function sync($content)
    {
        // 1) 正则匹配 picasaweb 图片
		preg_match_all($this->pattern, $content, $match, PREG_SET_ORDER);
        // 2) 查询匹配到的图片是否已经有本地缓存
		$this->fillUrls($match);
        // 3) 爬取没有本地缓存的url
		$this->fetchAllPhotos();
        // 4) 上边都是预备工作，这里对输出文本进行替换
		return preg_replace_callback($this->pattern,
                array(&$this, 'replacePhoto'),
                $content);
	}

    // 爬虫函数，利用 curl_multi_select() 来支持并发抓取，该函数使用 select() 实现IO的多路复用
	// urls = array(url => cache url,
	//              ...)
	function crawlPhotos(&$urls = array(), $threads = 5, $timeout = 30)
    {
		// Urls to download
		$mcurl = curl_multi_init();
		$threadsRunning = 0;
		$urls_id = 0;

		reset($urls); // start again first item
		$url_item = current($urls);
		for(;;) {
			// Fill up the slots
			while($threadsRunning < $threads && $url_item !== FALSE){
				// if not cached, run a curl job
				if(empty($url_item["local"])){
					$this->log("URL item: ". $url_item["url"]);

					$ch = curl_init();
					curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
					curl_setopt($ch, CURLOPT_BINARYTRANSFER, 1);
					curl_setopt($ch, CURLOPT_TIMEOUT, $timeout);
					curl_setopt($ch, CURLOPT_URL, $url_item["url"]);	// url
					curl_multi_add_handle($mcurl, $ch);
					$threadsRunning++;
				}

				$url_item = next($urls);
			}
			// Check if done
			if ($threadsRunning == 0 && $url_item === FALSE)
				break;
			// Let mcurl do it's thing
			curl_multi_select($mcurl);
			while(($mcRes = curl_multi_exec($mcurl, $mcActive)) == CURLM_CALL_MULTI_PERFORM) usleep(100000);
			if($mcRes != CURLM_OK) break;
			while($done = curl_multi_info_read($mcurl)) {
				$ch = $done['handle'];
				$done_url = curl_getinfo($ch, CURLINFO_EFFECTIVE_URL);
				$done_content = curl_multi_getcontent($ch);
				if(curl_errno($ch) == 0) {
					$urls[$this->checksum($done_url)]["local"] = $this->storePhotoToCache($done_content, $done_url);
					$this->log("Succeed to cache url: ".$done_url);
				} else {
					$this->log("Link <a href='$done_url'>$done_url</a> failed: ".curl_error($ch)."\n");
				}
				curl_multi_remove_handle($mcurl, $ch);
				curl_close($ch);
				$threadsRunning--;
			}
		}
		curl_multi_close($mcurl);
		$this->log( 'Done.' );
	}

	// 利用wordpress的attachment相关函数来操作图片缓存，这些图片则都可以保存
    // 到wordpress的Media库中，你可以从后台进行管理。
	function storePhotoToCache($content, $url)
    {
		$filename = $this->fileName($url);
		$title = $this->url_list[$this->checksum($url)]["alt"];
		// wp_upload_bits() 返回 array( 'file' => $new_file, 'url' => $url, 'error' => false );
		$newfile = $this->wp_upload_bits($filename, $content);

		$filepath = $newfile["file"];
		$filetype = wp_check_filetype($filepath);
		$photo = array(
                       "post_title" => $title,
                       "post_content" => $filename,
                       "post_status" => "inherit",
                       "post_parent" => 0,
                       "post_mime_type" => $filetype["type"],
                       "guid" => $newfile["url"]);
		$postid = wp_insert_attachment($photo, $filepath);
		if( !is_wp_error($postid)){
			wp_update_attachment_metadata( $postid, wp_generate_attachment_metadata( $postid, $filepath ) );
		}
		// TODO: convert local path to url
		return $newfile["url"];
	}

	function wp_upload_dir()
    {
        // Hack了 wordpress 的 wp_upload_dir()，让它不再根据时间来创建目录，因为现在
        // 所有的图片都放到同一个目录之下。
	}

	function wp_upload_bits( $name, $bits)
    {
        // Hack了 wordpress 的 wp_upload_bits()，省略了两个无用的参数。
	}
}
```
