# egs/ — Amphion technical reports

每份 Amphion 技术报告住在自己的 egs/<slug>/ 子目录下，结构对齐 [k2-fsa/icefall](https://github.com/k2-fsa/icefall) 的 egs 模式：顶层提供公共能力（template / tools / refs / rules），叶子节点提供单份报告的全部材料。

## 子目录约定

| 子目录 | 用途 |
| --- | --- |
| `_skeleton/` | 新报告的脚手架。请勿直接编辑作为发布内容；通过 `tools/new-report.sh <slug> ...` 派生新 egs |
| `<slug>/` | 单份正式报告。子目录名即报告 slug（如 `amphion-asr-2026`） |

下划线开头（`_*`）的目录被视作非发布脚手架；CI 与 `tools/build-all.sh` / `tools/fact-check-regex.sh` 都会跳过。

## 起一份新报告

```bash
tools/new-report.sh amphion-tts-2026 \
  --title    "AmphionTTS: ..." \
  --shortname "AmphionTTS" \
  --author   "Amphion TTS Team" \
  --venue    "arXiv" \
  --maintainers "@user1, @user2"
```

脚本会从 `egs/_skeleton/` cp 一份并替换 main.tex / REPORT.md / ack/llm-usage.md 中的 `<<NAME>>` 占位符。

## 单份报告的标准结构

```
egs/<slug>/
├── main.tex                # \documentclass{template/amphion}; ~30 行
├── REPORT.md               # 报告元数据（slug / status / venue / 维护者 / ...）
├── latexmkrc               # 设置 TEXINPUTS=../../ 让 template/ 解析正确
├── references.bib          # 报告 specific cites（顶层 starter 在 ../../references.bib）
├── ack/llm-usage.md        # ICLR / NeurIPS LLM 披露日志
├── sections/               # XX_name.tex 单文件单节
├── figures/                # 该报告 specific figures（TikZ 源 + 编译产物 PDF）
├── tables/                 # 大表抽出来 \input 的位置
└── refs/
    ├── docs/               # 内部 plan / model_arch / task_prompts / train_eval_data 等
    └── internal/           # 数据统计、内部 model card、训练日志摘要
```

公共参考（任何报告都可能用）放在顶层 `refs/notes/papers/`、`refs/datasets/`、`refs/leaderboards/`，**不**复制到每份 egs。

## 编译

```bash
cd egs/<slug>
PATH=/Library/TeX/texbin:$PATH latexmk -pdf main.tex
```

或一次性编所有 active egs：

```bash
tools/build-all.sh
```

## 活跃报告

最新名单维护在 [顶层 README.md](../README.md) 的"活跃报告"表中；`REPORT.md` 是单一真相源。
