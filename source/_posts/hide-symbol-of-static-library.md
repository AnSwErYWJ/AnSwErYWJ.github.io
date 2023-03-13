---
title: 屏蔽静态库接口
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - hidden
  - objcopy
categories: 编译链接
abbrlink: 15675
date: 2019-04-13 14:43:13
---

分享屏蔽静态库接口的一种方法.
<!--more-->

## 准备
`hello.c`:
```
#include <stdio.h>

__attribute__ ((visibility ("default"))) void hello() {
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

`bye.c`:
```
#include <stdio.h>

void bye() {
	printf("Bye Bye!\n");
}
```
`bye.h`:
```
#ifndef __BYE__H
#define __BYE__H

#ifdef __cplusplus
extern "C" {
#endif

void bye();

#ifdef __cplusplus
}
#endif

#endif
```

## 编译
编译时使用`-fvisibility=hidden`,可以默认将符号隐藏;需要对外的符号使用`__attribute__ ((visibility ("default")))`修饰即可:
```
$ gcc -fvisibility=hidden -I. -c hello.c -o hello.o
$ gcc -fvisibility=hidden -I. -c bye.c -o bye.o
```
其中`hello()`未被隐藏,`bye()`是被隐藏的.

## 链接
将生成的两个`.o`文件重定位到`libt.o`中:
```
$ ld -r hello.o bye.o -o libt.o
```

## 去除无用的符号
```
$ strip --strip-unneeded libt.o
```

## 隐藏的符号本地化(我也不知道中文怎么翻译了)
```
$ objcopy --localize-hidden libt.o libt_hidden.o
```

## 打包成静态库
```
$ ar crv libt.a libt_hidden.o
```

## 验证
### 调用未被隐藏的`hello()`
`test1.c`:
```
#include "hello.h"

int main(void) {
    hello();
    return 0;
}
```
编译并运行
```
$ gcc -I. test1.c -L. -lt -o test
$ ./test
Hello World!
```

### 调用隐藏的`bye()`
test2.c
```
#include "bye.h"

int main(void) {
    bye();
    return 0;
}
```
编译并运行
```
$ gcc -I. test2.c -L. -lt -o test
$ ./test
/tmp/ccdaJT7s.o: In function `main':
test2.c:(.text+0xa): undefined reference to `bye'
collect2: error: ld returned 1 exit status
```

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)