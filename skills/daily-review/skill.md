---
name: daily-review
description: Use when Obsidian Inbox has notes to process - splits multi-topic notes into atomic pieces, classifies and moves to correct vault location. Triggers on "/daily-review", "處理 inbox", "review inbox", "整理筆記"
---

# Daily Review

消化 `00 - Inbox/` 嘅筆記：拆分多主題 → 分類 → 搬去正確位置。

**核心原則：一個話題/想法 = 一篇筆記。**

## 常量

- **Vault**：`C:/Users/Kenneth/Desktop/Obsidian`
- **今日日期**：用 `date +%Y-%m-%d` 取得

## Process

### Step 1 — 掃描 Inbox

用 Bash `ls` 列出 `00 - Inbox/` 入面所有 `.md` 檔案。

- 跳過 `_index.md`
- 如果 Inbox 冇筆記，通知用戶「Inbox 清晒，冇嘢要處理」然後結束
- 列出筆記清單俾用戶睇，顯示檔案名同第一行內容摘要

### Step 2 — 建立 Vault Context

喺分類之前，先了解 vault 現有結構。呢步嘅結果會用喺之後所有分類、wikilinks 同搬移步驟。

1. `ls` 掃描 `10 - Projects/`、`20 - Areas/`、`30 - Notes/` 嘅子資料夾同檔案名
2. 對每個 project 子資料夾，讀 Overview / 主文件（如有），了解 project scope
3. 記住呢個結構，之後唔使重複掃描

### Step 3 — 讀取 Inbox 筆記

用 Read tool 讀取每篇 Inbox 筆記嘅完整內容（frontmatter + body）。

**讀取順序：短筆記先（body < 20 行），長筆記後。**

短筆記通常係單一主題，可以快速處理；長筆記（session logs、方案研究）多數需要拆分。

### Step 4 — 拆分多主題筆記

對每篇筆記判斷需唔需要拆分。

**需要拆嘅信號：**
- 標題有 `+` 或 `、` 連接多個主題
- 內容有多個 `##`/`###` section 講完全唔同嘅事
- Session log 記錄咗多件獨立工作

**唔使拆嘅情況：**
- 只有一個核心主題（子 section 圍繞同一件事）
- Body 少過 5 行
- 已經係原子筆記（`type: note`）

**拆分流程：**

1. 識別獨立主題，每個主題提取為一篇新筆記
2. 新筆記格式：
   - 檔名：`YYYY-MM-DD 主題標題.md`（日期沿用原筆記）
   - Frontmatter：
     ```yaml
     title: "主題標題"
     date: "原筆記日期"
     type: {{按內容判斷}}
     status: active
     tags: [inbox, {{相關 tags}}]
     source_note: "[[原筆記名]]"
     ```
   - Body：從原筆記提取相關內容，**保持原文，唔好改寫或摘要**
   - 底部加 `## Related` 連結返原筆記同其他拆出嚟嘅筆記
3. 原筆記處理：
   - 更新 frontmatter：tags 第一個改 `archive`，status 改 `archived`
   - 底部加 `## 拆分筆記` section，列出所有子筆記 wikilinks
   - 搬去 `99 - Archive/Sessions/`
4. 用 Write tool 寫入子筆記（寫入目標位置前，先暫放 Inbox）
5. **用 Read tool 讀返每篇子筆記，驗證內容完整、冇漏嘢**
6. 驗證通過後，子筆記進入 Step 5 分類

**注意：**
- 如果原筆記有「未完成 / Follow-up」section，將每個 follow-up 歸入相關嘅子筆記
- 跨主題內容（例如比較表）複製到所有相關筆記
- **同名檔案 guard**：寫入前檢查目標路徑有冇同名檔案，有就喺檔名加 ` (2)` 後綴

### Step 5 — 三問決策樹分類

對每篇筆記（原本單主題 + Step 4 拆出嚟嘅子筆記），行決策樹：

