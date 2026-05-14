# egs/ — Amphion technical reports

每份 Amphion 技术报告住在自己的 egs/<slug>/ 子目录下，结构对齐 [k2-fsa/icefall](https://github.com/k2-fsa/icefall) 的 egs 模式：顶层提供公共能力（template / tools / rules），叶子节点提供单份报告的全部材料（含报告私有的 refs/）。

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
    ├── docs/                          # 内部 plan / model_arch / task_prompts / train_eval_data
    ├── internal/                      # 数据统计、内部 model card、训练日志摘要
    ├── notes/
    │   ├── papers/
    │   │   ├── INDEX.yaml             # 真相源 (file/url/sha256/group/usage)
    │   │   ├── INDEX.md               # 人类视图（由 yaml 派生）
    │   │   └── *.pdf                  # gitignored，由 tools/fetch-refs.py 下载
    │   └── commercial-systems.md      # 闭源 / 商用 ASR / TTS / Audio-LLM 系统的官方信息源
    ├── datasets/
    │   ├── INDEX.yaml
    │   ├── INDEX.md
    │   └── *.pdf                      # gitignored
    ├── leaderboards/                  # 评测榜单截图（按需）
    └── README.md
```

每份报告完全自维护一份 `refs/`；新报告启动时由 `tools/new-report.sh` 从 `_skeleton` 拷一份骨架（含 INDEX.yaml 模板）。论文 / 数据集 PDF 不入 git，由 `tools/fetch-refs.py egs/<slug>` 按 INDEX.yaml 下载并 sha256 校验。通用写作方法学源在 `.cursor/rules/_sources.md`，所有报告共享一份。

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
