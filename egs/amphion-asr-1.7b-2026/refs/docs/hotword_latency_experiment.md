# 热词召回时延实验需求

状态：待执行

范围：AmphionASR-1.7B 帧级 hotword tower retriever

目标交付：论文主表中的效果—时延对照，以及附录中的候选池伸缩实验

## 1. 要回答的问题

本实验需要回答的不是“开启热词后总共用了多久”，而是以下三个可分离的问题：

1. 在线热词检索本身增加多少时延？
2. 将检索得到的 Top-$K$ 热词加入 prompt 后，LLM prefill 和完整 ASR 推理增加多少时延？
3. 当候选池扩大时，召回效果与时延是否仍处于可接受的折中范围？

当前论文方法使用帧级音频表示：每个候选热词与所有音频帧计算相似度，经 max-over-time 得到候选分数，再选取 Top-$K$。因此，端到端增量至少包含检索打分、Top-$K$ 选择和额外 prompt 三部分。实验必须将这些部分拆开，不能只报告一个无法归因的总 RTF。

## 2. 实验启动前的协议门槛

执行人必须先确认被测实现与当前论文方法一致：

- 使用帧级 audio tower 表示，不做 utterance-level pooling；
- 使用 audio adapter 和 text adapter 映射到共享空间；
- 每个候选热词对所有音频帧打分，并采用 max-over-time；
- 在线检索后只进行一次 ASR 转写；
- 默认完整实验采用 $K=50$。

`retrieve_hotwords.md` 中仍保留“粗解码—文本检索—精解码”的两遍方案。该方案不能与当前 tower retriever 混测。若实际部署实现仍是两遍方案，应停止实验并先统一论文、实现和评测协议。

实验记录必须写入以下实现身份信息：

- 模型 checkpoint 或不可变 revision；
- retriever checkpoint 或不可变 revision；
- 推理代码 revision；
- 检索方法标识，例如 `frame-level-tower`；
- 热词文本 embedding 是否预计算；
- 热词池是否常驻 GPU，以及冷、热缓存状态。

## 3. 数据与候选池

### 3.1 主实验数据

主实验复用当前论文的 CommonVoice Mandarin 和 English hotword test splits。两种语言必须分别报告，不得将 CER 和 WER 混合平均。

每条样本至少需要：

- 唯一 `sample_id`；
- 语言；
- 音频时长；
- 编码后的音频帧数；
- 参考文本；
- 标注热词；
- 热词是否存在于候选池；
- 输入音频读取成功与否。

主设置使用当前论文规模：Mandarin 候选池 $10{,}112$ 条，English 候选池 $10{,}000$ 条，$K=50$。候选池内容、去重规则和顺序必须在三种对照条件间完全相同。

优先运行完整 test split。若完整运行成本不可接受，可以按语言和音频时长分层抽样，但必须保存抽样清单和随机种子，并保证每种语言均覆盖短、中、长音频。样本数不预先指定固定下限；以 P95 端到端时延的置信区间稳定为停止条件。

### 3.2 伸缩实验数据

为区分候选池规模和 prompt 长度的影响，至少扫描：

- 候选池大小 $N\in\{100,1{,}000,10{,}000\}$；
- Top-$K\in\{10,25,50\}$；
- 短、中、长三个音频时长分桶。

候选池子集必须嵌套构造，即较小池是较大池的确定性子集，并尽可能保留每条样本的真实热词。每个设置同时记录 pool coverage；否则 Recall@$K$ 下降可能只是目标热词不在候选池，而非 retriever 失败。

## 4. 三组隔离对照

同一批样本必须在相同硬件和解码配置下运行以下三个条件：

| 条件 | 在线检索计时 | Prompt 含 Top-$K$ | 回答的问题 |
| --- | ---: | ---: | --- |
| `no-hotword` | 否 | 否 | 基础 ASR 时延 |
| `precomputed-topk` | 否 | 是 | 仅由额外 prompt 引入的开销 |
| `online-retrieval` | 是 | 是 | 完整检索条件下的端到端时延 |

`precomputed-topk` 必须使用 `online-retrieval` 预先生成并固化的候选列表。两组的 prompt 内容和顺序必须逐样本相同，检索是否位于计时区间内是唯一差异。

据此计算：

