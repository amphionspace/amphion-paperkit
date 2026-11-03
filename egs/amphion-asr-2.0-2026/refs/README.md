# refs/ — AmphionASR 2.0 参考资料

本报告自维护一份 refs。所有写内容、画图、对数字、补 cite 之前，agent 都必须先在这里 `ls` 看看可用资料。

详见根目录 [`AGENTS.md`](../../../AGENTS.md) 规则 2。

## 目录

```
refs/
├── docs/                            # 内部 plan / model_arch / task_prompts / train_eval_data（只放本机，不入 git）
├── internal/                        # 数据统计、内部 model card、训练日志摘要（只放本机，不入 git）
├── notes/
│   ├── papers/
│   │   ├── INDEX.yaml               # 真相源 (file/url/sha256/group/usage)
│   │   ├── INDEX.md                 # 人类视图（由 yaml 派生）
│   │   └── *.pdf                    # gitignored，由 tools/fetch-refs.py 下载
│   └── commercial-systems.md        # 闭源 / 商用系统的官方信息源
├── datasets/
│   ├── INDEX.yaml                   # 真相源
│   ├── INDEX.md                     # 人类视图
│   └── *.pdf                        # gitignored
├── leaderboards/                    # 评测榜单截图（按需）
└── README.md                        # 本文件
```

## 本报告的内容速览（2026-10-31）

本仓库是公开仓库：下表中 `docs/` 与 `internal/` 下的文件只放在本机，不入 git。

| 位置 | 内容 |
| --- | --- |
| `docs/plan.md` | **先读**：报告定位（两项贡献）、对外口径、已定事项、章节结构、图的重画要求、关键数字 |
| `docs/ts_benchmark.md` | 贡献一 AmphionTS-Bench：构造、规模、指标、基准分析、局限 |
| `docs/model_arch.md` / `docs/task_prompts.md` | 贡献二的模型结构（[SEP] 在 AuT 卷积之后）与任务格式 |
| `docs/train_eval_data.md` | 训练数据、训练设置、评测集 |
| `internal/html-report/` | 已发布 HTML 报告的源码、净化数据与定稿正文（说明见 `internal/README.md`） |
| `notes/papers/INDEX.*`、`datasets/INDEX.*` | 引用文献与数据集清单 |
| `internal/amphion-eval.yaml` | 本报告用到的 AmphionEval 记录与测试集登记；`uv run tools/fetch-eval.py egs/amphion-asr-2.0-2026` 拉到 `internal/amphion-eval/`（不入 git，含不可公开子集） |

## PDF 下载

PDF 不入 git。首次准备（推荐用 [uv](https://docs.astral.sh/uv/)，脚本依赖通过 PEP 723 inline metadata 声明）：

```bash
uv run ../../tools/fetch-refs.py egs/amphion-asr-2.0-2026
```

详见 [`tools/fetch-refs.py`](../../tools/fetch-refs.py) 顶部 docstring 与 [`AGENTS.md`](../../../AGENTS.md) 规则 2。

## 加新论文 / 数据集

1. 编辑对应 `INDEX.yaml`：在 `papers:` 节加一条 entry，`sha256: null` 待回填。
2. 跑 `uv run tools/fetch-refs.py egs/amphion-asr-2.0-2026`，脚本下载并把 sha256 写回 yaml。
3. 同步 `INDEX.md`：手工加一行表格。
4. `git add` 两份 INDEX.yaml + 两份 INDEX.md，commit。

## 写作方法学源

写作 / 评审 / 复现 / agent 协作 / LaTeX 工程的方法学源不在这里 —— 在 [`.cursor/rules/_sources.md`](../../../.cursor/rules/_sources.md)，所有报告共享一份。
