---
title: GCC编译ARM篇
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
categories: 编译链接
tags: gcc
abbrlink: 38414
date: 2017-08-04 16:30:40
---

`ARM` 平台下`GCC`编译相关介绍，待补充
<!--more-->

## ARM处理器架构
`ARM`处理器架构，通过选项`-march`指定，如`-march=armv7-a`，常见的有
1. `armv5te`
`arm9`系列使用该架构
2. ` armv6`
`arm11`系列使用该架构
3. `armv7-a`
`cortex-a`系列使用该架构，如`cortex-a5、a7、a8、a9、a12、a15`
4. `armv8`
`cortex-a`系列使用该架构，如`cortex-a53、a57、a72`

## 指令集
指令集，通过选项`-m`指定，如`-mthumb`，常见的有
1. `thumb`
16位指令集，它将32位arm指令的压缩成16位的指令编码方式，节省代码存储空间，实现低功耗
2. `thumb-2`
16位/32位指令集，对`thumb`指令集进行了扩充，增加了一些32位指令，改善`thumb`指令集的性能
3. `arm`
32位指令集, 兼容所有`arm`架构，性能高

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
其中`vfpv2`应用于`armv5te, armv6`架构中的浮点计算指令集，`vfpv3`和`vfpv4`应用于部分`armv7a`架构中的浮点计算指令集
2. `neon`
应用于`cortex-a`系列处理器，性能好

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)