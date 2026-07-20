# 闭源 / 商用 ASR 系统参考（collected 2026-05-14）

工程上要做"竞品对比"的闭源系统大都不发完整 paper，本文件汇总它们的官方信息源（blog / API 文档 / 价格 / 评测页），写实验对比表时优先引用本文件指向的 URL。引用时务必标注访问日期（"retrieved on 2026-05-14"）。

## 1. 字节跳动 / 火山引擎 Doubao（必引）

plan.md 第 4 行已经把"对标 Qwen3-ASR-1.7B 抗噪 + 比 Doubao 强"作为目标之一。

| 项 | 内容 |
| --- | --- |
| 最新版本 | Doubao Speech Recognition 2.0（Doubao-Seed-ASR-2.0），2025-12-05 由火山引擎发布 |
| 上一代论文 | Seed-ASR (Bai et al. 2024)，arXiv 2407.04675（已在 `papers/bai2024-seed-asr.pdf`）；2.0 在 1.0 基础上加 MoE + 视觉多模态 |
| 关键能力（2.0） | 13 海外语种、上下文关键词召回 +20%、多模态（图像辅助 OCR 名词）、PPO RL |
| 官方公告（中文） | https://m.nbd.com.cn/articles/2025-12-05/4169650.html |
| 团队 blog 1 | https://team.doubao.com/blog/8-key-moments-of-doubao-large-models-in-2024 |
| 团队 blog 2 | https://team.doubao.com/blog/豆包-听力-水平现场开箱-看seed-asr如何突破语音识别瓶颈 |
| Realtime Voice | https://research.doubao.com/en/realtime_voice |
| API 文档 | https://www.volcengine.com/docs/6561（中文）；async submit-then-poll workflow |
| 集成 / 第三方 | https://blog.ax0x.ai/doubao-stt-runbook（社区 STT 集成指南） |
| 报告里如何写 | "Doubao-Seed-ASR 2.0 (Volcano Engine, December 2025; built on Seed-ASR \citep{bai2024seedasr})" |

## 2. OpenAI gpt-4o-transcribe

