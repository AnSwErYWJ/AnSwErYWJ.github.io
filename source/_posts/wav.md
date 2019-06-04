---
title: wav文件解析
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - wav
date: 2019-06-03 15:06:22
categories: C
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
<table>
<tr>
  <th>offset</th>
  <th>field</th>
  <th>size</th>
  <th>description</th>
</tr>
<tr>
  <td>0</td>
  <td>ChunkID</td>
  <td>4</td>
  <td>RIFF</td>
</tr>
<tr>
  <td>4</td>
  <td>ChunkSize</td>
  <td>4</td>
  <td>除了RIFF及自己之外，整个文件的长度，即文件总字节数减去8字节</td>
</tr>
<tr>
  <td>8</td>
  <td>Format</td>
  <td>4</td>
  <td>WAVE</td>
</tr>
<tr>
  <td>12</td>
  <td>Subchunk1lD</td>
  <td>4</td>
  <td>fmt</td>
</tr>
<tr>
  <td>16</td>
  <td>Subchunk1Size</td>
  <td>4</td>
  <td>表示fmt数据块即subchunk1除去Subchunk1lD和Subchunk1Size之后剩下的长度，一般为16</td>
</tr>
<tr>
  <td>20</td>
  <td>AudioFormat</td>
  <td>2</td>
  <td>编码格式，即压缩格式，0x01表示pcm格式，无压缩</td>
</tr>
<tr>
  <td>22</td>
  <td>NumChannels</td>
  <td>2</td>
  <td>通道数</td>
</tr>
<tr>
  <td>24</td>
  <td>SampleRate</td>
  <td>4</td>
  <td>采样率</td>
</tr>
<tr>
  <td>28</td>
  <td>ByteRate</td>
  <td>4</td>
  <td>字节率，ByteRate=SampleRate*BlockAlign</td>
</tr>
<tr>
  <td>32</td>
  <td>BlockAlign</td>
  <td>2</td>
  <td>表示块对齐的内容（数据块的调整数），播放软件一次处理多少个该值大小的字节数据，以便将其用于缓冲区的调整，也表示一帧的字节数，NumChannels*(BitsPerSample/8)</td>
</tr>
<tr>
  <td>34</td>
  <td>BitsPerSample</td>
  <td>2</td>
  <td>采样位宽，即每个采样点的bit数</td>
</tr>
<tr>
  <td>36</td>
  <td>Subchunk2ID</td>
  <td>4</td>
  <td>data</td>
</tr>
<tr>
  <td>40</td>
  <td>Subchunk2Size</td>
  <td>4</td>
  <td>音频数据的总长度，单位字节，即文件总字节数减去44字节</td>
</tr>
<tr>
  <td>44</td>
  <td>Data</td>
  <td></td>
  <td>音频数据</td>
</tr>
</table>

通过`wav`文件头信息，我们可以计算出音频时长:
```
音频时长 = Subchunk2Size/ByteRate
```
#### 编码类型
`wav`文件几乎支持所有`ACM`规范的编码格式，其信息存储在文件头`21`、`22`两个字节中，有如下编码格式：
<table>
<tr>
  <th>编码格式</th>
  <th>描述</th>
</tr>
<tr>
  <td>0 (0x0000)</td>
  <td>Unknown</td>
</tr>
<tr>
  <td>1 (0x0001)</td>
  <td>PCM/uncompressed</td>
</tr>
<tr>
  <td>2 (0x0002)</td>
  <td>Microsoft ADPCM</td>
</tr>
<tr>
  <td>6 (0x0006)</td>
  <td>ITU G.711 a-law</td>
</tr>
<tr>
  <td>7 (0x0007)</td>
  <td>ITU G.711 Âµ-law</td>
</tr>
<tr>
  <td>17 (0x0011)</td>
  <td>IMA ADPCM</td>
</tr>
<tr>
  <td>20 (0x0016)</td>
  <td>ITU G.723 ADPCM (Yamaha)</td>
</tr>
<tr>
  <td>49 (0x0031)</td>
  <td>GSM 6.10</td>
</tr>
<tr>
  <td>64 (0x0040)</td>
  <td>ITU G.721 ADPCM</td>
</tr>
<tr>
  <td>80 (0x0050)</td>
  <td>MPEG</td>
</tr>
<tr>
  <td>65,536 (0xFFFF)</td>
  <td>Experimental</td>
</tr>
</table>


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