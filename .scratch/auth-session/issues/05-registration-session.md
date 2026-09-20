# 05 — Registration Session（In + Stay）加固

**What to build:** 新用户注册通过的标准是本地已写入 Auth Session。响应带 token 则直接写入；成功但无 token 且非「先验证邮箱」时可再登录写入。邮箱已存在则停在注册页并提示，不自动改登录、不写会话。

**Blocked by:** None — can start immediately

**Status:** done

- [x] 注册成功且可建会话时，本地 Auth Session 已存在
- [x] 「用户已存在」→ 明确失败提示，会话不被写入
- [x] 主缝自动化覆盖 In / Stay；不实现邮箱验证产品流
- [x] 联调前提（关邮箱验证）在票或 SPEC 中可被执行者看到
