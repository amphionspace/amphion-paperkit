# Datasets INDEX (derived view)

This is a human-readable view derived from [`INDEX.yaml`](INDEX.yaml).
`INDEX.yaml` is the single source of truth; PDFs are gitignored and downloaded by `tools/fetch-refs.py`.

Total entries: 31 across 4 groups.

## 1. 中文 ASR 数据集 (10)

中文 ASR 训练 / 评测语料（朗读 / 工业 / 大规模 / 方言 / 中英混合）。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [bu2017-aishell1.pdf](https://arxiv.org/pdf/1709.05522.pdf) | AISHELL-1: An Open-Source Mandarin Speech Corpus and a Speech Recognition Baseline | 2017-09 | 170 h 朗读 / 400 speakers；中文 ASR baseline test set 必引。 |
| [du2018-aishell2.pdf](https://arxiv.org/pdf/1808.10583.pdf) | AISHELL-2: Transforming Mandarin ASR Research Into Industrial Scale | 2018-08 | 1000 h iOS 朗读 / 1991 speakers；工业规模中文 ASR test set。 |
| [shi2020-aishell3.pdf](https://arxiv.org/pdf/2010.11567.pdf) | AISHELL-3: A Multi-speaker Mandarin TTS Corpus | 2020-10 | 85 h 多说话人 TTS / 218 speakers；TTS / TS-ASR 合成源。 |
| [fu2021-aishell4.pdf](https://arxiv.org/pdf/2104.03603.pdf) | AISHELL-4: An Open Source Dataset for Speech Enhancement, Separation, Recognition and Speaker Diarization in Conference Scenario | 2021-04 | 120 h 8-channel 会议 / 4–8 speakers per session；多人会议 ASR + diarization baseline 可引。 |
| [zhang2022-wenetspeech.pdf](https://arxiv.org/pdf/2110.03370.pdf) | WenetSpeech: A 10000+ Hours Multi-domain Mandarin Corpus for Speech Recognition | 2021-10 | 10000 h + 2400 h 弱标注 + 10000 h 无标注（22400 h 总）；中文 ASR 大规模数据。 |
| [ma2024-wenetspeech4tts.pdf](https://arxiv.org/pdf/2406.05763.pdf) | WenetSpeech4TTS: A 12,800-hour Mandarin TTS Corpus for Large Speech Generation Model Benchmark | 2024-06 | 12800 h DNSMOS-filtered (Premium/Standard/Basic/Rest)；中文 TTS / TS-ASR 合成源。 |
| [tang2021-kespeech.pdf](https://arxiv.org/pdf/2110.06023.pdf) | KeSpeech: An Open Source Speech Dataset of Mandarin and Its Eight Subdialects | 2021-10 | 1542 h / 27237 speakers / Mandarin + 8 dialects；多方言中文。 |
| [wang2015-thchs30.pdf](https://arxiv.org/pdf/1512.01882.pdf) | THCHS-30: A Free Chinese Speech Corpus | 2015-12 | 35 h Mandarin 朗读；中文 ASR 小数据集 baseline。 |
| [li2022-talcs.pdf](https://arxiv.org/pdf/2206.13135.pdf) | TALCS: An Open-source Mandarin-English Code-switching Corpus and a Speech Recognition Baseline | 2022-06 | 587 h Mandarin-English code-switch；中英混合训练 + dev 集。 |
| [lyu2010-seame.pdf](https://www.isca-archive.org/interspeech_2010/lyu10_interspeech.pdf) | SEAME: A Mandarin-English Code-switching Speech Corpus in South-East Asia | 2010-09 | 63–192 h Mandarin-English 自然口语 code-switch；Code-switch benchmark 补充。 |

## 2. 英文 / 多语 ASR 数据集 (11)

英文与多语种 ASR 训练 / 评测语料（朗读 / 多语种 / 长音频 / 口音）。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [panayotov2015-librispeech.pdf](https://www.danielpovey.com/files/2015_icassp_librispeech.pdf) | LibriSpeech: An ASR Corpus Based on Public Domain Audio Books | 2015-04 | 960 h 朗读 audiobook (train-clean-100/360 + train-other-500)； 英文 ASR baseline 必引；TS-ASR Libri2Mix/3Mix 之母。 |
| [pratap2020-mls.pdf](https://arxiv.org/pdf/2012.03411.pdf) | MLS: A Large-Scale Multilingual Dataset for Speech Research | 2020-12 | 44.5 k h EN + 6 k h × 7 其他语种；英文 ASR 大规模 + 多语。 |
| [ardila2020-commonvoice.pdf](https://arxiv.org/pdf/1912.06670.pdf) | Common Voice: A Massively-Multilingual Speech Corpus | 2019-12 | 2500 h（2019 当时），现在已远超；100+ 语；多语 + 热词测试。 |
| [chen2021-gigaspeech.pdf](https://arxiv.org/pdf/2106.06909.pdf) | GigaSpeech: An Evolving, Multi-domain ASR Corpus with 10,000 Hours of Transcribed Audio | 2021-06 | 10000 h 标注 + 40000 h 总；英文 ASR 大规模。 |
| [conneau2022-fleurs.pdf](https://arxiv.org/pdf/2205.12446.pdf) | FLEURS: Few-shot Learning Evaluation of Universal Representations of Speech | 2022-05 | 102 语种 × ≈12 h；多语种 ASR / LID benchmark。 |
| [li2024-yodas.pdf](https://arxiv.org/pdf/2406.00899.pdf) | YODAS: Youtube-Oriented Dataset for Audio and Speech | 2024-06 | 500 k h 100+ 语种 YouTube；多语种大规模训练源。 |
| [he2024-emilia.pdf](https://arxiv.org/pdf/2407.05361.pdf) | Emilia: An Extensive, Multilingual, and Diverse Speech Dataset for Large-Scale Speech Generation | 2024-07 | 101 k h 6 语 / 216 k h 扩展；训练前景源 + ESC 在线混合的前景。 |
| [koh2019-nsc.pdf](https://www.isca-archive.org/interspeech_2019/koh19_interspeech.pdf) | Building the Singapore English National Speech Corpus | 2019-09 | >2000 h 新加坡英语；仓库 singaporean / singapore_english 数据源。 |
| [hernandez2018-tedlium3.pdf](https://arxiv.org/pdf/1805.04699.pdf) | TED-LIUM 3: Twice as Much Data and Corpus Repartition for Experiments on Speaker Adaptation | 2018-05 | 452 h TED talks；长音频 / oratory ASR benchmark。 |
| [delrio2021-earnings21.pdf](https://arxiv.org/pdf/2104.11348.pdf) | Earnings-21: A Practical Benchmark for ASR in the Wild | 2021-04 | 39 h earnings calls + NER 注释；长音频 + entity-dense benchmark。 |
| [delrio2022-earnings22.pdf](https://arxiv.org/pdf/2203.15591.pdf) | Earnings-22: A Practical Benchmark for Accents in the Wild | 2022-03 | 119 h 多口音 global earnings calls；长音频 + 口音 benchmark。 |

## 3. 多人 / 分离 / 噪声 / 增广 (5)

多人 ASR、说话人分离、噪声增广、RIR 增广所用的源 corpus。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [cosentino2020-librimix.pdf](https://arxiv.org/pdf/2005.11262.pdf) | LibriMix: An Open-Source Dataset for Generalizable Speech Separation | 2020-05 | Libri2Mix / Libri3Mix；clean / both / single；TS-ASR 开源测试集。 |
| [wichern2019-wham.pdf](https://arxiv.org/pdf/1907.01160.pdf) | WHAM!: Extending Speech Separation to Noisy Environments | 2019-07 | LibriMix `both` mode 的环境噪声源；噪声增广 / 分离。 |
| [gemmeke2017-audioset.pdf](https://research.google.com/pubs/archive/45857.pdf) | Audio Set: An Ontology and Human-labeled Dataset for Audio Events | 2017-03 | 2.08 M × 10 s clips / 527 + 632 ontology；ESC 训练源（仓库 audioset_esc）。 |
| [snyder2015-musan.pdf](https://arxiv.org/pdf/1510.08484.pdf) | MUSAN: A Music, Speech, and Noise Corpus | 2015-10 | 60 h 多语 speech + 多流派 music + noise；加性噪声训练。 |
| [carletta2007-ami.pdf](http://homepages.inf.ed.ac.uk/jeanc/carletta.LREC-keynote06.pdf) | Unleashing the Killer Corpus: Experiences in Creating the Multi-everything AMI Meeting Corpus | 2007-04 | 100 h 会议录音 + 多模态注释；多人会议 ASR / TS-ASR 经典 benchmark。 |

## 4. SER / SEC (语音情感 / 事件) (5)

语音情感识别与事件分类的训练 / 评测语料。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [busso2008-iemocap.pdf](https://www.carlosbusso.com/publications/Busso_2008.pdf) | IEMOCAP: Interactive Emotional Dyadic Motion Capture Database | 2008-12 | 12 h 10 演员 5 dyad sessions / 多模态；英文 SER baseline 必引。 |
| [busso2008-acted-emotional-databases.pdf](https://www.carlosbusso.com/publications/Busso_2008_3.pdf) | Recording Audio-Visual Emotional Databases from Actors: A Closer Look | 2008-05 | IEMOCAP 的 collection methodology 补充；方法学注释（可放 Appendix）。 |
| [lotfian2018-msp-podcast.pdf](https://www.isca-archive.org/interspeech_2018/lotfian18_interspeech.pdf) | Predicting Categorical Emotions by Jointly Learning Primary and Secondary Emotions through Multitask Learning | 2018-09 | 用 MSP-Podcast 1.1 (22 630 句 / 39 h) 做 multitask 主/副情感分类； MSP-Podcast 数据集 + SER 方法学引用入口。 |
| [poria2018-meld.pdf](https://arxiv.org/pdf/1810.02508.pdf) | MELD: A Multimodal Multi-Party Dataset for Emotion Recognition in Conversations | 2018-10 | 13 k utterances / Friends TV / 7 emotion；多人对话 SER（仅 test）。 |
| [zhao2022-m3ed.pdf](https://arxiv.org/pdf/2205.10351.pdf) | M3ED: Multi-modal Multi-scene Multi-label Emotional Dialogue Database | 2022-05 | 990 dialogues × 24449 utterances / 7 emotion；中文多模态 SER。 |

