# 训练 / 测试数据与数据合成策略（论文 Data 章节素材）

> 与本仓库三份文档配合食用：
> - `model_architecture_qwen3_asr_aut.md` → 模型架构
> - `integrations_tasks_and_prompts.md` → 训练/部署/评测/prompt 全链路
> - 本文档 → 开源数据集清单 + TS-ASR 合成 + ESC 前景混音 + 测试集构造

本文档汇总以下内容，所有数字 / 路径 / 概率均直接来自仓库源文件（`local/prepare_*.py`、`configs/target_speaker/*.json`、`configs/eval_plans/*.yaml`、`src/asr_datamodule.py`、`src/dataset_registry.py`、`src/esc_mixing.py`、`src/ser_datamodule.py`），可直接作为 paper Data 章节的事实依据。

## 1. 训练数据全景

仓库支持五大类训练数据，所有源都以 Lhotse 的 recordings + supervisions（或 cuts）形式存在。以最完整的多任务 `configs/target_speaker/train.yaml` 为例，模型一次训练同时见到 7 类任务、共 30 个数据源。

| 任务类型 | 数据源 | 备注 |
| --- | --- | --- |
| ASR（中文） | aishell, aishell2, aishell3, magicdata, kespeech, aidatatang, primewords, thchs30, common_voice_zh, wenetspeech, wenetspeech4tts, emilia_zh | 大数据用 train_dataset_samples 子采样 |
| ASR（英文） | librispeech, mls, common_voice_en, gigaspeech | 同上 |
| ASR（其他） | singaporean, singapore_english, talcs | TALCS 是中英 code-switch |
| ASR（多语种 registry） | ar/bn/de/es/fr/ja/ko/ru/zh/en 的 fleurs/common_voice/yodas/mls/emilia/... | 通过 `/ai_sds_wuzz/MULTILINGUAL_DATA/dataset_registry.json` 动态注册 |
| Hotwords ASR | aidatatang_hotwords, magicdata_hotwords, gigaspeech_hotwords | 在原 ASR 数据基础上合成的热词侧 supervisions |
| Target-Speaker ASR（合成） | tsasr（mix_all_cuts_all.jsonl.gz） | local/prepare_tsasr_data.py 离线合成 |
| SER | biic_podcast_ser, m3ed_ser, meld_ser, iemocap_ser, msp_podcast_ser, emotion1200_en_ser, emotion1200_zh_ser | 统一 8 标签 |
| SEC | emotion1200_en_sec, emotion1200_zh_sec, emotion1200_en_batch2_sec, emotion1200_zh_batch2_sec | Emotion1200 自带情感描述 |
| ESC | audioset_esc + Emilia 前景在线混合 | local/prepare_audioset_esc_test.py 离线版用于评测 |

### 1.1 ASR 公开数据集（22 个）

| Key | 来源 | 语种 | 是否带 dev | 是否子采样上限 (训练 yaml 示例) | 训练 reps |
| --- | --- | --- | --- | --- | --- |
| librispeech | LibriSpeech (train-clean-100/360/other-500) | en | dev | 全量 | 1 |
| mls | MLS English | en | dev | 500k | 1 |
| common_voice_en | Common Voice EN（cleaned） | en | dev | 500k | 1 |
| gigaspeech | GigaSpeech XL | en | dev | 1M | 1 |
| singaporean | NSC（新加坡英语） | en | 无 | 全量 | 1 |
| singapore_english | Hugging Face singapore_english | en | dev | 全量 | 1 |
| aishell | AISHELL-1 | zh | dev | 全量 | 1 |
| aishell2 | AISHELL-2 | zh | 无 | 500k | 1 |
| aishell3 | AISHELL-3 | zh | 无 | 全量 | 1 |
| magicdata | MagicData (Mandarin) | zh | dev | 全量 | 1 |
| aidatatang | aidatatang_200zh | zh | 无 | 全量 | 1 |
| primewords | Primewords Chinese 100h | zh | 无 | 全量 | 1 |
| thchs30 | THCHS-30 | zh | dev | 全量 | 1 |
| common_voice_zh | Common Voice ZH-CN | zh | dev | 全量 | 1 |
| wenetspeech | WenetSpeech | zh | dev | 1M | 1 |
| wenetspeech4tts | WenetSpeech4TTS | zh | 无 | 500k | 1 |
| emilia_zh | Emilia ZH（DNSMOS-filtered） | zh | 无 | 500k | 1 |
| kespeech | KeSpeech（多方言中文，phase1+phase2） | zh | dev | 500k | 1 |
| talcs | TALCS 中英混合 | mixed | dev | 全量 | 1 |
| (multilingual) | fleurs / common_voice / yodas / mls / emilia / 等 | ar/bn/de/es/fr/ja/ko/ru/zh/en | 部分 | 视语言 | 1 |

仓库内 `_LANGUAGE_NORMALIZE_MAP`（`src/integrations/ms_swift/data/convert.py`）支持把 ISO 639-1 / 639-3 / locale-tag 全部规整成英文全称（`zh` → `Chinese`、`en-us` → `English`，等等），覆盖 zh / en / ja / ko / fr / de / es / ru / pt / it / nl / tr / ar / hi / vi / th / id / ms。

