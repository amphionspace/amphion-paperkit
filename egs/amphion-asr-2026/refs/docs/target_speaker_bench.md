# 开源模型 TS-ASR 评测对比（含自研 SFT 对照行）

> 数据来源：`exp/eval_vllm/*/summary.json`（由 `eval_vllm.sh` 跑出），覆盖三类开源 audio-LLM（阿里 Qwen3-ASR-{0.6B, 1.7B}、阿里 Qwen3-Omni-30B-A3B-Instruct），并增补一个本仓库自研 SFT ckpt（Amphion-4B-vitw-v1-SFT）作为"经过任务对齐训练后能改进到什么程度"的对照行。
> 评测口径：`src/integrations/vllm/test_vllm_inference.py` + `src/compute_wer.py`
> 截至日期：2026-05-27
> 主线仍是开源 audio-LLM 在双音频（enrollment + mixed）TS-ASR 任务上的盲跑表现。自研行只作为单点参考；其它 Amphion-4B SFT 变体（sft_v0/v1/v2、vitw_v2 等）此处不展开，数据见 `exp/eval_vllm/amphion_4b_*_ts_hw_test/summary.{json,xlsx}`。

---

## 1. 任务定义与评测口径

### 1.1 TS-ASR 任务
模型同时接收两段音频：

1. enrollment audio：3 ~ 5 s 的目标说话人干净语音
2. mixed audio：目标说话人 + 1 ~ 2 个干扰说话人 + 噪声/混响

模型应当只转写目标说话人在 mixed 中所说的内容，忽略所有干扰说话人；若 mixed 中目标说话人完全不出现，应当输出空字符串。

仓库统一 prompt（与训练侧 `src/integrations/ms_swift/data/convert.py::build_unified_instruction` 对齐）：

```
Given the speaker's voice:<audio_enroll>
Transcribe what this speaker says in the following audio.
Language: zh-cn
<audio_mixed>
```

### 1.2 测试集

| 数据集 | n_pos | n_neg | 备注 |
|---|---|---|---|
| ts_hw_test | 6227 | 328 | 内部自建 TS-ASR 测试集，含 164 negative_silence + 164 negative_distractor |
| libri2mix | 6000 | 0 | LibriMix 官方生成，纯 positive，2-speaker |
| libri3mix | 9000 | 0 | LibriMix 官方生成，纯 positive，3-speaker |

ts_hw_test 的 cuts.custom.sample_type 区分三类：

- positive：mixed 中目标说话人存在，ref 非空
- negative_silence：mixed 为纯背景/噪声无任何说话人，ref 为空
- negative_distractor：mixed 中只有干扰说话人，没有目标说话人，ref 为空

### 1.3 指标
基于 `compute_silence_metrics`（`src/compute_wer.py:1269`）：

| 指标 | 定义 | 方向 |
|---|---|---|
| WER | 标准 WER，仅对 positive 样本（ref 非空）计算 | 越低越好 |
| Miss | positive 样本里模型输出空的比例 | 越低越好 |
| FA | negative 样本里模型输出非空的比例 | 越低越好 |
| SM | negative 样本里模型也保持静音的比例 = 1 − FA | 越高越好 |

libri2mix / libri3mix 没有 negative 样本（n_neg=0），FA / SM 不可定义。

---

## 2. 模型与部署

| 模型 | 参数量 | 架构 | 模型路径 | 是否原生支持双音频 prompt |
|---|---|---|---|---|
| Qwen3-ASR-0.6B | 0.6B | Qwen3ASRForConditionalGeneration | /ai_sds_wuzz/MODELS/Qwen3-ASR-0.6B | 否 |
| Qwen3-ASR-1.7B | 1.7B | Qwen3ASRForConditionalGeneration | /ai_sds_wuzz/MODELS/Qwen3-ASR-1.7B/Qwen/Qwen3-ASR-1___7B | 否 |
| Qwen3-Omni | 30B-A3B MoE | Qwen3OmniMoeForConditionalGeneration | /ai_sds_wuzz/MODELS/Qwen3-Omni-30B-A3B-Instruct | 是（multi-modal chat） |
| Amphion-4B-vitw-v1-SFT | 4B | Qwen3-4B 系（仓库内 ms-swift SFT，训练加入 Voices-in-the-Wild-2M 数据） | exp/qwen3asr_aut_qwen3_4b_continue_sft_v4_robust_vitw_v1/v0-20260524-145659/checkpoint-6000_merged（served-model-name = Amphion-4B，部署脚本见 `scripts/lx/server_amphion_4b_sft.sh`） | 是（训练 prompt 含 enrollment + mixed 双 audio 槽） |

