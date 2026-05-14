# refs/ — AmphionASR 参考资料

本报告自维护一份 refs，供写作 / fact-check / 实验对比时检索。所有写内容、画图、对数字、补 cite 之前，agent 都必须先在这里 `ls` 看看可用资料。

详见根目录 [`AGENTS.md`](../../../AGENTS.md) 规则 2。

## 目录

```
refs/
├── docs/                            # 内部 plan / model_arch / task_prompts / train_eval_data
├── internal/                        # 数据统计、内部 model card、训练日志摘要
├── notes/
│   ├── papers/
│   │   ├── INDEX.yaml               # 真相源 (file/url/sha256/group/usage)
│   │   ├── INDEX.md                 # 人类视图（由 yaml 派生）
│   │   └── *.pdf                    # gitignored，由 tools/fetch-refs.py 下载
│   └── commercial-systems.md        # 闭源 / 商用 ASR / TTS / Audio-LLM 官方信息源
├── datasets/
│   ├── INDEX.yaml                   # 真相源
│   ├── INDEX.md                     # 人类视图
│   └── *.pdf                        # gitignored
├── leaderboards/                    # 评测榜单截图（按需）
└── README.md                        # 本文件
```

## PDF 下载

PDF 不入 git。首次准备：

```bash
pip install -r ../../tools/requirements-fetch.txt
python ../../tools/fetch-refs.py egs/amphion-asr-2026
```

行为：

- 解析两份 `INDEX.yaml`（schema 校验 + papers[*].group 与 groups[*].id 交叉校验）。
- 并行下载（默认 4 路）；已存在文件按 sha256 校验后 SKIP。
- 首次下载完成后，自动把计算到的 sha256 回填到 yaml；请 `git diff` 后 commit。
- 后续任何人 clone 仓库再跑同一脚本，sha256 不一致会 MISMATCH（URL 漂移 / 文件损坏的早期信号）。

详见 [`tools/fetch-refs.py`](../../tools/fetch-refs.py) 顶部 docstring。

## 加新论文 / 数据集

1. 编辑对应 `INDEX.yaml`：在 `papers:` 节加一条 entry，`sha256: null` 待回填。
2. 跑 `python tools/fetch-refs.py egs/amphion-asr-2026`，脚本下载并把 sha256 写回 yaml。
3. 同步 `INDEX.md`：手工加一行表格（同 yaml 元数据）。
4. `git add` 两份 INDEX.yaml + 两份 INDEX.md，commit。

## 写作方法学源

写作 / 评审 / 复现 / agent 协作 / LaTeX 工程的方法学源不在这里 —— 在 [`.cursor/rules/_sources.md`](../../../.cursor/rules/_sources.md)。该文件是 `.cursor/rules/*.mdc` 与 `AGENTS.md` 的源汇总，所有报告共享一份。
