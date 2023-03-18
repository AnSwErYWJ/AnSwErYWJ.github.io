---
title: 记一次踩坑|空table应该编码为数组还是对象
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
categories: Lua
tags: lua-cjson
abbrlink: 43826
date: 2017-06-16 15:58:40
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
