---
title: Shell脚本浮点运算
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
tags:
  - script
categories: Shell脚本
abbrlink: 21307
date: 2016-09-05 14:58:50
---

本文将介绍几种Linux下通过Shell脚本进行浮点数计算的方法。

<!--more-->

## Why
Bash Shell本身不具备处理浮点计算的能力, 如`expr`命令只支持整数运算 :
```
#!/bin/bash
a=59
b=60
expr $a / $b
```
运行结果 :
```
$ ./cal.sh
0
```

## Plan A
使用``bc``进行处理。
代码 :
```
#!/bin/bash

a=59
b=60
echo "scale=4; $a / $b" | bc
```
运行结果 :
```
$ ./bc.sh
.9833
```
> ``scale``表示结果的小数精度。

## Plan B
使用``awk``进行处理。
代码 :
```
#!/bin/bash
a=59
b=60
awk 'BEGIN{printf "%.2f\n",('$a'/'$b')}'
```

运行结果 :
```
$ ./awk.sh
0.98
```


## Compare

使用bc :
![bc](bc.png)

使用awk :
![awk](awk.png)

> 可以看出使用``awk``的效率更高,特别是运算次数比较大时。