部署：`src/integrations/scripts/deploy/serve_vllm.sh`（vLLM OpenAI 兼容 API + limit-mm-per-prompt=2 放开双音频上限）；评测：`src/integrations/scripts/eval/eval_vllm.sh`，plan = `configs/eval_plans/ts_hw_test_only.yaml`。Qwen3-ASR 系列本次现场补跑（2026-05-26），Qwen3-Omni 沿用历史 run；Amphion-4B-vitw-v1-SFT 是 2026-05-25 的历史 run，本次只重生成 `summary.xlsx` 以暴露 silence-aware 指标列（FA / Miss / Silence Match），未重跑推理。

---

## 3. 主表：ts_hw_test 跨模型对比

| 模型 | run | n_pos | n_neg | WER | FA | Miss | SM |
|---|---|---|---|---|---|---|---|
| Qwen3-ASR-0.6B | Qwen3-ASR-0.6B-ts_hw_test_only-20260526_091101 | 6227 | 328 | 84.97 | 100.00% | 0.00% | 0.00% |
| Qwen3-ASR-1.7B | Qwen3-ASR-1.7B-ts_hw_test_only-20260526_091101 | 6227 | 328 | 78.99 | 100.00% | 0.00% | 0.00% |
| Qwen3-Omni | qwen3-omni-20260427_091734 | 6227 | 328 | 53.52 | 100.00% | 0.00% | 0.00% |
| Qwen3-Omni | qwen3-omni-20260427_093108 | 6227 | 328 | 52.90 | 100.00% | 0.00% | 0.00% |
| Amphion-4B-vitw-v1-SFT | amphion_4b_vitw_sft_asr_ts_hw_test | 6227 | 328 | 12.56 | 98.17% | 0.00% | 1.83% |

观察：

1. 三个开源模型的 negative 样本 FA 全部 = 100%（SM = 0%），即面对没有目标说话人的音频，没有一个会保持静音。这是 negative_silence + negative_distractor 两个子类合算的结果，下一节给出拆分确认两个子类都同样失效。
2. ts_hw_test positive 上的 WER 反差大：Qwen3-Omni 53% < Qwen3-ASR-1.7B 79% < Qwen3-ASR-0.6B 85%。直觉上参数量更大、专做 ASR 的模型应该表现更好，但 Qwen3-Omni 反而最低，原因见 7.1 节。
3. 同一模型两次跑（Qwen3-Omni 091734 / 093108）WER 差 ≤ 0.62pp，可视为评测噪声。
4. 自研 Amphion-4B-vitw-v1-SFT 把 positive WER 从开源最佳的 53% 拉到 12.56%（~4.2× 改进），但 FA 仍高达 98.17%（SM 仅 1.83%）— positive 与 FA 是两个解耦能力，仅靠 positive 数据加量不会自动学到 silence prior，详见 7.5 节。

---

## 4. negative 子类型拆分（ts_hw_test 上）

| 模型 | n_silence | silence FA | silence SM | n_distractor | distractor FA | distractor SM |
|---|---|---|---|---|---|---|
| Qwen3-ASR-0.6B | 164 | 100.00% | 0.00% | 164 | 100.00% | 0.00% |
| Qwen3-ASR-1.7B | 164 | 100.00% | 0.00% | 164 | 100.00% | 0.00% |
| Qwen3-Omni (091734) | 164 | 100.00% | 0.00% | 164 | 100.00% | 0.00% |
| Amphion-4B-vitw-v1-SFT | 164 | 96.34% | 3.66% | 164 | 100.00% | 0.00% |

观察：

1. 三个开源模型在两类 negative 上都是 100% FA 全军覆没。即使是纯背景（negative_silence，音频里完全没有人说话）也照样会吐字。
2. 对比内部带 negative 训练的 SFT 模型（数据已在历史 run 里），negative_silence 上能做到 ≤ 2.4% FA、negative_distractor 上 40 ~ 85% FA。也就是说"在纯背景上保持静音"对模型来说是一个完全可学的信号，但开源 ASR / Omni 模型默认就没有这条 prior。
3. 自研 Amphion-4B-vitw-v1-SFT 处在中间状态：negative_silence 上 FA 从 100% 降到 96.34%（SM 3.66%）出现微弱信号，但 negative_distractor 上仍是 100% FA 与开源完全一致。即"纯背景"维度刚刚开始崩开，"只有干扰说话人"维度完全没碰。这条 ckpt 不属于上一行"带 negative 训练"的类别（VITW-2M 训练数据是纯 positive 的开放语音转写），所以两个数字并不冲突；FA 分布的成因见 7.5 节。

