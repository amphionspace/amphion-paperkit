# Papers INDEX (derived view)

This is a human-readable view derived from [`INDEX.yaml`](INDEX.yaml).
`INDEX.yaml` is the single source of truth; PDFs are gitignored and downloaded by `tools/fetch-refs.py`.

Total entries: 47 across 8 groups.

## 1. 端到端 Audio LLM / Speech-LLM (直接对标) (16)

与本报告 4.3B Qwen3-Audio-style 模型最直接可比；作为 baseline 或 architecture reference。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [qwenteam2026-qwen3-asr.pdf](https://arxiv.org/pdf/2601.21337.pdf) | Qwen3-ASR Technical Report | 2026-02 | 直接竞品（plan 中"对标 Qwen3-ASR-1.7B 抗噪"）； 架构 / 训练 / 评测协议直接参考。 |
| [qwenteam2025-qwen3-omni.pdf](https://arxiv.org/pdf/2509.17765.pdf) | Qwen3-Omni Technical Report | 2025-09 | Thinker-Talker MoE、多模态对齐参考。 |
| [xu2025-qwen25-omni.pdf](https://arxiv.org/pdf/2503.20215.pdf) | Qwen2.5-Omni Technical Report | 2025-03 | TMRoPE / Thinker-Talker 先驱。 |
| [chu2024-qwen2-audio.pdf](https://arxiv.org/pdf/2407.10759.pdf) | Qwen2-Audio Technical Report | 2024-07 | Adapter + LLM 经典结构、AIR-Bench 评测协议参考。 |
| [chu2023-qwen-audio.pdf](https://arxiv.org/pdf/2311.07919.pdf) | Qwen-Audio: Advancing Universal Audio Understanding | 2023-11 | hierarchical-tag 多任务训练（hotword / 长尾 task 借鉴）。 |
| [kimiteam2025-kimi-audio.pdf](https://arxiv.org/pdf/2504.18425.pdf) | Kimi-Audio Technical Report | 2025-04 | 12.5Hz 离散 + 连续 dual tokenizer、parallel head 设计。 |
| [bai2024-seed-asr.pdf](https://arxiv.org/pdf/2407.04675.pdf) | Seed-ASR: Understanding Diverse Speech and Contexts with LLM-based ASR | 2024-07 | LLM-based ASR 训练 recipe（SSL→SFT→Context SFT→RL）； 数据规模披露。 |
| [stepfun2025-step-audio2.pdf](https://arxiv.org/pdf/2507.16632.pdf) | Step-Audio 2 Technical Report | 2025-07 | 工业级 audio LLM 报告结构、RAG / tool 调用。 |
| [xiaomi2025-mimo-audio.pdf](https://arxiv.org/pdf/2512.23808.pdf) | MiMo-Audio: Audio Language Models are Few-Shot Learners | 2025-12 | 100M-hour 预训练、tokenizer + patch decoder 设计。 |
| [baichuan2025-baichuan-audio.pdf](https://arxiv.org/pdf/2502.17239.pdf) | Baichuan-Audio: End-to-End Speech Interaction | 2025-02 | 12.5Hz multi-codebook + audio head 设计。 |
| [fu2025-vita15.pdf](https://arxiv.org/pdf/2501.01957.pdf) | VITA-1.5: Towards GPT-4o Level Real-Time Vision and Speech | 2025-01 | 三阶段 vision+speech 训练、modality conflict 缓解。 |
| [mistral2025-voxtral.pdf](https://arxiv.org/pdf/2507.13264.pdf) | Voxtral | 2025-07 | Whisper-large-v3 encoder + 4× downsample adapter；text capability preservation。 |
| [microsoft2025-phi4-mm.pdf](https://huggingface.co/microsoft/Phi-4-multimodal-instruct/resolve/main/phi_4_mm.tech_report.02252025.pdf) | Phi-4-Multimodal Technical Report | 2025-02 | Mixture-of-LoRAs：speech LoRA 460M，避免 catastrophic forgetting 的范本。 |
| [abouelenin2025-phi4-mini.pdf](https://arxiv.org/pdf/2503.01743.pdf) | Phi-4-Mini Technical Report | 2025-03 | Phi-4-Mini 文本骨干、与 mm 版本对照。 |
| [openmoss2026-moss-ttsd.pdf](https://arxiv.org/pdf/2603.19739.pdf) | MOSS-TTSD: Text to Spoken Dialogue Generation | 2026-03 | Qwen3-8B-base + multi-head delay pattern 长对话生成。 |
| [openmoss2026-moss-audio-tokenizer.pdf](https://arxiv.org/pdf/2602.10934.pdf) | MOSS-Audio-Tokenizer: Scaling Audio Tokenizers | 2026-02 | 12.5Hz CAT-tokenizer，3M-hour 预训练。 |

## 2. 经典 ASR baseline / encoder (必引) (9)

Whisper / Conformer / Paraformer 等强 baseline；几乎所有 audio LLM 的 encoder 都源自此组工作。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [radford2022-whisper.pdf](https://arxiv.org/pdf/2212.04356.pdf) | Robust Speech Recognition via Large-Scale Weak Supervision | 2022-12 | Whisper：680k h 弱监督、零样本鲁棒性范本，必为主表 baseline。 |
| [gulati2020-conformer.pdf](https://arxiv.org/pdf/2005.08100.pdf) | Conformer: Convolution-augmented Transformer | 2020-05 | Conformer encoder 范本，几乎所有 audio LLM 的 encoder 都是它或变体。 |
| [gao2022-paraformer.pdf](https://arxiv.org/pdf/2206.08317.pdf) | Paraformer: Fast and Accurate Parallel Transformer | 2022-06 | NAR + glancing LM；中文 ASR baseline / FunASR 旗舰。 |
| [google2023-usm.pdf](https://arxiv.org/pdf/2303.01037.pdf) | Google USM: Scaling ASR Beyond 100 Languages | 2023-03 | 2B Conformer + RPQ-SSL，多语种 ASR 范本。 |
| [meta2023-seamlessm4t.pdf](https://arxiv.org/pdf/2308.11596.pdf) | SeamlessM4T: Massively Multilingual & Multimodal MT | 2023-08 | 100 语种 S2ST/ASR；噪声鲁棒性 / 多语对照。 |
| [nvidia2024-canary.pdf](https://arxiv.org/pdf/2406.19674.pdf) | Less is More: Accurate Speech Recognition & Translation without Web-Scale Data | 2024-06 | NVIDIA Canary FastConformer-AED，少数据多 SOTA。 |
| [nvidia2025-canary-parakeet-v3.pdf](https://arxiv.org/pdf/2509.14128.pdf) | Canary-1B-v2 & Parakeet-TDT-0.6B-v3 | 2025-09 | 多语种 ASR + AST efficient baseline，open ASR Leaderboard 强 baseline。 |
| [peng2024-owsm-v31.pdf](https://arxiv.org/pdf/2401.16658.pdf) | OWSM v3.1: Better and Faster Open Whisper-Style Speech Models | 2024-01 | E-Branchformer 替换 Transformer 编码器；可复现 Whisper。 |
| [funaudio2024-sensevoice.pdf](https://arxiv.org/pdf/2407.04051.pdf) | FunAudioLLM: SenseVoice + CosyVoice | 2024-07 | SenseVoice 多任务 ASR + emotion + event；与 Paraformer 同源。 |

## 3. SSL Speech Encoder (3)

HuBERT / WavLM / BEATs 等自监督 speech encoder。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [hsu2021-hubert.pdf](https://arxiv.org/pdf/2106.07447.pdf) | HuBERT: Masked Prediction of Hidden Units | 2021-06 | HuBERT 经典自监督，SLAM-ASR 主用 encoder。 |
| [chen2021-wavlm.pdf](https://arxiv.org/pdf/2110.13900.pdf) | WavLM: Full Stack Speech Processing SSL | 2021-10 | denoising + masked prediction，SUPERB SOTA。 |
| [chen2022-beats.pdf](https://arxiv.org/pdf/2212.09058.pdf) | BEATs: Audio Pre-Training with Acoustic Tokenizers | 2022-12 | 通用音频 SSL；SALMONN 二路 encoder 之一。 |

## 4. LLM-based ASR 范式 (adapter / prompt / 端到端) (6)

直接将语音特征接入 LLM 的方法学先驱。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [tang2023-salmonn.pdf](https://arxiv.org/pdf/2310.13289.pdf) | SALMONN: Towards Generic Hearing Abilities for LLMs | 2023-10 | Whisper + BEATs + Q-Former + Vicuna 双路融合。 |
| [ma2024-slam-asr.pdf](https://arxiv.org/pdf/2402.08846.pdf) | An Embarrassingly Simple Approach for LLM with Strong ASR Capacity | 2024-02 | SLAM-ASR：HuBERT + 单层 linear projector + Vicuna，LibriSpeech test-clean 1.84。 |
| [fang2024-llama-omni.pdf](https://arxiv.org/pdf/2409.06666.pdf) | LLaMA-Omni: Seamless Speech Interaction | 2024-09 | Llama-3.1-8B + speech adapter + streaming decoder，226 ms latency。 |
| [xie2024-mini-omni.pdf](https://arxiv.org/pdf/2408.16725.pdf) | Mini-Omni: Language Models Can Hear, Talk While Thinking in Streaming | 2024-08 | "Any Model Can Talk" 训练范式。 |
| [xie2024-mini-omni2.pdf](https://arxiv.org/pdf/2410.11190.pdf) | Mini-Omni2 | 2024-10 | 加入 vision + duplex。 |
| [zeng2024-glm4-voice.pdf](https://arxiv.org/pdf/2412.02612.pdf) | GLM-4-Voice | 2024-12 | 175 bps 单码本 tokenizer、1T token 预训练。 |

## 5. 热词 / Contextual Biasing (本报告重点章节) (4)

上下文偏置 / 热词召回相关工作。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [lakomkin2025-contextual-biasing-rl.pdf](https://arxiv.org/pdf/2512.21828.pdf) | Contextual Biasing for LLM-Based ASR with Hotword Retrieval and RL | 2025-12 | GLCLAP 检索 + GRPO RL；中文长尾 hotword 强对照。 |
| [yang2024-ctc-assisted-contextual.pdf](https://arxiv.org/pdf/2411.06437.pdf) | CTC-Assisted LLM-Based Contextual ASR | 2024-11 | CTC coarse decode 过滤 hotword 进 prompt；LS test-clean B-WER 3.67。 |
| [sun2025-br-asr.pdf](https://arxiv.org/pdf/2505.19179.pdf) | BR-ASR: Bias Retrieval Framework for Contextual Biasing ASR | 2025-05 | 200k entry 检索；LS test-clean B-WER 2.8。 |
| [min2024-speechrag.pdf](https://arxiv.org/pdf/2412.16500.pdf) | Speech Retrieval-Augmented Generation without Automatic Speech Recognition | 2024-12 | audio-space speech retriever（speech adapter + frozen text retriever，distillation loss）；作为本工作 text-space retrieve 的对照路线，§7.2.2 显式 cite。 |

## 6. Target-Speaker ASR (本报告重点章节) (3)

目标说话人 ASR / 说话人条件解码。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [meng2024-sq-whisper.pdf](https://arxiv.org/pdf/2412.05589.pdf) | SQ-Whisper: Speaker-Querying Whisper for TS-ASR | 2024-12 | trainable speaker queries；Libri2Mix 14.6%、WSJ0-2Mix 4.4%。 |
| [polok2024-target-speaker-whisper.pdf](https://arxiv.org/pdf/2409.09543.pdf) | Target Speaker ASR with Whisper | 2024-09 | diarization-conditioned；NOTSOFAR-1 ORC-WER 改善 12.9。 |
| [ma2023-whisper-prompt-tuning-tsasr.pdf](https://arxiv.org/pdf/2312.08079.pdf) | Extending Whisper with Prompt Tuning to Target-Speaker ASR | 2023-12 | prompt-tuning 路线，LibriMix baseline。 |

## 7. Benchmark / 评测协议 (5)

公开 benchmark 与挑战赛协议。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [srivastav2025-asr-leaderboard.pdf](https://arxiv.org/pdf/2510.06961.pdf) | Open ASR Leaderboard | 2025-10 | 60+ 系统 + 10 dataset + RTFx，本报告实验设置 / normalization 参照。 |
| [watanabe2020-chime6.pdf](https://arxiv.org/pdf/2004.09249.pdf) | CHiME-6 Challenge: Tackling Multispeaker Speech Recognition for Unsegmented Recordings | 2020-04 | 多人 unsegmented 会议 ASR；TS-ASR / diarization baseline。 |
| [cornell2023-chime7.pdf](https://arxiv.org/pdf/2306.13734.pdf) | CHiME-7 DASR Challenge: Distant Meeting Transcription with Multiple Devices | 2023-06 | 跨 array / 跨场景泛化（CHiME-6 + DiPCo + Mixer 6）。 |
| [cornell2024-chime8.pdf](https://arxiv.org/pdf/2407.16447.pdf) | CHiME-8 DASR Challenge for Generalizable and Array Agnostic Distant ASR and Diarization | 2024-07 | 加入 NOTSOFAR-1 + LLM-allowed track。 |
| [vinnikov2024-notsofar1.pdf](https://arxiv.org/pdf/2401.08887.pdf) | NOTSOFAR-1 Challenge: New Datasets, Baseline, and Tasks for Distant Meeting Transcription | 2024-01 | 315 会议 / 1000 h 模拟训练；办公场景 distant ASR + diarization。 |

## 8. 闭源 / 商用系统 (1)

商用系统的可下载 PDF（多数在 commercial-systems.md 仅列链接）。

| File | Title | Date | Usage |
| --- | --- | --- | --- |
| [openai2024-gpt4o-systemcard.pdf](https://arxiv.org/pdf/2410.21276.pdf) | GPT-4o System Card | 2024-10 | OpenAI omni 模型；包含 gpt-4o-transcribe baseline， 第 9 节有 audio safety 评测。 |

