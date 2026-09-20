# App Visual Design

全 App（除 bfui 演示包）的视觉语言与主题边界。规范来源是仓库根目录 `DESIGN.md`（Vercel）。

## Language

**Design Source of Truth（设计真源）**:
仓库根目录 `DESIGN.md`；生产 UI 与主题层以它为准，而不是现有 iOS 风格 `AppTheme` 或各 feature 本地色板。
_Avoid_: 「参考一下 Vercel」、随意挑几色、bfui 演示主题

**Production Surface（生产界面）**:
壳工程、`module_common_ui`、以及除 `module_bfui` 外的全部业务 feature 页面与组件。
_Avoid_: bfui、把演示模板当成生产设计系统

**Theme Layer（主题层）**:
全局浅色/深色 token、`ThemeData` / 等价扩展，以及共享脚手架（Scaffold、NavBar、TabBar、按钮、输入、列表卡片等）的样式定义处。
_Avoid_: 页面内散落的硬编码色值当作「主题」

**Screen Visual Pass（逐屏视觉过稿）**:
按 Design Source of Truth 重做单个业务页的布局、层次、组件态与装饰（含允许的网格渐变用法），不只是换色。
_Avoid_: 仅替换 hex、局部「看起来差不多」

**Phased Completion（分步完成）**:
改造可分多票、多会话推进，但范围终点是全部 Production Surface 完成 Screen Visual Pass；未完成不算交付。顺序：主题层 → 共享脚手架 → 主 Tab → 其余业务 → 清扫与深色验收。
_Avoid_: 只做主题层就结项、长期停在「半 Vercel」

**Vercel Token API（Vercel Token 接口）**:
住在 `module_common_ui` 的单一主题真源（浅色/深色 token + ThemeExtension 或等价 API）；业务页只读它。
_Avoid_: 各 feature 自建 `*Theme` 色板、页面硬编码 hex

**Mesh Accent（网格渐变点缀）**:
DESIGN.md 中 cyan/blue/magenta/amber 网格渐变；仅用于营销 Hero、空态等少数强调面，不用在常规列表/表单页顶栏铺满。
_Avoid_: 每个 Tab 都上渐变、把 App 做成落地页拼贴

**Category Skin（品类皮肤）**:
某业务模块自带的非 Vercel 形态（如 iMessage 气泡壳、课堂绿品牌、音乐强制暗场）。目标态下取消品类皮肤，只保留 DESIGN.md 语义角色（error / warning / link 等）。
_Avoid_: 「聊天可以例外」「课堂保留绿」

**Mobile Type Scale（手机字号表）**:
DESIGN.md 字号角色（display / body / caption）与字重、字距比例在手机上保持；物理 px 按断点换算，不照搬 Web 的 48px Display XL。
_Avoid_: 手机硬搬 Web 字号、砍掉 display 层级

**Visual Pass Checklist（过稿清单）**:
单页完成标准：无 feature 私有主题、无违例硬编码色、组件态符合 DESIGN.md、浅/深各过一眼、Mesh Accent 只出现在允许位。
_Avoid_: 截图黄金文件、仅靠「像不像」主观收尾

**Immersive Playback Shell（沉浸播放壳）**:
视频等沉浸页保留藏系统栏与画面铺满行为；其上控件与文案仍走 Vercel Token API。
_Avoid_: 为换肤取消沉浸、沉浸页整类延期不管主题