### 1.2 Hotwords ASR 数据（3 个训练集 + 2 个测试集）

仓库不重建音频，只在原始 supervisions 上附加 `custom.hotwords`（候选词列表）与可选 `custom.clean.pass`（QA 标记）。训练侧使用三套带 hotwords 的 supervisions：

| Key | 原始数据 | Supervisions 文件名 | 用途 |
| --- | --- | --- | --- |
| aidatatang_hotwords | aidatatang_200zh | zhaidatatang_supervisions_all_cleaned_punc_hotwords.jsonl.gz | 训练 |
| magicdata_hotwords | MagicData | magicdata_supervisions_train_punc_hotwords.jsonl.gz | 训练 |
| gigaspeech_hotwords | GigaSpeech | gigaspeech_supervisions_XL_punc_hotwords.jsonl.gz | 训练 |
| commonvoice_en_hotwords | Common Voice EN test | cv-en_supervisions_test_orig_punc_hotwords.jsonl.gz | 测试 |
| commonvoice_zh_hotwords | Common Voice ZH test | cv-zh-CN_supervisions_test_punc_hotwords.jsonl.gz | 测试 |

`custom.hotwords` 是论文里的 ground-truth 真实热词；运行时由 `src/integrations/ms_swift/data/hotwords.py` 在每条样本上做"real ∪ hard-negative ∪ random distractor"采样后注入 prompt。

### 1.3 SER 数据（7 个）

`local/prepare_ser_manifests.py` 把六个英文 / 中文 / 多语 SER 公开集统一映射成 8 标签分类（`Neutral, Happy, Sad, Angry, Fear, Disgust, Surprise, Other/Complex`），mapped label 写到 `supervisions.text`，原始 label 保留在 `supervisions.custom`：

| Key | 来源 | 语种 | 备注 |
| --- | --- | --- | --- |
| biic_podcast_ser | BIIC Podcast | zh | 有 dev/test |
| m3ed_ser | M3ED | zh | 有 dev/test |
| meld_ser | MELD | en | 仅 test |
| iemocap_ser | IEMOCAP | en | 仅 test，fear/surprise/disgust 在源数据被映射为 None 丢弃 |
| msp_podcast_ser | MSP-Podcast | en | 有 dev，test 拆 test1/test2 |
| emotion1200_en_ser | Emotion1200-EN | en | 自建，多类细标签 → 8 类 |
| emotion1200_zh_ser | Emotion1200-ZH | zh | 自建，中文细标签 → 8 类 |

8 标签映射对照（`local/prepare_ser_manifests.py` 中的 `*_LABEL_MAP`）：

| 数据源 | 关键映射 |
| --- | --- |
| BIIC | Contempt / Other → Other/Complex；xxx → 丢弃 |
| M3ED | Anger → Angry，其余同名 |
| MELD | joy → Happy，sadness → Sad，anger → Angry |
| IEMOCAP | neu/ang/sad/hap/exc → 5 类（fear/surprise/disgust 丢弃） |
| MSP | N/H/S/A/F/D 直映；U → Surprise；C/O → Other/Complex；X 丢弃 |
| Emotion1200 EN | anxious/nervous/apprehensive/desperate/stressed/harried → Fear；frustrated/defiant/exasperated → Angry；relief/relieved/grateful/amused/admiration/proud → Happy；embarrassed/awkward/sheepish/disappointed/pain/yearning → Sad；shock/awe/bewildered → Surprise |
| Emotion1200 ZH | 焦虑/担忧/担心/忧虑/紧张/焦急/急切/急迫/不安/忐忑/警觉/警惕 → Fear；不屑/轻蔑/嫌弃/讥讽/讽刺 → Disgust；无奈/失望/委屈/痛苦/迷茫/遗憾/难受/疲惫/愧疚 → Sad；自豪/感激/感动/欣慰/庆幸/兴奋 → Happy；震惊 → Surprise |

### 1.4 SEC 数据（4 个）

Emotion1200 同源数据用作"情感描述（一句话 caption）"任务。共 4 个 split：`emotion1200_{en,zh}_sec` 与 `emotion1200_{en,zh}_batch2_sec`。`supervisions.text` 即为目标 caption。训练时这 4 个集合各重复 5 次平衡 mux 权重。

### 1.5 ESC 数据（AudioSet ESC）

`audioset_esc` 来自 `/ai_sds_wuzz/MULTILINGUAL_DATA/sound/AudioSet/manifest_v1_esc/`，约 218k cuts，每条 cut 自带 `custom.label_only_class`（用于识别"silence"背景）。训练时通过 `EscForegroundMix`（见第 4 节）做在线前景 Emilia 语音叠加，让模型学会"忽略说话内容、只描述背景"。

### 1.6 RIR / Noise 资源（增广用）