\[
L_{\text{prompt}} = L_{\text{precomputed-topk}} - L_{\text{no-hotword}},
\]

\[
L_{\text{retriever}} = L_{\text{online-retrieval}} - L_{\text{precomputed-topk}},
\]

\[
L_{\text{total-delta}} = L_{\text{online-retrieval}} - L_{\text{no-hotword}}.
\]

上述差值应基于相同样本的配对结果计算，再汇总其分布；不能用来自不同请求集合的两个总体平均值相减。

## 5. 计时边界

### 5.1 论文主指标

端到端时延从服务端完成请求解析并取得音频字节开始，到完整转写结果生成结束。主指标包含：

- 请求排队；
- 音频特征处理和 audio encoder；
- 在线热词检索；
- prompt 构造与 LLM prefill；
- autoregressive decode。

音频文件读取和客户端网络传输默认不纳入论文主指标，因为它们不属于模型方法本身。若需要报告线上用户体验，可另给一个包含客户端 I/O 和网络的 service latency，并明确区分两种口径。

### 5.2 模块分解

至少测量：

- `queue_time_ms`；
- `audio_frontend_encoder_time_ms`；
- `retriever_time_ms`；
- `llm_prefill_time_ms`；
- `llm_decode_time_ms`；
- `end_to_end_time_ms`。

如果实现允许，进一步将 `retriever_time_ms` 拆为：

- audio adapter；
- candidate embedding 获取或传输；
- frame-by-candidate similarity；
- max-over-time 与 Top-$K$。

GPU 模块计时必须处理异步执行：使用 CUDA event 或在计时边界显式同步。服务端端到端计时使用单调时钟。不得用未同步的 CPU 墙钟差值作为 GPU kernel 时延。

### 5.3 冷启动与稳态

主表报告预热后的稳态结果。预热必须覆盖模型加载后的实际推理路径，且预热请求不得进入统计。以下开销单独记录，不混入稳态主表：

- 模型和 retriever 加载；
- 热词文本 embedding 首次生成；
- 热词池首次搬运到 GPU；
- 编译或 kernel autotuning。

如果候选池在生产环境中会频繁更新，另报告一次冷池构建时间和显存占用。

## 6. 逐样本原始记录

每个请求必须保留一条机器可读记录，最低字段如下：

```text
run_id
sample_id
condition
language
audio_duration_s
audio_frame_count
candidate_pool_size
top_k
prompt_token_count
output_token_count
batch_size
concurrency
queue_time_ms
audio_frontend_encoder_time_ms
retriever_time_ms
llm_prefill_time_ms
llm_decode_time_ms
end_to_end_time_ms
peak_gpu_memory_mb
retriever_hit
cer_or_wer
biased_cer_or_wer
failed
failure_reason
```

汇总表不能替代逐样本记录。逐样本数据用于配对差值、时长分桶、异常值检查和置信区间计算。

## 7. 固定环境与运行设置

每轮实验必须记录并固定：

- GPU 型号、数量、显存和功耗模式；
- CPU 型号和内存；
- CUDA、驱动、PyTorch、推理后端版本；
- 数值精度；
- tensor parallel、data parallel 等并行设置；
- batch size、并发数和请求调度策略；
- greedy 或 beam decoding、temperature、最大输出 token；
- 模型最大上下文长度；
- 热词 embedding 的 dtype、存储设备和缓存策略；
- 随机种子；
- warm-up 规则、重复次数和运行顺序。

主实验先使用 batch size 1、concurrency 1，以测量单请求代价。若论文还要陈述服务吞吐能力，再增加固定并发扫描，例如 $1,4,8,16$；吞吐实验不得替代单请求时延实验。

三种条件应交错或随机化运行顺序，避免温度、系统负载和动态频率变化持续偏向某一条件。每个条件至少进行多轮独立重复；停止条件是关键统计量及其置信区间稳定，而不是机械追求固定轮数。

## 8. 汇总指标

### 8.1 时延与效率

每种语言和条件分别报告：

- end-to-end latency 的 P50、P95 和 P99；
- retriever-only latency 的 P50 和 P95；
- 配对总时延增量的中位数和 P95；
- RTF；
- inverse RTF（RTFx，可选，用于与 Open ASR Leaderboard 口径对照）；
- 每秒处理的音频秒数；
- 峰值 GPU 显存。

