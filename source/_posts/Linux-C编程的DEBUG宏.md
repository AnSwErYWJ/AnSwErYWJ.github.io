---
title: Linux C编程的DEBUG宏
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - debug
date: 2016-07-14 14:20:25
categories: Linux C
---

# Linux C编程的DEBUG宏

**在完成项目的过程中，免不了要进行调试，在这里我给大家介绍一种我正在使用的DEBUG宏。废话不多说，直接上代码。**

## 实现代码
```
/*************************************************************************
	> File Name: debug.c
	> Author: AnSwEr
	> Mail: 1045837697@qq.com
	> Created Time: 2015年07月23日 星期四 18时19分48秒
 ************************************************************************/

#include<stdio.h>
#define DEBUG_PRINT do{}while(0)

#if defined(DEBUG_PRINT)
#define DEBUG(...)\
        do{\
            fprintf(stderr,"-----DEBUG-----\n");\
            fprintf(stderr,"%s %s\n",__TIME__,__DATE__);\
            fprintf(stderr,"%s:%d:%s():",__FILE__,__LINE__,__func__);\
            fprintf(stderr,__VA_ARGS__);\
        }while(0)
#endif

int main(void)
{
    DEBUG("Debug successfully!\n");
    return 0;
}
```

## 说明
1. *do{}while(0)*：使用*do{...}while(0)*构造后的宏定义不会受到大括号、分号等的影响，而且可以定义空宏而不受警告。
2. 参数介绍：
```
 __LINE__：在源代码中插入当前源代码行号；
 __FILE__：在源文件中插入当前源文件名；
 __DATE__：在源文件中插入当前的编译日期
 __TIME__：在源文件中插入当前编译时间；
 __func__：输出函数名称,功能与_Function_相同；
 __VA_ARGS__：可变参数类型。
```


>**注意：**具体代码可以参见<https://github.com/AnSwErYWJ/DogFood/blob/master/debug.c>。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。







