# 喝水小助手（HydrationAssistant）

一个面向 macOS 的菜单栏喝水提醒应用，目标是在工作时段内帮助你稳定完成每日饮水量。

当前实现重点：
- 菜单栏常驻（不占 Dock）
- 首次使用引导（在设置窗口完成配置）
- 上班/下班控制提醒开关
- 午休免打扰
- 仅保留“喝水提醒”（不再有“接水提醒”）
- 支持通知内快捷动作：`我已经喝了半杯水` / `我已经喝了一杯水`
- 支持直接点击通知主体：默认记作“喝了半杯水”
- 支持“自动计算”与“手动输入每日目标”二选一
- 明显化进度卡片（百分比 + 当前/目标 ml + 视觉高亮）
- 本地持久化（UserDefaults）

---

## 1. 运行环境

- macOS 14+
- Apple Silicon（`arm64`）
- Swift 6.1+

说明：
- 项目使用 Swift Package Manager。
- 当前打包为 ad-hoc 签名，适合本机/朋友内测。

---

## 2. 快速开始

### 2.1 本地运行

```bash
swift build
swift run HydrationAssistantApp
```

### 2.2 运行测试

```bash
swift test
```

---

## 3. 安装（pkg）

安装包通常在：
- `release/<version>/HydrationAssistant-<version>.pkg`

安装示例：

```bash
pkill -f HydrationAssistantApp || true
sudo installer -pkg /Users/wangzhishan1/aiProject/release/1.0.1/HydrationAssistant-1.0.1.pkg -target /
open /Applications/HydrationAssistant.app
```

如被系统拦截：
- 到「系统设置 -> 隐私与安全性」允许应用。

---

## 4. 使用流程

### 第一次使用

1. 打开应用，菜单显示“首次使用设置”。
2. 点击“打开设置”进入设置窗口。
3. 选择每日目标方式（2 选 1）：
   - 自动计算：使用体重/性别/年龄
   - 手动输入：直接填每日目标 ml
4. 填写工作时间与午休时间。
5. 点击“保存设置”，会显示“保存设置成功”。

### 日常使用

1. 点击“上班”开始提醒。
2. 收到提醒后：
   - 可在菜单中点“喝半杯水 / 喝一杯水”
   - 也可直接在通知上操作（含动作按钮）
3. 临时不便可点“稍后提醒”。
4. 点击“下班”后停止提醒。

---

## 5. 功能说明

### 5.1 每日目标（核心）

支持两种模式：

1. 自动计算模式
- 基于体重公式估算目标
- 按性别/年龄做轻量修正

2. 手动输入模式
- 直接输入每天计划饮水量（ml）
- 保存后立即生效

### 5.2 提醒规则

提醒触发前提：
- 已完成首次设置
- 当前处于上班状态
- 当前不在午休时段
- 今日目标未完成

提醒频率不是固定值，而是动态计算：
- 依据剩余目标量 + 剩余可提醒时长
- 点“稍后提醒”会在指定分钟内抑制提醒

### 5.3 通知交互

正式“喝水提醒”通知支持：
- 动作按钮：
  - `我已经喝了半杯水`
  - `我已经喝了一杯水`
- 直接点击通知主体：默认记作“喝了半杯水”

测试通知也带同样动作按钮，便于验证通知链路。

### 5.4 UI 反馈

菜单栏主界面包含：
- 顶部状态卡片（大字号 + 渐变背景）
- 喝水进度卡片（百分比、进度条、当前/目标）
- 预计下次提醒喝水时间
- 小动物状态文案（按“当前时段进度”评估，不是必须喝满才积极）

### 5.5 设置管理

- 保存设置：写入本地并提示成功
- 重置设置：恢复默认值并提示成功
- 默认值重置后需重新完成首次设置

---

## 6. 输入规则与校验

数字项（体重/年龄/杯子容量/手动目标）为直接输入。

保存时会做基础兜底：
- 体重最小 30
- 年龄最小 10
- 杯子容量最小 100
- 手动目标最小 1000

非法或空输入会回退为有效值，不会写入坏数据。

---

## 7. 项目结构

```text
.
├── Package.swift
├── Sources
│   ├── HydrationAssistantApp
│   │   ├── HydrationAssistantApp.swift      # App 入口、菜单栏和设置窗口
│   │   ├── AppViewModel.swift               # 状态、规则编排、持久化
│   │   ├── MenuBarContentView.swift         # 菜单栏 UI
│   │   ├── SettingsView.swift               # 设置窗口 UI
│   │   └── NotificationManager.swift        # 通知权限/发送/动作回调
│   └── HydrationAssistantDomain
│       ├── Models.swift                     # UserProfile / WorkSchedule
│       ├── GoalCalculator.swift             # 目标计算
│       ├── ReminderScheduler.swift          # 提醒间隔
│       ├── ScheduleEvaluator.swift          # 上班/午休判定
│       ├── HydrationEngine.swift            # 饮水状态变更
│       ├── HydrationAppStore.swift          # 饮水状态管理
│       ├── NotificationDecision.swift       # 提醒决策
│       └── WorkdayPlanSummaryCalculator.swift
└── Tests/HydrationAssistantDomainTests      # 领域测试
```

---

## 8. 测试覆盖

当前自动化测试覆盖：
- 目标计算
- 提醒间隔
- 工作/午休时段判定
- 饮水状态机（含大杯限额）
- 通知决策
- 每日计划汇总

当前未覆盖：
- UI 自动化
- 通知中心动作端到端自动化（依赖系统环境）

---

## 9. 常见问题（FAQ）

### Q1：测试提示点了没看到通知
优先看菜单内反馈文案：
- 已发送：查看系统通知中心
- 未授权：到系统设置开启该应用通知
- 发送失败：稍后重试

另外：
- 专注模式可能隐藏横幅
- 系统通知样式可能折叠动作按钮到“选项”中

### Q2：为什么不再做“接水提醒”
- 已按产品决策移除，避免过度打扰
- 默认假设用户水喝完会自然接水

### Q3：通知里两个动作能不能都直接显示成按钮
- 受 macOS 原生通知样式限制，部分场景会折叠到“选项”
- 当前已支持：直接点通知主体 = 喝半杯（一步完成）

---

## 10. 打包与分发说明

当前打包方式：
- `.app`：ad-hoc 签名
- `.pkg`：固定安装路径（避免重定位）

若需要“真正正式对外分发”（减少系统拦截）：
1. Developer ID Application 签名 `.app`
2. Developer ID Installer 签名 `.pkg`
3. Apple Notarization 公证
4. stapler 固化票据

---

## 11. 开发约定

- 语言：Swift + SwiftUI
- 包管理：Swift Package Manager
- 测试：Swift Testing

---

## 12. 免责声明

本项目用于习惯管理，不构成医疗建议。
如有特殊健康状况，请遵循医生或专业机构建议。
