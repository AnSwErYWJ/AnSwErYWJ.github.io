---
title: 将二进制文件作为目标文件中的一个段
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - objdump
  - elf
abbrlink: 11283
date: 2019-07-24 11:50:23
categories: 编译链接
---

本文将展示，如何将一个二进制文件(如图片、音频等)作为目标文件中的一个段，该技巧主要应用在一些无文件系统的平台。

<!--more-->

本次的实验场景为`i386:x86-64 GNU/Linux`，测试音频为`nhxc.wav`，测试程序为`bin2obj.c`。

## 查看该平台的ELF文件相关信息
生成目标文件
```
$ gcc -c bin2obj.c -o bin2obj.o
```

查看该平台`ELF`文件相关信息
```
$ objdump -x bin2obj.o

bin2obj.o:     file format elf64-x86-64
bin2obj.o
architecture: i386:x86-64, flags 0x00000011:
HAS_RELOC, HAS_SYMS
start address 0x0000000000000000
```
由上可知，文件格式为`elf64-x86-64`，`CPU`架构为`architecture`。

## 转换
首先通过`objcopy --help`选项查看相关参数的意义:
```
$ objcopy --help
-I --input-target <bfdname>      Assume input file is in format <bfdname>
-O --output-target <bfdname>     Create an output file in format <bfdname>
-B --binary-architecture <arch>  Set output arch, when input is arch-less
......
objcopy: supported targets: elf64-x86-64 elf32-i386 elf32-iamcu elf32-x86-64 a.out-i386-linux pei-i386 pei-x86-64 elf64-l1om elf64-k1om elf64-little elf64-big elf32-little elf32-big pe-x86-64 pe-bigobj-x86-64 pe-i386 plugin srec symbolsrec verilog tekhex binary ihex
```
由上可知，`-I`选项指定输入文件的格式，`-O`指定输出文件的格式，在`supported targets`中选择对应的格式；-B是指定目标文件的架构`i386:x86-64`，即上文`objdump -x`命令查询的`architecture`。

转换：
```
$ objcopy -I binary -O elf64-x86-64 -B i386:x86-64 nhxc.wav audio.o
```

查看转换后生成的目标文件：
```
$ objdump -x audio.o

audio.o:     file format elf64-x86-64
audio.o
architecture: i386:x86-64, flags 0x00000010:
HAS_SYMS
start address 0x0000000000000000

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .data         0000fab0  0000000000000000  0000000000000000  00000040  2**0
                  CONTENTS, ALLOC, LOAD, DATA
SYMBOL TABLE:
0000000000000000 l    d  .data	0000000000000000 .data
0000000000000000 g       .data	0000000000000000 _binary_nhxc_wav_start
000000000000fab0 g       .data	0000000000000000 _binary_nhxc_wav_end
000000000000fab0 g       *ABS*	0000000000000000 _binary_nhxc_wav_size
```
可以看到`file format`、`architecture`信息与`bin2obj.o`的相同，`_binary_nhxc_wav_start`指向音频内容的起始地址，`_binary_nhxc_wav_end`指向音频内容的结尾地址，`_binary_nhxc_wav_size`指向文件大小的存储地址。
> `_binary_*_start/end/size`，`*`是二进制文件的文件名及后缀名。

## 测试
[bin2obj.c](https://github.com/AnSwErYWJ/DogFood/blob/master/C/bin2obj/bin2obj.c)：
```
#include <stdio.h>
#include <elf.h>

extern _binary_nhxc_wav_start;
extern _binary_nhxc_wav_end;
extern _binary_nhxc_wav_size;

int main() {
	printf("binary to object:\n");
    
	printf("elf head: %ld\n", sizeof(Elf64_Ehdr));
    printf("_binary_nhxc_wav_size: %p\n_binary_nhxc_wav_end: %p\n_binary_nhxc_wav_size: %p\n", &_binary_nhxc_wav_start, &_binary_nhxc_wav_end,  &_binary_nhxc_wav_size);

    unsigned char * audio_buf = (unsigned char *)&_binary_nhxc_wav_start;
    unsigned long size = (unsigned long)&_binary_nhxc_wav_size;

	FILE *fp = fopen("./out.wav", "wb");
	if (!fp) {
		fprintf(stderr, "fopen failed!\n");
		return -1;
	}

	fwrite(audio_buf, size, 1, fp);

	fclose(fp);

	return 0;
}
```
通过`_binary_nhxc_wav_start`和`_binary_nhxc_wav_size`两个符号，读取音频文件。

编译并运行：
```
$ gcc -c bin2obj.c -o bin2obj.o
$ g++ bin2obj.o audio.o -o bin2obj
$ ./bin2obj
binary to object:
elf head: 64
_binary_nhxc_wav_size: 0x601040
_binary_nhxc_wav_end: 0x610af0
_binary_nhxc_wav_size: 0xfab0
```
比对写入的文件`out.wav`与原始文件`nhxc.wav`，完全一致：
```
155e62d81e84fa7493fefe82223bcc2a  nhxc.wav
155e62d81e84fa7493fefe82223bcc2a  out.wav
```

查看audio.o：
```
$ hexdump -C audio.o | head -n 5
00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
00000010  01 00 3e 00 01 00 00 00  00 00 00 00 00 00 00 00  |..>.............|
00000020  00 00 00 00 00 00 00 00  d0 fb 00 00 00 00 00 00  |................|
00000030  00 00 00 00 40 00 00 00  00 00 40 00 05 00 02 00  |....@.....@.....|
00000040  52 49 46 46 a8 fa 00 00  57 41 56 45 66 6d 74 20  |RIFF....WAVEfmt |
```
如程序输出，`ELF`文件头部信息结构体为64字节，而转换生成的目标文件中，音频内容始于`0x40`字节偏移（`wav`头始于`RIFF`，可以参考[wav文件解析](http://answerywj.com/2019/06/03/wav/)），而`0x40`正是十进制的`64`。


## Reference
- 《程序员的自我修养——链接、装载与库》P68

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)