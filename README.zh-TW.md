# claude-obsidian — Claude Code 知識編譯技能集

將你的 Obsidian 知識庫變成自我維護的知識基地。受 [Karpathy 的 LLM Wiki](https://x.com/karpathy/status/1927101613498171681) 架構啟發，這些技能讓 Claude Code 成為你的**知識編譯器** — 消化原始內容、維護結構化筆記、持續檢查知識庫健康度。

[English](README.md)

## 架構

```
原始來源              知識編譯                    維護
(Web Clips,    -->   (Daily Review +          -->   (Vault Lint +
 Sessions)           Session-to-Obsidian)            Weekly/Monthly Review)
     |                       |                              |
  Inbox/raw/          原子筆記 +                     健康分數 /100
  Inbox/               Wikilinks                    + 矛盾檢查
                                                    + 過期偵測
```

## 三大操作

源自 Karpathy 的 LLM Wiki 模型，本技能集實作三個核心操作：

### 消化（Ingest）

`/daily-review` 處理收件匣與原始剪貼。Web Clipper 文章會自動偵測，拆解為斷言式標題的原子筆記，提取重點並透過 wikilink 探索織入知識圖譜。多主題的 session log 會拆分為獨立筆記。所有筆記經由三問決策樹分類（Projects / Areas / Notes / Archive）。

### 查詢（Query）

`/recall` 以三路平行搜尋（檔名 + 標籤 + 內容）搜尋知識庫，支援相關性評分、時間篩選（`--since 2w`、`--month 2026-03`）、時間線模式（ASCII 活動圖）及活躍主題模式。

### 檢測（Lint）

`/vault-lint` 掃描矛盾、過期、孤立筆記及內容缺口四個維度，各 25 分，總計健康分數 /100。安全的機械性問題自動修復；其餘僅產出報告。

## 技能總覽

| 技能 | 指令 | 說明 |
|------|------|------|
| **每日回顧** | `/daily-review` | 處理收件匣：偵測原始剪貼、編譯原子筆記、拆分多主題、分類並移動 |
| **工作階段轉存** | `/session-to-obsidian` | 將當前 Claude Code 工作階段儲存為結構化 Obsidian 筆記 |
| **召回搜尋** | `/recall [關鍵字]` | 以關鍵字搜尋知識庫，支援評分、時間篩選及時間線模式 |
| **每週回顧** | `/weekly-review` | 每週知識累積分析，含重新浮現建議及健康摘要 |
| **每月回顧** | `/monthly-review` | 每月深度回顧，含知識漂移分析、合併建議及歸檔 |
| **知識庫檢測** | `/vault-lint` | 健康分數 /100：矛盾、過期、孤立、缺口 |
| **連線檢查** | `/obsidian-connect` | 驗證知識庫連線並排除存取問題 |

## 建議工作流程

```
每日：    /session-to-obsidian  →  /daily-review
每週：    /weekly-review
每月：    /monthly-review
隨時：    /recall [關鍵字]
按需：    /vault-lint
```

1. **擷取** — 每次工作階段結束後，執行 `/session-to-obsidian` 將結構化摘要儲存至收件匣。
2. **編譯** — 執行 `/daily-review` 消化原始剪貼為原子筆記、拆分多主題、分類並歸檔至正確資料夾。
3. **查詢** — 隨時使用 `/recall` 以關鍵字搜尋，支援評分、時間篩選或時間線視圖。
4. **回顧** — 每週末使用 `/weekly-review` 分析累積趨勢並重新浮現舊筆記；每月使用 `/monthly-review` 進行漂移分析與深度整理。
5. **檢測** — 定期執行 `/vault-lint` 在矛盾、過期筆記、孤立筆記及內容缺口累積前捕捉問題。

## 知識庫結構

本技能集預期 Obsidian 知識庫採用以下資料夾結構（由 `setup.sh` 自動建立）：

| 資料夾 | 用途 |
|--------|------|
| `00 - Inbox/` | 所有新筆記與原始剪貼的入口 |
| `01 - Active/` | 每日使用的筆記（建議 5-10 篇） |
| `10 - Projects/` | 有期限的專案 |
| `20 - Areas/` | 持續關注的主題領域 |
| `30 - Notes/` | 原子筆記（一個想法一篇，斷言式標題） |
| `40 - Daily/` | 日記、回顧報告、檢測報告 |
| `99 - Archive/` | 已完成或過時的筆記；`Sessions/` 子資料夾存放處理完的 log |

**命名格式：** `YYYY-MM-DD Title.md`（日期前綴必填）

**Frontmatter 格式：**
```yaml
---
title: "筆記標題"
date: "2026-03-26"
type: dev-session    # fleeting | project | note | daily | dev-session | learning | work-journal | idea
status: active       # active | completed | archived
tags: [inbox, topic1, topic2]
---
```

詳細結構文件請參閱 [docs/vault-structure.md](docs/vault-structure.md)。

## 設定

所有技能使用 `$VAULT_PATH` 定位你的 Obsidian 知識庫。兩種設定方式：

### 方式一：執行 setup.sh（建議）

```bash
bash setup.sh
```

腳本會提示輸入知識庫路徑、儲存至 `skills/.vault-config`、安裝所有技能至 `~/.claude/skills/`，並建立必要資料夾。

### 方式二：環境變數

```bash
export VAULT_PATH="/path/to/your/obsidian/vault"
```

加入 shell 設定檔（`.bashrc`、`.zshrc` 等）以持久化。

## 快速開始

```bash
# 1. 複製儲存庫
git clone https://github.com/kalawcreator919/claude-obsidian.git

# 2. 執行安裝
cd claude-obsidian
bash setup.sh

# 3. 重新啟動 Claude Code — 技能即可使用
```

安裝後試試：
- `/obsidian-connect` — 驗證知識庫可存取
- `/session-to-obsidian` — 儲存第一個工作階段
- `/daily-review` — 處理收件匣
- `/vault-lint` — 檢查知識庫健康度

## 系統需求

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- [Obsidian](https://obsidian.md/) 桌面應用程式
- Obsidian CLI（選用，需要 Obsidian 1.12+）— 可直接執行知識庫指令；若不可用則回退至檔案系統存取

## 貢獻

歡迎貢獻。請：

1. Fork 此儲存庫
2. 建立功能分支（`git checkout -b feature/my-skill`）
3. 遵循現有技能格式（YAML frontmatter、Process 區段、Guidelines、Related Skills）
4. 以自己的知識庫測試
5. 開啟 Pull Request

## 授權條款

[MIT](LICENSE)
