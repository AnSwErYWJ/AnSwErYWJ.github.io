---
title: C程序判断你主机的数据存储方式(大端和小端)
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - 大小端字节序
date: 2016-12-07 11:16:51
categories: C
---

本文将使用C语言编写一个可以判断你主机数据存储方式(大端和小端)的程序.

----------
<!--more-->

## C程序判断你主机的数据存储方式(大端和小端)
### 大端和小端字节序
计算机硬件存储数据的方式有两种: 大端字节序(big endian) 和 小端字节序(little endian),两者的区别可以简单理解为:
- 大端: 数据高位字节放在内存低地址(人类读写的习惯).
- 小端: 数据高位字节放在内存高地址.

如现在有数 0x1234,则两者存储方式如下:
| 内存地址    | 0x100    | 0x101     |
| :---------:|:---------:| :---------:|
|  大端      | 0x12     | 0x34      |
|  小端      | 0x34     | 0x12      |

>  既然大端字节序符合人类读写的习惯,那么为什么会有小端字节序呢？
> 因为大多数默认情况下计算机的电路先处理低位字节，效率比较高，因为计算都是从低位开始的。所以，计算机的内部处理都是小端字节序。但是，人类还是习惯读写大端字节序。所以，除了计算机的内部处理，其他的场合几乎都是大端字节序，比如网络传输和文件储存。

当然并不是所有的计算机处理器都是小端模式的,目前IBM和Freescale的一些处理器以及一些常见的单片机芯片等都是采用大端字节序存储数据.而市面上大部分CPU则是采用小端字节序,如intel等.


### 实现([完整代码](https://github.com/AnSwErYWJ/DogFood/blob/master/C/host_byte_order.c))
本例都认为short占2个字节,不考虑可移植的情况.
```
#include <stdio.h>
#include <stdlib.h>

union _byteorder
{
    short s;
    char c[2];
};

int main(void)
{
    union _byteorder un;

    un.s = 0x0102;
    
    if(sizeof(short) == 2)
    {
        if(un.c[0] == 2 && un.c[1] == 1)
            printf("little-endian\n");
        else if(un.c[0] == 1 && un.c[1] == 2)
            printf("big-endian\n");
        else
            fprintf(stderr,"Error:can not judge host byte order.\n");
    }
    else
        printf("sizeof(short) = %ld\n",sizeof(short));
    
    exit(EXIT_SUCCESS);
}
```
这里利用了``union`` 中所有的数据成员共用一个空间，同一时间只能储存其中一个数据成员的特性.
首先分配了一个占2个字节的内存空间(``union``分配的空间需要容纳最大长度的数据成员),将``0x0102``赋予``short``型变量.
然后利用``char``数组,按一个字节的长度依次取出数据,然后利用上节介绍的大小端存储方式的不同进行判断.

## Reference
- [理解字节序](http://www.ruanyifeng.com/blog/2016/11/byte-order.html)

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。