---

## 5. LibriMix 跨数据集表现（仅 positive）

| 模型 | libri2mix WER | libri2mix Miss | libri3mix WER | libri3mix Miss |
|---|---|---|---|---|
| Qwen3-ASR-0.6B | 156.49 | 0.00% | 153.95 | 0.00% |
| Qwen3-ASR-1.7B | 167.16 | 0.00% | 172.81 | 0.00% |
| Qwen3-Omni (091734) | 135.91 | 0.00% | 138.41 | 0.00% |
| Qwen3-Omni (093108) | 135.91 | 0.00% | 138.68 | 0.00% |
| Amphion-4B-vitw-v1-SFT | 66.33 | 0.00% | 86.00 | 0.00% |

观察：

1. 三个开源模型 WER 都远大于 100%（150 ~ 173%）。在 ref-token 加权 WER 定义里，WER > 100% 意味着 hypothesis 比 ref 长得多（多说话人转写全堆在一起）。和 ts_hw_test 上的趋势一致：Qwen3-Omni 最低，Qwen3-ASR-1.7B 反超 0.6B。
2. Miss 全部 = 0%，即模型对每一条 positive 样本都吐了字。这进一步印证"开源模型不会主动选择沉默"。
3. LibriMix 2-speaker 与 3-speaker 上 WER 差异很小（开源模型 < 5pp 以内），说明模型在 2 个干扰人和 1 个干扰人的混合音频上同样无选择性。
4. 自研 Amphion-4B-vitw-v1-SFT 把 libri2mix / libri3mix 的 WER 拉到 100% 以下（66.33 / 86.00），即在大多数样本上至少不再"把所有 speaker 全部硬转出来"，相对开源最佳 Qwen3-Omni 仍有 ~2× 改进。但需要留意：libri2mix → libri3mix 时 Amphion 模型 WER 跳了 ~20pp（开源模型只跳 ~3pp），说明该 ckpt 的 speaker selection 能力对干扰说话人数量更敏感，3-speaker 场景比 2-speaker 退化明显，而开源模型本就"全部转写"，反而对干扰数量不敏感。

---

## 6. 服务部署细节（本次补跑）

GPU 6/7 共享给其他进程使用，需要按 vllm 的 `--gpu-memory-utilization`（基于 total 比例）显式控制以避免与其他 user 冲突：

| 模型 | GPU | -u (util) | 估算占用 | max-model-len |
|---|---|---|---|---|
| Qwen3-ASR-1.7B | 6 | 0.40 | ~32 GB（含权重 3.87 GB + cudagraph capture peak + KV cache budget） | 8192 |
| Qwen3-ASR-0.6B | 7 | 0.10 | ~8 GB（权重 1.53 GB + cudagraph + KV cache） | 8192 |

KV cache 每 token bf16 大小 = 2 × 28 layers × 8 kv_heads × 128 head_dim × 2 B ≈ 0.109 MiB（1.7B 与 0.6B 的 KV cache shape 完全相同，二者只在 hidden_size 上不同，与 KV cache 大小无关）。max-model-len = 8192 时 batch=64 并发的 KV cache 上限需求约 (64 × 1900 tokens) × 0.109 MiB ≈ 13 GB，1.7B 留 32 GB 显存绰绰有余，0.6B 8 GB 也够。

第一次启动 1.7B 用 `-u 0.18` 失败，提示 `No available memory for the cache blocks`：原因是 vLLM 0.18 的 cudagraph capture 阶段需要额外 ~5 GB 临时显存，再加上权重 3.87 GB，0.18 × 80 GB = 14.4 GB 已经吃完，分不到 KV cache 块。把 `-u` 调到 0.40 后正常启动并完成评测。

---

## 7. 结论与解释

### 7.1 模型规模 vs TS-ASR 能力的反直觉关系

ts_hw_test 上 WER 排序：Qwen3-Omni (53%) < Qwen3-ASR-1.7B (79%) < Qwen3-ASR-0.6B (85%)。直觉上 Qwen3-ASR 系列是专门做 ASR 训练的应该更强，但实际 Qwen3-Omni 更低。

第一性原理：WER 反映"输出与 ref 的对齐度"，不是"对错"。三个模型在 ts_hw_test 上全部把 mixed 中的多个说话人内容混着输出，WER 主要由"输出文本与 ref 的字符串差异"决定：

