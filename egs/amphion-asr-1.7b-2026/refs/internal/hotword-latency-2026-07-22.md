# AmphionASR 热词检索延迟实验报告

实验日期：2026-07-22（Asia/Shanghai）

证据状态：初步系统实验；可用于报告当前被测配置，不用于线上容量或跨系统延迟结论。

## 结论

在单张 H20、单请求、`frame_max + max-over-time + TopK + 单次 ASR` 路径上，在线检索相对预计算 TopK 的配对端到端延迟中位数为：

- EN：`+1.37 ms`，P95 `+7.92 ms`
- ZH：`+3.25 ms`，P95 `+7.17 ms`

完整池、K=50 时，在线路径的端到端均值约为 EN `71.11 ms`、ZH `72.07 ms`。相对不带热词路径的配对中位数增量为 EN `+2.82 ms`、ZH `+5.61 ms`，这里同时包含检索和较长 prompt 的代价。

K 从 10 增大到 50 时，Recall@K 明显提升：EN `83.33% -> 93.75%`，ZH `75.93% -> 92.59%`。本次共享 GPU 环境下延迟不随 K 单调变化，差异与运行噪声同量级；若 retriever recall 优先，K=50 是更合适的默认值。当前样本量不足以据此判断下游 B-WER/B-CER 的最优 K。

## 实验口径

- 模型：`AmphionASR-1.7B`
- 检索 adapter：`hotword_adapter/frame_max/best_adapter.pt`
- 检索：逐帧 audio tower，对每个候选做 max-over-time，TopK 只进入一次 ASR prompt
- 三条件均经过同一个 Triton audio projector；只有 `online_retrieval` 开启候选打分
- `precomputed_topk` 使用同一音频提前冻结的 TopK，冻结过程不计时
- 三条件均把 Triton 生成的同格式 `audio_embeds` 发送到 vLLM
- 每次 vLLM 请求使用唯一 UUID，避免复用多模态缓存
- 每个配置 30 条样本：短、中、长各 10 条；条件顺序按样本确定性打乱
- 单请求串行执行，不测并发吞吐
- 共 12 个配置、1,080 个正式条件请求；另有预计算、warmup 和冷启动请求

协议门槛由脚本查询 Triton model config 强制校验，正式结果中均为：

```text
retrieval_mode=frame_max
adapter_subdir=hotword_adapter/frame_max
paper_eligible=true
```

## 主配置：完整池，K=50

端到端延迟（ms）：

| 语言 | 条件 | Mean | P50 | P95 | P99 |
| --- | --- | ---: | ---: | ---: | ---: |
| EN | no-hotword | 67.80 | 67.63 | 85.63 | 88.15 |
| EN | precomputed-topk | 72.67 | 72.54 | 87.89 | 133.36 |
| EN | online-retrieval | 71.11 | 72.46 | 89.24 | 94.21 |
| ZH | no-hotword | 66.68 | 64.40 | 88.26 | 100.09 |
| ZH | precomputed-topk | 70.15 | 66.74 | 95.04 | 107.64 |
| ZH | online-retrieval | 72.07 | 69.00 | 96.23 | 105.52 |

配对增量（online - precomputed，ms）：

| 语言 | Mean | P50 | P95 |
| --- | ---: | ---: | ---: |
| EN | -1.55 | 1.37 | 7.92 |
| ZH | 1.92 | 3.25 | 7.17 |

EN 的 mean 为负是一次 precomputed Triton 长尾把均值拉高所致；配对 P50 与 P95 更能代表当前共享卡上的中心趋势。该长尾也造成 EN precomputed 的 P99=133.36 ms。

### 按音频长度

在线路径端到端延迟（Mean / P95，ms）：

| 语言 | 短 | 中 | 长 |
| --- | ---: | ---: | ---: |
| EN | 63.33 / 75.12 | 68.84 / 78.20 | 81.16 / 93.85 |
| ZH | 56.03 / 66.05 | 69.41 / 78.75 | 90.76 / 103.60 |

### 热词准确率

这里直接调用 AmphionASR 的 `compute_hotword_metrics`。EN 是词级 B-WER/U-WER；ZH 的 tokenizer 将中文拆为字符，因此对应字符级口径。

| 语言 | 条件 | B-WER/B-CER | U-WER/U-CER | KER | Recall@50 |
| --- | --- | ---: | ---: | ---: | ---: |
| EN | no-hotword | 18.89% | 10.64% | 29.17% | -- |
| EN | precomputed-topk | 11.11% | 7.66% | 12.50% | -- |
| EN | online-retrieval | 12.22% | 7.66% | 14.58% | 93.75% |
| ZH | no-hotword | 6.28% | 3.88% | 20.37% | -- |
| ZH | precomputed-topk | 3.77% | 3.88% | 11.11% | -- |
| ZH | online-retrieval | 3.77% | 3.88% | 11.11% | 92.59% |

