---
name: session-to-obsidian
description: Use when user wants to save, log, or record the current Claude Code session to Obsidian. Triggers on "save session", "record this to Obsidian", "log session", "寫低呢個 session", "記錄落 Obsidian"
---

# Session to Obsidian

Save a detailed summary of the current Claude Code session as an Obsidian note in `00 - Inbox/`.

## Process

### Step 1 — Early Exit Check

Before doing anything, evaluate the session:

- **Skip conditions:** Session 少過 5 個來回、只係問咗一條簡單問題、或者純粹讀檔冇任何改動
- 如果 session 太 trivial，同用戶講「呢個 session 太短/trivial，唔值得記錄」然後停止
- 用戶堅持要記嘅話就繼續

### Step 2 — Summarize the Session

分析整個對話，提取以下資訊：

1. **Title** — 簡潔描述性標題（例如「Playwright MCP 設定 + E2E 測試框架搭建」）
2. **討論咗咩** — 核心主題，唔好寫「討論咗設定」，要寫「討論咗 Playwright MCP vs community 版嘅取捨」
3. **做咗咩改動** — 具體到 file path，例如：
   - `~/.claude/settings.json` — 加咗 `playwright` MCP server config
   - `apps/web/tests/e2e/login.spec.ts` — 新增登入流程 E2E 測試（38 行）
4. **決策背景** — 每個重要決定記錄 why A not B，例如：
   - 揀 Playwright MCP 唔揀 community 版 → Microsoft 官方維護，API 穩定性更好
   - 用 SQLite 唔用 PostgreSQL → MVP 階段唔需要 network DB，embedded 更簡單
5. **重點收穫** — 3 個 non-obvious insights（唔好寫「學咗 X」，要寫具體發現）
6. **未完成 / Follow-up** — 具體可行動嘅 items，要寫到：
   - 邊個 file 要改
   - 行咩 command
   - 點樣 verify 成功（例如「run `npm test` 確認全部 pass」）

### Step 3 — Determine Note Type

根據 session 內容揀 `type`：

| Type | 適用場景 |
|------|----------|
| `dev-session` | 寫 code、debug、設定開發環境、skill 開發 |
| `learning` | 研究工具、探索概念、睇文件 |
| `work-journal` | 工作項目進度 |
| `project` | 項目層面嘅規劃、架構決策 |
| `note` | 原子知識筆記、一個清晰嘅 insight |
| `idea` | 腦力激盪、探索可能性 |
| `daily` | 日記類記錄 |
| `fleeting` | 快速捕捉、冇明確分類 |

### Step 4 — Generate the Note

**檔案名格式：** `YYYY-MM-DD Title.md`

**完整筆記結構：**

```markdown
---
title: "[Title]"
date: "YYYY-MM-DD"
type: [type]
status: active
tags: [inbox, [topic1], [topic2]]
# -- Custom --
source: "Claude Code Session"
---

# [Title]

## 一句總結
> [一句講清楚呢個 session 做咗咩、達成咗咩]

## Session 內容

### 討論咗咩
- [具體主題，附背景]

### 做咗咩改動
- `[file path]` — [改咗咩]（[幾多行 / 咩性質嘅改動]）
- `[file path]` — [改咗咩]

### 決策記錄
| 決定 | 原因 |
|------|------|
| [揀咗 A] | [點解唔揀 B — 具體 reasoning] |

## 技術細節

[重要嘅 code snippets、config 設定、指令，用 code block 包住]

例如：
- 關鍵 config：
  ```json
  { "mcpServers": { "playwright": { "command": "npx", "args": ["@anthropic/mcp-playwright"] } } }
  ```
- 重要指令：
  ```bash
  npx prisma db push --force-reset
  ```

## 重點收穫
1. [Non-obvious insight 1 — 要具體]
2. [Non-obvious insight 2]
3. [Non-obvious insight 3]

## 未完成 / Follow-up
- [ ] [具體 action item]（file: `[path]`, verify: `[command]`）
- [ ] [具體 action item]

## 相關連結
- [[Related note 1]]
- [[Related note 2]]
```

**寫作原則：**
- 用粵語寫（繁體中文），技術名詞保留英文
- 具體 > 模糊：永遠寫具體 file path、command、數字
- 每句都要有實質資訊，唔好寫廢話
- 目標字數：300-500 字

### Step 5 — Add Wikilinks

掃描 Obsidian vault 搵相關筆記，加 `[[wikilinks]]`：

1. 用 Glob tool 搵 vault 入面嘅 `.md` 檔案，優先搜尋：
   - `C:/Users/Kenneth/Desktop/Obsidian/30 - Notes/*.md`
   - `C:/Users/Kenneth/Desktop/Obsidian/10 - Projects/*.md`
   - `C:/Users/Kenneth/Desktop/Obsidian/20 - Areas/*.md`
2. 根據 session 主題（keywords、project names、tool names）match 相關筆記
3. 將匹配到嘅筆記名加入「相關連結」section，格式 `[[筆記名]]`（唔包 `.md`）
4. 如果搵唔到相關筆記，留空或寫「暫無相關筆記」

### Step 6 — Write to Inbox

**一律寫入 `00 - Inbox/`**，唔好直接分 folder。

用 Write tool 寫入：
```
Write tool → file_path: "C:/Users/Kenneth/Desktop/Obsidian/00 - Inbox/YYYY-MM-DD [Title].md"
```

### Step 7 — Confirm

報告：
- 筆記路徑（完整 path）
- 字數
- Tags
- 加咗幾個 wikilinks（列出邊啲）
- 提醒用戶下次 `/daily-review` 會處理呢篇筆記嘅分類

## Guidelines

- **所有筆記寫入 `00 - Inbox/`** — 分類由 `/daily-review` 統一處理
- tags 第一個永遠係 `inbox`，第二個開始係 topic tags
- 用 `[[wikilinks]]` 連結相關筆記，增加知識圖譜密度
- 具體 > 模糊：file paths、commands、line numbers、error messages 都要記
- 決策背景必記：每個 trade-off 都要寫「why A not B」
- Code snippets 只記關鍵嘅（config、command、workaround），唔好全部 dump
- **多主題 session** — 用 `+` 連接多主題嘅標題係正常嘅（例如「修復 X + 研究 Y + 設定 Z」）。入 Inbox 後 `/daily-review` 會自動拆分成獨立筆記
- **唔好自己拆分 session** — 一個 session 永遠寫一篇筆記，拆分交畀 `/daily-review` 處理
