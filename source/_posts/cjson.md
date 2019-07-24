---
title: cJSON的秘密
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - cJSON
date: 2018-05-03 16:58:02
categories: 源码阅读笔记
---

学习使用cJSON过程的一些发现和总结，不涉及具体的函数
<!--more-->

## cJSON简介
`cJSON`是一个快速，高性能的`json`解析器，由`C`语言编写，仅包含`cJSON.c`和`cJSON.h`两个文件，不支持跨平台；跨平台推荐纯`lua`写的[`dkjson`](http://dkolf.de/src/dkjson-lua.fsl/home)

## cJSON结构体
`cJSON`结构体的组成：

```
typedef struct cJSON {
	struct cJSON *next, *prev;
	struct cJSON *child;

	int type;

	char *valuestring;
	int valueint;
	double valuedouble;

	char *string;
} cJSON;
```
其中

- `next`指向链表中下一个兄弟节点，`prev`指向本节点前一个节点
- `child`节点只有对象和数组有，并且`child`节点是双向链表的头节点，`child`的`prev`一般为`NULL`，不指向任何节点，双向链表的最后一个兄弟节点的`next`是无指向的
- `type`取值有`Null/True/False/Number/String/Array/Object`，这些值类型都在`cJSON.h`中通过宏定义了
- `String`类型节点有`valuestring `，`Number`类型节点有`valueint`和`valuedouble`
- `string`表示节点的名称，所有的节点都是一个链表，都具有`string`值

> `cJSON`默认所有值都为`0`，除非额外为其赋有意义的值

### cJSON树结构
`cJSON`使用树结构存储`JSON`的各个节点，而这个树结构是使用双向链表实现的(实线表示节点间有真实的引用关系，而虚线表示逻辑上的引用关系)：
![cJSON树结构](cjson-tree.png)

- 树结构的每一层都是一个双向链表，表示一堆兄弟节点
- 当前层的所有节点都是当前链表头节点的父节点的子节点

下面举例说明：

```
{
    "name": "Jack (\"Bee\") Nimble", 
    "format": {
        "type":       "rect", 
        "width":      1920, 
        "height":     1080, 
        "interlace":  false, 
        "frame rate": 24
    }
}
```

- `name`和`format`节点组成一个链表，`type`、`width`、`height`、`interlace`和`frame rate`节点组成一个链表
- 根节点包含节点类型`Object`和子节点`name`
- 子节点包含节点名称`name`、节点值`Jack ("Bee") Nimble`和兄弟节点`format`
- `format`节点包含节点类型`Object`、节点名称`format`和子节点`type`
- `type`节点包含节点类型`String`、节点名称`type`、节点值`rect`和兄弟节点`width`
- `width`节点包含节点类型`Number`、节点名称`width`、节点值`1920`和兄弟节点`height`
- `height`节点包含节点类型`Number`、节点名称`height`、节点值`1080`和兄弟节点`interlace` 
- `interlace`节点包含节点类型`False`、节点名称`interlace`和兄弟节点`frame rate`
- `frame rate`节点包含节点类型`Number`、节点名称`frame tate`和节点值`25`

## cJSON内存管理

`cJson`分为自动和手动两种使用方式：

- 在自动模式下，`cJSON`使用默认的`malloc`和`free`函数管理内存，在`cJSON`中，每个节点都是`malloc`而来，每个节点的`string`和`valuestring`也是`malloc`而来，使用`cJSON_Delete`函数可以递归释放`JSON`树中`malloc`的节点内存和字符内存，使用`cJSON_Print`函数后，则需要手动释放`cJSON_Print`函数分配的内存，避免内存泄露
- 在手动模式下，`cJSON`提供了钩子函数来帮助用户自定义内存管理函数，如果不设置，这默认为`malloc`和`free`

```
	struct cJSON_Hooks js_hook = {xxx_malloc, xxx_free};
	cJSON_InitHooks(&js_hook);
```

## cJSON序列化

`cJSON`序列化就是把`cJSON`输出，有两种形式：
- 格式化输出`char  *cJSON_Print(cJSON *item);`
- 压缩输出`char  *cJSON_PrintUnformatted(cJSON *item);`

需要注意的是`cJSON`采用了预先将要输的内容全部以字符串形式存储在内存中，最后输出整个字符串的方法，而不是边分析`json`数据边输出，所以对于比较大的`json`数据来说，内存就是个问题了


## Reference
- [cJson源码和源码分析](https://github.com/faycheng/cJSON)


## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。