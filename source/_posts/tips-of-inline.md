---
title: inline使用注意事项
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - inline
  - O0
categories: C/C++
abbrlink: 60636
date: 2021-07-28 14:34:31
---

**`GCC`在不优化时不会内联任何函数，除非指定函数的“`always_inline`”属性。**

<!--more-->

先附上结论：**`GCC`在不优化时不会内联任何函数，除非指定函数的“`always_inline`”属性。**
​

测试代码：
```c
#include <stdio.h>

inline void say(void) {
    printf("Hello, World\n");
}

int main(void) {
    say();
    return 0;
}
```

使用`-O3`优化选项，一切正常：
```bash
$ gcc -O3 -o test_O3.o -c test.c
$ g++ test_O3.o -o test_O3
$ ./test_O3
Hello, World
```

使用`-O0`优化选项，链接时报错，提示找不到内联函数`say`：
```bash
$ gcc -O0 -o test_O0.o -c test.c
$ g++ test_O0.o -o test_O0
test_O0.o: In function `main':
test.c:(.text+0x5): undefined reference to `say'
collect2: error: ld returned 1 exit status
```

分别查看文件`test_O0.o`和`test_O3.o`：
```bash
$ readelf -s test_O0.o

Symbol table '.symtab' contains 10 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS test.c
     2: 0000000000000000     0 SECTION LOCAL  DEFAULT    1 
     3: 0000000000000000     0 SECTION LOCAL  DEFAULT    3 
     4: 0000000000000000     0 SECTION LOCAL  DEFAULT    4 
     5: 0000000000000000     0 SECTION LOCAL  DEFAULT    6 
     6: 0000000000000000     0 SECTION LOCAL  DEFAULT    7 
     7: 0000000000000000     0 SECTION LOCAL  DEFAULT    5 
     8: 0000000000000000    16 FUNC    GLOBAL DEFAULT    1 main
     9: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND say
```

```bash
$ readelf -s test_O3.o

Symbol table '.symtab' contains 13 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS test.c
     2: 0000000000000000     0 SECTION LOCAL  DEFAULT    1 
     3: 0000000000000000     0 SECTION LOCAL  DEFAULT    2 
     4: 0000000000000000     0 SECTION LOCAL  DEFAULT    3 
     5: 0000000000000000     0 SECTION LOCAL  DEFAULT    4 
     6: 0000000000000000     0 SECTION LOCAL  DEFAULT    5 
     7: 0000000000000000     0 SECTION LOCAL  DEFAULT    6 
     8: 0000000000000000     0 SECTION LOCAL  DEFAULT    9 
     9: 0000000000000000     0 SECTION LOCAL  DEFAULT   10 
    10: 0000000000000000     0 SECTION LOCAL  DEFAULT    8 
    11: 0000000000000000    21 FUNC    GLOBAL DEFAULT    6 main
    12: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND puts
```
可以发现文件`test_O0.o`中，`inline`修饰的函数`say`为未定义状态，说明`inline`函数并没有展开。
​

指定`say`函数为“`always_inline`”属性：
```c
#include <stdio.h>

__attribute__((always_inline)) inline void say(void) {
    printf("Hello, World\n");
}

int main(void) {
    say();
    return 0;
}
```

重新使用`-O0`优化选项编译运行，一切`ok`：
```bash
$ gcc -O0 -o test.o -c test.c
$ gcc -O0 -o test_O0_2.o -c test.c
$ g++ test_O0_2.o -o test_O0_2
$ ./test_O0_2
Hello, World
```
