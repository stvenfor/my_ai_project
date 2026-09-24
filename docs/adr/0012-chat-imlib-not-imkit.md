# ADR 0012: 聊天 Tab 用 Flutter IMLib，不用 IMKit

聊天已有自研会话列表与聊天气泡（`module_chat` + `module_rongcloud_im` 引擎壳）。融云 skill 默认优先 IMKit，但换 IMKit 等于重做聊天壳。本期采用 **IMLib**（`rongcloud_im_wrapper_plugin`）：SDK 只负责连接与收发，UI 继续自研。超级群/聊天室不在本期。未选 IMKit 的原因是现有 UI 与 Mock 骨架已按 IMLib 预留；若将来要官方会话页，需单独评估迁移成本。
