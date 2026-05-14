# REPORT.md — <<TITLE>>

报告元数据。每份 egs 都必须维护这一份；顶层 README.md 的活跃报告表从这里汇聚。

字段说明：
- slug: 与 egs 目录名一致
- title: 报告全称（与 main.tex \title 一致）
- shortname: 用作 page header 的短名（与 main.tex \fancyhead[L] 一致）
- maintainers: 维护者（@用户名）
- status: active | submitted | archived
- venue: arXiv | ICLR-2026 | NeurIPS-2026 | ...
- pdf: 最近一次成功 build 的 PDF 路径或 release 链接
- last_updated: 最近 commit / build 日期
- depends_on_template: 兼容的 template/amphion.cls 版本号

填写示例（替换占位值）：

slug: <<SLUG>>
title: <<TITLE>>
shortname: <<SHORTNAME>>
maintainers: <<MAINTAINERS>>
status: active
venue: <<VENUE>>
pdf: TBD
last_updated: <<DATE>>
depends_on_template: v0.1
