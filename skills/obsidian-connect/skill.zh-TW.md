---
name: obsidian-connect
description: Use when connecting to Obsidian, verifying vault access, or troubleshooting Obsidian CLI issues
---

# Obsidian Connect

驗證 Obsidian vault 連接。優先用 CLI，fallback 用 Read/Write/Edit tool。

## When to Use

- 用戶話要連接 Obsidian
- Obsidian CLI 指令失敗
- 驗證 vault 存取

## Connection

**Vault:** `{{VAULT}}`
**Method:** Obsidian CLI（需要 Obsidian 1.12+ 運行中 + Settings → General → CLI 開啟）

### 驗證連接

```bash
obsidian read vault="Obsidian" file="Home"
```

成功返回 Home.md 內容；失敗就試 fallback。

## CLI Commands

| 操作 | 指令 |
|------|------|
| 讀取 | `obsidian read vault="Obsidian" file="<name>"` |
| 建立 | `obsidian create vault="Obsidian" name="YYYY-MM-DD Title" content="..."` |
| 追加 | `obsidian append vault="Obsidian" file="<name>" content="..."` |
| 搜索 | `obsidian search vault="Obsidian" query="keyword"` |
| 每日筆記 | `obsidian daily vault="Obsidian"` |
| 任務 | `obsidian tasks vault="Obsidian" todo` |

**Windows 注意：** 用 `Obsidian.com`（唔係 `Obsidian.exe`）先有正確嘅 stdin/stdout。

**Content 格式：** 值有空格要加引號，用 `\n` 換行，`\t` tab。

## Steps

1. 執行 `obsidian read vault="Obsidian" file="Home"` 測試連接
2. 成功：報告連接正常
3. 失敗：檢查以下
   - Obsidian desktop 有冇開？
   - CLI 有冇 enable？（Settings → General → Command line interface）
   - 版本係咪 1.12+？
   - Windows 有冇用 `Obsidian.com`？

## Fallback（CLI 唔 work 時）

用 Read/Write/Edit tool 直接操作 vault markdown 檔案：

```
Read: {{VAULT}}\00 - Inbox\筆記名.md
Write: {{VAULT}}\00 - Inbox\新筆記.md
Edit: {{VAULT}}\30 - Notes\現有筆記.md
```

## Common Mistakes

| 問題 | 原因 | 解決 |
|------|------|------|
| Unable to connect to main process | Obsidian 未開或 CLI 未 enable | 開 Obsidian + enable CLI setting |
| Command not found | CLI 未加入 PATH | Windows: 確認用 `Obsidian.com` |
| Colon subcommand 唔 work | Windows Git Bash 將 `:` 解析成 drive path | 用 `MSYS_NO_PATHCONV=1` 或用 fallback |

## Vault Structure

```
00 - Inbox/          收集層：所有新筆記入口
01 - Active/         每日常開筆記（5-10 篇）
10 - Projects/       有期限嘅項目
20 - Areas/          冇期限、持續關注嘅主題
30 - Notes/          原子筆記（一個想法 = 一篇）
40 - Daily/          日記 + Review 報告
99 - Archive/        完成/過時嘅筆記
    Sessions/        處理完嘅 session logs
Attachments/
Home.md
Templates/
```

Note 命名格式：`YYYY-MM-DD Title.md`（日期必須喺前面）