**前置規則：**
- `source: "Claude Code Session"` 且 Step 4 判定唔使拆 → 直接去 `99 - Archive/Sessions/`，唔使行三問

**Q1：有冇期限/明確終點？** → 有 → `10 - Projects/{project名}/`
**Q2：係持續性主題？** → 係 → `20 - Areas/{area名}/`
**Q3：可以獨立存在嘅想法/洞察？** → 係 → `30 - Notes/`
**全部冇** → 保留 `00 - Inbox/`

用 Step 2 嘅 vault context 決定具體嘅 project/area 子資料夾。

**信心門檻：**
- `>80%` → 自動搬，記錄落 report
- `≤80%` → 加入待確認清單（Step 7）

對每篇筆記記錄：`filename`、`destination`、`confidence`、`reason`、`new_title`（去 Notes 先要）

### Step 6 — 補充 Wikilinks

用 Step 2 嘅 vault context（唔使重新掃描），對每篇要搬嘅筆記：

1. 比較內容，搵語義相關嘅現有筆記
2. 喺筆記 body 底部加 `## Related` section，列出 `[[筆記名]]` wikilinks
3. 如果已經有足夠 wikilinks，唔使再加

**只加有意義嘅連結，唔好為加而加。**

### Step 6.5 — 品質評分

對每篇要搬嘅筆記（唔包括去 Archive 嘅），自動判斷品質等級並寫入 frontmatter。

**評分規則：**

| quality | 條件（符合任意一項即可） |
|---------|------------------------|
| `high` | 有決策記錄或技術細節或原創洞察；wikilinks ≥ 3；字數 > 300 且有結構（≥ 3 個 section） |
| `medium` | 有結構（≥ 2 個 section）；字數 100-300；有 frontmatter 且 tags ≥ 2 |
| `low` | 純剪貼 / 冇結構 / 少過 100 字 / frontmatter 缺欄位 |

**執行：** 用 Edit tool 喺 frontmatter 加入 `quality: high/medium/low`（加喺 `status:` 之後）。

**注意：**
- 去 `99 - Archive/` 嘅筆記唔使評品質
- 已有 `quality` 欄位嘅筆記唔使覆蓋

### Step 7 — 執行搬移（自動部分）

對所有信心 >80% 嘅筆記執行搬移。

**通用搬移 pattern：**
1. 確認目標資料夾存在（唔存在 → `mkdir -p`）
2. **同名檔案 guard**：檢查目標有冇同名檔案
3. 用 Edit tool 更新 frontmatter tags 第一個值（見下表）
4. 用 Bash `mv` 搬移

| 目標 | tags 第一個值 | status | 額外動作 |
|------|-------------|--------|---------|
| `10 - Projects/{name}/` | `projects` | 不變 | — |
| `20 - Areas/{name}/` | `areas` | 不變 | — |
| `30 - Notes/` | `notes` | 不變 | 標題改成斷言句（詞語→觀點句） |
| `99 - Archive/Sessions/` | `archive` | `archived` | — |

**搬移指令：**
```bash
mv "C:/Users/Kenneth/Desktop/Obsidian/來源/檔名.md" "C:/Users/Kenneth/Desktop/Obsidian/目標/新檔名.md"
```

### Step 8 — 待確認清單

如果有信心 ≤80% 嘅筆記，列出清單：

```
以下筆記需要你決定去向：

1. 「筆記標題」— [摘要一句話]
   建議：10 - Projects/XXX（因為...）
   選項：a) Projects/XXX  b) Areas/YYY  c) Notes  d) 保留 Inbox

2. ...
```

等用戶回覆後執行搬移（同 Step 7 流程）。全部自動就跳過。

### Step 8.5 — 更新 MOC（Map of Content）

對每個今次有筆記搬入嘅資料夾，更新（或建立）`_index.md`。

