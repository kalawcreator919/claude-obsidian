---
name: monthly-review
description: Use when a month has passed since last review, or user wants deep self-insight on knowledge drift, merge overlapping notes, and archive completed projects. Triggers on "/monthly-review", "月度回顧", "monthly review"
---

# Monthly Review

月度整理 + 深度自我洞察。每月尾手動觸發。粵語寫 report，技術名詞英文，洞察要直接有數據，唔好客套。

## Step 1 — 掃描 Vault + 收集本月資料

掃描 `10 - Projects/`、`20 - Areas/`、`30 - Notes/` 結構。

**優先讀 Weekly Reports 聚合：**
1. Glob 搵 `40 - Daily/` 入面嘅 `*Weekly Review.md`
2. ≥3 份 → 讀取聚合 tags/主題/筆記數，用 `find -mtime -30` 補充 folder 分佈
3. < 3 份 → fallback：`find -mtime -30` 掃描所有筆記，自己統計 folder 分佈 + tags 頻率 top 10

**筆記太少（< 10 篇）→ 簡化 report，跳過知識漂移分析，只做基本統計。**

## Step 2 — 內容質素掃描

一次掃描，兩個輸出：

**A. 整合建議** — 搵標題重複關鍵詞 / tags ≥80% 重疊 / 互相引用嘅筆記，列出每組 + 原因。唔自動合併。

**B. 簡略筆記** — 搵內容 <100 字 / 冇結構 / frontmatter 缺欄位嘅筆記，列出名 + 字數。唔自動修改。

## Step 3 — 歸檔完成嘅 Projects

掃描 `10 - Projects/`，搵 `status: completed` / 30 日冇修改 / 明顯完成嘅筆記。列出建議（≤5 個一批），逐個問用戶確認後先搬去 `99 - Archive/`。

## Step 4 — 知識漂移分析（核心價值）

比較 Active Projects/Areas 嘅主題 vs Step 1 嘅實際 tags 頻率 top 5。搵出落差：tags 高頻但唔喺 Active 嘅、Active 但冇相關筆記嘅。如有上月 Monthly Review，比較 tags 分佈變化。洞察要真實直接，用數據支撐，指出用戶冇意識到嘅模式。

## Step 5 — 生成 Monthly Report

寫入 `40 - Daily/YYYY-MM Monthly Review.md`。

**Report sections（按順序）：**
1. Frontmatter: title/date/type:daily/status:active/tags:[daily, monthly-review]
2. 本月筆記分佈 — table: 位置|筆記數|佔比（6 個 folder + 合計）
3. Tags 頻率 Top 10 — table: Tag|次數
4. 最活躍項目/領域 — numbered list with note count
5. 建議整合嘅筆記 — wikilink pairs + reason（冇就寫「冇」）
6. 需要補充嘅筆記 — wikilink + word count（冇就寫「冇」）
7. 建議歸檔嘅 Projects — wikilink + last modified date（冇就寫「冇」）
8. 知識漂移洞察:
   - 你以為自己在思考...（active projects/areas）
   - 數據話你真正在思考...（top tags）
   - 洞察（data-driven, direct, no platitudes）
   - 同上月比較（冇上月就寫「首次 monthly review」）
9. 本月總結 — 新增筆記/完成 Projects/歸檔筆記/最大成就/下月重點

完成後向用戶報告 report 路徑、知識漂移重點、需要跟進嘅 action items。