聚合 RTF 定义为：

\[
\mathrm{RTF}=
\frac{\sum_i L_i}{\sum_i D_i},
\]

其中 $L_i$ 为请求端到端处理时间，$D_i$ 为对应音频时长。不得先计算每条样本 RTF 再做简单平均作为唯一结果，因为短音频会获得过高权重。

相对增量定义为：

\[
\Delta_{\text{latency}}=
\frac{L_{\text{online-retrieval}}-L_{\text{no-hotword}}}
     {L_{\text{no-hotword}}}\times100\%.
\]

### 8.2 效果指标

时延结果必须与下列效果指标成对报告：

- candidate-pool coverage；
- Recall@$K$；
- Mandarin B-CER；
- English B-WER；
- U-CER 或 U-WER（如评测器可得）；
- 完整 CER 或 WER。

这样可以区分三层失败：目标热词不在池中、retriever 未召回，以及 decoder 未使用已召回的热词。

### 8.3 分桶结果

至少保留下列切片：

- Mandarin 与 English；
- 短、中、长音频；
- 不同候选池规模；
- 不同 Top-$K$。

正文不需要放入所有切片，但原始结果必须可生成这些视图。

## 9. 论文交付物

### 9.1 主表

建议正文加入一张紧凑表：

| Setting | Recall@$50$ | B-CER / B-WER | RTF | P50 latency | P95 latency | Peak memory |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| No hotword | -- | TBD | TBD | TBD | TBD | TBD |
| Precomputed Top-$50$ | -- | TBD | TBD | TBD | TBD | TBD |
| Online retrieval | TBD | TBD | TBD | TBD | TBD | TBD |

Mandarin 和 English 应分行，不能把 B-CER 与 B-WER 合并平均。

### 9.2 附录图

附录使用 TikZ/pgfplots 绘制候选池伸缩图：

- 横轴：候选池大小，建议使用对数刻度；
- 左纵轴：retriever-only P50/P95 latency；
- 右纵轴：Recall@$K$；
- 分面或线型：不同 Top-$K$ 或语言。

最终图必须遵守本仓库公共调色板和 TikZ 规范。

### 9.3 复现材料

提交论文结果时一并保存：

- 固化的样本清单；
- 每个候选池的内容或可重建清单；
- 三组条件的逐样本 JSONL；
- 环境与运行配置；
- 汇总脚本输出；
- 失败请求及原因；
- 生成论文表格和图的数据文件。

## 10. 验收标准

只有满足以下条件，时延数字才可进入论文：

- 被测实现已确认是当前帧级 tower retriever；
- 三组条件使用相同样本、模型、解码参数和硬件；
- `precomputed-topk` 与 `online-retrieval` 的 prompt 逐样本一致；
- GPU 分阶段计时处理了异步执行；
- 主表采用预热后的稳态结果，冷启动另列；
- RTF 的计时边界和聚合公式明确；
- 报告 P50/P95，而非仅报告平均值；
- 时延与 Recall@$K$、B-CER/B-WER 同时给出；
- 原始逐样本结果可以复算论文表格；
- 所有未完成字段保持 `TBD`，不得用估计值代替测量。

## 11. 依据与当前已知边界

- 当前方法定义：`sections/04_model.tex` 的 Hotword Retrieval 小节，采用 frame-level scoring、max-over-time 和 Top-$K$。
- 当前效果设置：`sections/07_hotwords.tex` 使用约 $10{,}000$ 条候选池和 $K=50$，报告 Recall@$50$ 与 B-CER/B-WER。
- 当前评测能力：`refs/docs/task_prompts.md` 已定义 `total_duration_s`、`total_inflight_s` 和 RTF 输出字段，但目前没有可用于论文的数值化时延结果。
- 外部方法学参照：Open ASR Leaderboard v4 将 WER 与 inverse real-time factor（RTFx）标准化用于 accuracy-efficiency 比较：<https://arxiv.org/abs/2510.06961v4>。
- GPU 计时参照：PyTorch CUDA Event 与同步接口文档：<https://docs.pytorch.org/docs/stable/generated/torch.cuda.Event.html>、<https://docs.pytorch.org/docs/stable/generated/torch.cuda.synchronize.html>。
