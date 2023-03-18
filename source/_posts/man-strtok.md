---
title: 深究strtok系列函数
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - strtok
  - strtok_r
categories: C/C++
abbrlink: 31998
date: 2019-05-21 15:59:44
---

本文通过分析源码，深究`GLIBC`中`strtok`和`strtok_r`函数的实现原理和使用过程中的注意事项。

<!--more-->

## 函数说明
```
#include <string.h>

char *strtok(char *str, const char *delim);
char *strtok_r(char *str, const char *delim, char **saveptr);
```

### 说明
- `strtok`以包含在`delim`中的字符为分割符，将`str`分割成一个个子串；若`str`为空值`NULL`，则函数内部保存的静态指针（指向上一次分割位置后一个字节）在下一次调用中将作为起始位置。
- `strtok_r`功能同`strtok`，不过其将`strtok`函数内部保存的指针显示化，通过`saveptr`输入，以`saveptr`作为分割的起始位置。

### 参数
- `str`: 待分割的源字符串
- `delim`: 分割符字符集合
- `saveptr`: 一个指向`char *`的指针变量，保存分割时的上下文

### 返回值
- 若未提取到子串，返回值为指向源字符串首地址的指针，可以完整打印源字符串
- 若提取到子串，返回值为提取出的子串的指针，这个指针指向的是子串在源字符串中的起始位置，因为子串末尾的下一个字符在提取前为分割符，提取后被修改成了`'/0’`，所以可以成功打印子串的内容
- 若在成功提取到子串后，没有可以被分割的子串，返回NULL

## 示例
```
#include <stdio.h>
#include <string.h>

int main(void) {
  char str[12] = "hello,world\0";
  char *token = strtok(str, ",");

  while (token != NULL) {
    printf("%s\n", token);
    token = strtok(NULL, ",");
  }
   
  return 0;
}
```

## 使用注意事项
### 不会生成新的字符串，只是在源字符串上做了修改，源字符串会发生变化
```
char str[12] = "hello,world\0";
printf("str before strtok: %s\n", str);
char *token = strtok(str, ",");
printf("str after strtok: %s\n", str);
```
```
$ str before strtok: hello,world
$ str after strtok: hello
```
如上实验，`str`的值，在对其做`strtok`操作之后，发生了变化，分割符之后的内容不见了。事实上，`strtok`函数是根据输入的分割符（即`,`），找到其首次出现的位置（即`world`之前的`,`），将其修改为`'/0’`。

### 第一个参数不可为字符串常量
因为`strtok`函数会修改源字符串，所以第一个参数不可为字符串常量，不然程序会抛出异常。

### 若在第一次提取子串后，继续对源字符串进行提取，应在其后的调用中将第一个参数置为空值`NULL`
```
char str[12] = "hello,world\0";
char *token = strtok(str, ",");   
while (token != NULL) {
    printf("%s\n", token);
    token = strtok(NULL, ",");
}
```
```
$ hello
$ world
```
在第一次提取子串时，`strtok`用一个指针指向了分割符的下一位，即'w’所在的位置，后续的提取给`strtok`的第一个参数传递了空值`NULL`，`strtok`会从上一次调用隐式保存的位置，继续分割字符串。

### 第二个参数是分割符的集合，支持多个分割符
```
char str[12] = "hello,world\0";
char *token = strtok(str, ",l");
printf("%s\n", token);
```
```
$ he
```
由上可见，`strtok`函数在分割字符串时，不是完整匹配第二个参数传入的分割符，而是使用包含在分割符集合中的字符进行匹配。

### 若首字符为分割符，则会被忽略
```
char str[13] = ",hello,world\0";
char *token = strtok(str, ",");
printf("%s\n", token);
```
```
$ hello
```
如上所示，若首字符为分割符，`strtok`采用了比常规处理更快的方式，直接跳过了首字符。

### `strtok`为不可重入函数，使用`strtok_r`更灵活和安全
`strtok`函数在内部使用了静态变量，即用静态指针保存了下一次调用的起始位置，对调用者不可见；`strtok_r`则将`strtok`内部隐式保存的指针，以参数的形式由调用者进行传递、保存甚至是修改，使函数更具灵活性和安全性；此外，在`windows`也有分割字符串安全函数`strtok_s`。

## 源码
strtok.c:
```
/* Copyright (C) 1991-2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#include <string.h>


/* Parse S into tokens separated by characters in DELIM.
   If S is NULL, the last string strtok() was called with is
   used.  For example:
	char s[] = "-abc-=-def";
	x = strtok(s, "-");		// x = "abc"
	x = strtok(NULL, "-=");		// x = "def"
	x = strtok(NULL, "=");		// x = NULL
		// s = "abc\0=-def\0"
*/
char *
strtok (char *s, const char *delim)
{
  static char *olds;
  return __strtok_r (s, delim, &olds);
}
```

strtok_r.c:
```
/* Reentrant string tokenizer.  Generic version.
   Copyright (C) 1991-2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <string.h>

#ifndef _LIBC
/* Get specification.  */
# include "strtok_r.h"
# define __strtok_r strtok_r
#endif

/* Parse S into tokens separated by characters in DELIM.
   If S is NULL, the saved pointer in SAVE_PTR is used as
   the next starting point.  For example:
	char s[] = "-abc-=-def";
	char *sp;
	x = strtok_r(s, "-", &sp);	// x = "abc", sp = "=-def"
	x = strtok_r(NULL, "-=", &sp);	// x = "def", sp = NULL
	x = strtok_r(NULL, "=", &sp);	// x = NULL
		// s = "abc\0-def\0"
*/
char *
__strtok_r (char *s, const char *delim, char **save_ptr)
{
  char *end;

  if (s == NULL)
    s = *save_ptr;

  if (*s == '\0')
    {
      *save_ptr = s;
      return NULL;
    }

  /* Scan leading delimiters.  */
  s += strspn (s, delim);
  if (*s == '\0')
    {
      *save_ptr = s;
      return NULL;
    }

  /* Find the end of the token.  */
  end = s + strcspn (s, delim);
  if (*end == '\0')
    {
      *save_ptr = end;
      return s;
    }

  /* Terminate the token and make *SAVE_PTR point past it.  */
  *end = '\0';
  *save_ptr = end + 1;
  return s;
}
#ifdef weak_alias
libc_hidden_def (__strtok_r)
weak_alias (__strtok_r, strtok_r)
#endif
```

## Reference
- [C语言线程安全:不可重入函数汇总](https://vimsky.com/article/3185.html)
