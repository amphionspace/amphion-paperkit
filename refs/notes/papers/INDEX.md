# Papers Index (collected 2026-05-13)

本次下载的 41 篇 audio LLM / ASR 相关论文 PDF。按主题分组，每篇含 arXiv ID、标题、对应本文的章节。

引用约定：bib key 用 `<lastname><year><firstword>` 形式（见 `AGENTS.md`），下表 PDF 文件名按 `<author><year>-<keyword>.pdf` 命名（README 推荐）。

## 1. 端到端 Audio LLM / Speech-LLM（直接对标）

这一类与本文 4.3B Qwen3-Audio-style 模型最直接可比，应作为 baseline 或 architecture reference。

| PDF | arXiv | 标题 | 团队 / 年 | 用处 |
| --- | --- | --- | --- | --- |
| qwenteam2026-qwen3-asr.pdf | 2601.21337 | Qwen3-ASR Technical Report | Alibaba Qwen, 2026-02 | 直接竞品（plan.md 中"对标 Qwen3-ASR-1.7B 抗噪"）；架构 / 训练 / 评测协议直接参考 |
| qwenteam2025-qwen3-omni.pdf | 2509.17765 | Qwen3-Omni Technical Report | Alibaba Qwen, 2025-09 | Thinker-Talker MoE、多模态对齐参考 |
| xu2025-qwen25-omni.pdf | 2503.20215 | Qwen2.5-Omni Technical Report | Alibaba Qwen, 2025-03 | TMRoPE / Thinker-Talker 先驱 |
| chu2024-qwen2-audio.pdf | 2407.10759 | Qwen2-Audio Technical Report | Alibaba, 2024-07 | Adapter + LLM 经典结构、AIR-Bench 评测协议 |
| chu2023-qwen-audio.pdf | 2311.07919 | Qwen-Audio: Advancing Universal Audio Understanding | Chu et al., 2023-11 | hierarchical-tag 多任务训练（hotword / 长尾 task 借鉴） |
| kimiteam2025-kimi-audio.pdf | 2504.18425 | Kimi-Audio Technical Report | Moonshot Kimi Team, 2025-04 | 12.5Hz 离散 + 连续 dual tokenizer、parallel head 设计 |
| bai2024-seed-asr.pdf | 2407.04675 | Seed-ASR: Understanding Diverse Speech and Contexts with LLM-based ASR | ByteDance Seed, 2024-07 | LLM-based ASR 训练 recipe（SSL→SFT→Context SFT→RL）；数据规模披露 |
| stepfun2025-step-audio2.pdf | 2507.16632 | Step-Audio 2 Technical Report | StepFun, 2025-07 | 工业级 audio LLM 报告结构、RAG / tool 调用 |
| xiaomi2025-mimo-audio.pdf | 2512.23808 | MiMo-Audio: Audio Language Models are Few-Shot Learners | Xiaomi LLM-Core, 2025-12 | 100M-hour 预训练、tokenizer + patch decoder 设计 |
| baichuan2025-baichuan-audio.pdf | 2502.17239 | Baichuan-Audio: End-to-End Speech Interaction | Baichuan, 2025-02 | 12.5Hz multi-codebook + audio head 设计 |
| fu2025-vita15.pdf | 2501.01957 | VITA-1.5: Towards GPT-4o Level Real-Time Vision and Speech | VITA-MLLM, 2025-01 | 三阶段 vision+speech 训练、modality conflict 缓解 |
| mistral2025-voxtral.pdf | 2507.13264 | Voxtral | Mistral AI, 2025-07 | Whisper-large-v3 encoder + 4× downsample adapter；text capability preservation |
| microsoft2025-phi4-mm.pdf | (HF mirror) | Phi-4-Multimodal Technical Report | Microsoft, 2025-02 | Mixture-of-LoRAs：speech LoRA 460M，避免 catastrophic forgetting 的范本 |
| abouelenin2025-phi4-mini.pdf | 2503.01743 | Phi-4-Mini Technical Report | Microsoft, 2025-03 | Phi-4-Mini 文本骨干、与 mm 版本对照 |
| openmoss2026-moss-ttsd.pdf | 2603.19739 | MOSS-TTSD: Text to Spoken Dialogue Generation | OpenMOSS, 2026-03 | Qwen3-8B-base + multi-head delay pattern 长对话生成 |
| openmoss2026-moss-audio-tokenizer.pdf | 2602.10934 | MOSS-Audio-Tokenizer: Scaling Audio Tokenizers | OpenMOSS, 2026-02 | 12.5Hz CAT-tokenizer，3M-hour 预训练 |

