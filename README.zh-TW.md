# claude-obsidian

為 Claude Code 打造的 Obsidian 知識管理技能集。

將你的 Obsidian 知識庫變成結構化的第二大腦 — 從 Claude Code CLI 直接擷取工作階段、處理收件匣、搜尋筆記、執行定期回顧。

[English](README.md)

## 功能特色

- 自動將 Claude Code 工作階段儲存為 Obsidian 筆記
- 處理並分類收件匣筆記至正確的知識庫資料夾
- 以關鍵字搜尋知識庫，支援相關性評分
- 執行每週及每月知識回顧與漂移分析
- 驗證及排除 Obsidian 知識庫連線問題

## 快速開始

1. 複製儲存庫：

   ```bash
   git clone https://github.com/kalawcreator919/claude-obsidian.git
   ```

2. 執行安裝腳本：

   ```bash
   cd claude-obsidian
   bash setup.sh
   ```

3. 重新啟動 Claude Code，技能即可使用。

## 技能總覽

| 技能 | 指令 | 說明 |
|------|------|------|
| 每日回顧 | `/daily-review` | 處理收件匣：拆分多主題筆記、分類並移至正確資料夾 |
| 工作階段轉存 | `/session-to-obsidian` | 將當前 Claude Code 工作階段儲存為 Obsidian 筆記 |
| 召回搜尋 | `/recall [關鍵字]` | 以關鍵字搜尋知識庫，支援相關性評分 |
| 每週回顧 | `/weekly-review` | 每週知識累積分析 |
| 每月回顧 | `/monthly-review` | 每月深度回顧，含知識漂移分析 |
| 連線檢查 | `/obsidian-connect` | 驗證知識庫連線並排除問題 |

## 建議工作流程

```
每日：    /session-to-obsidian  -->  /daily-review
每週：    /weekly-review
每月：    /monthly-review
隨時：    /recall [關鍵字]
```

1. **擷取** -- 每次工作階段結束後，執行 `/session-to-obsidian` 將摘要儲存至知識庫的收件匣。
2. **處理** -- 執行 `/daily-review` 拆分、分類並歸檔收件匣中的筆記。
3. **回顧** -- 每週末使用 `/weekly-review` 分析知識累積情況；每月使用 `/monthly-review` 進行更深入的趨勢與漂移分析。
4. **搜尋** -- 隨時使用 `/recall` 以關鍵字查找筆記。

## 知識庫結構

本技能集預期 Obsidian 知識庫採用以下資料夾結構：

| 資料夾 | 用途 |
|--------|------|
| `00 - Inbox/` | 所有新筆記的入口 |
| `01 - Active/` | 每日使用的筆記（建議 5-10 篇） |
| `10 - Projects/` | 有期限的專案 |
| `20 - Areas/` | 持續關注的主題領域 |
| `30 - Notes/` | 原子筆記（一個想法一篇筆記） |
| `40 - Daily/` | 日記與回顧報告 |
| `99 - Archive/` | 已完成或過時的筆記 |

詳細說明請參閱 [docs/vault-structure.md](docs/vault-structure.md)。

## 語言支援

- English（英文）
- 繁體中文（預設）

寫入 Obsidian 的筆記內容預設使用繁體中文。技能介面與文件同時提供中英兩種語言。

## 系統需求

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- [Obsidian](https://obsidian.md/) 桌面應用程式
- Obsidian CLI（選用，需要 Obsidian 1.12+）-- 可直接寫入知識庫；若不可用則回退至檔案系統存取

## 授權條款

[MIT](LICENSE)