| 资源 | 路径 | 用途 |
| --- | --- | --- |
| SLR26 sim RIR | sim_rir_slr26_recordings_all.jsonl.gz | TS-ASR 房间响应卷积（合成时） |
| SLR28 sim RIR | sim_rir_slr28_recordings_all.jsonl.gz | 同上 |
| SLR28 real RIR | real_rir_slr28_recordings_all.jsonl.gz | 同上，真实房间 IR |
| MUSAN noise | musan_recordings_noise.jsonl.gz | 加性噪声背景（权重 0.30） |
| MUSAN music | musan_recordings_music.jsonl.gz | 背景音乐（权重 0.20） |
| AudioSet Road Traffic | audioset_road_traffic_recordings_noise.jsonl.gz | 真实交通噪声（权重 0.50） |

工程细节：RIR 卷积按 `_RIR_MAX_DURATION_S = 1.5 s` 截尾（早反射主导可懂度），并通过 `oaconvolve` 做 overlap-add；噪声做 SNR-controlled 加性混合（详见第 3.5 节）。

## 2. 数据子采样与重复策略

`configs/target_speaker/train.yaml` 的两类配置直接决定训练 mux 比例（论文中可作为"data balancing"的描述）：

`train_dataset_samples`（按 supervision 条数截断大数据，单位：utterances）：

| 数据集 | 上限 | 说明 |
| --- | --- | --- |
| wenetspeech | 1,000,000 | 中文 |
| gigaspeech | 1,000,000 | 英文 |
| gigaspeech_hotwords | 1,000,000 | 与 gigaspeech 对齐 mux 权重 |
| emilia_zh | 500,000 | 防止单源吞噬 |
| wenetspeech4tts | 500,000 | 同上 |
| mls | 500,000 | 同上 |
| aishell2 | 500,000 | 同上 |
| common_voice_en | 500,000 | 同上 |
| kespeech | 500,000 | 同上 |

`train_dataset_reps`（重复次数，等价上采样）：

| 数据集 | reps | 动机 |
| --- | --- | --- |
| aidatatang_hotwords | 3 | 与 magicdata/aidatatang 主 ASR 同量级 |
| magicdata_hotwords | 2 | 同上 |
| audioset_esc | 10 | 单源仅 ~218k，10× 后达 ~2.2M 与主力 ASR 回放量级相当 |
| biic_podcast_ser / m3ed_ser / meld_ser / iemocap_ser / msp_podcast_ser / emotion1200_en_ser / emotion1200_zh_ser | 5 | SER 单集普遍 5–50k |
| emotion1200_en_sec / emotion1200_zh_sec / emotion1200_en_batch2_sec / emotion1200_zh_batch2_sec | 5 | SEC 同上 |
| tsasr | 1 | 本身就有 ~3M 条合成样本，无需放大 |

论文里可直接写：所有任务以 utterance-level mux 形式喂入；大语料按上限子采样、小语料按整数倍重复，最终各任务在每个 batch 内的期望占比由 mux 权重控制。

## 3. TS-ASR 训练数据合成（最重要的合成管线）

`local/prepare_tsasr_data.py` 把单说话人 Lhotse manifest 合成为 Target-Speaker ASR 训练 cuts，输出 `mix_all_cuts_all.jsonl.gz`。论文里 TS-ASR 数据可以单独成一节，下面给出按"输入源→合成单元→采样→增广→负样本→输出"的完整描述。

### 3.1 输入源（`source_datasets`）

`configs/target_speaker/synth_raw.json` 共 16 个源（合成"原始"大集 `mix_all_with_negative_v3`，规模约 3 M 样本）：

| 源 | 语种 | Supervisions |
| --- | --- | --- |
| aishell | zh | aishell_supervisions_train |
| aishell2 | zh | aishell2_supervisions_train |
| aishell3 | zh | aishell3_supervisions_train |
| magicdata | zh | magicdata_supervisions_train |
| kespeech | zh | kespeech-asr_supervisions_train_phase1 |
| aidatatang | zh | zhaidatatang_supervisions_all |
| primewords | zh | primewords_supervisions_train |
| thchs30 | zh | thchs_30_supervisions_train |
| cv_zh | zh | cv-zh-CN_supervisions_train |
| emilia_zh | zh | emilia_zh_supervisions_all |
| librispeech_100 | en | librispeech_supervisions_train-clean-100 |
| librispeech_360 | en | librispeech_supervisions_train-clean-360 |
| librispeech_500 | en | librispeech_supervisions_train-other-500 |
| mls_en | en | mls-english_supervisions_train |
| cv_en | en | cv-en_supervisions_train_cleaned |
| emilia_en | en | emilia_en_supervisions_all |

`synth_hotwords.json` 是一个仅基于 `cv-en_supervisions_train_orig_punc_hotwords` 的小规模变体（专用于带 hotwords 的 TS-ASR）。

### 3.2 合成单元（每条样本结构）

```
sample = {
  mixed_audio:        target_speech ⊕ {interferer_speech} (⊕ optional RIR ⊕ optional bg_noise),
  enrollment_audio:   3–5 s of target speaker from DIFFERENT utterance,
  text:               target speaker's transcription,
  sample_type:        positive / negative_silence / negative_distractor,
  custom:             {hotwords?, sample_type, dataset, language, ...}
}
```

### 3.3 SpeakerPool 与采样规则

`SpeakerPool` 在加载阶段就把每条 supervision 按 `(dataset, speaker_id)` 分桶（`SpeakerPool.load_dataset`），并在 `filter_speakers` 中按以下硬约束过滤：

