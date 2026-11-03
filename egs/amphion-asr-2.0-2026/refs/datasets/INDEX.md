# Datasets INDEX (derived view)

This is a human-readable view derived from [`INDEX.yaml`](INDEX.yaml).
`INDEX.yaml` is the single source of truth; PDFs are gitignored and downloaded by `tools/fetch-refs.py`.

Total entries: 18 across 4 groups. arXiv ids checked against the abstract-page titles on 2026-10-31.

## 1. 中文识别语料 (5)

TS 目标说话人来源、普通识别训练 / 评测。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [bu2017-aishell1.pdf](https://arxiv.org/pdf/1709.05522.pdf) | AISHELL-1: An Open-Source Mandarin Speech Corpus and a Speech Recognition Baseline | 2017-09 | 通用识别测试（测试文本多数出现在 AISHELL-2 训练里，加 † 不计平均）；基准合成部分说话人来源之一。 |
| [du2018-aishell2.pdf](https://arxiv.org/pdf/1808.10583.pdf) | AISHELL-2: Transforming Mandarin ASR Research Into Industrial Scale | 2018-08 | TS 训练的主要中文目标说话人来源；通用识别测试。 |
| [zhang2022-wenetspeech.pdf](https://arxiv.org/pdf/2110.03370.pdf) | WenetSpeech: A 10000+ Hours Multi-domain Mandarin Corpus for Speech Recognition | 2021-10 | 普通识别训练（清洗子集）；test_net / test_meeting 测试；检索候选热词评测的真实口语来源之一。 |
| [li2022-talcs.pdf](https://arxiv.org/pdf/2206.13135.pdf) | TALCS: An Open-Source Mandarin-English Code-Switching Corpus and a Speech Recognition Baseline | 2022-06 | 中英混说测试。 |
| [zheng2023-3d-speaker.pdf](https://arxiv.org/pdf/2306.15354.pdf) | 3D-Speaker: A Large-Scale Multi-Device, Multi-Distance, and Multi-Dialect Corpus for Speech Representation Disentanglement | 2023-06 | 普通识别训练中的中文远场录音。 |

## 2. 英文识别语料 (4)

普通识别训练 / 评测。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [panayotov2015-librispeech.pdf](https://www.danielpovey.com/files/2015_icassp_librispeech.pdf) | LibriSpeech: An ASR Corpus Based on Public Domain Audio Books | 2015-04 | 英文 TS 目标来源与普通识别训练；test-clean / test-other 测试。 |
| [chen2021-gigaspeech.pdf](https://arxiv.org/pdf/2106.06909.pdf) | GigaSpeech: An Evolving, Multi-domain ASR Corpus with 10,000 Hours of Transcribed Audio | 2021-06 | 普通识别训练与测试；检索候选热词评测。 |
| [ardila2020-common-voice.pdf](https://arxiv.org/pdf/1912.06670.pdf) | Common Voice: A Massively-Multilingual Speech Corpus | 2019-12 | 普通识别训练与中 / 英测试；热词子集。 |
| [pratap2020-mls.pdf](https://arxiv.org/pdf/2012.03411.pdf) | MLS: A Large-Scale Multilingual Dataset for Speech Research | 2020-12 | MLS 英文测试。 |

## 3. 会议、通话与网络对话 (5)

AmphionTS-Bench 真实部分的来源；训练用的真实会议窗口与干扰人。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [fu2021-aishell4.pdf](https://arxiv.org/pdf/2104.03603.pdf) | AISHELL-4: An Open Source Dataset for Speech Enhancement, Separation, Recognition and Speaker Diarization in Conference Scenario | 2021-04 | AmphionTS-Bench 真实远场会议（测试集，阵列第 0 通道）；训练用真实会议窗口（训练集）。 |
| [yu2022-m2met.pdf](https://arxiv.org/pdf/2110.07393.pdf) | M2MeT: The ICASSP 2022 Multi-Channel Multi-Party Meeting Transcription Challenge | 2021-10 | AliMeeting 的出处：基准真实远场会议与近 / 远场对照（测试集）；训练用真实会议窗口（训练集）。 |
| [yang2022-magicdata-ramc.pdf](https://arxiv.org/pdf/2203.16844.pdf) | Open Source MagicData-RAMC: A Rich Annotated Mandarin Conversational (RAMC) Speech Dataset | 2022-03 | 基准真实手机通话（测试集）；训练用真实对话窗口。存在一人多个说话人编号的情况（局限）。 |
| [he2024-emilia.pdf](https://arxiv.org/pdf/2407.05361.pdf) | Emilia: An Extensive, Multilingual, and Diverse Speech Dataset for Large-Scale Speech Generation | 2024-07 | 网络多人对话：基准真实部分（伪标签）与训练用对话窗口、目标说话人来源。 |
| [watanabe2020-chime6.pdf](https://arxiv.org/pdf/2004.09249.pdf) | CHiME-6 Challenge: Tackling Multispeaker Speech Recognition for Unsegmented Recordings | 2020-04 | 干扰人与真实对话训练数据；Related work（评测）。 |

## 4. 噪声与房间响应 (4)

在线混合与基准合成部分的噪声、背景声、房间响应。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [snyder2015-musan.pdf](https://arxiv.org/pdf/1510.08484.pdf) | MUSAN: A Music, Speech, and Noise Corpus | 2015-10 | 训练与基准合成的噪声和音乐。 |
| [wichern2019-wham.pdf](https://arxiv.org/pdf/1907.01160.pdf) | WHAM!: Extending Speech Separation to Noisy Environments | 2019-07 | 真实环境底噪（训练与基准）；同时是常用评测对照表里的 WHAM!。 |
| [fonseca2022-fsd50k.pdf](https://arxiv.org/pdf/2010.00475.pdf) | FSD50K: An Open Dataset of Human-Labeled Sound Events | 2020-10 | 环境事件声与人群录音（背景人声评测、基准背景噪声）。 |
| [dubey2023-dns-challenge.pdf](https://arxiv.org/pdf/2303.11510.pdf) | ICASSP 2023 Deep Noise Suppression Challenge | 2023-03 | DNS 噪声与房间响应（训练与基准底噪）。 |

## 未入 yaml（暂无可直接下载、已核对的 PDF 链接）

| Authors | Title | Venue | Usage |
| --- | --- | --- | --- |
| Z. Tang, D. Wang, Y. Xu, et al. | KeSpeech: An Open Source Speech Dataset of Mandarin and Its Eight Subdialects | NeurIPS Datasets and Benchmarks, 2021 | TS 目标来源（同一说话人普通话 / 方言两次录音）、基准说话人、方言测试；HTML [14] |
| J. Carletta, S. Ashby, S. Bourban, et al. | The AMI Meeting Corpus: A Pre-Announcement | MLMI, 2005 | 干扰人与真实对话训练数据；HTML [26] |
| E. Vincent, S. Watanabe, A. A. Nugraha, J. Barker, R. Marxer | An Analysis of Environment, Microphone and Data Simulation Mismatches in Robust Speech Recognition | Computer Speech & Language, 2017 | CHiME-4 et05_real 测试；HTML [18] |
| J. Traer, J. H. McDermott | Statistics of Natural Reverberation Enable Perceptual Separation of Sound and Space | PNAS, 2016 | MIT 实测房间响应库；HTML [28] |
| — | MagicData Mandarin / THCHS-30 / AISHELL-3 / FLEURS / Voice-in-the-Wild-2M / SpeechIO / WenetSpeech-Chuan / MIR-1K | — | 报告中提到但未单独引用的语料；需要时补条目 |