## 2. 经典 ASR baseline / encoder（必引）

| PDF | arXiv | 标题 | 用处 |
| --- | --- | --- | --- |
| radford2022-whisper.pdf | 2212.04356 | Robust Speech Recognition via Large-Scale Weak Supervision | Whisper：680k h 弱监督、零样本鲁棒性范本，必为主表 baseline |
| gulati2020-conformer.pdf | 2005.08100 | Conformer: Convolution-augmented Transformer | Conformer encoder 范本，几乎所有 audio LLM 的 encoder 都是它或变体 |
| gao2022-paraformer.pdf | 2206.08317 | Paraformer: Fast and Accurate Parallel Transformer | NAR + glancing LM；中文 ASR baseline / FunASR 旗舰 |
| google2023-usm.pdf | 2303.01037 | Google USM: Scaling ASR Beyond 100 Languages | 2B Conformer + RPQ-SSL，多语种 ASR 范本 |
| meta2023-seamlessm4t.pdf | 2308.11596 | SeamlessM4T: Massively Multilingual & Multimodal MT | 100 语种 S2ST/ASR；噪声鲁棒性 / 多语对照 |
| nvidia2024-canary.pdf | 2406.19674 | Less is More: Accurate Speech Recognition & Translation without Web-Scale Data | NVIDIA Canary FastConformer-AED，少数据多 SOTA |
| nvidia2025-canary-parakeet-v3.pdf | 2509.14128 | Canary-1B-v2 & Parakeet-TDT-0.6B-v3 | 多语种 ASR + AST efficient baseline，open ASR Leaderboard 强 baseline |
| peng2024-owsm-v31.pdf | 2401.16658 | OWSM v3.1: Better and Faster Open Whisper-Style Speech Models | E-Branchformer 替换 Transformer 编码器；可复现 Whisper |
| funaudio2024-sensevoice.pdf | 2407.04051 | FunAudioLLM: SenseVoice + CosyVoice | SenseVoice 多任务 ASR + emotion + event；与 Paraformer 同源 |

## 3. SSL Speech Encoder

| PDF | arXiv | 标题 | 用处 |
| --- | --- | --- | --- |
| hsu2021-hubert.pdf | 2106.07447 | HuBERT: Masked Prediction of Hidden Units | HuBERT 经典自监督，SLAM-ASR 主用 encoder |
| chen2021-wavlm.pdf | 2110.13900 | WavLM: Full Stack Speech Processing SSL | denoising + masked prediction，SUPERB SOTA |
| chen2022-beats.pdf | 2212.09058 | BEATs: Audio Pre-Training with Acoustic Tokenizers | 通用音频 SSL；SALMONN 二路 encoder 之一 |

## 4. LLM-based ASR 范式（adapter / prompt / 端到端）

