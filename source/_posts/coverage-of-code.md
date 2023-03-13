---
title: C代码覆盖率测试工具Gcov
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags: 代码覆盖率
categories: C/C++
abbrlink: 63477
date: 2018-09-25 18:48:49
---

代码覆盖率测试反映了测试的广度与深度，量化了测试和开发质量，是十分有必要的，业界目前有针对各种语言的覆盖率测试工具，本文主要介绍`C/C++`相关的覆盖率测试工具`Gcov`
<!--more-->

## 介绍
### 简介
`Gcov`是一个测试覆盖程序，是集成在`GCC`中的，随`GCC`一起发布

### 基本概念
#### 基本块BB
基本块指一段程序的第一条语句被执行过一次后，这段程序中的每一跳语句都需要执行一次，称为基本块，因此基本块中的所有语句的执行次数是相同的，一般由多个顺序执行语句后边跟一个跳转语句组成

#### 跳转ARC
从一个`BB`到另外一个`BB`的跳转叫做一个`ARC`,要想知道程序中的每个语句和分支的执行次数，就必须知道每个`BB`和`ARC`的执行次数

#### 程序流图
如果把`BB`作为一个节点，这样一个函数中的所有`BB`就构成了一个有向图，要想知道程序中的每个语句和分支的执行次数，就必须知道每个`BB`和`ARC`的执行次数，根据图论可以知道有向图中`BB`的入度和出度是相同的，所以只要知道了部分的`BB`或者`ARC`大小，就可以推断所有的大小，这里选择由`ARC`的执行次数来推断`BB`的执行次数，所以对部分`ARC`插桩，只要满足可以统计出来所有的`BB`和`ARC`的执行次数即可

### 原理
测试程序首先进行编译预处理，生成汇编文件，并完成插桩，插桩的过程中会向源文件的末尾插入一个静态数组，数组的大小就是这个源文件中桩点的个数，数组的值就是桩点的执行次数，每个桩点插入3~4条汇编语句，直接插入生成的`*.s`文件中，最后汇编文件经过汇编生成目标文件，在程序运行过程中桩点负责收集程序的执行信息

## 使用
### 编译
测试代码如下：  
`say.c`:
```
#include <stdio.h>

int say(char *what) {
    printf("------ %s\n", what);
    return 0;
}
```
`main.c`
```
#include <stdio.h>

extern int say(const char *);

int main(int argc, const char *argv[]) {
    
    if (argv[1]) {
        say("hello");
    } else {
        say("bye");
    }
    return 0;
}

```

添加`-fprofile-arcs -ftest-coverage -fPIC`编译参数编译程序，生成可执行程序和`*.gcno`文件，里面记录了行信息和程序流图信息：
```
$ gcc -fprofile-arcs -ftest-coverage -fPIC -O0 say.c main.c

$ ls
a.out  main.c  main.gcno  say.c  say.gcno  
```

### 数据收集
运行可执行文件，生成`*.gcda`在默认生成在相应`*.o`文件目录，里面记录了`*.c`文件中程序的执行情况，包括跳变次数等:
```
$ ./a.out
------ bye

$ ls
a.out  main.c  main.gcda  main.gcno  say.c  say.gcda  say.gcno
```
可以通过设置环境变量`GCOV_PREFIX=/xxx/xxx`和`GCOV_PREFIX_STRIP=x`来改变路径，其中`GCOV_PREFIX_STRIP`表示去掉源代码路径中的前几级，默认为`0`，比如源代码路径为`/a/b/c/d.c`，`GCOV_PREFIX_STRIP=2`，则实际使用的路径是`c/d.c`，如果`GCOV_PREFIX=/e/f`，则`.gcda`实际存放的路径是`/e/f/c/d.gcda`

