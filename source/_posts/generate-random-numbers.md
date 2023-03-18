---
title: C语言生成随机数
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - 随机数
categories: C/C++
abbrlink: 6131
date: 2016-07-14 14:16:51
---

本文将介绍C语言生成随机数的方法,主要使用 *rand()* 函数和 *srand()* 函数.

<!--more-->

## rand函数

### 函数介绍
*rand()*函数是产生随机数的一个随机函数：
```
#include<stdlib.h>

int rand(void);
```
返回值：
*rand()*返回值为一随机数值，范围在0至RAND_MAX 间（RAND_MAX定义在stdlib.h，其值为2147483647）。

>**注：**在调用此函数前，必须先利用srand()设好随机数种子。如果未设随机数种子，rand()在调用时会自动设随机数种子为1。

### 示例一：
代码：
```
/*************************************************************************
	> File Name: rand.c
	> Author: AnSwEr
	> Mail: 1045837697@qq.com
	> Created Time: 2015年10月24日 星期六 20时50分59秒
 ************************************************************************/

/*
 * 产生1到6的随机数
 */

#include<stdio.h>
#include<stdlib.h>

int main(void)
{
    int i = 0;

    for(i=0;i<10;i++)
    {
        printf("%d ",rand()%6+1);
    }
    printf("\n");

    return 0;
}
```

运行结果：
![这里写图片描述](http://img.blog.csdn.net/20151024205732527)

**说明：**这里两次运行的结果相同，是因为未利用*srand()*设置随机数种子，所以rand()在调用时会自动设随机数种子为1。

## srand函数
### 函数介绍
*srand()*函数是随机数发生器的初始化函数：
```
#include<stdlib.h>

void srand (unsigned int seed);
```
参数：
seed必须是个整数，通常可以利用*geypid()*或*time(0)*的返回值来当做seed。如果每次seed都设相同值，那么*rand()*所产生的随机数值会像上面的示例一每次就会一样。

### 示例二：
代码：
```
/*************************************************************************
	> File Name: srand.c
	> Author: AnSwEr
	> Mail: 1045837697@qq.com
	> Created Time: 2015年10月24日 星期六 21时01分58秒
 ************************************************************************/

/*
 * 产生1-6的随机数
 */

#include<stdio.h>
#include<stdlib.h>
#include<time.h>

int main(void)
{
    int i = 0;

    srand((unsigned int)time(NULL));
    for(i=0;i<10;i++)
    {
        printf("%d ",rand()%6+1);
    }
    printf("\n");

    return 0;
}
```

运行结果：
![这里写图片描述](http://img.blog.csdn.net/20151024210616461)

哈哈，这下两次结果就不同了吧。

## 总结
关于随机数的知识就先总结这么多，以后碰到更复杂的再继续。
