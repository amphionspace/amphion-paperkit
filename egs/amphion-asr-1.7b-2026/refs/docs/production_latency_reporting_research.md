# 热词检索：从学术延迟刻画到生产容量证据

调研日期：2026-07-22（Asia/Shanghai）

范围：评估当前 `frame_max` 热词检索实验是否足以支撑“面向实际生产”的报告，并整理高质量论文、公开基准与推理服务工具的报告口径。

## 结论

当前结果**足以作为 academic latency characterization（学术延迟刻画）**：它通过 `no-hotword`、`precomputed-topk`、`online-retrieval` 三个配对条件，隔离了 prompt 与在线检索开销，并覆盖候选池规模、TopK、音频长度和冷启动。它可以支撑如下限定结论：

> 在单张共享 H20、单请求、预热后的被测配置上，在线帧级检索相对预计算 TopK 的配对延迟中位增量为 EN 1.37 ms、ZH 3.25 ms。

当前结果**不足以作为 production capacity / SLO evidence（生产容量或 SLO 证据）**。生产结论必须回答“在指定请求到达过程、负载与尾延迟门槛下，目标部署能稳定完成多少请求”，而当前实验只有 concurrency=1、每配置每语言 30 条、共享 GPU、非线上默认 `frame_max` 配置、不含客户端网络路径，也没有吞吐、队列、错误率、RTF/RTFx 或原始产物的仓内复算。以上事实来自本项目的[初步实验报告](../internal/hotword-latency-2026-07-22.md)。

风险等级：

- 继续把它表述为“initial latency characterisation”：低风险。
- 表述为“low overhead on the measured configuration”：中风险，必须保留硬件、单并发、共享卡和样本量限定。
- 表述为“production-ready”“real-time serving”或线上容量结论：高风险，现有证据不充分。

## 两类证据不能混用

| 问题 | 学术延迟刻画 | 生产容量 / SLO 证据 |
| --- | --- | --- |
| 主要目的 | 隔离方法增量、比较模型/模块 | 为容量规划、上线门槛和告警阈值提供依据 |
| 负载 | 常见为 batch 1 / concurrency 1 | 开环请求率或真实 trace；扫描到饱和区 |
| 主指标 | 模块延迟、E2E P50/P95、RTF/RTFx | 满足 SLO 时的最大 goodput/QPS、P95/P99、排队、错误率 |
| 数据 | 可控分层样本 | 生产代表性时长、语言、prompt、输出长度与突发分布 |
| 环境 | 固定且可复现的单机环境 | 与目标部署同构的网络、调度、实例数、缓存和共租策略 |
| 结论边界 | “该实现的额外计算代价” | “该部署在目标 SLO 下可承载的流量” |

