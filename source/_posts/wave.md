---
title: WAVE音频文件格式分析--实现C语言读写文件头
Antuor: AnSwEr(Weijie Yuan)
comments: true
toc: true
tags:
  - wave文件头
date: 2017-01-09 14:54:17
categories: C
---

本文将详细分析WAVE音频文件的格式,并通过C语言对wave文件头进行读写操作。

----------
<!--more-->

## WAVE音频文件格式分析--实现C语言读写文件头
### WAVE音频文件
WAVE文件格式是一种由微软和IBM联合开发的用于音频数字存储的标准, 它采用*RIFF(Resource Interchange File Format,资源交换文件标准)*文件格式结构文件的扩展名为*“WAV”*, 所有的*WAV*都有一个文件头, 数据本身的格式为*PCM*或压缩型.  

### WAVE文件头
*WAVE*文件分成两部分:文件头和数据块. *WAV*格式文件主要有两种文件头: 标准的44字节文件头和经过了一些软件处理的58字节文件头. 
*WAVE*文件头包含RIFF数据块,一个*"fmt"*数据块和一个*"data"*数据块
> 本文所介绍的*WAV*文件头是标准的44字节文件头.

### WAVE文件格式
![wave format](wave.png)
> **纠正**: ByteRate应该为每秒存储的字节数

通过*WAVE*文件头信息,我们可以计算出播放时长:
```
文件播放时长 = Subchunk2Size/ByteRate
```