- Qwen3-Omni 是 multi-modal chat 模型，能正确解析"Given the speaker's voice: ... Transcribe what THIS speaker says ..." 这种 instruction 语义，即使无法分离 target speaker，至少 chat 框架会把输出限制在合理长度内。
- Qwen3-ASR 系列是纯 ASR 模型，其 chat_template 主要为单段音频 ASR 设计，把 enrollment 当 prefix audio 喂过去时，模型会把 enrollment 的内容也当作转写目标一起输出，导致输出文本被 enrollment 内容污染，WER 反而更高。

所以这里 WER 数字反映的不是 TS-ASR 任务能力，而是 prompt 与模型 chat_template 的契合程度。

### 7.2 FA = 100% 的统一现象

三个模型在 negative 上全部 100% FA，包括纯背景的 negative_silence。这是个非常强的负面信号：

- negative_silence 是"音频里完全没有人说话"，按声学常识模型应该不输出。但所有开源模型都输出了——说明 LLM 端的 generation prior 是"只要给定 audio token 就一定要解码出文本"，没有"什么都没听到 → 输出空"的兜底学习。
- negative_distractor 上同样 100% FA 是预期内的，因为开源模型本来就没有"目标说话人"的 sense，看到任何 speaker 都会转写。
- 这反过来证明：仓库的 SFT 训练（在 negative_silence 上能学到 ≤ 2.4% FA）确实给模型注入了"应当沉默"的新能力，不是仅仅靠 base 模型自带 prior 就能做出来的。

### 7.3 LibriMix 上 WER > 100% 的来源

WER > 100% 只能由 insertions 贡献，即 hypothesis 比 ref 长很多。在 mixed_both 混音里，模型把 2-3 个 speakers 的内容全部转写出来，导致：

- ref = "目标说话人的文本"
- hyp = "目标说话人文本 + 干扰说话人 1 文本 + 干扰说话人 2 文本"
- WER ≈ insertions / len(ref) ≈ (1 ~ 2) × len(ref) / len(ref) ≈ 100 ~ 200%

这与 2/3-speaker mixed 在 LibriMix 上 WER 152-173% 的实测吻合。说明所有三个开源模型在多说话人音频上的行为是"无差别全部转写"，没有任何 speaker selection 能力。

### 7.4 工程建议

1. 不要直接用 Qwen3-ASR 或 Qwen3-Omni 当 TS-ASR 系统。它们能跑出"看上去合理"的字符流（Qwen3-Omni WER 53% 看起来不算太离谱），但 FA = 100% 意味着任何"目标说话人不在场"的真实场景都会输出无关文本，下游对错误转写敏感的应用会大量误触发。
2. 选评测 baseline 时，"WER 单一指标"具有误导性。Qwen3-Omni WER 比 Qwen3-ASR 还低，但两者都不能完成 TS-ASR 任务。负样本上的 FA / SM 才是区分"能否做 TS-ASR"的硬指标。
3. negative_silence 应该作为最低保底线。如果一个声称做 TS-ASR 的模型，在纯背景上 FA 不接近 0%，就还远没收敛到"目标说话人感知"。

### 7.5 自研 Amphion-4B-vitw-v1-SFT 的位置：positive WER 大改进、FA 仍是开放问题

加入 Amphion-4B-vitw-v1-SFT 一行后的对比：

| 维度 | 开源最佳（Qwen3-Omni） | Amphion-4B-vitw-v1-SFT | 相对变化 |
|---|---|---|---|
| ts_hw_test positive WER | 52.90 ~ 53.52 | 12.56 | ~4.2× 改进 |
| libri2mix WER | 135.91 | 66.33 | ~2.0× 改进 |
| libri3mix WER | 138.41 | 86.00 | ~1.6× 改进 |
| negative_silence FA | 100.00% | 96.34% | -3.66pp（弱信号） |
| negative_distractor FA | 100.00% | 100.00% | 0pp（持平） |

第一性原理拆解：

