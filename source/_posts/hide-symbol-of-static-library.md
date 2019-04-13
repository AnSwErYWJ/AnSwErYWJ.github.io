---
title: 屏蔽静态库接口
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - hidden
  - objcopy
date: 2019-04-13 14:43:13
categories: Compile
---

分享屏蔽静态库接口的一种方法.
<!--more-->

## 准备
`hello.c`:
```
#include <stdio.h>

void hello() {
	printf("Hello World!\n");
}
```
`hello.h`:
```
#ifndef __HELLO__H
#define __HELLO__H

#ifdef __cplusplus
extern "C" {
#endif

void hello();

#ifdef __cplusplus
}
#endif

#endif
```
`test.h`:
```
```


## Reference

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。