**流程：**
1. 列出該 folder 內所有 `.md` 檔案（排除 `_index.md`）
2. 對每篇讀 frontmatter `title`、`date`、`quality`，加上內容首段提煉一句摘要（≤ 20 字）
3. 按日期倒序排列
4. 用 Write tool 寫入 `_index.md`（覆蓋舊版）：

```markdown
# {Folder Name}

> 自動生成，上次更新：YYYY-MM-DD

| 筆記 | 日期 | 品質 | 摘要 |
|------|------|------|------|
| [[筆記名]] | 2026-03-26 | high | 一句摘要 |
| [[筆記名]] | 2026-03-25 | medium | 一句摘要 |

共 N 篇筆記
```

**注意：**
- 只更新有筆記搬入嘅 folder，唔使全 vault 更新
- 子資料夾（例如 `TEC - TechPulse/`）有自己嘅 `_index.md`，唔好同父資料夾混合
- `99 - Archive/` 唔使建 MOC
- `40 - Daily/` 唔使建 MOC
- 摘要用筆記內容提煉，**唔好用 frontmatter title 直接抄**（title 往往太短）

### Step 8.7 — 更新 Status Dashboard

用 Read tool 讀 `C:/Users/Kenneth/Desktop/Obsidian/01 - Active/Status Dashboard.md`，然後用 Edit tool 更新：

1. **「進行中項目」表格** — 根據今次 review 嘅筆記內容，更新項目狀態：
   - 如果發現某項目有新進展（例如新嘅研究筆記、新嘅 session 記錄），更新狀態同下一步
   - 完成嘅項目標記完成或移除
   - 新項目加入（例如 Inbox 有新 Business Idea 被分類到 Projects）
2. **更新「最後更新」日期**

注意：
- 只改有變化嘅部分，唔好重寫成個 Dashboard
- 如果冇任何項目狀態變化，跳過呢步

### Step 9 — 生成 Daily Report

寫入 `40 - Daily/YYYY-MM-DD Daily Review.md`。如果已存在，用 Edit tool 追加。

```markdown
---
title: "YYYY-MM-DD Daily Review"
date: "YYYY-MM-DD"
type: daily
status: active
tags: [daily, review]
---

# YYYY-MM-DD Daily Review

## Inbox 處理
處理咗 N 篇筆記

| 筆記 | 去向 | 備注 |
|------|------|------|
| [[筆記名]] | 目標資料夾 | 自動/待確認 |

## 拆分筆記
（冇就寫「冇筆記需要拆分」）

| 原筆記 | 拆出 |
|--------|------|
| [[原筆記名]] | [[子筆記A]]、[[子筆記B]] |

## 待確認結果
（冇就寫「全部自動處理」）

## 新增 Wikilinks
- [[筆記A]] 加咗 → [[筆記B]]

## 孤立筆記提醒
以下筆記冇任何 wikilinks，建議加連結：
- [[筆記名]]

## Dashboard 更新
（冇就寫「Status Dashboard 冇需要更新」）
- 更新咗邊個項目嘅狀態
```

**注意：** Report 用粵語。確認 `40 - Daily/` 存在。

## 重要規則

1. **唔好改寫筆記內容** — 只改 frontmatter（title、tags、status）同加 wikilinks；拆分時提取原文，唔好摘要或改寫
2. **搬移用 `mv`** — 唔好 copy + delete
3. **斷言句標題** — 只有去 `30 - Notes/` 嘅筆記先改（例：「Git Hooks」→「Git Hooks 可以自動化 commit 前嘅檢查」）
4. **保留 frontmatter** — 搬移時唔好刪除任何現有欄位
5. **資料夾唔存在就建** — `mkdir -p`
6. **同名檔案 guard** — 搬移/寫入前檢查目標有冇同名，有就加 ` (2)` 後綴
7. **冪等性** — 同一日跑多次唔會出問題：Daily Report 追加唔覆蓋，已搬走嘅筆記唔會再出現喺 Inbox
