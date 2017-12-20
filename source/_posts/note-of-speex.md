---
title: Speex学习笔记
Antuor: AnSwEr(Weijie Yuan)
toc: true
date: 2017-08-04 16:30:40
categories: 
tags: 
---


------
<!--more-->

[TOC]

##  介绍

### Speex编解码器
*Speex*编解码器是一款开源且免费的语音编解码器，遵循*BSD*协议，为分封网络（*packet network*）和网络电话（*VoIP*）而设计，支持文件的压缩
> 为网络电话而不是移动电话而设计，意味着*Speex*对数据丢失具有鲁棒性，但是对数据包损坏不鲁棒，在*VoIP*中的数据包要么完整到达，要么不能到达

*Speex*选用CELP（码激励线性预测编码）编码技术，在高比特率和低比特率都稳定可靠，复杂性适度并且占用内存较少

### 相关概念
#### 采样率
采样率是每秒钟采集到的信号样本数，单位是*Hertz*（*Hz*），*Speex*为三种不同的采样率而设计：*8kHz*（窄带），*16kHz*（宽带）和*32kHz*（超宽带）

#### 比特率
在对语音信号编码时，比特率定义为单位时间内的比特数，单位是比特每秒（*bps*）或通常的千比特每秒（*kbps*）
 > 注意千比特每秒（*kbps*）和千字节每秒（*kBps*）的区别。

#### 质量（可变）
*Speex*是有损的编解码器，意味着压缩率以输入语音信号的保真度为代价
*Speex*可以控制质量和比特率之间的折中，大多数时间由一个范围在*0*到*10*之间的质量参数控制
> 在不变比特率（*CBR*）中，质量参数是一个整数； 在可变比特率（*VBR*）中，质量参数是一个浮点数。

#### 复杂度（可变）
*Speex*允许编码器拥有可变的复杂度，通过一个范围在*1*到*10*之间的整数控制搜索的执行来实现，类似于*gzip*和*bzip2*压缩工具的-1到*-9*选项
正常使用情况下，复杂度为*1*的噪声等级比复杂度为*10*的噪声等级高*1*到*2*个*dB*，但复杂度为*10*的*CPU*要求比复杂度为1的高*5*倍。
> 实际应用中，最好的折中是复杂度*2*到*4*，但在编码非语音声音如*DTMF*声调时更高的复杂度经常被用到

#### 可变比特率（*VBR*）
可变比特率（*VBR*）允许编解码器自适应的根据待编码音频的“难度”动态地改变比特率，如元音和高能瞬态变化的声音需要高比特率以获得好的质量； 但是摩擦音（如*s，f*）用低比特率就能充分编码
+ 优点：*VBR*在相同的质量下能获得更低的比特率，或在不变比特率下获得更好的质量
+ 缺点：在指定质量情况下，无法保证最终的平均比特率；在一些如网络电话（*VoIP*）这样的实时应用中，依赖于最大比特率，这在通信信道中必须足够低。

#### 平均比特率（*ABR*）
平均比特率解决了*VBR*中的一个问题，它动态地调整*VBR*质量以获得指定的比特率，因为质量和比特率是实时调整的，*ABR*的全局质量比正好达到目标平均比特率的*VBR*编码质量稍微差些。

#### 声音活动检测（*VAD*）
*VAD*检测待编码的音频是语音还是无声/背景噪声，*VBR*编码中默认激活
> *Speex*检测出非语言段并仅使用足够复现背景噪声的比特率进行编码，这叫“柔化噪音生成”（*CNG*）。

#### 断续传输（DTX）
断续传输是*VAD/VBR*的附加操作，当背景噪声平稳时会完全停止传输

#### 知觉增强
知觉增强是解码器的一部分，当被启用时，能减少编解码过程中产生的噪声或失真的知觉
 > 在大多数情况下，知觉增强会带来声音客观上的偏离（如仅考虑*SNR*），但最后仍听起来更好（主管增强）

#### 等待时间和算法延时
每一个语音编解码器在传输中都会引入延时，对于*Speex*，延时等于帧长加上处理每一帧需要前几帧的数量
> 在窄带操作中延时为*30ms*，在宽带操作中延时为*34ms*，这不包括编解码帧时的*CPU*时间

## Reference
- [关于pthread_cond_wait使用while循环判断的理解](https://www.cnblogs.com/leijiangtao/p/4028338.html)
- [Linux线程同步之条件变量pthread_cond_t](https://www.cnblogs.com/zhx831/p/3543633.html)
- [APUE]()

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。

