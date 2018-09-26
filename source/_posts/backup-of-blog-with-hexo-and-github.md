---
title: Hexo+Github博客备份方法
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - git
date: 2016-08-10 21:16:48
categories: Git
---

使用hexo+github搭建的博客,博客作为一个单独的github仓库存在,可是仓库中不包含你每篇博客的源文件。如果你换了一台机器想要更新博客或者想重新发布以前的博客,这就不好办了。我这里推荐一种云端备份的方法。

----------
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

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
