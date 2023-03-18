---
title: RPATH与RUNPATH的区别
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - RPATH
  - RUNPATH
  - LD_DEBUG
categories: 编译链接
abbrlink: 35393
date: 2021-02-22 18:26:04
---

本文从一个实际遇到的问题出发，分析 `RPATH` 与 `RUNPATH` 的区别，以及产生的原因。

<!--more-->

# RPATH与RUNPATH的区别

年前升级了操作系统后，同样的代码在新系统编译后无法执行，提示找不到依赖库，本文用来记录一下是如何解决这个问题的。
## 源文件
`main.c` ：
```c
#include "a.h"

int main() {
	a();
	return 0;
}
```
`libA.so`：
```c
// a.c
#include "b.h"

void a() {
	b();
}
```
```c
// a.h
void a();
```
`ubuntu 16.04(gcc version 5.4.0)`：
```bash
$ gcc -fPIC -shared a.c -I. -L. -lB -o libA.so
```
`libB.so`：
```c
// b.c
#include <stdio.h>

void b() {
	printf("Hello, World\n");
}
```
```c
// b.h
void b();
```
`ubuntu 16.04(gcc version 5.4.0)`：
```bash
$ gcc -fPIC -shared -I. b.c -o libB.so
```


> **函数调用依赖关系：`main` -> `a` -> `b`**。



## 复现步骤

1. 分别在 `ubuntu 16.04(gcc version 5.4.0)` 和 `ubuntu 20.04(gcc version 9.3.0)` 编译可执行程序：
```bash
$ gcc -I. -o main main.c -Wl,--rpath,. -L. -lA -lB
```


2. 在 `ubuntu 16.04(gcc version 5.4.0)` 运行**成功**：
```bash
$ ./main
Hello, World
```

3. 在 `ubuntu 20.04(gcc version 9.3.0)` 运行**失败**：
```bash
$ ./main 
./main: error while loading shared libraries: libB.so: cannot open shared object file: No such file or directory
```
> 错误提示为找不到可执行程序 `./main` 依赖的共享库 `libB.so` 。



## 问题原因
### 排除共享库本身问题
首先，由于 `libA.so` 和 `libB.so` 是在 `ubuntu 16.04(gcc version 5.4.0)` 上编译的，所以重新在`ubuntu 20.04(gcc version 9.3.0)` 上编译 `libA.so` 和 `libB.so`，并重复复现步骤，现象相同，说明不是 `libA.so` 和 `libB.so` 导致的问题；


### 分析库查找过程
使用 **`LD_DEBUG`**，打开链接器的调试功能，分析共享库的查找过程：
`ubuntu 16.04(gcc version 5.4.0)`：
```bash
$ LD_DEBUG=libs ./main                                                        [16:37:15]
     22331:	find library=libA.so [0]; searching
     22331:	 search path=./tls/x86_64:./tls:./x86_64:.		(RPATH from file ./main)
......
     22331:	  trying file=./libA.so
......
     22331:	find library=libB.so [0]; searching
     22331:	 search path=./tls/x86_64:./tls:./x86_64:.		(RPATH from file ./main)
......
     22331:	  trying file=./libB.so
 ......
```
`ubuntu 20.04(gcc version 9.3.0)`：
```bash
$ LD_DEBUG=libs ./main
     33218:	find library=libA.so [0]; searching
     33218:	 search path=./tls/haswell/x86_64:./tls/haswell:./tls/x86_64:./tls:./haswell/x86_64:./haswell:./x86_64:.		(RUNPATH from file ./main)
......
     33218:	  trying file=./libA.so
......
     33218:	find library=libB.so [0]; searching
     33218:	 search cache=/etc/ld.so.cache
     33218:	 search path=/lib/x86_64-linux-gnu/tls/haswell/x86_64:/lib/x86_64-linux-gnu/tls/haswell:/lib/x86_64-linux-gnu/tls/x86_64:/lib/x86_64-linux-gnu/tls:/lib/x86_64-linux-gnu/haswell/x86_64:/lib/x86_64-linux-gnu/haswell:/lib/x86_64-linux-gnu/x86_64:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu/tls/haswell/x86_64:/usr/lib/x86_64-linux-gnu/tls/haswell:/usr/lib/x86_64-linux-gnu/tls/x86_64:/usr/lib/x86_64-linux-gnu/tls:/usr/lib/x86_64-linux-gnu/haswell/x86_64:/usr/lib/x86_64-linux-gnu/haswell:/usr/lib/x86_64-linux-gnu/x86_64:/usr/lib/x86_64-linux-gnu:/lib/tls/haswell/x86_64:/lib/tls/haswell:/lib/tls/x86_64:/lib/tls:/lib/haswell/x86_64:/lib/haswell:/lib/x86_64:/lib:/usr/lib/tls/haswell/x86_64:/usr/lib/tls/haswell:/usr/lib/tls/x86_64:/usr/lib/tls:/usr/lib/haswell/x86_64:/usr/lib/haswell:/usr/lib/x86_64:/usr/lib		(system search path)
......
./main: error while loading shared libraries: libB.so: cannot open shared object file: No such file or directory

```
结果在 `ubuntu 20.04(gcc version 9.3.0)` 中， 可以正确查找到 `libA.so` ，但是无法正确查找到 `libB.so` 。
`libB.so` 的查找路径是 `system search path` ，而非我们在编译时设定的查找时路径 `./` ，导致可执行程序无法加载 `libB.so` 。
> 动态链接器对共享库的查找顺序：
> 1. `LD_LIBRARY_PATH`、`-L` 和 `-rpath`；
> 1. `/etc/ld.so.cache`；
> 1. 默认共享库目录：`/usr/lib`、`/lib`；



