# 飞书文档同步

将本仓库 Markdown **单向同步**到飞书知识库，通过官方 [`lark-cli`](https://github.com/larksuite/cli) 实现。Git 为唯一真相源。

## Wiki 目录结构

```
项目 docs/                    ← 知识库（Wiki Space）
└── my_ai_project/            ← 项目文件夹（与仓库名一致，可在 config 修改）
    ├── AGENTS.md
    ├── README.md
    ├── docs/
    │   ├── USAGE_GUIDE
    │   └── ...
    └── packages/
        └── features/auth/README
```

配置见 [`feishu-sync.config.yaml`](./feishu-sync.config.yaml)，节点映射见 [`feishu-sync.manifest.json`](./feishu-sync.manifest.json)。

## 一、前置准备（一次性）

### 1. 安装并登录 lark-cli

```bash
# 安装见 https://github.com/larksuite/cli#installation
lark-cli config init    # 填入 App ID / App Secret
lark-cli auth login     # 用户 OAuth（bootstrap 建库需要 user 身份）
lark-cli auth status
```

### 2. 应用权限

在 [飞书开放平台](https://open.feishu.cn/app) 为自建应用开通：

- 查看、编辑和管理知识库（`wiki:wiki`）
- 创建知识空间节点（`wiki:node:create`）
- 创建及编辑新版文档（`docx:document`）

并将应用加为「项目 docs」知识库成员（bootstrap 完成后在知识库设置中添加应用，供 CI bot 写入）。

### 3. 可选环境变量

`.env.local`（已 gitignore）或 CI Secrets：

| 变量 | 说明 |
|------|------|
| `FEISHU_WIKI_SPACE_ID` | 已有知识库 ID 时可跳过自动建库 |
| `FEISHU_SYNC_AS` | `user`（默认，本地 bootstrap）或 `bot`（CI 增量 sync） |

## 二、命令

```bash
# 首次：创建「项目 docs」知识库 + my_ai_project 文件夹 + 导入全部 md
./scripts/sync_docs_to_feishu.sh bootstrap

# 增量同步（仅 hash 变更的文件）
./scripts/sync_docs_to_feishu.sh sync

# 预览
./scripts/sync_docs_to_feishu.sh dry-run

# 单文件
python3 scripts/feishu_doc_sync/main.py sync --file docs/USAGE_GUIDE.md
```

依赖：`lark-cli`（必需）、Python 3.10+ 与 `PyYAML`（脚本自动安装）。

## 三、GitHub Actions

工作流：[`.github/workflows/sync-docs-feishu.yml`](../.github/workflows/sync-docs-feishu.yml)

- push 到 `main` 且 `**/*.md` 等路径变更时触发
- 安装 `lark-cli`，以 **bot** 身份增量 sync
- 自动 commit 更新的 `feishu-sync.manifest.json`

Secrets：

- `FEISHU_APP_ID` / `FEISHU_APP_SECRET` — 与本地 lark-cli 相同应用
- `FEISHU_WIKI_SPACE_ID` — bootstrap 后从 manifest 复制

## 四、修改项目文件夹名

编辑 `docs/feishu-sync.config.yaml`：

```yaml
wiki:
  project_folder: "my_ai_project"   # 改成你的项目名
```

删除 manifest 中 `project_folder_node_token` 后重新 `bootstrap`（或手动在飞书建文件夹后写入 manifest）。

## 五、常见问题

| 现象 | 处理 |
|------|------|
| `lark-cli not found` | 安装 CLI 并确保在 PATH 中 |
| `User identity: needs_refresh` | 运行 `lark-cli auth login` |
| `permission denied` | 将应用加为知识库成员；CI 使用 `FEISHU_SYNC_AS=bot` |
| 飞书内修改被覆盖 | 预期行为；请改 Git 后 sync |

## 六、相关文件

| 文件 | 说明 |
|------|------|
| [`feishu-sync.config.yaml`](./feishu-sync.config.yaml) | 知识库名、项目文件夹、include/exclude |
| [`feishu-sync.manifest.json`](./feishu-sync.manifest.json) | space / 项目文件夹 / 文档 node 映射 |
| [`scripts/feishu_doc_sync/`](../scripts/feishu_doc_sync/) | 扫描 + 调 lark-cli |
| [`scripts/sync_docs_to_feishu.sh`](../scripts/sync_docs_to_feishu.sh) | 本地入口 |
