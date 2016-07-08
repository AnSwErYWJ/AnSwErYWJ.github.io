---
title: Git实用命令补充
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2016-07-08 15:28:12
categories: git
tags:
---


# Git实用命令补充
这是对[廖雪峰老师的git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)的一个补充,增加了一些实用却很少被提及的命令.如果你是初学者,建议先阅读廖雪峰老师的git教程.

[TOC]


## ssh连接检查
git支持https和ssh等协议.https除了速度慢以外，还有个最大的麻烦是每次推送都必须输入口令,而ssh支持的原生git协议速度最快.
当ssh配置完成后,再次检查ssh连接情况:
```
ssh -T git@github.com
```
如果看到如下所示，则表示添加成功:
```
Hi! You’ve successfully authenticated, but GitHub does not provide shell access.
```

## git commit 信息
在这里,我强烈建议一定要写git commit 信息.这里给大家推荐一篇文章,[写好 Git Commit 信息的 7 个建议](http://blog.jobbole.com/92713/)([英文版](http://chris.beams.io/posts/git-commit/)).

## 远程分支清理
当你使用`git branch -a`查看全部分支时,有可能会发现一些以前开发时残留的远程分支,可以使用如下命令进行清除:
```
git remote prune origin
```

## .gitignore无效解决
当你在项目开发过程中,突然想把一些文件加入到.gitignore规则中,可是却发现不起作用.那是因为.gitignore只忽略那些原来没有被track的文件，如果某些文件已经被纳入了版本管理中，则修改.gitignore是无效的。解决方法就是先把本地缓存删除（改变成未track状态:
```
git rm -r --cached .
```

## 配置可视化diff和merge工具
在Linux下推荐使用meld工具:
```
$ git config --global diff.tool meld
$ git config --global merge.tool meld
```
然后就可以使用工具查看了:
```
$ git difftool XXX
$ git mergetool XXX
```

## 自定义配置git
先谈谈`git config`的作用域,一共有三个:
1. --system :作用于当前系统的所有用户,配置文件目录为`/etc/gitconfig`.
2. --global :作用于当前用户,配置文件目录为`~/.gitconfig`.
3. --local : 作用于当前仓库,配置文件目录为`repo/.git/config`,缺省可以省略该参数,优先级最高.

使命令输出和文件显示看起来更醒目,有不同颜色区别:
```
$ git config --global color.ui true
```

查看已有的配置信息:
```
git config --list
```
可以通过设置作用域,查看不同作用域的信息.


## 处理大型二进制文件
由于git在存储二进制文件时效率不高,所以需要借助第三方组件,[这里](http://www.oschina.net/news/71365/git-annex-lfs-bigfiles-fat-media-bigstore-sym)介绍了几种处理大型二进制文件的组件.

## 其它
这里推荐一份阮一峰老师整理的[常用 Git 命令清单](http://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html).
最后给大家推荐一本Git Book,可以从网上免费[获取](https://git-scm.com/book/en/v2).

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- WebSite：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com]()
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。