### C语言实现对**WAVE**文件头的读写
这里我提供了几个接口供大家使用,[handle_wave.c](https://github.com/AnSwErYWJ/AudioResamplerate/blob/master/src/waveHeader/handle_wave.c) 和 [handle_wave.h](https://github.com/AnSwErYWJ/AudioResamplerate/blob/master/include/waveHeader/handle_wave.h).
```
#ifndef _HANDLE_WAVE_H
#define _HANDLE_WAVE_H

typedef struct
{
    char  riff_id[4];                       //"RIFF"
    int   riff_datasize;                    // RIFF chunk data size,exclude riff_id[4] and riff_datasize,total - 8

    char  riff_type[4];                     // "WAVE"

    char  fmt_id[4];                        // "fmt "
    int   fmt_datasize;                     // fmt chunk data size,16 for pcm
    short fmt_compression_code;             // 1 for PCM
    short fmt_channels;                     // 1(mono) or 2(stereo)
    int   fmt_sample_rate;                  // samples per second
    int   fmt_avg_bytes_per_sec;            // sample_rate * channels * bit_per_sample / 8
    short fmt_block_align;                  // number bytes per sample, bit_per_sample * channels / 8
    short fmt_bit_per_sample;               // bits of each sample(8,16,32).

    char  data_id[4];                       // "data"
    int   data_datasize;                    // data chunk size,pcm_size - 44
}WaveHeader_t;

void init_wavheader(WaveHeader_t *wavheader);
int read_wavheader(FILE *fp,WaveHeader_t *wavheader);
int write_wavheader(FILE *fp,WaveHeader_t wavheader);
void print_wavheader(WaveHeader_t wavheader);

#endif
```

```
#include <stdio.h>
#include <stdlib.h>
#include "handle_wave.h"

/* read and write integer from file stream */
static int get_int(FILE *fp)
{
    char *s;
    int i;
    s = (char *)&i;
    size_t len = sizeof(int);
    int n = 0;
    for(;n < len;n++)
    {
    	s[n]=getc(fp);
    	//printf("%x\n",s[n]);
    }
    return i;
}

static int put_int(int i,FILE *fp)
{
    char *s;
    s=(char *)&i;
    size_t len = sizeof(int);
    int n = 0;
    for(;n < len;n++)
    {
    	putc(s[n],fp);
        //printf("%x\n",s[n]);
    }

    return i;
}

static short int get_sint(FILE *fp)
{
    char *s;
    short int i;
    s = (char *)&i;
    size_t len = sizeof(short);
    int n = 0;
    for(;n < len;n++)
    {
    	s[n]=getc(fp);
    	//printf("%x\n",s[n]);
    }

    return i;
}

static short int put_sint(short int i,FILE *fp)
{
    char *s;
    s=(char *)&i;
    size_t len = sizeof(short);
    int n = 0;
    for(;n < len;n++)
    {
    	putc(s[n],fp);
        //printf("%x\n",s[n]);
    };

    return i;
}

void init_wavheader(WaveHeader_t *wavheader)
{
	sprintf(wavheader->riff_id,"RIFF");
    wavheader->riff_datasize = -1;

    sprintf(wavheader->riff_type,"WAVE");

    sprintf(wavheader->fmt_id,"fmt ");
    wavheader->fmt_datasize = 16;
    wavheader->fmt_compression_code = 1;
    wavheader->fmt_channels = -1;
    wavheader->fmt_sample_rate = -1;
    wavheader->fmt_avg_bytes_per_sec = -1;
    wavheader->fmt_block_align = -1;
    wavheader->fmt_bit_per_sample = 16;

    sprintf(wavheader->data_id,"data");
    wavheader->data_datasize = -1;
}

int read_wavheader(FILE *fp,WaveHeader_t *wavheader)
{
	if (fp ==NULL)
		return -1;

    fread(wavheader->riff_id,4,1,fp);
    wavheader->riff_datasize = get_int(fp);
    fread(wavheader->riff_type,4,1,fp);
    fread(wavheader->fmt_id,4,1,fp);
    wavheader->fmt_datasize = get_int(fp);
    wavheader->fmt_compression_code = get_sint(fp);
    wavheader->fmt_channels = get_sint(fp);
    wavheader->fmt_sample_rate = get_int(fp);
    wavheader->fmt_avg_bytes_per_sec = get_int(fp);
    wavheader->fmt_block_align = get_sint(fp);
    wavheader->fmt_bit_per_sample = get_sint(fp);
    fread(wavheader->data_id,4,1,fp);
    wavheader->data_datasize = get_int(fp);

    return 0;
}

int write_wavheader(FILE *fp,WaveHeader_t wavheader)
{
	if (fp ==NULL)
		return -1;

    fwrite(wavheader.riff_id,4,1,fp);
    put_int(wavheader.riff_datasize,fp);
    fwrite(wavheader.riff_type,4,1,fp);
    fwrite(wavheader.fmt_id,4,1,fp);
    put_int(wavheader.fmt_datasize,fp);
    put_sint(wavheader.fmt_compression_code,fp);
    put_sint(wavheader.fmt_channels,fp);
    put_int(wavheader.fmt_sample_rate,fp);
    put_int(wavheader.fmt_avg_bytes_per_sec,fp);
    put_sint(wavheader.fmt_block_align,fp);
    put_sint(wavheader.fmt_bit_per_sample,fp);
    fwrite(wavheader.data_id,4,1,fp);
    put_int(wavheader.data_datasize,fp);

    return 0;
}

void print_wavheader(WaveHeader_t wavheader)
{
    printf("wavheader.riff_id: %c%c%c%c\n",wavheader.riff_id[0],wavheader.riff_id[1],wavheader.riff_id[2],wavheader.riff_id[3]);
    printf("wavheader.riff_datasize: %d\n",wavheader.riff_datasize);
    printf("wavheader.riff_type: %c%c%c%c\n",wavheader.riff_type[0],wavheader.riff_type[1],wavheader.riff_type[2],wavheader.riff_type[3]);
    printf("wavheader.fmt_id: %c%c%c%c\n",wavheader.fmt_id[0],wavheader.fmt_id[1],wavheader.fmt_id[2],wavheader.fmt_id[3]);
    printf("wavheader.fmt_datasize: %d\n",wavheader.fmt_datasize);
    printf("wavheader.fmt_compression_code: %hd\n",wavheader.fmt_compression_code);
    printf("wavheader.fmt_channels: %hd\n",wavheader.fmt_channels);
    printf("wavheader.fmt_sample_rate: %d\n",wavheader.fmt_sample_rate);
    printf("wavheader.fmt_avg_bytes_per_sec: %d\n",wavheader.fmt_avg_bytes_per_sec);
    printf("wavheader.fmt_block_align: %hd\n",wavheader.fmt_block_align);
    printf("wavheader.fmt_bit_per_sample: %hd\n",wavheader.fmt_bit_per_sample);
    printf("wavheader.data_id: %c%c%c%c\n",wavheader.data_id[0],wavheader.data_id[1],wavheader.data_id[2],wavheader.data_id[3]);
    printf("wavheader.data_datasize: %d\n",wavheader.data_datasize);
}
```

## About me
[![forthebadge](http://forthebadge.com/images/badges/ages-20-30.svg)](http://forthebadge.com)
- GitHub：[AnSwErYWJ](https://github.com/AnSwErYWJ)
- Blog：[http://www.answerywj.com](http://www.answerywj.com)
- Email：[yuanweijie1993@gmail.com](https://mail.google.com)
- Weibo：[@AnSwEr不是答案](http://weibo.com/1783591593)
- CSDN：[AnSwEr不是答案的专栏](http://blog.csdn.net/u011192270)

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
本作品采用知识共享署名-相同方式共享 4.0 国际许可协议进行许可。


