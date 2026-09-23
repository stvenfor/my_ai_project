# 双仓编码流程（Flutter 侧入口）

> **全文真相源：** [`my_go_study/docs/coding-playbook-dual-repo.md`](../../my_code_study/my_go_study/docs/coding-playbook-dual-repo.md)  
> 本文只放日常一键提示词 + Flutter 约束指针，避免双份长文漂移。

## 心法

先冻结合同，再写代码；机跑与人证分开；假完成不如 Partial + Deferred。  
人闸门：**批 Brief → 人证/Accept → commit/push**。

## 开新模块一键提示词

### 规划（先不写码）

```text
结合双仓（my_go_study + 本仓）设计 <模块>：
1) 两端 CONTEXT 术语草案（含 Avoid）
2) Go 表/API/权限口径（对照成交/二手车/待办）
3) Flutter 对标页 + 四层边界（禁止 feature 互引）
4) Slice backlog；标假实现（假上传/空 AppKey 等）
先方案与 Brief 草稿，等我批再落地。
完整流程：my_go_study/docs/coding-playbook-dual-repo.md
```

### 执行（Brief 已批）

```text
执行 my_go_study/plans/slices/<id>.md（或本仓对应 Brief）
只改白名单；遵守 AGENTS.md 四层边界。
验证：dart analyze 触及包；UI 对标 Brief「对标要点」。
主题/原生插件改完要热重启。写 acceptance（Partial 可）。
commit/push 等我指令。
```

### 修 Bug

```text
现象：…… 证据：栈/截图/请求路径
先分层：Flutter / Go BFF / Docker 镜像过旧（改 Go 后需 make lan-up）/ 主题双真源
不扩大首页宫格与权限口径；最小修复。
```

### UI 对标

```text
对标页面：features/.../<reference>
必须同构：顶栏四格 / 吸顶 Tab / 卡片行 / 底 FAB / 空态
允许复制 widgets 到本模块，不强抽跨 feature
禁止裸 ListTile 堆叠冒充完成；人证并排对照
```

## Flutter 必守

| 项 | 说明 |
|----|------|
| 边界 | `lib` → `features`/`components`/`commons`；禁止 feature 互引页面/VM |
| 联调 | `--dart-define-from-file=.env.lan`；后端改码后对方仓 `make lan-up` |
| 验收 | Partial 可；未人证勿 Full；勿把 push 当 Accept |

编排与 Slice 合同以 Go 仓 `.harness` + `plans/slices/` 为准。
