---
title: Hexo+Github博客备份方法
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - git
  - hexo
  - blog
categories: 博客建站
abbrlink: 6583
date: 2016-08-10 21:16:48
---

使用hexo+github搭建的博客,博客作为一个单独的github仓库存在,可是仓库中不包含你每篇博客的源文件。如果你换了一台机器想要更新博客或者想重新发布以前的博客,这就不好办了。我这里推荐一种云端备份的方法。

<!--more-->

## How
- 首先,在你博客的仓库中新开一个分支,作为backup(master为博客的推送分支),并且设为默认分支。
- 将远程仓库获取到本地(两个仓库都需要获取)。
- 每次写完博客之前,需要先获取更新:
```
$ git pull
```
- 写完后,对backup分支进行备份:
```
$ git add .
$ git commit -m "message"
$ git push
```
- 然后更新博客到master分支:
```
$ hexo n "postName" # hexo new 新建文章
$ hexo g # hexo generate 生成静态页面至public目录
$ hexo s # hexo server 开启预览访问端口（默认端口4000，'ctrl + c'关闭server）
$ hexo d # hexo deploy #将.deploy目录部署到GitHub
$ hexo clean
```
- 最后将master分支的修改获取到本地:
```
$ git pull
```
