---
title: 记一次踩坑|空table应该编码为数组还是对象
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2017-06-16 15:58:40
categories: Lua
tags: lua-cjson
---

`Json`有两种比较常用的数据类型：被`{}`包裹的对象（`object`），被`[]`包裹的数组（`array`）

<!--more-->

## 问题描述
从第三方`API`返回的`json`数据，存在一个`key`的值为空数组，可是经过`decode`和`encode`这两步操作后，这个`key`的值就变为空对象了：
```lua
local cjson = require('cjson')

local raw = {}
raw.name = 'answer'
raw.list = {}
local str = cjson.encode(raw)
print('after cjson encode:', str)
```

输出：
```
after cjson encode:	{"name":"answer","list":{}}
```
`cjson`对于空的`table`，会默认处理为`object`，对于`Lua`本身，是无法区分空数组和空字典的（数组和字典融合到一起了），但是对于强类型语言(`C/C++, Java`等)，这时候就会出现问题，必须作容错处理

## 解决方法
### 使用`encode_empty_table_as_object`方法
```lua
local cjson = require('cjson')

local raw = {}
raw.name = 'answer'
raw.list = {}
cjson.encode_empty_table_as_object(false)
local str = cjson.encode(raw)
print('after cjson encode:', str)
```
输出：
```
after cjson encode:	{"name":"answer","list":[]}
```

### 更换`dkjson`库
```lua
local dkjson = require('dkjson')

local raw = {}
raw.name = 'answer'
raw.list = {}
local str = dkjson.encode(raw)
print('after cjson encode:', str)
```
输出：
```
after cjson encode:	{"name":"answer","list":[]}
```

### 使用`metatable`将`table`标记为`array`
```lua
local cjson = require('cjson')

local raw = {}
raw.name = 'answer'
raw.list = {}
setmetatable(raw.list, cjson.empty_array_mt)
local str = cjson.encode(raw)
print('after cjson encode:', str)
```

输出：
```
after cjson encode:	{"name":"answer","list":[]}
```

## Reference
- [编码为 array 还是 object](https://moonbingbing.gitbooks.io/openresty-best-practices/content/json/array_or_object.html)
- [使用lua CJSON库如何将空table编码成数组](http://blog.csdn.net/ljfrocky/article/details/53034932?_t=t)
- [openresty/lua-cjson](https://github.com/openresty/lua-cjson)

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。
