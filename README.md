# 📔 LLM Notes

每天一篇 Markdown，记录大模型相关的学习：论文、原理、代码、踩坑。

> 一天一篇，写多写少都行。**「今天写了吗」比「今天写了多少」重要。**

## 每天怎么写（就两步）

在仓库根目录 `llm-notes` 里打开 PowerShell：

```powershell
.\new-note.cmd                          # 1. 建今天的笔记 → 自动用编辑器打开
.\publish.cmd                           # 2. 写完发布 → 刷新目录 + commit + push
```

两步都支持双击运行，也可以给笔记起名字：

```powershell
.\new-note.cmd -Title "Transformer 的注意力机制"
# → notes\2026-11-17-transformer-的注意力机制.md
```

> `.cmd` 只是包了一层 `powershell -ExecutionPolicy Bypass`，所以**不用改执行策略**也能跑。
> 想直接运行 `.ps1`，先做一次：`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

## 首次配置（只做一次）

1. 在 GitHub 上建空仓库：<https://github.com/new>
   - Repository name 填 `llm-notes`
   - 选 **Public**
   - **不要**勾选 Add a README / .gitignore / license（本地已经有了，勾了会冲突）
2. 在这个目录里执行一次：

```powershell
git push -u origin main
```

3. 会弹出 GitHub 登录窗口，浏览器里授权一次即可（Windows 凭据管理器会记住）。

之后每天就只剩上面那两步。

## 文件结构

```
llm-notes/
├── README.md                   # 本页：说明 + 笔记目录
├── new-note.cmd                # 新建今天的笔记
├── publish.cmd                 # 提交 + 推送
├── notes/                      # 每天一篇，全部在这里
│   └── 2026-11-17.md
├── templates/
│   └── daily-template.md       # 笔记模板，想改栏目就改它
└── scripts/
    ├── new-note.ps1            # new-note.cmd 真正调用的脚本
    ├── build-index.ps1         # 刷新本页目录（publish 会自动调用）
    └── publish.ps1             # publish.cmd 真正调用的脚本
```

## 笔记格式

每篇开头是一段 frontmatter，正文用 Markdown：

```markdown
---
date: 2026-11-17
tags: [transformer, attention]
---

# 今天搞懂了 attention 的 scaled dot-product

## 今天学了什么
- ...

## 关键点 / 结论
- ...

## 没搞懂的地方
- ...

## 参考链接
- ...
```

- `date` 和 `tags` 会被目录脚本读到，方便以后检索，不填也能用。
- 文件名以日期开头，按名字排序就是按时间排序。
- 想改每日栏目？改 `templates/daily-template.md` 就行，只影响以后的新笔记。

## 目录

<!-- INDEX:START -->
| 日期 | 标题 |
| --- | --- |
| 2026-11-17 | [开张：为什么每天记一篇](notes/2026-11-17.md) |
<!-- INDEX:END -->

---

## 常见问题

**Q：`git push` 报 `Failed to connect to github.com:443 over proxy 127.0.0.1:7890`**

本机 Git 配了走 7890 端口的代理，但代理软件没开。二选一：

```powershell
# A. 打开 Clash / VPN 等代理软件（端口要和 git 配置一致）
# B. 或者临时不用代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

**Q：代理端口不是 7890 怎么办？**

```powershell
git config --global http.proxy http://127.0.0.1:7890    # 换成你实际的端口
git config --global https.proxy http://127.0.0.1:7890
```

**Q：换台电脑怎么接着写？**

```powershell
git clone https://github.com/wjb616/llm-notes.git
```

**Q：今天不想开电脑，能用手机写吗？**

可以。在 GitHub 网页上打开 `notes/` 目录 → Add file → Create new file → 文件名填 `2026-11-18.md` → 提交。
回到电脑后先 `git pull` 再继续。

**Q：某天忘了写，需要补吗？**

不需要。缺了就缺了，第二天写就行——这个仓库只记录「写了什么」，不考核「连续多少天」。

---

*Powered by 每天 10 分钟。*
