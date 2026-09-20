# 冷启动保留本地会话；真实登出需服务端确认（Gone 视为成功）

验收「登录后缓存」时，冷启动以本地 Auth Session 为准：启动静默 refresh 失败不得 `clearUser`（Cold Start Keep），以免网络抖动被当成缓存无效。真实后端登出采用 Server-Confirmed Logout：须服务端接受退出才清本地；若服务端表示 token/会话已不存在，视为登出已完成并清本地；网络错误或拒绝退出则保持登录并提示。Mock 模式仍只清本地。邮箱验证在联调环境关闭，以便 Registration Session 能直接写入会话。
