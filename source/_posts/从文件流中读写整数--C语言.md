---
title: 从文件流中读写整数--C语言
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - getw
date: 2016-12-06 14:16:51
categories: C
---

本文将介绍在文本流中,读写整数的两个接口-- ``int getw(FILE *fp)``和``int putw(int w, FILE *fp)``,并且与你分享改进后的更实用的接口-- ``int get_int(FILE *fp)``和``int put_int(int w, FILE *fp)``

----------
<!--more-->

## 从文件流中读写整数--C语言
我们都知道,数据在计算机内存中都是以二进制的形式存储的,大多数PC的存储方式为小端存储,关于大小端字节序的讨论请参考[阮一峰的理解字节序](http://www.ruanyifeng.com/blog/2016/11/byte-order.html). 如果想直接读写整数,并不是很方便,这里就为你介绍两个接口,需要注意的是这两个接口非ANSI标准函数.

### getw 
函数原型：
```
int getw(FILE *fp)
```
函数功能：
```
从fp所指向文件读取下一个整数.
```
返回值：
```
返回输入的整数,如果文件结束或者出错返回-1.
```

### putw
函数原型：
```
int putw(int w, FILE *fp)
```
函数功能：
```
将整型w写进fp指向的文件.
```
返回值：
```
返回输出的整数,如果出错,则返回EOF.
```

### 应用
代码:
```
#include <stdio.h>
#include <stdlib.h>

int main(int argc,char *argv[])
{
	FILE *fp = NULL;
    int num[2] = {-2147483648,2147483647};
    
    fp = fopen("./log", "wb");
    if (fp == NULL)
    {
        fprintf(stderr,"open file failed");
        exit(EXIT_FAILURE);
    }

    putw(num[0],fp);
    putw(num[1],fp);

    fclose(fp);
    fp = NULL;
    
    fp = fopen("./log", "rb");
    if (fp == NULL)
    {
        fprintf(stderr,"open file failed");
        exit(EXIT_FAILURE);
    }

    printf("%d %d\n",getw(fp),getw(fp));

    fclose(fp);
	fp = NULL;
	
    return 0;
}
```
结果为:
```
$ 2147483647 -2147483648
```
> 注意: 函数参数的压栈顺序是从左到右的,所以最后一个参数``getw(fp)``在栈顶,第一个出栈执行.

### 实现与改进
由于上述两个接口支持的是int型,所以取值范围为``-2147483648～2147483647``.(此文认为int型都为4个字节).笔者需要使用这两个接口去读写文件的大小,负数无用处的,所以决定改装一下这两个函数,顺便探究一下这个函数的实现:
代码:
```
#include <stdio.h>
#include <stdlib.h>

unsigned int get_int(FILE *fp)
{
    unsigned char *s;
    unsigned int i;
    s = (unsigned char *)&i;
    s[0]=getc(fp);
    //printf("%x\n",s[0]);
    s[1]=getc(fp);
    //printf("%x\n",s[1]);
    s[2]=getc(fp);
    //printf("%x\n",s[2]);
    s[3]=getc(fp);
    //printf("%x\n",s[3]);
    return i;
}

unsigned int put_int(unsigned int i,FILE*fp)
{
    unsigned char *s;
    s=(unsigned char *)&i;
    putc(s[0],fp);
    //printf("%x\n",s[0]);
    putc(s[1],fp);
    //printf("%x\n",s[1]);
    putc(s[2],fp);
    //printf("%x\n",s[2]);
    putc(s[3],fp);
    //printf("%x\n",s[3]);
    return(i);
}

int main(int argc,char *argv[])
{
	FILE *fp = NULL;
    int num[2] = {4294967295,0};

    fp = fopen("./log", "wb");
    if (fp == NULL)
    {
        fprintf(stderr,"open file failed");
        exit(EXIT_FAILURE);
    }

    put_int(num[0],fp);
    put_int(num[1],fp);

    fclose(fp);
    fp = NULL;
    
    fp = fopen("./log", "rb");
    if (fp == NULL)
    {
        fprintf(stderr,"open file failed");
        exit(EXIT_FAILURE);
    }

    printf("%u %u\n",get_int(fp),get_int(fp));

    fclose(fp);
	fp = NULL;
	
    return 0;
}

```

结果:
```
$ 0 4294967295
```
>改进后取值范围为``0~4294967295``.

同理,你也可以将这两个接口改为支持 ``long int``和``unsigned long int``等不同长度的整数类型.

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。

