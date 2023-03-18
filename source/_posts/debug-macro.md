---
title: Linux C编程的DEBUG宏
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - debug
categories: C/C++
abbrlink: 60496
date: 2016-07-14 14:20:25
---

DEBUG宏用于Linux下C编程时调试使用.

<!--more-->

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
