# refs/

参考资料目录。所有写内容、画图、对数字、补 cite 之前，agent 都必须先 `ls` 这里看看有什么。

详见根目录 `AGENTS.md` 规则 2。

## 推荐分类放置

```
refs/
├── docs/          # 项目内部文档（plan.md / data.xlsx 等）
├── notes/         # 随笔 / 摘录 / 设计草稿（.md）
│   ├── research-references.md   # 全网外部参考目录
│   └── papers/                  # 论文 PDF（41 篇 audio LLM / ASR，见 papers/INDEX.md）
├── datasets/      # 数据集 datasheet / README（待补）
├── benchmarks/    # 评测协议 / leaderboard 截图（待补）
└── internal/      # 自有数据统计、内部模型 spec、训练日志摘要（待补）
```

注：原先建议把论文 PDF 放在 `refs/papers/`，本仓库当前把 PDF 集中放在 `refs/notes/papers/`，方便和阅读笔记并列。两种放法都可，按团队习惯统一即可。

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