### 报告生成
针对某一个文件的执行情况，可以通过如下命令生成报告，并创建`*.gcov`文件：
```
$ gcov -a main.c
File 'main.c'
Lines executed:80.00% of 5
Creating 'main.c.gcov'
```
常用选项，更多可参考[Invoking gcov](https://gcc.gnu.org/onlinedocs/gcc/Invoking-Gcov.html#Invoking-Gcov)：
```
-b：分支覆盖
-a：所有基本块覆盖
-f：函数覆盖
```

### 注意事项
1. 在编译时不要加优化选项，否则代码会发生变化，无法准确定位
2. 代码中复杂的宏，比如宏展开后是循环或者其他控制结构，可以用内联函数来代替，因为`gcov`只统计宏调用出现的那一行
3. 代码每一行最好只有一条语句
4. `*.gcno`与`*.gcda`需要匹配，两个文件是有时间戳来记录是不是匹配的
5. 若是编译动态库，需要在链接时`-lgcov`


### 图形化展示
`gcov`生成的报告分散在各个源码文件所对应的`*.gcov`文件中，难以汇总分析，并且可视化效果较差，所以需要转化成可视图形化报告，有`lcov`或`gcovr`两个工具可以完成，两者功能基本相同，本文主要介绍`gcovr`，是一个用`Python`编写的开源软件，大小只有几十KB，安装参见[官网](https://gcovr.com/installation.html)

#### 列表形式
1. 代码覆盖率
```
$ gcovr -r .
------------------------------------------------------------------------------
                           GCC Code Coverage Report
Directory: .
------------------------------------------------------------------------------
File                                       Lines    Exec  Cover   Missing
------------------------------------------------------------------------------
main.c                                         5       4    80%   15
say.c                                          3       3   100%   
------------------------------------------------------------------------------
TOTAL                                          8       7    87%
------------------------------------------------------------------------------
```
报告展示程序运行后覆盖了`80%`的代码

2. 分支覆盖率
```
$ gcovr -b -r .
------------------------------------------------------------------------------
                           GCC Code Coverage Report
Directory: .
------------------------------------------------------------------------------
File                                    Branches   Taken  Cover   Missing
------------------------------------------------------------------------------
main.c                                         2       1    50%   14
say.c                                          0       0    --%   
------------------------------------------------------------------------------
TOTAL                                          2       1    50%
------------------------------------------------------------------------------
```
报告展示了在`main.c`中有一个分支没有执行到

#### XML文件形式
```
$ gcovr --xml-pretty -r .
<?xml version="1.0" ?>
<!DOCTYPE coverage
  SYSTEM 'http://cobertura.sourceforge.net/xml/coverage-04.dtd'>
<coverage branch-rate="0.5" branches-covered="1" branches-valid="2"
 complexity="0.0" line-rate="0.875" lines-covered="7" lines-valid="8"
 timestamp="1537930892" version="gcovr 3.4">
 <sources>
  <source>.</source>
 </sources>
 <packages>
  <package branch-rate="0.5" complexity="0.0" line-rate="0.875" name="">
   <classes>
    <class branch-rate="0.5" complexity="0.0" filename="main.c"
     line-rate="0.8" name="main_c">
     <methods/>
     <lines>
      <line branch="false" hits="1" number="12"/>
      <line branch="true" condition-coverage="50% (1/2)" hits="1" number="14">
       <conditions>
        <condition coverage="50%" number="0" type="jump"/>
       </conditions>
      </line>
      <line branch="false" hits="0" number="15"/>
      <line branch="false" hits="1" number="17"/>
      <line branch="false" hits="1" number="19"/>
     </lines>
    </class>
    <class branch-rate="0.0" complexity="0.0" filename="say.c" line-rate="1.0"
     name="say_c">
     <methods/>
     <lines>
      <line branch="false" hits="1" number="10"/>
      <line branch="false" hits="1" number="11"/>
      <line branch="false" hits="1" number="12"/>
     </lines>
    </class>
   </classes>
  </package>
 </packages>
</coverage>
```

#### HTML文件形式
```
$ gcovr -r . --html -o xxx.html
$ ls
a.out  main.c  main.gcda  main.gcno  say.c  say.gcda  say.gcno  xxx.html
```
可以发现添加`--html`参数后，可以生成`html`文件，用浏览器打开，如下图：
![gcovr_xxx.png](gcovr_xxx.png)

还可以添加`--html-details`选项，为每个代码文件单独生成`html`
```
$ gcovr -r . --html --html-details -o xxx.html
$ ls
a.out  main.c  main.gcda  main.gcno  say.c  say.gcda  say.gcno  xxx.html  xxx.main.c.html  xxx.say.c.html
```
可以发现多了`xxx.main.c.html`和`xxx.say.c.html`，用浏览器打开`xxx.html`，如下图：
![gcovr_xxx_detail.png](gcovr_xxx_detail.png)
文件名较之前带上了下划线，单击文件名，可以看到具体的代码覆盖情况，如下图：
![gcovr_xxx_main.png](gcovr_xxx_main.png)

#### 其它
其它功能，如`Filters`等，可以参考[官方文档](https://gcovr.com/guide.html)

## Reference
- [gcov—a Test Coverage Program](https://gcc.gnu.org/onlinedocs/gcc/Gcov.html#Gcov)
- [关于C++ code coverage tool 的研究 —GCOV 实现原理](https://blog.csdn.net/bryanlai0720/article/details/38729535)
- [gcovr官网](https://gcovr.com/installation.html)

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)