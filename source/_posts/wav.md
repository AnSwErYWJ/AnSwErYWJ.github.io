---
title: wav文件解析
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - wav
date: 2019-06-03 15:06:22
categories: 语音知识
---

本文将解析`wav`音频文件格式，并实现一套用于读写`wav`文件的`API`。

----------
<!--more-->

## wav文件解析
### wav文件简介
`wav/wave`文件格式是由微软开发的用于音频数字存储的标准，它采用`RIFF`（`Resource Interchange File Format`，资源交换文件标准）文件规范，文件扩展名为`.wav`，采用小端存储。  

### wav文件头
`wav`文件分成两部分：  
- 文件头：主要包含标准的44字节文件头或经过了一些软件处理的58字节文件头，文件头中包含`RIFF`数据块，一个`fmt`数据块和一个`data`数据块  
- 数据块：用于存储数据，数据本身的格式为`PCM`或压缩型

> 本文所介绍的`wav`文件头是标准的44字节文件头。

### wav文件格式
`wav`文件格式如下:
![wav_header](wav_header.png)

通过`wav`文件头信息，我们可以计算出音频时长:
```
音频时长 = Subchunk2Size/ByteRate
```

#### 编码类型
`wav`文件几乎支持所有`ACM`规范的编码格式，其信息存储在文件头`21`、`22`两个字节中，有如下编码格式：
![audio_code](audio_code.png)


### wav文件读写API
这里提供了一套用于[`wav`文件读写的`API`](https://github.com/AudioTools/wavfile)，欢迎大家来添砖加瓦。

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。