| 项 | 内容 |
| --- | --- |
| 论文 | GPT-4o System Card (OpenAI 2024, arXiv 2410.21276；本仓库 `papers/openai2024-gpt4o-systemcard.pdf`，§3 voice mode + §6 safety evals） |
| 上游模型 | Whisper-large-v3（OpenAI 2023）；transcribe 系列在其上做 RLHF |
| 可用模型（API） | gpt-4o-transcribe / gpt-4o-mini-transcribe / gpt-4o-transcribe-diarize |
| API 文档 | https://platform.openai.com/docs/guides/speech-to-text |
| 文件大小限制 | 25 MB / 请求；支持 mp3 / mp4 / wav / webm |
| 报告里如何写 | "gpt-4o-transcribe API \citep{openai2024gpt4o}，accessed on YYYY-MM-DD" |

## 3. Google 系列

| 项 | 内容 |
| --- | --- |
| Universal Speech Model (USM) | 论文 arXiv 2303.01037（本仓库 `papers/google2023-usm.pdf`） |
| Chirp / Chirp 2 / Chirp 3 | https://cloud.google.com/blog/products/ai-machine-learning/chirp-3-google-models-for-conversational-ai-and-speech-recognition |
| Cloud Speech-to-Text 文档 | https://cloud.google.com/speech-to-text |
| 报告里如何写 | "Google Chirp 2 (gemini-1.5-flash backbone, retrieved YYYY-MM-DD)"——若评测中使用，需要在 Limitations 节标注 |

## 4. Microsoft / Azure

| 项 | 内容 |
| --- | --- |
| Phi-4-Multimodal | arXiv 不直接发；HF 镜像 PDF 已下载至 `papers/microsoft2025-phi4-mm.pdf`（用 mixture-of-LoRA 训练 460 M speech adapter） |
| Azure Speech Service | https://learn.microsoft.com/en-us/azure/ai-services/speech-service/ |

## 5. AssemblyAI / Deepgram / Speechmatics（独立 ASR 厂商）

| 厂商 | 主要模型 | 评测对照 / 来源 |
| --- | --- | --- |
| AssemblyAI | Universal-1 (2024) / Universal-2 (2025) | https://www.assemblyai.com/research/universal-1 |
| Deepgram | Nova-2 / Nova-3 (2025) | https://deepgram.com/blog/announcing-nova-3 |
| Speechmatics | Ursa 2 (2024) | https://www.speechmatics.com/product/asr |
| 评测来源 | Open ASR Leaderboard（已下，`papers/srivastav2025-asr-leaderboard.pdf`）；Gladia ASR Benchmarking 文档（research-references.md 第 6 节） |

## 6. 阿里 Qwen3-ASR vs 本文模型

我们的模型 (4.3 B Qwen3-Audio-style) 直接对标 Qwen3-ASR-1.7 B，paper 已下载至 `papers/qwenteam2026-qwen3-asr.pdf`。Plan 第 56-62 行指明抗噪超越 Qwen3-ASR-1.7B 是 KPI 之一。建议写比较时：

- 抗噪：Whisper-RIR-Mega test（仓库内部 manifest，路径见 plan.md）；
- 中文 ASR：AISHELL-2 / WenetSpeech test_net / test_meeting；
- 热词：CV-EN/ZH hotwords；
- 多语：FLEURS。

## 6.1 阿里 FunAudioLLM Fun-ASR-Nano-2512（hotword 评测 baseline）

| 项 | 内容 |
| --- | --- |
| 模型 | Fun-ASR-Nano-2512（800 M 参数，end-to-end real-time ASR） |
| 发布方 | 阿里 FunAudioLLM 团队 |
| 发布日期 | 2025-12-15 |
| HuggingFace | https://huggingface.co/FunAudioLLM/Fun-ASR-Nano-2512 |
| Demo Space | https://huggingface.co/spaces/FunAudioLLM/Fun-ASR-Nano |
| Tech blog | https://www.stable-learn.com/en/fun-asr-tech-guide/ |
| 语种 / 方言 | 31 语种 + 7 中文主要方言（吴语、粤语、闽南、客家、赣、湘、晋）+ 26 地区口音 |
| 上游 | FunAudioLLM 系列；与 Paraformer / SenseVoice 同源（参见 `papers/funaudio2024-sensevoice.pdf`） |
| 本报告引用 | §7.3.3 Hotword baseline 对比表（CommonVoice EN/ZH oracle prompt + retrieve client 模式）；retrieved on 2026-05-20 |
| 报告里如何写 | "Fun-ASR-Nano-2512 \citep{funasrnano} (FunAudioLLM, December 2025; 800\,M parameters; retrieved 2026-05-20)" |

## 7. 报告章节里如何"诚实写商用 baseline"

参考 ICLR 2026 ReviewerGuide + asr-domain.mdc，必须满足：

1. 注明评测 API 的版本号（如有）和访问日期：例如 "gpt-4o-transcribe (snapshot 2025-09-30, retrieved 2026-04-12)"。
2. 注明 normalization 处理：例如 "we apply Whisper English normalizer to both reference and hypothesis"。
3. 注明 decoding config：例如 "default beam, temperature=0, no LM"。
4. 若直接复用对手报告的数字，标注 "as reported in \citep{qwenteam2026qwen3asr} Table 5"，且在 Limitations 中说明可能存在评测协议差异。

## 8. TODO（数据待补）

- Doubao-Seed-ASR 2.0 在我们测试集上的 WER（plan.md 已列任务，@李煦 测）
- gpt-4o-transcribe 在 Whisper-RIR-Mega test 上的 WER（需要工程实现 OpenAI API 客户端）
- 国内多家 ASR API（讯飞 / 腾讯云 / 阿里云通义听悟）的对照表（如果走开放评测路径）

---

注：本文件不放具体 PDF（它们没有公开 paper）。需要补一份正式 publication 引用时，直接补在 references.bib 里用 `@misc` + URL + accessed=YYYY-MM-DD 即可。