| 约束 | 默认 |
| --- | --- |
| 每个 speaker 至少 2 条 utterance | min_utterances=2 |
| enrollment 候选时长范围 | `enrollment.min_duration` ~ `max_duration`（默认 1–5 s，论文级配置 3–5 s） |
| target 候选时长范围 | `target.min_duration` ~ `mixing.max_mixed_duration`（默认 1–30 s） |
| QA 标记 | 丢弃 `custom.clean.pass = false` |
| speaker / language / dataset | 三个二级索引 `speakers / lang_index / dataset_index` 同时维护，支持跨数据集采样 |

采样阶段（`generate_plan`）按 budget-driven 模式工作：

```
max_total_samples → 按 (1 - neg_ratio) 切出 positive 配额
   ↓
pos_cap 在 N 个 source datasets 上平均切（_distribute_quota）
   ↓
每个 dataset 内再按 speaker 数平均切配额（每 speaker 上限 samples_per_speaker，
   且不超过 len(utts) - 1，保证 enrollment ≠ target）
   ↓
干扰说话人采样：默认 same_language_only=true（语种内采），interferers 数量按
   num_interferers_weights 抽样
```

`synth_raw.json` 的关键采样参数：

| 字段 | 值 | 说明 |
| --- | --- | --- |
| seed | 42 | 全局随机种子 |
| sample_rate | 16000 | 输出 wav 采样率 |
| samples_per_speaker | 20 | 单 speaker 最多产 20 条样本 |
| max_total_samples | 3,000,000 | 全局上限 |
| cross_dataset_mixing | true | enrollment 与 interferer 可跨数据集（同语种内） |
| same_language_only | true | 干扰只在同语言池里挑 |
| num_interferers_weights | {1: 0.5, 2: 0.3, 3: 0.2} | 期望 1.7 个干扰说话人 |
| snr_range / snr_mean / snr_std | [-5, 20] / 2.0 / 7.0 dB | target-to-interferer SNR，高斯采样后裁剪 |
| overlap_ratio_range / mean / std | [0.1, 1.0] / 0.35 / 0.5 | 干扰相对 target 的重叠比例 |
| max_mixed_duration | 30 s | 合成混合的最长 |

`synth_template.json`（论文里默认报告的"clean"配置，~3 M 训练样本量级）：

| 字段 | 值 | 与 raw 的差异 |
| --- | --- | --- |
| enrollment.min/max_duration | 3 / 5 s | 比 raw 的 1–5 s 更严格 |
| num_interferers_weights | {1: 0.8, 2: 0.2} | 干扰更少（更接近真实场景） |
| snr_mean / std | 5 / 7 dB | SNR 高 3 dB（更易转写） |
| overlap_ratio_mean / std | 0.35 / 0.2 | 重叠比例分布更窄 |
| augmentation.enable_rir | true | 启用 RIR 卷积 |
| samples_per_speaker | 200 | 每 speaker 上限更高 |

### 3.4 混合核心（`mix_speakers`）

`mix_speakers` 把目标说话人 1-D 波形与 N 个干扰说话人波形混合，每个干扰附带 (snr_db, overlap_ratio) 两个参数：

1. 干扰长度超过 `overlap = tgt_len × overlap_ratio` 时随机裁剪到 `overlap` 长度；
2. 在 target 时间轴上随机选 offset，使干扰与 target 重叠 `min(int_len, tgt_len)`；
3. 按 SNR 缩放：`desired_rms = target_rms × 10^(-snr_db/20)`；
4. 全部叠加后做峰值归一化到 0.95，避免 clip。

数学上等价于：

\[
\mathrm{mixed}[n] = s_{\text{tgt}}[n] + \sum_{k=1}^{K} \alpha_k \cdot s_{\text{int}_k}[n - o_k]
\]

其中 \(\alpha_k = \rho_{\text{tgt}} / \rho_{\text{int}_k} \cdot 10^{-\mathrm{SNR}_k/20}\)，\(o_k\) 为该干扰的随机时间偏移。

### 3.5 增广（RIR + 背景噪声）

RIR 与噪声是 per-sample 独立采样的：

- RIR（`apply_rir`）：从 `RirPool`（SLR26+SLR28 三个 manifest 合池）随机抽一条 IR，截到 ≤1.5 s（早反射主导可懂度），与混音做 `scipy.signal.oaconvolve`；`apply_prob` 控制启用率（默认 0.5）。
- 加性噪声（`add_background_noise`）：从 `NoiseSourcePool`（MUSAN noise / MUSAN music / AudioSet Road Traffic，加权 0.30 / 0.20 / 0.50）抽段，按 SNR 加到混音上，最后再做峰值归一化。SNR 默认 [0, 25] dB（合成 raw 配置）或 [-2, 25] dB（hotwords 配置）。

### 3.6 负样本（反幻觉）

`negative_samples.enable=true` 时启用，比例 `ratio` 默认 0.05 ~ 0.10。两个子类型按 weight 抽签：

