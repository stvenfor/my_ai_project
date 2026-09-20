# Data Analytics (Flutter)

首页「数据分析」列表与详情的可视化展示语境。记录是单次观测快照，不是时间序列。

## Language

**Analytics Record（分析记录）**:
一条带流量/财务/评分的观测快照，对应列表项与详情页主体。
_Avoid_: 报表、订单、会话

**Snapshot Metrics（快照指标）**:
记录上某一观测窗口内的汇总数值（PV/UV/点击/转化/收入/成本/ROI 等），不是按时间点展开的序列。
_Avoid_: 趋势、时序、历史曲线（除非后端另提供序列接口）

**Conversion Rate（转化率）**:
列表转化环使用的比率：`转化 ÷ 点击`；分母为 0 时显示「—」。
_Avoid_: 点击率、UV 转化率（除非产品另行指定）

**List Glance Chart（列表扫一眼图）**:
列表卡片上的迷你可视化：转化环 + 以该记录 PV 为 100% 归一的 PV/UV/点击/转化迷你柱；不假装有历史趋势。
_Avoid_: sparkline（在无序列数据时）、迷你折线图

**Detail Chart Panel（详情图表面板）**:
详情页中完整图表区块：以 PV 为 100% 的流量漏斗柱、收入/成本对比柱、质量/风险雷达（刻度 0–100）；下方仍保留概况等键值分节。
_Avoid_: 仪表盘首页、总览看板

**Chart Emphasis Zone（图表强调区）**:
用留白与语义强调色突出图表的区域；非整页装饰性深色舱。色板来自 App Visual Design 的 Vercel Token API，不再使用独立 AnalyticsTheme 品牌色。
_Avoid_: 数据舱深色模式、Charles 风格、模块私有强调蓝

**Anomaly Cue（异常提示）**:
`flagAnomaly` 时的强提示：列表卡片左边色条，详情图表区顶部红色 Banner。
_Avoid_: 仅靠小字 Chip

**Featured Cue（精选提示）**:
`flagFeatured` 时的次级提示：列表左边琥珀条（若同时异常则异常优先），详情顶部琥珀 Banner。
_Avoid_: 与异常同级抢视线

**wys_chart**:
独立图表组件包（`components/wys_chart`），封装 fl_chart；数据分析等业务模块依赖它，而不是把 fl_chart 直接绑在 home 上。
_Avoid_: 把图表实现散落在各个 feature 里

**Stickiness（粘性）**:
雷达第三轴：由跳出率推导的 0–100 分（越高越好），仅用于让雷达至少三轴可读；不是独立后端字段。
_Avoid_: 当作真实业务 KPI 对外宣传
