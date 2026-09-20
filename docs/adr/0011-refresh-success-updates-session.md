# 冷启动 refresh 成功须更新本地会话

在 Cold Start Keep（ADR 0008：失败不清本地）之外，明确：静默 refresh **成功**时必须用服务端返回的 access/refresh/session 更新本地 Auth Session。主缝测试「refresh success updates tokens」锁定该行为；失败仍保留旧会话。
