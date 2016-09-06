---
title: Shell脚本清空文件的几种方法
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - script
date: 2016-09-05 11:35:14
categories: Linux
---

本文将介绍几种在Linux下清空文件的方法。

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

$
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
$

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
$
```

> ``/dev/null``可以看作一个"黑洞"。所有写入它的内容都会丢失。从它那儿读取也什么都读不到。这里被清空的文件同样不再有空行，实现真正意义的清空。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
