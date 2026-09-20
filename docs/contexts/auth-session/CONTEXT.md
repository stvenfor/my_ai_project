# Auth Session

壳工程登录、注册与本地会话的产品边界：谁拥有会话、从哪进入登录、冷启动与登出怎样算成功。

## Language

**Auth Session（认证会话）**:
登录成功后保存在本机的凭证与最小用户资料（access token、refresh token、session id、device id、用户 id/展示名等），用于证明「当前已登录」。
_Avoid_: Account、wys_account 会话、笼统说「用户缓存」

**Session Owner（会话主人）**:
负责写入、读取、清除 Auth Session 并向组件暴露登录态的模块边界；当前为 `module_auth`（经 `UserService` / `AuthLifecycle`）。
_Avoid_: `wys_account`、业务 feature 各自存 token

**Login Gate（登录门）**:
产品中唯一允许发起登录/注册的入口面：壳工程打开的 `LoginPage`（注册由其进入）；业务侧通过统一导航邀请用户登录。
_Avoid_: auth 独立 App 登录、各业务自建登录表单、直接散落打开登录路由

**Invite Login（邀请登录）**:
用户仍可能已登录或未登录时，「去做某事前请先登录」的导航：叠在当前栈上打开登录门，并可带回跳目标。
_Avoid_: 与强制回登录混用、清掉整个导航栈

**Force Reset Login（强制回登录）**:
会话已失效或用户主动登出成功后，清空导航栈并停在登录门。
_Avoid_: 仅盖一层 modal、登出后仍能返回已登录主页

**Cold Start Keep（冷启动保留）**:
进程重启后以本地 Auth Session 为准恢复已登录；启动时静默刷新失败（网络/超时/接口错误）不得清掉本地会话。
_Avoid_: 刷新失败即视为登出、用「启动 refresh 成功」当缓存验收标准

**Server-Confirmed Logout（服务端确认登出）**:
真实后端模式下，仅当服务端接受登出，或明确表示会话已不存在时，才清除本地 Auth Session；网络失败或服务端拒绝退出时保持登录并提示。
_Avoid_: 本地先清再尽力通知服务端、Mock 模式也要求打 Go

**Registration Session（注册即会话）**:
新用户注册通过的标准是本地已写入 Auth Session（响应带 token 则直接写入；成功但无 token 且非「先验证邮箱」时可再登录写入）。邮箱已存在是失败，不自动改登录。
_Avoid_: 「账号创建成功但未登录」算本轮注册通过、已存在邮箱自动登录