### RPATH与RUNPATH的区别
由上分析可以得出是共享库运行时加载路径非法导致的问题，在排除设置 `LD_LIBRARY_PATH` 等环境变量的情况下，可以将焦点锁定在使用的链接选项 `-rpath` 上，查看源文件依赖：
`ubuntu 16.04(gcc version 5.4.0)`：
```bash
$ readelf -d main
Dynamic section at offset 0xe08 contains 26 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libA.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000f (RPATH)              Library rpath: [.]
 
 $ readelf -d libA.so
Dynamic section at offset 0xe08 contains 25 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libB.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 
 $ readelf -d libB.so
Dynamic section at offset 0xe18 contains 24 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
```
`ubuntu 20.04(gcc version 9.3.0)`：
```bash
$ readelf -d main 
Dynamic section at offset 0x2da8 contains 29 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libA.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000001d (RUNPATH)            Library runpath: [.]
 
 $ readelf -d libA.so 
Dynamic section at offset 0xe08 contains 25 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libB.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 
 $ readelf -d libB.so 
Dynamic section at offset 0xe18 contains 24 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
```
发现在 `ubuntu 20.04(gcc version 9.3.0)` 上 `RPATH` 变成了 `RUNPATH` ，说明链接器选项 `-rpath` 的行为发生了改变。
> 源文件依赖关系：`main` -> `libA.so` -> `libB.so`；



**综上，问题的原因是 `ubuntu 20.04(gcc version 9.3.0) `上，链接器选项 `-rpath` 的行为发生改变，默认配置为 `RUNPATH` 而不是 `RPATH`；由于 `RUNPATH` 不适用于间接依赖的库，所以导致在 `ubuntu 20.04(gcc version 9.3.0)` 上只能正确查找到 `libA.so` ，而无法正确查找到 `libB.so` 。**
> `gcc version >= 7.5.0`时，`-rpath`默认行为即发生改变。



## 解决方案
### LD_LIBRARY_PATH（不推荐）
`LD_LIBRARY_PATH` 是一个环境变量，作用是**临时**改变链接器的加载路径，可以存储多个路径，用冒号分隔：
```bash
$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./libs
```
不推荐的原因：

1. 若全局设置 `LD_LIBRARY_PATH`，会影响其它应用程序的共享库加载过程；
1. 若只在该应用程序启动时局部设置 `LD_LIBRARY_PATH`，则每次启动都需要设置，步骤过于繁琐；



### --disable-new-dtags
可以使用 `-Wl,--disable-new-dtags` 选项来使链接器保持旧行为，即在 `ubuntu 20.04(gcc version 9.3.0)` 使用如下命令编译：
```bash
$ gcc -I. -o main main.c -Wl,--disable-new-dtags,--rpath,. -L. -lA -lB
```
重新运行并查看依赖：
```bash
$ ./main 
Hello, World

$ readelf -d main
Dynamic section at offset 0x2da8 contains 29 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libA.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000f (RPATH)              Library rpath: [.]
```
可执行程序 `main` 可以正确运行，`RUNPATH` 也变成了 `RPATH`，链接器行为与 `ubuntu 16.04(gcc version 5.4.0)` 保持一致了。
> 同理，也有 `-Wl,--enable-new-dtags` 选项来使链接器保持新行为



如下为官方解释：
```
--enable-new-dtags
--disable-new-dtags
This linker can create the new dynamic tags in ELF. But the older ELF systems may not understand them. If you specify --enable-new-dtags, the new dynamic tags will be created as needed and older dynamic tags will be omitted. If you specify --disable-new-dtags, no new dynamic tags will be created. By default, the new dynamic tags are not created. Note that those options are only available for ELF systems.
```
## 参考

- [How to set RPATH and RUNPATH with GCC/LD?](https://stackoverflow.com/questions/52018092/how-to-set-rpath-and-runpath-with-gcc-ld)
- [use RPATH but not RUNPATH?](https://stackoverflow.com/questions/7967848/use-rpath-but-not-runpath)
