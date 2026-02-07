# Hydration Assistant (macOS)

A cute menu bar hydration helper for macOS.

## M1 Features

- Menu bar quick actions: `半杯`, `一杯`, `已接满`, `稍后`
- Work-hour-only reminder window
- Lunch quiet period (no reminders)
- Dual reminder decision:
  - `该喝水了` (drink reminder)
  - `该接水了` (refill reminder)
- Weight-based daily hydration target with mild gender/age adjustment
- Cute animal mood feedback tied to progress

## Run

```bash
swift build
swift run HydrationAssistantApp
```

## Test

```bash
swift test
```

## Current Scope

- Local-only data/state (no cloud sync)
- Basic settings and reminders, focused on workday hydration completion

## Next

- SwiftData persistence for profile/schedule/logs
- Daily recap view
- More configurable reminder rules