| 子类型 | 含义 | 关键参数 |
| --- | --- | --- |
| noise_only | enrollment 真，但混音里没有目标说话人，只有噪声 / 静音 | duration_range=[3, 15] s, num_noises_weights={1:0.7, 2:0.3}, noise_gain_db_range=[-30, 0], include_silence_prob=0.1, noise_source_weights={audioset_road_traffic:0.6, musan_noise:0.3, musan_music:0.1} |
| distractor_only | enrollment 真，但混音里只有其他说话人（无目标） | num_speakers_weights={1:0.5, 2:0.3, 3:0.2}, snr_range=[-5, 20] dB, overlap_ratio_range=[0.1, 1.0] |

两类负样本的 ground-truth text 都是空字符串。论文里直接称为 "anti-hallucination negatives"，配合 unified prompt 里"answer=空"使模型学会在目标说话人缺席时保持沉默；评测端通过 `compute_silence_metrics` 统计 hyp 全空率作为正负样本对齐指标。

### 3.7 工程细节（可放 Appendix）

- 流式 manifest 读取：`_stream_jsonl_gz` 配合 `_derive_load_caps`，按 budget 自动反推 `max_speakers_per_dataset / max_utts_per_speaker / max_samples_per_dataset`，超大 manifest（Emilia / MLS）能在达到 budget 后早停，避免解析尾部无用数据。
- LRU 音频缓存：worker 内 1024 条解码后波形缓存（约 200 MB），对 RIR 池（<1k 条）和噪声池（数千条）命中率极高，网络 FS 上从 25–50 ms/读降到内存返回。
- 多进程：`num_workers=128`，`imap_unordered(chunksize=256)` 摊销 pickle 开销；输出 manifest gzip 压缩级别 1（速度 vs 1.3× 大小的折中）。
- 输出布局：`<out_dir>/mixed_audio/<dataset>/<speaker_id>_mix_<idx>.wav`、`<out_dir>/enrollment_audio/<dataset>/<speaker_id>_enroll_<idx>.wav`、负样本在 `_negative/silence` 与 `_negative/distractor` 子目录。

## 4. ESC 在线前景语音混合（`EscForegroundMix`）

`src/esc_mixing.py:EscForegroundMix` 把"AudioSet ESC 背景声"与"Emilia 干净语音"在线叠加成训练 cut，让模型学会"忽略说话内容、只描述背景"。

### 4.1 前景与背景源

| 源 | 用途 | manifest |
| --- | --- | --- |
| 前景 EN | Emilia EN（DNSMOS-filtered） | emilia_en_dnsmos_gt34_*.jsonl.gz |
| 前景 ZH | Emilia ZH（DNSMOS-filtered） | emilia_zh_dnsmos_gt34_*.jsonl.gz |
| 背景 ESC | audioset_esc train + dev | audioset_esc_recordings_{train,dev}.jsonl.gz |

前景过滤条件：`min_duration ≤ cut.duration ≤ max_duration`（默认 [0.5, 10] s）且有 supervision。在 16 kHz 重采样后形成单一 lazy `CutSet`。

### 4.2 混合模式与概率

`__call__` 时仅对 `task == "esc"` 的 cut 起作用（其他任务直通），按 `p` 概率触发混合：

| 模式 | 描述 | 默认权重（归一化前） |
| --- | --- | --- |
| overlap | 前景语音叠加在背景某随机时间窗内（保留背景全长） | 0.8 |
| prepend | 前景直接接在背景前面（先说话再播背景） | 0.1 |
| append | 前景接在背景后面 | 0.1 |

SNR 处理：默认 `snr ~ Uniform(esc_foreground_snr_min, esc_foreground_snr_max)`（训练 yaml: 0–20 dB）。若背景的 `custom.label_only_class == "silence"`，强制 `snr=None`（直接叠加，不做能量归一化），保证"静音背景 + 任意前景"的 SNR 自由度。

混合后通过 `_annotate` 把以下字段写到 base cut 与 supervision 的 `custom` 中（便于 metric 与 prompt 路由）：

| 字段 | 含义 |
| --- | --- |
| esc_foreground_mode | overlap / prepend / append |
| esc_silence_background | bool（原始背景是否为 silence 类） |
| esc_effective_snr | float 或 None |
| task | "esc"（不可被前景 cut 的 custom 覆盖） |

### 4.3 训练 / Valid / 离线 Test 的对齐

为保证验证 loss 跨 ckpt 可比，valid 路径与离线 test 路径都用固定种子 `_ESC_VALID_MIX_SEED = 20251119`：

| 用途 | 触发方式 |
| --- | --- |
| Train | `esc_foreground_mix=true` + `esc_foreground_prob=1.0`，每个 worker 不同 seed |
| Valid | 同样的 EscForegroundMix，seed = `_ESC_VALID_MIX_SEED` |
| 离线 Test 集 | `local/prepare_audioset_esc_test.py` 生成的 `audioset_esc_test_mixed_cuts.jsonl.gz`（2166 条 dev + Emilia 前景，seed 一致，MixedCut 描述而非重写 wav） |

`configs/target_speaker/train.yaml` 中的 ESC 混合参数：

