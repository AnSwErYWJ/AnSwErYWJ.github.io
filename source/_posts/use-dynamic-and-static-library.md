---
title: Linux下C调用静态库和动态库
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2016-10-10 10:50:40
categories: 编译链接
tags: lib
---

本文主要介绍Linux下C调用静态库和动态库,使用的样例文件请点击[这里](https://github.com/AnSwErYWJ/DogFood/tree/master/Make/example-lib).
<!--more-->

## 样例文件
welcome.c:
```
#include<stdio.h>
#include"welcome.h"

void welcome()
{
    printf("welcome to my code world!\n");
}
```
> 这是一个样例程序,打印一句话.

welcome.h:
```
#ifndef _WELCOME_H
#define _WELCOME_H

void welcome();

#endif
```
> 为上一个文件的声明.

## 概念
动态库和静态库二者的不同点在于代码被载入的时刻不同。

静态库的代码在编译过程中已经被载入可执行程序,因此体积比较大。动态库(共享库)的代码在可执行程序运行时才载入内存，在编译过程中仅简单的引用，因此代码体积比较小。

静态情况下,把库直接加载到程序中,而动态库链接的时候,它只是保留接口,将动态库与程序代码独立,这样就可以提高代码的可复用度，和降低程序的耦合度。

静态库在程序编译时会被连接到目标代码中，程序运行时将不再需要该静态库。动态库在程序编译时并不会被连接到目标代码中，而是在程序运行是才被载入，因此在程序运行时还需要动态库存在.

## 静态库
生成静态库文件:
```
$ gcc -Wall -O2 -fPIC -I./  -c -o welcome.o welcome.c
$ ar crv libwelcome.a welcome.o
```
ar命令的参数如下:
```
参数        意义
-r      将objfile文件插入静态库尾或者替换静态库中同名文件
-x      从静态库文件中抽取文件objfile
-t      打印静态库的成员文件列表
-d      从静态库中删除文件objfile
-s      重置静态库文件索引
-v      创建文件冗余信息
-c      创建静态库文件
```

test-sta.c:
```
#include<stdio.h>

int main(void)
{
    welcome();
    
    return 0;
}
```

编译:
```
$ gcc test-sta.c -o test-sta ./libwelcome.a
```
运行:
```
$ ./test-sta 
$ welcome to my code world!
```


## 动态库
生成动态库文件: 
```
$ gcc -o2 -fPIC -shared welcome.c -o libwelcome.so
or
$ gcc -o2 -fPIC -c welcome.c 
$ gcc -shared -o libwelcome.so welcome.o 
```
其中:
-	fPIC : 产生与位置无关代码,全部使用相对地址.
-	shared : 生成动态库.


### 编译时加载(隐式)
test-implicit.c:
```
#include<stdio.h>

int main()
{
    welcome();

    return 0;
}
```

> 和静态库一样,测试代码不需要包含导出函数的头文件.

编译:
```
$ gcc -o2 -Wall -L. -lwelcome test-implicit.c -o test-implicit
```

查看`test-implicit`动态段信息,发现已经依赖`libwelcome.so`:
```
$ ldd test-implicit 
	linux-vdso.so.1 =>  (0x00007f0902951000)
	libwelcome.so => ./libwelcome.so (0x00007f090274f000)
	libstdc++.so.6 => /usr/lib64/libstdc++.so.6 (0x0000003548600000)
	libm.so.6 => /lib64/libm.so.6 (0x000000353de00000)
	libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x0000003548200000)
	libc.so.6 => /lib64/libc.so.6 (0x000000353da00000)
	/lib64/ld-linux-x86-64.so.2 (0x000000353d600000)
```

若此时直接运行,会提示找不到动态库:
```
$ ./test-implicit
$ ./test-implicit: error while loading shared libraries: libwelcome.so: cannot open shared object file: No such file or directory
```
可以通过下列三种方法解决:
```
# 方法一 修改环境变量
$ export LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH

# 方法二 将库文件链接到系统目录下
$ ln -s ./libwelcome.so /usr/lib

# 方法三 修改/etc/ld.so.conf
$ sudo echo $(pwd) >> /etc/ld.so.conf
$ sudo ldconfig
```
再次运行:
```
$ ./test-implicit
$ welcome to my code world!
```

### 运行时链接(显式)
test-explicit.c:
```
#include<stdio.h>
#include<dlfcn.h>

#define LIB "./libwelcome.so"

int main(void)
{
    /*
     * RTLD_NOW：将共享库中的所有函数加载到内存 
     * RTLD_LAZY：会推后共享库中的函数的加载操作，直到调用dlsym()时方加载某函数
     */

    void *dl = dlopen(LIB,RTLD_LAZY); //打开动态库

    if (dl == NULL)
        fprintf(stderr,"Error:failed to load libary.\n");

    char *error = dlerror(); //检测错误
    if (error != NULL)
    {
        fprintf(stderr,"%s\n",error);
        return -1;
    }

    void (*func)() = dlsym(dl,"welcome"); // 获取函数地址
    error = dlerror(); //检测错误
    if (error != NULL)
    {
        fprintf(stderr,"%s\n",error);
        return -1;
    }

    func(); //调用动态库中的函数

    dlclose(dl); //关闭动态库
    error = dlerror(); //检测错误
    if (error != NULL)
    {
        fprintf(stderr,"%s\n",error);
        return -1;
    }
   
    return 0;
}
```
编译:
``` 
$ gcc  -ldl test-explicit.c -o test-explicit
```

查看`test-explicit`动态段信息,没有发现依赖`libwelcome.so`:
```
$ ldd test-explicit
	linux-vdso.so.1 =>  (0x00007ffed89e5000)
	libdl.so.2 => /lib64/libdl.so.2 (0x000000353e600000)
	libstdc++.so.6 => /usr/lib64/libstdc++.so.6 (0x0000003548600000)
	libm.so.6 => /lib64/libm.so.6 (0x000000353de00000)
	libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x0000003548200000)
	libc.so.6 => /lib64/libc.so.6 (0x000000353da00000)
	/lib64/ld-linux-x86-64.so.2 (0x000000353d600000)
```

运行:
```
$ ./test-explicit
$ welcome to my code world!
```


>  区别: 隐式调用在编译可执行程序时需要指定库文件的搜索路径，而显式调用编译可执行程序时不用加上.

## Reference
- [Linux下静态、动态库（隐式、显式调用）的创建和使用及区别](http://blog.csdn.net/star_xiong/article/details/17301191)
- [Linux下编译链接动态库](http://hbprotoss.github.io/posts/linuxxia-bian-yi-lian-jie-dong-tai-ku.html)
- [Linux下动态库(.so)和静态库(.a)](http://blog.csdn.net/felixit0120/article/details/7652907)

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](https://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](https://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
