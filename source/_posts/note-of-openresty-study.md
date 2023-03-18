---
title: 笔记 | OpenResty系列课程
author: AnSwErYWJ
comments: true
category_bar: true
toc: true
categories: Lua
tags: OpenResty
abbrlink: 33307
date: 2017-06-20 17:30:40
---

观看[OpenResty 系列课程](http://www.stuq.org/course/1015/study)的学习笔记
<!--more-->

## 用 OpenResty 快乐的搭建高性能服务端

### 1.1 OpenResty简介
高性能服务端的两个特点：
- 缓存（内存>SSD>机械磁盘，本机>网络，进程内>进程外）
- 异步非阻塞（事件驱动）

### 1.2 hello world
参考资料：
- [官网](http://openresty.org/en/)
- [文档](https://github.com/openresty/lua-nginx-module/blob/master/README.markdown)

`OpenResty = Nginx + LuaJIT（LuaJIT虚拟机嵌在Nginx worker中）`


[lua_code_cache](https://github.com/openresty/lua-nginx-module#lua_code_cache)：`lua`代码缓存，默认开启，支持`set_by_lua_file`和`content_by_lua_file`等指令和`lua`模块，关闭后方便开发（不用重启Nginx），生产环境建议开启（影响性能）

[content_by_lua_file](https://github.com/openresty/lua-nginx-module#content_by_lua_file)：指定要执行的`lua`文件

### 1.3 OpenResty入门
书籍：[openresty最佳实践](https://moonbingbing.gitbooks.io/openresty-best-practices/content/index.html)

运行时的错误日志保存在`logs/error.log`中

`nginx.conf`示例片段：
```
  location = /api/random {
  content_by_lua_file lua/random.lua;
 }
```
`random.lua`：
```
local args = ngx.req.get_uri_args() --max is 100，set 0 to unlimit
local salt = args.salt
if not salt then
  ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local string = ngx.md5(ngx.time() .. salt)
ngx.say(string)
```

### 1.4 ngx lua API介绍
> Tips： 不要使用 `lua API`（阻塞），要用`ngx lua API`（非阻塞）


### 1.5 连接数据库
> Tips： 数据库操作的代码逻辑看上去是同步的，但是内部实现是异步的

主要有[lua-resty-redis](https://github.com/openresty/lua-resty-redis)和[lua-resty-mysql](https://github.com/openresty/lua-resty-mysql)

### 1.6 OpenResty缓存
- [share_dict](https://github.com/openresty/lua-nginx-module#ngxshareddict)： 字典缓存，纯内存缓存，可以预设内存大小，多个`worker`共享，需要锁操作
- [lua-resty-lrucache](https://github.com/openresty/lua-resty-lrucache)：可以预设`key`个数，单个`worker`使用，内存使用翻倍  

缓存失效风暴：在缓存超时时间触发的瞬间，所有的并发请求都同时执行数据库查询操作，数据库压力瞬间变大，下次请求又全部进入缓存，压力瞬间变小，出现两个极值。可以使用[lua-resty-lock](https://github.com/openresty/lua-resty-lock)对数据库查询操作加锁，使数据库查询只进行一次

### 1.7 FFI和第三方模块
`FFI`：`LuaJIT`的一个库，可以在`LuaJIT`中调用`C`的数据结构和外部`C`函数。如[random.lua](https://github.com/openresty/lua-resty-string/blob/master/lib/resty/random.lua)
第三方模块：放在`/openresty/lualib/resty`目录下。

### 1.8 子查询
`ngx.location.capture`和`ngx.location.capture_multi`：在一个`location`内部，对另一个`location`进行请求，因为这不是`http`请求，是`C`级别的调用，所以有开销小的优点; 同时可以降级服务（某一个非关键服务`down`掉，可以继续使用），开放给前端就一个`api`接口即可，在这个`api`接口内做多个子查询，不需要前端调用多个`api`进行查询，避免由于某一个`api`服务挂掉而导致阻塞
```
  location = /api/test_parallels {
  content_by_lua_block {
  local start_time = ngx.now()
  local res1, res2 = ngx.location.capture_multi({
				  {"/sum",{args={a=3, b=8}}},
				  {"/subduction",{args={a=3, b=8}}},
				  })
  ngx.say("status:", res1.status, "response:", res1.body)
  ngx.say("status:", res2.status, "response:", res2.body)
  ngx.say("time used:", ngx.now()-start_time)
  }
  }
```

### 1.9 执行阶段
这个是`Nginx`和`OpenResty`独有的概念，不同的阶段有不同的处理行为，可参考[执行阶段概念](https://moonbingbing.gitbooks.io/openresty-best-practices/content/ngx_lua/phase.html)

## 常用命令
更改conf后，检查conf文件是否正确：`nginx -t -c [conf]`
重启：`nginx：nginx -s reload -p [path]`

## Reference
- [OpenResty 系列课程](http://www.stuq.org/course/1015/study)
- [OpenResty官网](http://openresty.org/en/)
- [OpenResty](https://github.com/openresty)
