---
name: weekly-review
description: Use when a week has passed since last review, or user wants to analyze knowledge accumulation trends and resurface valuable old notes. Triggers on "/weekly-review", "weekly review", "每週回顧"
---

# Weekly Review

每週知識回顧 — 分析 Obsidian vault 嘅知識累積方向，resurface 有價值嘅舊筆記。

**Vault 路徑：** `C:/Users/Kenneth/Desktop/Obsidian`
**Report 輸出：** `40 - Daily/YYYY-MM-DD Weekly Review.md`
**唯讀：** 只分析，唔改任何現有筆記

## Process

### Step 1 — 建立 Vault Context

掃描 vault 結構，了解現有 Projects/Areas/Notes：

```bash
ls "C:/Users/Kenneth/Desktop/Obsidian/10 - Projects/"
ls "C:/Users/Kenneth/Desktop/Obsidian/20 - Areas/"
ls "C:/Users/Kenneth/Desktop/Obsidian/30 - Notes/"
```

### Step 2 — 收集本週資料

搵過去 7 日內新增或修改嘅所有 `.md` 筆記：

```bash
find "C:/Users/Kenneth/Desktop/Obsidian" -name "*.md" -mtime -7 -not -path "*/.obsidian/*" -not -path "*/.trash/*"
```

用 Read tool 讀取每篇筆記，記錄：
- 筆記檔名、所在資料夾
- Frontmatter tags
- 內容長度
- Wikilinks 數量

### Step 3 — Tags 分析

統計每個 tag 出現次數。

**排除 meta tags：** `daily`, `review`, `weekly-review`, `inbox`, `fleeting`, `active`, `completed`, `archived`, `archive`, `projects`, `areas`, `notes`

揀出最高頻嘅 **3 個核心主題**，每個寫一句描述。

### Step 4 — 筆記價值評估

對每篇本週筆記評分（1-5）：

| 標準 | 高分特徵 |
|------|---------|
| 內容完整度 | 有技術細節、決策背景、步驟記錄 |
| Wikilinks 數量 | 連結越多，知識網絡越豐富 |
| Insight 深度 | 有洞察、反思，唔止係事實記錄 |
| 可重用性 | 可以被其他筆記引用 |

選出 **Top 3-5 最有價值嘅筆記**，每篇附一句說明。

### Step 5 — Resurface 舊筆記

基於 Step 3 嘅 3 個核心主題，用 Grep tool 搵相關嘅舊筆記（超過 7 日前）：

```
Grep: pattern = "主題關鍵字", path = "C:/Users/Kenneth/Desktop/Obsidian", glob = "**/*.md", output_mode = "files_with_matches", -i = true
```

排除本週已處理嘅筆記。每個主題搵 1-3 篇，簡述點解值得重新睇。

### Step 6 — 生成 Weekly Report

計算本週日期範圍（週一至週日）。寫入 `40 - Daily/YYYY-MM-DD Weekly Review.md`：

```markdown
---
title: "YYYY-MM-DD Weekly Review"
date: "YYYY-MM-DD"
type: daily
status: active
tags: [daily, weekly-review]
---

# YYYY-MM-DD Weekly Review
Week of YYYY-MM-DD to YYYY-MM-DD

## 本週知識累積

### Tags 統計
| Tag | 出現次數 | 主要筆記 |
|-----|---------|---------|
| tag-name | N | [[筆記A]], [[筆記B]] |

### 3 個核心主題
1. **[主題名]** — [一句描述]
2. ...
3. ...

## 本週最有價值筆記

1. **[[筆記名]]**（5/5）— [點解有價值]
2. ...

## 值得 Revisit 嘅舊筆記
- [[舊筆記名]] — [點解相關]

## 本週總結
- 新增筆記：N 篇
- 修改筆記：N 篇
- 最活躍嘅資料夾：XXX
- 下週建議關注：[基於趨勢嘅建議]
```

**Edge case：** 如果本週冇筆記，report 寫明「本週冇新增或修改筆記」，唔好生成空表格。

## Important Rules

1. **唯讀** — 唔改任何現有筆記，只產出 report
2. **粵語 report** — 技術名詞保留英文
3. **Wikilinks 用 `[[筆記名]]`** — 唔包路徑，只用檔名（去掉 `.md`）
4. **評分要有依據** — 每個分數都要解釋
5. **如果已有同日 Weekly Review** — 用 Edit tool 追加而唔係覆蓋
