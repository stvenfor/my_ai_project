# ADR 0001: Charts via `wys_chart` + fl_chart

## Status

Accepted

## Context

数据分析列表/详情需要可视化。备选包括 fl_chart、Syncfusion、flutter_echarts。需要兼顾观感、鸿蒙纯 Dart 友好、以及商用授权。

## Decision

1. 使用 **fl_chart**（MIT）作为图表引擎。
2. 新建独立包 **`components/wys_chart`** 封装环图/迷你柱/漏斗柱/对比柱/雷达，业务模块不直接依赖 fl_chart。
3. 无时间序列时，列表不做 sparkline；用转化率环 + 以 PV 为 100% 的迷你柱。

## Consequences

- 雷达至少需要三轴才好看：第三轴「粘性」由跳出率推导，不是后端字段。
- 以后多模块复用图表时只需扩 `wys_chart`，不必再抽 commons。
- Syncfusion 观感更「成品」但授权更重；若商用授权就绪可再评估替换封装实现。
