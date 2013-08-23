#!/usr/bin/env bash
#
# Copyright (C) 2013 Julian Qian
#
# @file      list_images.sh
# @author    Julian Qian <junist@gmail.com>
# @created   2013-05-02 17:21:47
#

# 获取输入目录下markdown文件里的所有图片名
# 处理格式：![](/path/to/jpg)

prefix='http://image.jqian.net/'

dir=$1
if [[ -z $dir ]]; then
    echo "Missing _posts directory"
    exit 1
fi

for f in $(find $dir -iname "*.md" -type f); do
    for img in $(grep -oE "${prefix}([^\)]+)" $f); do
        echo ${img:${#prefix}}
    done
done