1. positive WER 与 FA 是两个解耦的能力。前者考"audio → 文本"的对齐质量，由训练集 positive 样本的数量与覆盖决定；后者考"什么都不该说时是否能选择沉默"，必须训练集里显式混入 negative 样本（ref = ""）才能学到。在 cross-entropy 监督下，所有 positive 样本都在教模型"看到 audio token 就要 decode 出字"，没有任何信号告诉它"也可以输出空"。
2. VITW-2M 是 Voices-in-the-Wild-2M，一个纯 positive 的开放语音 ASR 数据集（每条音频都带 transcript，`scripts/lx/convert_vitw.sh` 直接对 parquet 做转换，不构造空 ref 样本）。因此 vitw-v1 SFT 的训练 prior 与开源 ASR 模型一致：从未见过"audio 给定 → 输出空"的合法标签。positive WER 大幅下降（任务对齐 + 数据加量起效），FA 几乎不动（数据里就没这个信号），完全符合预期。
3. negative_silence 上 3.66% SM（vs 开源 0%）的微弱信号，推测来自训练数据里偶发的低能音频段（VITW 数据包含各种 degradation）让模型在"audio 几乎没信息"时少量倾向短输出 / EOS；但 3.66% 的量级远不足以兜底，且没有迁移到 negative_distractor（那里仍 100% FA，因为干扰说话人音频信息丰富，纯 positive 训练的模型无法区分"目标 vs 任意" speaker）。
4. negative_distractor 上 100% FA 是更强的失败模式：只要 mixed 中有任何说话人就被当目标转写，说明 enrollment 与 mixed-target 之间的对应关系没有被对比性监督；模型把双音频 prompt 学成了"两段都尽量识别"，而不是"用 enrollment 选 mixed 里的子集"。
5. LibriMix 2→3 speaker 时 Amphion WER 从 66 跳到 86（+20pp），开源模型只跳 ~3pp。开源模型本来就是无差别全部转写，speaker 数量增加不会改变行为（只是 hyp 更长）；Amphion 出现了对干扰数量的敏感性，意味着它至少在尝试做 speaker selection，但 selection 的 robust 性还差。这也是"有方向但没收敛"的另一个旁证。

工程含义：

- 把 FA 拉下来的正确路径是训练数据扩充 — 在现有 positive 之外，显式构造 negative_silence（纯背景 / 非语音音频 + ref = ""）和 negative_distractor（enrollment = 说话人 A，mixed 中只有 B/C，ref = ""）配对样本，并加进 SFT mixture；只增加 positive 数据不会自动带出 silence prior。
- 当前 vitw-v1 ckpt 已经能在内部部署（`scripts/lx/server_amphion_4b_sft.sh`）给"已知目标说话人会出现"的 TS-ASR positive 场景做基线推理；但任何"目标说话人可能不在场"的生产链路（例如声纹门禁的"是否在说目标话人语"判别）必须在外层补一层 VAD / 能量门控 / 二次确认，不能依赖模型本身的 silence 行为。
- 后续要看的对照点：`amphion_4b_vitw_sft_v2_asr_ts_hw_test`（vitw_v2 ckpt，2026-05-26）silence FA 已降到 82.32%、SM 17.68%，说明 v1→v2 这一步训练里加入的修正确实在往正确方向走；定量分析单独成文。

---

## 8. 数据复现

```bash
cd /chenmingjie/mingdong/workspace/AmphionASR && python - <<'EOF'
import json, pathlib
runs = [
    "Qwen3-ASR-0.6B-ts_hw_test_only-20260526_091101",
    "Qwen3-ASR-1.7B-ts_hw_test_only-20260526_091101",
    "qwen3-omni-20260427_091734",
    "qwen3-omni-20260427_093108",
    "amphion_4b_vitw_sft_asr_ts_hw_test",
]
for run_name in runs:
    sj = pathlib.Path("exp/eval_vllm") / run_name / "summary.json"
    m = json.load(open(sj))
    model = (m.get("model") or {}).get("served_model_name", "?")
    print(f"=== {run_name} (model={model}) ===")
    for t in m.get("tests") or []:
        spec = t.get("spec") or {}
        if spec.get("task") != "ts_asr":
            continue
        sm = t.get("silence_metrics") or {}
        ov = t.get("overall") or {}
        print(f"  {spec.get('dataset'):20s}  WER={ov.get('wer')}  "
              f"FA={sm.get('false_alarm_rate')}  Miss={sm.get('miss_rate')}  "
              f"SM={sm.get('exact_silence_match')}")
EOF
```

更细的 sample_type 拆分（negative_silence vs negative_distractor）从 `per_sample_type` 字段读取，或者直接打开 `exp/eval_vllm/<run>/per_test/ts_hw_test__ts_asr/metrics.json`。

新的 xlsx 表头（来自 2026-05-26 起的 run）包含 `Dataset / n_pos / n_neg / WER % / FA % / Miss % / Silence Match %` 共 7 列，可直接对 ts_hw_test 行做横向比较；生成代码：`src/eval_io.py::_xlsx_tsasr_sheet`。