主配置中 precomputed 与 online 的输出文本一致率均为 29/30。两者 prompt 与冻结 TopK 相同，少量差异属于当前推理运行噪声；30 条样本不足以把约 1 个样本的质量差异解释为模型效果差异。

## 池规模实验：固定 K=50

三种池规模使用同一组由 N=100 子集筛选出的 30 条样本。Recall@K 以原始 GT 热词为分母，池中不存在的 GT 计为未召回。

| 语言 | N | Recall@50 | 在线 Triton Mean | 在线 Triton P95 | 在线总延迟 Mean |
| --- | ---: | ---: | ---: | ---: | ---: |
| EN | 100 | 55.56% | 19.43 ms | 26.95 ms | 73.69 ms |
| EN | 1,000 | 57.41% | 18.81 ms | 22.30 ms | 74.05 ms |
| EN | 10,000 | 94.44% | 20.46 ms | 23.65 ms | 74.94 ms |
| ZH | 100 | 43.66% | 18.94 ms | 22.67 ms | 75.86 ms |
| ZH | 1,000 | 47.89% | 19.21 ms | 22.75 ms | 75.64 ms |
| ZH | 10,000 | 97.18% | 19.58 ms | 23.91 ms | 75.92 ms |

从 N=100 到约 10k，Triton 总段均值只增加约 0--2 ms；主要变化是候选覆盖率，而不是可见的端到端延迟。由于 Triton 总段还包含 audio tower/projector，这不能被解读为纯矩阵打分耗时。

## TopK 实验：固定完整池

| 语言 | K | Recall@K | B-WER/B-CER | U-WER/U-CER | 在线总延迟 Mean | online-precomputed P50 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| EN | 10 | 83.33% | 8.89% | 8.51% | 71.85 ms | 0.95 ms |
| EN | 25 | 87.50% | 12.22% | 8.94% | 68.16 ms | 0.22 ms |
| EN | 50 | 93.75% | 12.22% | 7.66% | 71.11 ms | 1.37 ms |
| ZH | 10 | 75.93% | 4.60% | 3.49% | 68.17 ms | 1.15 ms |
| ZH | 25 | 83.33% | 3.77% | 3.49% | 71.99 ms | 0.61 ms |
| ZH | 50 | 92.59% | 3.77% | 3.88% | 72.07 ms | 3.25 ms |

## 冷启动

独立 `frame_max` Triton 重启后的首个 EN、N=10k、K=50 请求为 `800.91 ms`；紧接着同请求为 `18.04 ms`，冷启动增量 `782.87 ms`。此项只包含 Triton projector + retrieval，不包含 vLLM；主实验均在三次 warmup 后测量。

## Mock 热词池

- EN：7,566 个数据集真实有效词 + 2,434 个确定性合成词 = 10,000
- ZH：10,088 个数据集真实有效词 + 24 个确定性合成词 = 10,112
- 固定生成种子：`hotword-latency-mock-v1`
- 原始归档 SHA256：`42310c5e82c979449d2d93fd6d3945b6e4e6969c6f6e268b1f6bf6cda63b3f36`
- ZH 原标注有 25 个单字热词，被当前服务的最小长度规则拒绝；词值已记录在 `provenance.json`
- 合成词不出现在对应 reference 中；因此延迟结果可用，但质量绝对值不应与外部论文的候选池直接横向比较

## 限制与下一步

1. H20 同时承载已有 vLLM、Triton 和其他服务。本实验的 `frame_max` Triton 使用独立容器与端口，但共享 GPU；P95/P99 包含共享资源抖动。正式发布门槛建议在独占维护窗口复跑。
2. 每配置 30 条适合验证趋势，不足以给 B-WER/B-CER 做窄置信区间。质量结论建议扩大到每语言至少数百条。
3. 本实验按已确认约束不测并发吞吐。
4. 当前线上默认 Triton 仍是 `pooled`；本次没有修改线上配置。要把结果用于真实线上容量结论，需要先把目标部署切到 `frame_max`。

## 产物

实验执行侧报告存在以下产物；这些文件在本 paperkit 工作区中尚未归档，因此本报告中的数值目前不能由本仓库独立复算：

- `provenance.json`：mock 池来源、数量和文件 hash
- `results/*.jsonl`：逐请求原始记录
- `results/*.summary.json`：逐配置延迟、配对差、Recall、B/U 指标
- `results/cold_frame_max_en_n10000_k50.json`：冷启动记录
- `smoke/`：协议不匹配与正式协议通过的单样本链路验证