| PDF | arXiv | 标题 | 用处 |
| --- | --- | --- | --- |
| tang2023-salmonn.pdf | 2310.13289 | SALMONN: Towards Generic Hearing Abilities for LLMs | Whisper + BEATs + Q-Former + Vicuna 双路融合 |
| ma2024-slam-asr.pdf | 2402.08846 | An Embarrassingly Simple Approach for LLM with Strong ASR Capacity | SLAM-ASR：HuBERT + 单层 linear projector + Vicuna，LibriSpeech test-clean 1.84 |
| fang2024-llama-omni.pdf | 2409.06666 | LLaMA-Omni: Seamless Speech Interaction | Llama-3.1-8B + speech adapter + streaming decoder，226 ms latency |
| xie2024-mini-omni.pdf | 2408.16725 | Mini-Omni: Language Models Can Hear, Talk While Thinking in Streaming | "Any Model Can Talk" 训练范式 |
| xie2024-mini-omni2.pdf | 2410.11190 | Mini-Omni2 | 加入 vision + duplex |
| zeng2024-glm4-voice.pdf | 2412.02612 | GLM-4-Voice | 175 bps 单码本 tokenizer、1T token 预训练 |

## 5. 热词 / Contextual Biasing（本文重点章节）

| PDF | arXiv | 标题 | 用处 |
| --- | --- | --- | --- |
| lakomkin2025-contextual-biasing-rl.pdf | 2512.21828 | Contextual Biasing for LLM-Based ASR with Hotword Retrieval and RL | GLCLAP 检索 + GRPO RL；中文长尾 hotword 强对照 |
| yang2024-ctc-assisted-contextual.pdf | 2411.06437 | CTC-Assisted LLM-Based Contextual ASR | CTC coarse decode 过滤 hotword 进 prompt；LS test-clean B-WER 3.67 |
| sun2025-br-asr.pdf | 2505.19179 | BR-ASR: Bias Retrieval Framework for Contextual Biasing ASR | 200k entry 检索；LS test-clean B-WER 2.8 |

## 6. Target-Speaker ASR（本文重点章节）

| PDF | arXiv | 标题 | 用处 |
| --- | --- | --- | --- |
| meng2024-sq-whisper.pdf | 2412.05589 | SQ-Whisper: Speaker-Querying Whisper for TS-ASR | trainable speaker queries；Libri2Mix 14.6%、WSJ0-2Mix 4.4% |
| polok2024-target-speaker-whisper.pdf | 2409.09543 | Target Speaker ASR with Whisper | diarization-conditioned；NOTSOFAR-1 ORC-WER 改善 12.9 |
| ma2023-whisper-prompt-tuning-tsasr.pdf | 2312.08079 | Extending Whisper with Prompt Tuning to Target-Speaker ASR | prompt-tuning 路线，LibriMix baseline |

## 7. Benchmark / 评测协议

| PDF | arXiv | 标题 | 用处 |
| --- | --- | --- | --- |
| srivastav2025-asr-leaderboard.pdf | 2510.06961 | Open ASR Leaderboard | 60+ 系统 + 10 dataset + RTFx，本文实验设置 / normalization 参照 |

---

## 引用 / fact-check 时的查找捷径

```bash
ls refs/notes/papers/                     # 看有哪些
rg -l "Qwen3-ASR" refs/notes/papers/      # 检查 PDF 内有无某关键词
```

读单个 PDF 用 `pypdf` 抽文本（系统 Python 已装）：

```python
from pypdf import PdfReader
print(PdfReader("refs/notes/papers/qwenteam2026-qwen3-asr.pdf").pages[0].extract_text()[:2000])
```

## 补充计划（暂未下载，按需再补）

- 数据集 datasheet：LibriSpeech / GigaSpeech / CommonVoice / FLEURS / AMI / AISHELL-1/2/4 / WenetSpeech / KeSpeech（应放 `refs/datasets/`）
- 内部资料：Qwen3-ASR-1.7B 抗噪测试 log、Whisper-RIR-Mega 数据卡（应放 `refs/internal/`）
- 噪声 benchmark：CHiME-6 / NOTSOFAR-1 论文（plan.md TS-ASR + 抗噪需要）
- Doubao-ASR / 商业 API 报告（如果 plan 要做闭源对比表）
