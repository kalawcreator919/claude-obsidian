---
name: recall
description: Use when user wants to find old Obsidian notes by keyword, topic, or project name. Triggers on "/recall [keyword]", "搵返", "recall", "搵筆記", "有冇寫過"
---

# Recall — Obsidian 筆記搜索

快速搵返 vault 入面相關嘅舊筆記，評分排序後展示。

**只做搜索同展示，絕對唔移動或修改任何筆記。**

**Vault：** `C:/Users/Kenneth/Desktop/Obsidian`

## Process

### Step 1 — 理解搜索意圖

分析用戶 keyword，擴展成 2-5 個相關搜索詞。

例如：
- `/recall Paperclip` → "Paperclip", "AI orchestrator", "agents", "automation"
- `/recall 水晶` → "水晶", "crystal", "金米", "kimmi", "手串"

### Step 2 — 全 Vault 搜索

**唔分資料夾，一次過搜成個 vault。** 用 3 種方式 parallel 搜索每個搜索詞：

1. **文件名** — Glob tool：
   ```
   Glob: pattern = "**/*keyword*", path = "C:/Users/Kenneth/Desktop/Obsidian"
   ```

2. **Tags** — Grep tool：
   ```
   Grep: pattern = "tags:.*keyword", path = "C:/Users/Kenneth/Desktop/Obsidian", glob = "**/*.md", -i = true
   ```

3. **內容** — Grep tool（直接攞 context，唔使之後再 Read）：
   ```
   Grep: pattern = "keyword", path = "C:/Users/Kenneth/Desktop/Obsidian", glob = "**/*.md", -i = true, output_mode = "content", -C = 2, head_limit = 50
   ```

**所有搜索詞 parallel 跑。** 如果結果太多（>50 篇），只取每種方式前 10 個 match。

### Step 3 — 評分排序

對所有結果去重後評分：

| 條件 | 分數 |
|------|------|
| 文件名命中 | +3 |
| Tags 命中 | +2 |
| 內容命中（每個唔同搜索詞 +1，最多 +3） | +1 ~ +3 |
| 位於 `30 - Notes/` | +2 bonus |
| 位於 `10 - Projects/` | +1 bonus |
| 近期修改（30 日內） | +1 bonus |

取 Top 10，同分按資料夾優先級排：30 > 10 > 20 > 00 > 40 > 99。

### Step 4 — 展示結果

對 Top 10 每篇筆記，用 Step 2 嘅 Grep content 結果提煉一句核心觀點（唔使再 Read，除非 context 唔夠）。

```
🔍 `/recall [keyword]` 結果

找到 N 篇相關筆記：

**🔝 最相關**
1. [[筆記名]] （30 - Notes）⭐ X 分
   > [一句核心觀點]

2. [[筆記名]] （10 - Projects/XXX）⭐ X 分
   > [一句摘要]

3. [[筆記名]] （20 - Areas/YYY）⭐ X 分
   > [一句摘要]

**📁 其他相關**
4-10. ...

**🕸️ 相關筆記網絡**
[[筆記A]] ← → [[筆記B]]（基於 wikilinks）

💡 建議：[具體可行嘅建議]
```

### Step 5 — 可選操作

```
📌 可以做：
- 輸入筆記編號睇全文
- `/recall [另一個 keyword]` 搜索其他主題
- `/daily-review` 處理 Inbox 相關筆記
```

用戶輸入數字 → Read 對應筆記全文展示。

## Edge Cases

- **0 篇結果：** 建議 2-3 個相近 keyword 再試
- **中文搜索詞：** Grep 正常支援
- **資料夾唔存在：** Skip，唔 error

## Guidelines

- **唯讀** — 絕對唔改、搬、刪筆記
- 粵語摘要，技術名詞保留英文
- Case insensitive 搜索
- `[[筆記名]]` 唔包 `.md`