| 字段 | 值 |
| --- | --- |
| esc_foreground_mix | true |
| esc_foreground_prob | 1.0 |
| esc_foreground_snr_min / max | 0.0 / 20.0 dB |
| esc_overlap_prob / prepend_prob / append_prob | 0.8 / 0.1 / 0.1 |
| esc_foreground_min / max_duration | 0.5 / 10.0 s |

## 5. Hotwords 数据合成与候选注入

### 5.1 真实热词来源

训练 / 测试侧的 hotwords supervisions 都是离线产出（论文里只需说明"按数据集统一抽取领域名词作为真实热词"即可，下游代码不关心它们的具体抽取算法）。lhotse `supervisions.custom.hotwords` 是一个 list[str]，每条 supervision 单独标注。

候选词长度过滤（`is_valid_hotword`，按"字符制 / 词制脚本"分支）：

| 脚本 | 计数单位 | min_len | max_len |
| --- | --- | --- | --- |
| CJK / Thai | 字符（排除空格） | 2 | 8 |
| Latin 等 | 词（空格切分） | 1 | 8 |

### 5.2 Prompt 注入策略（训练时）

由 `src/integrations/ms_swift/data/hotwords.py:build_hotwords_for_sample` 在每条样本上独立执行，并在 `convert.py` 中通过两个全局概率门控：

1. `prompt_hotword_prob`（默认 0.8）：以该概率"保留 Hotwords 行"，否则整行省略；
2. `miss_prob`（默认 0.0）：每个真实热词独立丢弃概率，模拟检索召回不全；
3. distractor 总数 `n_distractor ~ Uniform[1, min(max_hotwords, |pool|)]`，其中 `max_hotwords=30`；
4. `n_hard = round(n_distractor × hard_neg_ratio)`，剩余从全 pool 随机抽，二者去重；
5. 拼成 `real ∪ sampled_hard ∪ sampled_random`，shuffle 后逗号拼接。

### 5.3 Hard-negative 检索（online）

`retrieve_hard_negatives_online` 给出"与目标转写易混淆的近邻热词"，论文里可单独成一段 Algorithm：

| 信号 | 实现 |
| --- | --- |
| 字符共现 + bigram Jaccard | 字符 → hotword 倒排索引；overlap = |hw ∩ text_chars| / |hw|；bigram Jaccard；最终打分 `0.6 × overlap + 0.4 × jaccard`，取 top-K |
| 同音 / 近音 | `pypinyin.lazy_pinyin` 把 hotword 转 syllable tuple；`PinyinIndex` 维护 exact + (n, pos, syllable) 倒排，支持"换 1 个 syllable"邻居搜索 |

注入策略默认参数：`online_hard_neg=true`, `online_hard_neg_top_k=10`, `hard_neg_ratio=1.0`, `miss_prob=0.05`, `max_hotwords=20`（来自 `configs/hotwords/train.yaml` 与 `configs/target_speaker/train.yaml`）。

### 5.4 Hotwords 测试侧（候选填充）

评测时为保证不同 spec 公平对比，按 `eval_vllm.sh -w K` 把每条样本的热词"填到 K 个"：`real ∪ random_distractor`（不引入额外 hard-neg），保证：

- K=0：基线，不含 hotwords 行（train 风格还会显式渲染 `Hotwords:N/A`）；
- K=N（N≥|real|）：把 N - |real| 个 distractor 从该数据集自带的全池里抽，避免引用数据集没见过的字符串。

`configs/eval_plans/hotwords.yaml` 默认 sweep `K ∈ {0, 5, 10, 15, 20}`，对中英两个 CV-hotwords 测试集各跑一遍。

## 6. ms-swift 端的"二次合成"：Lhotse → ShareGPT JSONL

训练数据从 Lhotse 到 ShareGPT 的转换全部在 `src/integrations/ms_swift/data/convert.py`（见 `integrations_tasks_and_prompts.md` 第 2 节），其与"数据合成"相关的关键点回顾：

- TS-ASR cuts 自带 `custom.enrollment_audio`，转换器自动把它放到 `audios[0]`、mixed audio 放 `audios[1]`，并使用"Given the speaker's voice ... Transcribe what this speaker says ..."模板；
- 负样本 (`sample_type` 以 `negative` 开头) 的 `text` 强制覆写为空字符串；
- 单说话人 + 普通 supervision 走"Transcribe the following audio."模板，并按概率决定 Language / Hotwords 是否出现；
- 段切片：只有 `start>0` 或 `duration < rec.duration - 0.05` 时才真正写新 wav 到 `<out>/<data_name>_segments/`，避免无谓 IO；
- 多源混合后写入单一 JSONL（推荐 TS-ASR cuts + 普通 supervision 按 ~1:1 拼），让模型学会"是否有 enrollment"的分支。

## 7. 测试 / 评测数据

所有评测都通过 `src/dataset_registry.py` 注册表统一寻址，`src/decode.py`（icefall-style）与 `src/integrations/vllm/test_vllm_inference.py`（vLLM HTTP 端）共享同一个 registry，保证结果可对齐。

### 7.1 注册表（`TEST_SET_DEFS`）摘要