这个区分与 MLPerf Inference 的场景设计一致：Single Stream 连续发送单请求，Server/Interactive 则用 Poisson 到达并以满足尾延迟约束时的最大吞吐为指标；两者回答的是不同问题。[MLPerf Inference rules, Scenarios and LoadGen](https://github.com/mlcommons/inference_policies/blob/master/inference_rules.adoc#3-scenarios)

## 当前报告已经做对的部分

1. **隔离根因层。** 配对的三条件设计将额外 prompt 和在线检索分开，优于只报告“开/关热词”的整体均值。
2. **报告分布而非只报均值。** 当前表给出 P50/P95/P99，并明确说明 EN mean 被单次长尾影响。Triton Model Analyzer 的正式指标同样区分平均值与 P90/P95/P99，并单列 server queue、client send/receive 等组成部分。[Triton Model Analyzer metrics](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/model_analyzer/docs/metrics.html)
3. **覆盖伸缩维度。** 候选池从 100 扫到约 10k，TopK 从 10 扫到 50，并同时报告召回和下游错误率。这与 BR-ASR 将 bias-list 规模、检索召回、B-WER 和 query latency 放在同一 scalability 分析中的写法相近。[BR-ASR paper](https://arxiv.org/abs/2505.19179)
4. **显式区分冷、热路径。** 当前报告把首次 Triton 请求的冷启动单列，没有混入稳态主表；vLLM 官方也把 startup、single-batch latency、online serving throughput 分成不同 benchmark。[vLLM benchmark modules](https://docs.vllm.ai/en/latest/api/vllm/benchmarks/index.html)
5. **没有把共享卡噪声解释成算法机理。** 这使当前数据适合作为初步系统观察，而不是对负 mean 或非单调 K 曲线做过度归因。

## 面向生产仍缺的关键证据

### 1. 明确 SLO 和生产工作负载

没有预先定义的 SLO，就不存在“延迟是否可接受”或“容量是多少”的可检验结论。至少需要冻结：

- P95/P99 端到端延迟门槛；
- 允许的错误率或超时率；
- 目标 QPS、并发、突发系数和请求到达模型；
- EN/ZH 比例、音频时长、prompt token、输出 token、候选池大小与更新频率分布；
- 计时边界是否包含网关、网络、音频读取、序列化和重试。

MLPerf Server 场景把 latency 定义为查询计划交给系统直到收到回复，并在给定尾延迟约束下搜索最大 QPS；Open division 也要求公开产生该性能结果时采用的 latency constraint。[MLPerf LoadGen latency definition](https://github.com/mlcommons/inference_policies/blob/master/inference_rules.adoc#51-loadgen-operation)

### 2. 负载扫描，而不是只测单请求

concurrency=1 能刻画空载服务时间，不能暴露排队、动态 batching、调度竞争或饱和点。需要两类负载：

- **开环 request-rate sweep**：按目标到达过程增加 RPS，直到 P95/P99 或错误率越过 SLO；
- **concurrency sweep**：用于观察调度、batching 和资源利用率，但不能单独替代生产到达率实验。

Triton Perf Analyzer 原生支持 concurrency、request-rate 和 custom-interval 三种负载，并用 time/count windows 重复测量直到稳定。[Triton Performance Analyzer](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/perf_analyzer/README.html) Triton 的优化指南也明确把动态 batching 描述为吞吐—时延折中，并建议在一系列 concurrency 上测量。[Triton optimization guide](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/user_guide/optimization.html)

生产主结论应改为：

> 在 workload W、部署 D 和 SLO S 下，系统可持续处理 X req/s（或 Y audio-s/s），同时保持 P99 E2E ≤ L、错误率 ≤ E。

而不是只写“平均延迟约 72 ms”。

### 3. 足够的尾延迟样本与运行时间

每条件 30 条时，经验 P99 基本由最慢的一条请求决定，无法形成稳定的尾延迟容量结论。应以 P95/P99 置信区间和跨轮稳定性作为停止条件，并至少独立重复多轮。

MLPerf 的严格公开基准用 600 秒 Server run、99% tail latency，并明确指出少量查询会增加方差；它给出的示例起点甚至为 P95 约 50,425 次、P99 约 262,742 次推理（99% 置信度下的特定误差目标）。这些数字不是本项目必须照搬的样本下限，但说明 30 条不能支撑 production-tail claim。[MLPerf tail-latency early stopping guidance](https://github.com/mlcommons/inference_policies/blob/master/inference_rules.adoc#3-scenarios)

可行做法是：每个负载点运行固定时间窗，保存逐请求记录，对 P95/P99 和 goodput 做 bootstrap 置信区间；关键负载点跨进程重启重复至少三轮，并在结果不稳定时继续采样。

### 4. 目标部署必须与被测系统一致

当前线上默认 Triton 是 `pooled`，实验测试的是独立 `frame_max` 容器；所以当前数字不能直接代表线上目标。发布前需要在**与目标部署同构**的栈上复跑，包括：

- frame-level retriever、adapter/model revision；
- Triton/vLLM 版本、model config、实例数、dynamic batching 与调度参数；
- GPU 数量、功耗/时钟策略、MIG 或共租策略；
- 网关、协议、网络拓扑和请求序列化；
- cache、热词 embedding 驻留位置和每请求唯一性策略。

MLPerf Network division把网络纳入 system under test，并要求说明 NIC、数据路径与可持续带宽；这说明“同卡上的服务端计时”和“用户可见服务时延”必须分开命名。[MLPerf network/system-boundary requirements](https://github.com/mlcommons/inference_policies/blob/master/inference_rules.adoc#51-loadgen-operation)

建议做两个互补版本：

- 独占 GPU：回答方法与实现的可复现基线；
- 生产同构部署：回答真实容量和 SLO，保留生产允许的共租、网关和网络路径。

### 5. 报告 queue、prefill、decode 与 goodput

生产容量必须解释尾延迟来自哪里。最低需要逐请求记录：

- client E2E、server E2E；
- queue、Triton compute/input/output；
- retriever；
- vLLM TTFT、TPOT、ITL、E2E；
- input/output token、audio duration；
- success/timeout/error；
- GPU 显存、利用率、功耗（若做成本/密度结论）。

vLLM 的 serving benchmark正式报告 request/token throughput、TTFT、TPOT、ITL 及其分位数；其 `goodput` 定义按每请求 TTFT/TPOT/E2E SLO 判断有效完成量，且支持保存 detailed per-request JSON。[vLLM benchmark CLI](https://docs.vllm.ai/en/latest/cli/bench/serve.html) 对语音数据，vLLM 的 benchmark metrics 还直接以输入音频总时长除以 benchmark duration 计算 RTFx。[vLLM serving metrics source](https://docs.vllm.ai/en/latest/api/vllm/benchmarks/serve/)

### 6. 质量与性能要在同一路径上验收

高负载下的超时、截断、重试、长度限制或 batching 配置可能改变实际输出，因此性能测试不能只看服务成功返回。至少需要在选定容量点重新跑准确率守门，并证明与低负载基线相比 B-WER/B-CER、U-WER/U-CER 和 Recall@K 没有超出预设容差。

MLPerf 要求 accuracy 和 performance mode 使用相同代码路径，并为每个 performance result 配套一次验证运行；这是一种可借鉴的“性能不能绕过质量”的发布门槛。[MLPerf accuracy/performance path rule](https://github.com/mlcommons/inference_policies/blob/master/inference_rules.adoc#51-loadgen-operation)

### 7. 冷启动之外，还要测热词池更新与恢复

当前 800.91 ms 的首次 Triton 请求很好地揭示了冷启动，但生产还需测：

- 10k 真实热词 embedding 构建、加载和 GPU 搬运耗时；
- 池的增量更新/全量切换时，请求 P95/P99 是否抖动；
- Triton/vLLM 实例重启后达到 steady state 的时间；
- readiness 之前是否拒绝流量；
- OOM、下游超时和单实例失效后的错误率与恢复时间。

这些属于运维证据，不必全部写进论文主表，但若报告声称“面向实际生产”，应进入附录或 deployment report。

### 8. 真实候选池与数据覆盖

mock pool 可以稳定控制 N 并用于计算伸缩，但不能替代生产热词分布。需要补一轮脱敏后的真实池或保留生产统计特性的合成池，记录：词长、token 长度、语言/字符类别、重复/同音/近音密度、更新频率、GT coverage。论文质量表应使用可追溯的真实 benchmark pool；mock pool 只用于 latency scaling。

## 其他高质量报告如何写

### BR-ASR：方法级 scalability，而不是生产容量

BR-ASR 同时报告 bias list 扩展到 200k 时的 WER/B-WER 退化、99.99% pruning 和 test-other 上每 query 20 ms latency。这种写法有效地回答“检索机制是否随候选池扩展”，与本项目的 N-scaling 表最接近。[BR-ASR abstract and scalability result](https://arxiv.org/abs/2505.19179)

但该论文没有把这个 20 ms 组织成“某 SLO 下的最大 QPS、P99、排队和错误率”结论，因此应将它视为 academic scalability reference，而不是 production serving benchmark。对 AmphionASR 的启示是：保留候选池规模—召回—B-WER/B-CER—retrieval latency 四联表，同时不要模仿其单点延迟去声称线上容量。

### Open ASR Leaderboard：统一准确率—效率口径

Open ASR Leaderboard 将标准化 WER 与 RTFx 放在一起，并公开评测代码，用于跨架构、跨 toolkit 的 accuracy-efficiency 比较。[Open ASR Leaderboard](https://arxiv.org/abs/2510.06961) 这种写法适合论文报告“处理音频的总体效率”，本项目应补全 full-split aggregate RTF/RTFx，并固定硬件、batch、模型版本和数据规范。

RTFx 仍不是生产 SLO：它不能单独表达请求到达、排队、P99、错误率或网络路径。因此建议论文同时保留两层：

- full-split WER/CER + RTFx：与 ASR 报告接轨；
- SLO-constrained goodput + P95/P99：面向服务容量。

### LLaMA-Omni：分阶段延迟与质量—延迟曲线

LLaMA-Omni 不只给一个 total latency，还拆出 LLM 和 TTS 延迟，并随生成步数报告 latency、ChatGPT score、ASR-WER、UTMOS 与 words/s，从而展示质量—延迟折中。[LLaMA-Omni, ICLR 2025 paper](https://proceedings.iclr.cc/paper_files/paper/2025/file/90d1fc07f46e31387978b88e7e057a31-Paper-Conference.pdf)

对本项目的对应写法是拆出 queue / Triton audio tower + projector / retrieval scoring + TopK / vLLM prefill / decode，并将 K 或 N 的质量变化与 latency 放在同一图表里。这仍属于方法与系统刻画，不自动构成生产容量证明。

### MLPerf + Triton/vLLM：生产式报告框架

MLPerf Server/Interactive 最接近生产容量表述：指定到达过程和尾延迟约束，搜索仍满足约束的最大吞吐；Triton Perf Analyzer 提供 request-rate/concurrency/custom trace 和稳定窗口；vLLM 提供 TTFT/TPOT/ITL/E2E、throughput、goodput 与详细逐请求结果。[MLPerf scenarios](https://github.com/mlcommons/inference_policies/blob/master/inference_rules.adoc#3-scenarios) [Triton Perf Analyzer](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/perf_analyzer/README.html) [vLLM benchmark serving](https://docs.vllm.ai/en/latest/cli/bench/serve.html)

需要注意：当前 MLPerf 的 Whisper speech-to-text 项主要是 Offline 场景，不是可直接套用的 ASR Server 认证；这里借鉴的是其 Server 场景方法论，而不是声称本项目符合 MLPerf ASR 规范。[MLPerf benchmark scenario matrix](https://github.com/mlcommons/inference_policies/blob/master/inference_rules.adoc#411-constraints-for-the-closed-division)

### NVIDIA Riva：最接近生产 ASR 的公开写法

NVIDIA Riva 的官方 ASR performance report 分开报告 streaming low-latency、streaming high-throughput 和 offline；固定 streaming audio chunk，扫描 parallel streams，同时给出 average/P50/P90/P95/P99 latency、RTFx 和 maximum effective streams，并公开客户端命令、硬件/软件版本。其表中结果为三轮试验的平均值，并按三轮标准差控制有效数字。[NVIDIA Riva ASR performance](https://docs.nvidia.com/deeplearning/riva/archives/2-19-0/public/asr/asr-performance.html)

这是 AmphionASR production appendix 最值得直接借鉴的版式：每种部署模式先声明 chunk/请求定义，再用“并发流数—尾延迟—RTFx”表呈现容量曲线，最后标出目标 SLO 下的 maximum effective streams。Riva 的固定单音频重复流量仍不等于本项目的真实 workload，因此应借鉴表格和复现信息，而不是照搬其数据生成方式。

## 建议的优先级实验清单

### P0：生产结论前必须补

1. **冻结生产契约**：目标部署拓扑、traffic mix、请求到达模型、P95/P99 E2E、错误率和目标 QPS。
2. **归档证据**：逐请求 JSONL、summary、provenance、完整命令、容器/代码/model revision 和候选池 hash；确保仓内可复算。
3. **独占 H20 复跑方法基线**：保留三配对条件，使用完整 EN/ZH test split或足以稳定置信区间的样本，补 aggregate RTF/RTFx、峰值显存和分阶段计时。
4. **生产同构 request-rate sweep**：对真实或可验证的 trace 扫描低载到过载，报告每点 QPS、goodput、P50/P95/P99 E2E、queue、timeout/error；找出满足 SLO 的最大 sustainable QPS。
5. **关键容量点重复**：跨进程重启至少三轮，报告置信区间和 run-to-run spread；不能用 30 条请求报告 production P99。
6. **同路径质量守门**：在选定容量点确认 Recall@50、B/U-WER 或 B/U-CER 没有超出预设退化阈值。

### P1：上线评审前应补

1. 真实生产候选池或等统计特性的脱敏池；覆盖词长、token 长度、同音密度和 pool update。
2. 音频时长、语言、prompt token、output token 分桶的 capacity table，加入长音频与 burst 流量。
3. 候选池更新、模型重载、冷启动到 ready 的恢复曲线；更新期间的 P99 和错误率。
4. dynamic batching、instance count、vLLM scheduler 与 Triton 配置的容量—时延 Pareto；明确最终选型。
5. 服务端与客户端两种计时边界，加入真实网关和网络后给用户可见 P95/P99。

### P2：规模化运维时补

1. 24 h soak、GPU/CPU/显存/功耗曲线、内存增长和性能漂移。
2. 单实例故障、Triton/vLLM 超时、OOM、热词池加载失败的降级与恢复测试。
3. 多实例/多卡扩展效率、负载均衡不均与跨 replica tail amplification。
4. 每 audio-hour 成本与单位 GPU 的 SLO-constrained audio throughput。

## 推荐的报告结构

面向论文与生产共用的报告可以按以下顺序写：

1. **Claim boundary**：一句话区分 method overhead 与 production capacity。
2. **System under test**：硬件、软件、模型、retriever、缓存、网络、调度和计时边界。
3. **Workload and SLO**：数据分布、到达过程、QPS/concurrency、时长、语言和输出长度。
4. **Quality gate**：Recall、B/U-WER/CER 及允许退化。
5. **Single-request characterization**：三配对条件、模块 breakdown、N/K scaling、RTFx。
6. **Capacity curve**：request rate → goodput / P95 / P99 / error / queue。
7. **Cold/update/recovery**：冷启动、池更新和故障恢复。
8. **Reproducibility**：raw artifacts、hash、命令和 revisions。
9. **Limitations**：真实流量覆盖、共享资源、地域网络、多 replica 等未覆盖项。

## 可直接采用的结论口径

在 P0 完成前：

> The experiment characterises the incremental cost of frame-level retrieval under a single-request, steady-state setup. It is not a production-capacity measurement: the target deployment, request-rate sweep, SLO-constrained goodput, and stable tail-latency estimates remain to be established.

P0 完成后，才适合写：

> Under the specified production-representative workload and deployment, the system sustains X requests/s (Y audio-seconds/s) while meeting the P99 end-to-end latency and error-rate objectives; enabling online retrieval changes SLO-constrained goodput by Z% and preserves the predefined hotword-accuracy gate.

## Fact check 摘要

- 当前实验的硬件、单并发、30 条/配置、共享卡、mock pool、冷启动、线上仍为 `pooled` 以及缺少原始产物等信息，均来自项目内[初步实验报告](../internal/hotword-latency-2026-07-22.md)。
- BR-ASR 的 200k bias list、99.99% pruning、20 ms/query 和 WER/B-WER 规模结果，已按[官方 arXiv 论文](https://arxiv.org/abs/2505.19179)核对。
- Open ASR Leaderboard 的 WER + RTFx 口径，已按[官方 arXiv 论文](https://arxiv.org/abs/2510.06961)核对。
- MLPerf 的 Poisson Server load、600 s、99% tail、最大受约束吞吐以及 tail-sample guidance，已按[MLCommons 官方规则](https://github.com/mlcommons/inference_policies/blob/master/inference_rules.adoc)核对；本文明确未把其中样本数当作本项目硬性下限。
- Triton 的 request-rate/concurrency/custom-interval 与稳定窗口，已按[NVIDIA 官方文档](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/perf_analyzer/README.html)核对。
- vLLM 的 TTFT/TPOT/ITL/E2E、throughput、goodput、detailed result 与 audio RTFx，已按[vLLM 官方 CLI 文档](https://docs.vllm.ai/en/latest/cli/bench/serve.html)和[指标源码文档](https://docs.vllm.ai/en/latest/api/vllm/benchmarks/serve/)核对。
- Riva 的 streaming/offline 分栏、parallel-stream sweep、average/P50/P90/P95/P99、RTFx、maximum effective streams、三轮平均与硬件披露，已按[NVIDIA Riva 官方 ASR performance report](https://docs.nvidia.com/deeplearning/riva/archives/2-19-0/public/asr/asr-performance.html)核对。
- 自作聪明 audit：没有对当前负 mean、K 非单调、共享 GPU 抖动或池规模耗时补充未经实验背书的机理解释。
