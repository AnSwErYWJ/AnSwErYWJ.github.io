---
title: GCC编译ARM篇
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2017-08-04 16:30:40
categories: Linux
tags: IO
---

`ARM` 平台下`GCC`编译相关介绍，待补充
<!--more-->

## ARM处理器架构
`ARM`处理器架构，通过选项`-march`指定，如`-march=armv7-a`，目前常见的有`armv5te`，` armv6`和`armv7-a`等

## 指令集
指令集，通过选项`-m`指定，如`-mthumb`，常见的有
1. `thumb`
16位指令集，它将32位arm指令的压缩成16位的指令编码方式,，实现低功耗
2. `thumb-2`
16位/32位指令集，对`thumb`指令集进行了扩充，增加了一些32位指令，改善`thumb`指令集的性能
3. `arm`
32位指令集, 兼容所有`arm`架构

## 浮点类型
浮点运算的类型，通过选项`-mfloat-abi`指定，如`-mfloat-abi=hard`，有三种类型
1. `soft`
使用软浮点库进行浮点运算，不使用硬浮点单元，适用于不含`FPU`的`CPU`
2. `softfp`
使用硬浮点单元进行浮点运算，生成硬浮点指令，调用接口的规则和`soft`兼容
3. `hard`
使用硬浮点单元进行浮点运算，生成硬浮点指令，与`softfp`的区别在于调用接口的规则不同

硬浮点指令的类型，通过选项`-mfpu`指定，如`-mfpu=neon`，常用的有两种
1. `vfp`
2. `neon`
应用于`cortex-a`系列处理器




## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。