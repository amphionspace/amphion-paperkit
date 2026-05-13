# refs/

参考资料目录。所有写内容、画图、对数字、补 cite 之前，agent 都必须先 `ls` 这里看看有什么。

详见根目录 `AGENTS.md` 规则 2。

## 推荐分类放置

```
refs/
├── papers/        # 同类系统 / baseline 的 technical report PDF
│   ├── whisper.pdf
│   ├── step-audio2.pdf
│   ├── kimi-audio.pdf
│   ├── seed-asr.pdf
│   └── qwen-audio.pdf
├── datasets/      # 数据集 datasheet / README
│   ├── librispeech.pdf
│   ├── gigaspeech.pdf
│   └── fleurs.pdf
├── benchmarks/    # 评测协议 / leaderboard 截图
├── internal/      # 自有数据统计、内部模型 spec、训练日志摘要
└── notes/         # 你自己的随笔 / 摘录 / 设计草稿（.md）
```

## 命名建议

- 论文 PDF：`<firstauthor><year>-<keyword>.pdf`，例：`radford2023-whisper.pdf`
- 数据集：`<dataset>-datasheet.pdf` / `<dataset>-README.md`
- 内部文档：尽量用英文短词避免空格

## Agent 怎么用

写一节前会跑：

```
ls refs/
rg -l "<关键词>" refs/
```

然后 Read 相关文件，整合事实再写。
