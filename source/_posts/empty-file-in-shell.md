---
title: Shell脚本清空文件的几种方法
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - script
categories: Shell脚本
abbrlink: 64265
date: 2016-09-05 11:35:14
---

本文将介绍几种在Linux下清空文件的方法。

<!--more-->

## Plan A
代码 :
```
	#!/bin/bash
	echo "" > $1
	echo "$1 is cleaned up."
```
运行结果 :
```
$ cat test.txt
1
2
3
4
5
$ ./plana.sh test.txt
test.txt cleaned up.
$ cat test.txt


```

>使用这个方法文件其实并没有真正被清空，而是有一个空行。

## Plan B
代码 :
```
	#!/bin/bash
	: > $1
	echo "$1 is cleaned up."
```

运行结果 :
```
$ cat test.txt
1
2
3
4
5
$ ./planb.sh test.txt
test.txt is cleaned up.
$ cat test.txt


```

> ``：``是一个空命令，起到占位符的作用。这里被清空的文件不再有空行，实现真正意义的清空。

## Plan C
代码 :
```
	#!/bin/bash
	cat /dev/null > $1
	echo "$1 is cleaned up."
```
运行结果 :
```
$ cat test.txt
1
2
3
4
5
$ ./planc.sh test.txt
test.txt is cleaned up.
$ cat test.txt

```

> ``/dev/null``可以看作一个"黑洞"。所有写入它的内容都会丢失。从它那儿读取也什么都读不到。这里被清空的文件同样不再有空行，实现真正意义的清空。

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)