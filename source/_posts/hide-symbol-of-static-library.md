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

### 调用隐藏的'bye()'
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