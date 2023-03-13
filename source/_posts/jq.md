---
title: Linux下处理json数据
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
categories: 系统配置
tags: json
abbrlink: 63699
date: 2016-10-10 10:50:40
---

当我们在Linux下需要处理json数据时,第一反应是用脚本编写一个工具,这样即耗时又不通用. 本文将介绍专门的命令行json处理工具**jq**.
<!--more-->

## 安装
Ubuntu用户可以直接使用下列命令安装:
```
$ sudo apt-get install jq 
```
也可以选择[源码](https://github.com/stedolan/jq)安装,当然最简单的方法是直接下载[可执行文件](https://stedolan.github.io/jq/),不过需要找到适配你系统的版本.

详细的安装方法可以参考[这里](https://stedolan.github.io/jq/download/).

## 使用
首先构建一个基本的字符串作为示例 test.json:
```
{
    "name": "中国",
    "province": [{
        "name": "黑龙江",
        "cities": {
            "city": ["哈尔滨", "大庆"]
        }
    }, {
        "name": "广东",
        "cities": {
            "city": ["广州", "深圳", "珠海"]
        }
    }, {
        "name": "台湾",
        "cities": {
            "city": ["台北", "高雄"]
        }
    }, {
        "name": "新疆",
        "cities": {
            "city": ["乌鲁木齐"]
        }
    }]
}
```

### 解析json对象
```
$ cat test.json | jq '.name'
"中国"

$ cat test.json | jq '.province[0].name'
"黑龙江"

$ cat test.json | jq '.province[].name'
"黑龙江"
"广东"
"台湾"
"新疆"
```

### 提取字段
```
$ cat test.json | jq '.province[0]'
{
  "cities": {
    "city": [
      "哈尔滨",
      "大庆"
    ]
  },
  "name": "黑龙江"
}

$ cat test.json | jq '.province[]'
{
  "cities": {
    "city": [
      "哈尔滨",
      "大庆"
    ]
  },
  "name": "黑龙江"
}
{
  "cities": {
    "city": [
      "广州",
      "深圳",
      "珠海"
    ]
  },
  "name": "广东"
}
{
  "cities": {
    "city": [
      "台北",
      "高雄"
    ]
  },
  "name": "台湾"
}
{
  "cities": {
    "city": [
      "乌鲁木齐"
    ]
  },
  "name": "新疆"
}


$ cat test.json | jq '.province[0] | {name ,cities}'
{
  "cities": {
    "city": [
      "哈尔滨",
      "大庆"
    ]
  },
  "name": "黑龙江"
}

$ cat test.json | jq '.province[0] | {name}'
{
  "name": "黑龙江"
}
```

## 内建函数
keys用来提取json中的key元素:
```
$ cat test.json | jq 'keys'
[
  "name",
  "province"
]

$ cat test.json | jq '.|keys'
[
  "name",
  "province"
]

$ cat test.json | jq '.province[0]|keys'
[
  "cities",
  "name"
]

$ cat test.json | jq '.province[]|keys'
[
  "cities",
  "name"
]
[
  "cities",
  "name"
]
[
  "cities",
  "name"
]
[
  "cities",
  "name"
]
```

has用来判断是否存在某个key:
```
$ cat test.json | jq 'has("name")'
true
$ cat test.json | jq '.province[0] | has("name")'
true
$ cat test.json | jq 'has("noname")'
false
```

### 验证json
若json串格式错误的话,可以直接使用jq运行,会报出具体错误.

## 总结
有了这个工具.你就可以直接在命令行或者shell脚本对json数据进行操作了.

-----

<a href="#"><img src="https://img.shields.io/badge/Author-AnSwErYWJ-blue" alt="Author"></a>
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[https://www.answerywj.com](https://www.answerywj.com) 
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[AnSwEr不是答案](https://weibo.com/1783591593)