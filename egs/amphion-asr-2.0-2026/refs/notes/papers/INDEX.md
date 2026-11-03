# Papers INDEX (derived view)

This is a human-readable view derived from [`INDEX.yaml`](INDEX.yaml).
`INDEX.yaml` is the single source of truth; PDFs are gitignored and downloaded by `tools/fetch-refs.py`.

Total entries: 28 across 4 groups. arXiv ids checked against the abstract-page titles on 2026-10-31 (ten entries added and checked on 2026-11-01; the two ISCA entries against their ISCA archive pages).

## 1. 目标说话人识别与提取（方法） (11)

TS-ASR / TSE 方法与直接对比系统；Related work 与 baseline。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [zhang2026-xiaomi-cocktailasr-1.pdf](https://arxiv.org/pdf/2609.11274.pdf) | Xiaomi-CocktailASR-1 Technical Report | 2026-09 | TS-ASR 主对比系统（约 8.9B，Data2Vec2 编码器 + Qwen3-8B，波形级拼接参考 + 1 秒静音 + 混合，支持 CoT）；HTML 表 9–13、图 4。 |
| [zhang2025-thinking-in-cocktail-party.pdf](https://arxiv.org/pdf/2509.15612.pdf) | Thinking in Cocktail Party: Chain-of-Thought and Reinforcement Learning for Target Speaker Automatic Speech Recognition | 2025-09 | CocktailASR-1 的前期工作；语音大模型 TS-ASR 多在合成双人混合上报告字错率的例子。 |
| [guo2024-sq-whisper.pdf](https://arxiv.org/pdf/2412.05589.pdf) | SQ-Whisper: Speaker-Querying based Whisper Model for Target-Speaker ASR | 2024-12 | 可学习说话人查询从注册语音抽提示；Related work（模型）与“合成双人混合评测”例子。 |
| [ma2023-whisper-prompt-tuning-tsasr.pdf](https://arxiv.org/pdf/2312.08079.pdf) | Extending Whisper with Prompt Tuning to Target-Speaker ASR | 2023-12 | 提示微调做 TS-ASR；Related work。 |
| [polok2024-target-speaker-asr-whisper.pdf](https://arxiv.org/pdf/2409.09543.pdf) | Target Speaker ASR with Whisper | 2024-09 | 逐帧说话人日志结果调制编码器；Related work。 |
| [meng2024-mt-llm.pdf](https://arxiv.org/pdf/2409.08596.pdf) | Large Language Model Can Transcribe Speech in Multi-Talker Scenarios with Versatile Instructions | 2024-09 | 多说话人语音大模型（MT-LLM），指令里可给目标说话人的注册片段；设计对比表。 |
| [yin2025-speakerlm.pdf](https://arxiv.org/pdf/2508.06372.pdf) | SpeakerLM: End-to-End Versatile Speaker Diarization and Recognition with Multimodal Large Language Models | 2025-08 | 带注册说话人的说话人日志 + 识别语音大模型（中文）；设计对比表。 |
| [polok2024-dicow.pdf](https://arxiv.org/pdf/2501.00114.pdf) | DiCoW: Diarization-Conditioned Whisper for Target Speaker Automatic Speech Recognition | 2024-12 | 用说话人日志掩码而非注册语音指定目标的 Whisper TS-ASR；设计对比表。 |
| [ding2019-personal-vad.pdf](https://arxiv.org/pdf/1908.04284.pdf) | Personal VAD: Speaker-Conditioned Voice Activity Detection | 2019-08 | 以注册说话人为条件的语音活动检测，区分目标与非目标语音；Related work（评测）。 |
| [borsdorf2021-universal-speaker-extraction.pdf](https://www.isca-archive.org/interspeech_2021/borsdorf21_interspeech.pdf) | Universal Speaker Extraction in the Presence and Absence of Target Speakers for Speech of One and Two Talkers | 2021-08 | 目标在场与缺席两种条件下的说话人提取；Related work（评测）。 |
| [zhang2023-tse-presence-absence.pdf](https://www.isca-archive.org/interspeech_2023/zhang23k_interspeech.pdf) | Speaker Extraction with Detection of Presence and Absence of Target Speakers | 2023-08 | 说话人提取联合检测目标是否在场；Related work（评测）。 |

## 2. TSE / TS-ASR 的常用评测 (10)

贡献一要对照的“理想化”评测：朗读语音合成混合、目标总在场。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [delcroix2022-listen-only-to-me.pdf](https://arxiv.org/pdf/2204.04811.pdf) | Listen Only to Me! How Well Can Target Speech Extraction Handle False Alarms? | 2022-04 | TSE 在目标不说话时的误提取；支持“假设目标总在说话的评测会掩盖误提取”。 |
| [zmolikova2023-tse-overview.pdf](https://arxiv.org/pdf/2301.13341.pdf) | Neural Target Speech Extraction: An Overview | 2023-01 | TSE 综述；常用评测（同一说话人另一条语句作注册、目标在场时报 SDR）的依据。 |
| [hershey2016-deep-clustering.pdf](https://arxiv.org/pdf/1508.04306.pdf) | Deep Clustering: Discriminative Embeddings for Segmentation and Separation | 2015-08 | WSJ0-2mix 的出处；常用评测对照表。 |
| [cosentino2020-librimix.pdf](https://arxiv.org/pdf/2005.11262.pdf) | LibriMix: An Open-Source Dataset for Generalizable Speech Separation | 2020-05 | Libri2Mix；常用评测对照表。 |
| [kanda2020-sot.pdf](https://arxiv.org/pdf/2003.12687.pdf) | Serialized Output Training for End-to-End Overlapped Speech Recognition | 2020-03 | LibriSpeechMix 的出处；多说话人 / 目标说话人识别常用评测。 |
| [maciejewski2020-whamr.pdf](https://arxiv.org/pdf/1910.10279.pdf) | WHAMR!: Noisy and Reverberant Single-Channel Speech Separation | 2019-10 | 在 WSJ0-2mix 上加噪声与混响；常用评测对照表。 |
| [peng2025-ts-superb.pdf](https://arxiv.org/pdf/2505.06660.pdf) | TS-SUPERB: A Target Speech Processing Benchmark for Speech Self-Supervised Learning Models | 2025-05 | 含 TS-ASR 等目标说话人任务的自监督模型基准；Related work（评测）。 |
| [liang2023-m2met2.pdf](https://arxiv.org/pdf/2309.13573.pdf) | The second multi-channel multi-party meeting transcription challenge (M2MeT 2.0): A benchmark for speaker-attributed ASR | 2023-09 | 真实会议上的说话人归属识别评测；Related work（评测）。 |
| [vinnikov2024-notsofar1.pdf](https://arxiv.org/pdf/2401.08887.pdf) | NOTSOFAR-1 Challenge: New Datasets, Baseline, and Tasks for Distant Meeting Transcription | 2024-01 | 真实远场会议转写评测；Related work（评测）。 |
| [lee2026-target-speaker-tagging.pdf](https://arxiv.org/pdf/2606.14091.pdf) | Who Spoke When in Multi-Conversation: Target Speaker Tagging Task and Benchmark | 2026-06 | 注册说话人打标签基准，要求拒绝未注册的人并报误报率；Related work（评测）。 |

## 3. 语音大模型与基线 (5)

初始化模型、前作、通用识别基线与编码器。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [qwenteam2026-qwen3-asr.pdf](https://arxiv.org/pdf/2601.21337.pdf) | Qwen3-ASR Technical Report | 2026-01 | 初始化模型（AuT 编码器 + Qwen3-1.7B）；通用识别与热词的主基线；分块注意力窗口 1–8 秒。 |
| [amphionteam2026-amphionasr.pdf](https://github.com/AmphionTeam/AmphionASR/raw/main/main.pdf) | AmphionASR: Personalized Context-Aware Speech Recognition (AmphionASR 1.0) | 2026-07 | AmphionASR 1.0。动机依据见 §5.4（in-house 合成 TS 评测，WER 13.02%、漏识 4.13%、164 条无人声缺席样本 FA 6.10%，自述不能证明与专用 TS-ASR 系统可比）；通用识别比较（HTML 表 19）只引用其已发表数字。 |
| [radford2022-whisper.pdf](https://arxiv.org/pdf/2212.04356.pdf) | Robust Speech Recognition via Large-Scale Weak Supervision | 2022-12 | Whisper 英文规整器（英文 WER 规整口径）。 |
| [xie2026-mega-asr.pdf](https://arxiv.org/pdf/2605.19833.pdf) | Mega-ASR: Towards In-the-Wild Speech Recognition via Scaling Up Real-World Acoustic Simulation | 2026-05 | Voice-in-the-Wild-2M 数据来源（普通识别训练数据之一）。 |
| [baevski2022-data2vec2.pdf](https://arxiv.org/pdf/2212.07525.pdf) | Efficient Self-supervised Learning with Contextualized Target Representations for Vision, Speech and Language | 2022-12 | Data2Vec2：CocktailASR-1 的音频编码器（图 4）。 |

## 4. 推理与训练技术 (2)

部署推理与权重平均。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [kwon2023-vllm.pdf](https://arxiv.org/pdf/2309.06180.pdf) | Efficient Memory Management for Large Language Model Serving with PagedAttention | 2023-09 | vLLM：AmphionASR 2.0 的部署推理栈。 |
| [wortsman2022-model-soups.pdf](https://arxiv.org/pdf/2203.05482.pdf) | Model Soups: Averaging Weights of Multiple Fine-tuned Models Improves Accuracy without Increasing Inference Time | 2022-03 | 发布权重为最后三个 checkpoint 的逐参数平均。 |

## 未入 yaml（暂无可直接下载、已核对的 PDF 链接）

| Authors | Title | Venue | Usage |
| --- | --- | --- | --- |
| K. Žmolíková, M. Delcroix, K. Kinoshita, et al. | SpeakerBeam: Speaker Aware Neural Network for Target Speaker Extraction in Speech Mixtures | IEEE JSTSP, 2019 | TSE 常用设定（同一说话人另一条语句作注册）；HTML 参考文献 [38] |