| 任务 | 数据集 | kind | 路径关键字段 |
| --- | --- | --- | --- |
| ASR-zh | aishell, aishell2, aishell3, magicdata, kespeech, thchs30, commonvoice_zh, wenetspeech_test_net, wenetspeech_test_meeting | single | 对应原 manifest dir |
| ASR-en | librispeech_test_clean, librispeech_test_other, gigaspeech, mls, commonvoice_en | single | 同上 |
| ASR 多语种 | multilingual:zh:fleurs_zh, multilingual:en:fleurs_en | multilingual | `/ai_sds_wuzz/MULTILINGUAL_DATA/dataset_registry.json` |
| ASR mixed | talcs | single | talcs_supervisions_test_cleaned |
| Hotwords ASR | commonvoice_en_hotwords, commonvoice_zh_hotwords | single + post_filter=_clean_pass | `_orig_punc_hotwords` / `_punc_hotwords` |
| TS-ASR | ts_hw_test, libri2mix, libri3mix | cuts_file | tsasr_test_manifest_dir |
| SER | biic_podcast_ser, m3ed_ser, meld_ser, iemocap_ser, msp_podcast_ser, emotion1200_en_ser, emotion1200_zh_ser | ser_pattern | DATA_SER root |
| SEC | emotion1200_en_sec, emotion1200_zh_sec | ser_pattern | 同上 |
| ESC | audioset_esc_test | cuts_file | esc_manifest_dir |

`commonvoice_*_hotwords` 套用 `_clean_pass` 后处理：丢弃 `custom.clean.pass = false` 的 cut（QA 已拒绝），保证两个语种测试集对称。

### 7.2 默认任务 / 默认语言映射

| 默认 | 表 |
| --- | --- |
| DATASET_TASK | 表注明每个 dataset 的默认任务（`asr` / `asr_hotwords` / `ser` / `sec` / `ts_asr` / `esc`） |
| DATASET_LANGUAGE | 中文测试集映射到 `zh`，英文映射 `en`，TS-ASR 测试集 `ts_hw_test` 是 `multi`（每条 cut 自带 language） |

### 7.3 关键测试集详情

#### 7.3.1 ASR 全套（asr_full.yaml）

按论文表布局把 LibriSpeech / WenetSpeech 拆 sub-spec：

中文：aishell, aishell2, aishell3, magicdata, kespeech, thchs30, commonvoice_zh, wenetspeech_test_net, wenetspeech_test_meeting, fleurs_zh
英文：librispeech_test_clean, librispeech_test_other, gigaspeech, mls, commonvoice_en, fleurs_en

#### 7.3.2 TS-ASR

| 测试集 | 说明 | 来源 |
| --- | --- | --- |
| ts_hw_test | 自研合成测试集（10k cuts），含正样本 + 5% 负样本（noise_only + distractor_only），中英混合 | `configs/target_speaker/synth_test.json` 配 `local/prepare_tsasr_data.py` |
| libri2mix | 公开 Librimix 2-speaker（test split, 16k, min, mix_both，6000 cuts） | `libri2mix_test_16k_min_mix_both_cuts.jsonl.gz`（cuts 内含绝对音频路径） |
| libri3mix | 公开 Librimix 3-speaker（同上，9000 cuts） | 同上 |

`ts_hw_test` 的合成配置（与训练侧合成同一管线，但 `seed=124`、`max_total_samples=10000`、`samples_per_speaker=40`、`enable_rir=false`）确保正负样本比例可控、与训练集种子互不重叠：

| 来源 | 语种 |
| --- | --- |
| aishell_test, aishell2_test, aishell3_test, magicdata_test, kespeech_test, thchs30_test, cv_zh_test | zh |
| librispeech_test_clean, librispeech_test_other, mls_en_test, cv_en_test | en |

#### 7.3.3 Hotwords ASR

| 测试集 | 来源 | 备注 |
| --- | --- | --- |
| commonvoice_en_hotwords | cv-en_supervisions_test_orig_punc_hotwords | 自带 `custom.hotwords` 与 `custom.clean` QA |
| commonvoice_zh_hotwords | cv-zh-CN_supervisions_test_punc_hotwords | 同上 |

评测端按 `hotwords_pad_to_sweep: [0, 5, 10, 15, 20]` 自动扩展成 5 条 sub-spec，结果按 (Dataset, K, n, WER%) 各占一行，可直接画"hotword count vs WER"曲线。

#### 7.3.4 SER / SEC

| 数据集 | 任务 | dev | test |
| --- | --- | --- | --- |
| biic_podcast_ser | ser | dev | test |
| m3ed_ser | ser | dev | test |
| meld_ser | ser | — | test |
| iemocap_ser | ser | — | test |
| msp_podcast_ser | ser | dev | test1 / test2 |
| emotion1200_en_ser / zh_ser | ser | — | test |
| emotion1200_en_sec / zh_sec | sec | — | test |

#### 7.3.5 ESC

`audioset_esc_test_mixed_cuts.jsonl.gz` 由 `local/prepare_audioset_esc_test.py` 离线生成，约 2166 条 dev cuts 各叠加一段 Emilia 前景；论文中的 metric 是 `compute_esc_metrics`：

- Tag-set Micro / Macro F1（基于 ref 标签词包含命中）
- ROUGE-L F1（词级 LCS）

### 7.4 评测 plan 总览（论文 Table 直接用）

| Plan | 用途 | 包含任务 |
| --- | --- | --- |
| asr_full.yaml | ASR 回归（中英 + fleurs） | asr |
| hotwords.yaml | Hotwords ablation（K=0/5/10/15/20） | asr_hotwords |
| hotwords_zh.yaml / hotwords_en.yaml | 单语种 hotwords sweep | asr_hotwords |
| ts_hw_test_only.yaml | TS-ASR 专测（ts_hw_test + libri2mix + libri3mix） | ts_asr |
| asr_hw_ts.yaml | TS + Hotwords + ASR 三类回归 | ts_asr, asr_hotwords, asr |
| mix_all.yaml | 6 大任务全量回归 | ts_asr, asr_hotwords, asr, ser, sec, esc |
| esc.yaml | 单独跑 ESC | esc |

### 7.5 度量

`src/compute_wer.py` 提供以下度量函数，论文里直接引用：

| 度量 | 任务 | 说明 |
| --- | --- | --- |
| compute_wer | ASR | 中英分别按字符 / 单词级 jiwer 计算；输出 substitutions / insertions / deletions |
| compute_per_language_wer | 多语 ASR | 按 normalized language 分别计 WER/CER 并汇总 |
| compute_silence_metrics | TS-ASR 负样本 | hyp 为空的召回率（正样本要"非空"，负样本要"空"） |
| compute_classification_metrics | SER | accuracy + macro-F1 + 混淆矩阵 |
| compute_esc_metrics | ESC | Tag-set Micro/Macro F1 + ROUGE-L F1 |

输出 JSON 结构（每个 sub-spec 一份）：

```text
{
  total, failed, evaluated, exact_match, exact_match_rate,
  per_language: {"zh-cn": {wer, n, substitutions, ...}, ...},
  overall:      {wer, substitutions, insertions, deletions, ...},
  total_duration_s, total_inflight_s, rtf,
  records: [{id, ref, hyp, wer, ...}, ...]
}
```

## 8. 论文 Data 章节 1-句话总结

我们的训练数据集包含 22 个公开 ASR 数据集（覆盖 10+ 语言）、7 个公开 SER 数据集（统一为 8 标签）、4 个 SEC 数据集与 AudioSet ESC（与 Emilia 前景在线混合），并通过 `prepare_tsasr_data.py` 在 16 个 ASR 源上离线合成约 3 M 条 Target-Speaker ASR 训练 cuts（包含 5–10% 反幻觉负样本，叠加 RIR 与多源加性噪声）；评测覆盖 12 个 ASR 公开 benchmark、Common Voice EN/ZH 热词测试集、3 个 TS-ASR 测试集（含 Librimix 2/3 speaker）、6 个 SER + 2 个 SEC 测试集以及 AudioSet ESC dev，所有评测在一个 dataset_registry 下统一寻址，并由 `compute_wer.py` 输出 per-language WER / CER + silence 召回 + classification F1 + ROUGE-L 等多任务度量。

## 9. 推荐论文 Figure / Table

| 图 / 表 | 内容 |
| --- | --- |
| Figure：TS-ASR 合成示意图 | enrollment + interferers + RIR + bg noise → mixed audio + negatives，标注 SNR/overlap/duration 参数 |
| Table：训练数据全景 | 22 ASR + 3 hotwords + tsasr + 7 SER + 4 SEC + esc，按任务/语种/上限/reps 列 |
| Table：合成参数 | snr / overlap / interferer 数 / RIR / 噪声源加权 / 负样本 ratio |
| Table：评测集合 | 每个测试集来源、cuts 数、语种、metric |
| Figure：Hotwords K vs WER | hotwords.yaml 直接产物，5 个 K × 2 个语种 = 10 条曲线 |
| Table：SER 8-class 标签映射 | 各源 raw label → 8 类的对应表（第 1.3 节） |

---

附：本文档关键模块的源代码索引（写 Data 章节时引用）

| 主题 | 主要文件 |
| --- | --- |
| TS-ASR 数据合成 | `local/prepare_tsasr_data.py` |
| TS-ASR 合成配置 | `configs/target_speaker/synth_template.json`, `synth_raw.json`, `synth_hotwords.json`, `synth_test.json` |
| ESC 前景混合 | `src/esc_mixing.py`，离线测试集脚本 `local/prepare_audioset_esc_test.py` |
| SER 标签统一 | `local/prepare_ser_manifests.py` |
| 数据集类（lhotse loader） | `src/asr_datamodule.py`, `src/ser_datamodule.py`, `src/esc_datamodule.py` |
| 训练任务 / 数据 mux | `src/train.py`（DATASET_REGISTRY, TASK_PROMPTS） |
| 测试集 registry | `src/dataset_registry.py`（TEST_SET_DEFS, DATASET_TASK, DATASET_LANGUAGE） |
| 评测 plan | `configs/eval_plans/*.yaml` |
| 度量 | `src/compute_wer.py` |
| Hotwords 注入 / hard-neg | `src/integrations/ms_swift/data/hotwords.py` |
