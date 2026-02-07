# Hydration Assistant M1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a usable macOS hydration assistant MVP with menu bar UI, work-hour-only reminders, lunch quiet period, dual notifications (drink/refill), and one-tap drink logging.

**Architecture:** Use a small layered SwiftUI app: UI views bind to a single app state store, domain services encapsulate calculation/scheduling rules, and persistence repositories isolate SwiftData interactions. Keep domain logic framework-agnostic and fully unit-tested first, then wire UI and notifications.

**Tech Stack:** Swift 6, SwiftUI, MenuBarExtra, SwiftData, XCTest, UserNotifications.

---

### Task 1: Project Scaffold

**Files:**
- Create: `Package.swift`
- Create: `Sources/HydrationAssistantApp/HydrationAssistantApp.swift`
- Create: `Sources/HydrationAssistantDomain/*.swift`
- Create: `Tests/HydrationAssistantDomainTests/*.swift`

**Step 1: Write failing test**

```swift
import XCTest
@testable import HydrationAssistantDomain

final class SmokeTests: XCTestCase {
    func testDomainModuleLoads() {
        XCTAssertEqual(1 + 1, 2)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL because targets/modules do not exist yet.

**Step 3: Write minimal implementation**

- Create package targets:
  - `HydrationAssistantDomain` (library)
  - `HydrationAssistantApp` (executable)
  - `HydrationAssistantDomainTests` (test target)
- Add minimal app entry and domain placeholder.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS for smoke test.

**Step 5: Commit**

```bash
git add Package.swift Sources Tests
git commit -m "chore: scaffold hydration assistant package"
```

### Task 2: Goal Calculator (TDD)

**Files:**
- Create: `Sources/HydrationAssistantDomain/GoalCalculator.swift`
- Create: `Sources/HydrationAssistantDomain/Models.swift`
- Create: `Tests/HydrationAssistantDomainTests/GoalCalculatorTests.swift`

**Step 1: Write failing test**

- Test base formula by weight.
- Test gender/age mild adjustment.
- Test clamped minimum/maximum daily target.

**Step 2: Run test to verify it fails**

Run: `swift test --filter GoalCalculatorTests`
Expected: FAIL with missing type/function.

**Step 3: Write minimal implementation**

- Implement `GoalCalculator.dailyTargetMl(profile:)`.
- Keep adjustment coefficients explicit constants.

**Step 4: Run test to verify it passes**

Run: `swift test --filter GoalCalculatorTests`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/HydrationAssistantDomain/GoalCalculator.swift Sources/HydrationAssistantDomain/Models.swift Tests/HydrationAssistantDomainTests/GoalCalculatorTests.swift
git commit -m "feat: implement hydration goal calculator"
```

### Task 3: Schedule Window + Lunch Quiet Logic (TDD)

**Files:**
- Create: `Sources/HydrationAssistantDomain/ScheduleEvaluator.swift`
- Create: `Tests/HydrationAssistantDomainTests/ScheduleEvaluatorTests.swift`

**Step 1: Write failing test**

- Inside work window and outside lunch -> active.
- During lunch -> inactive.
- Before work / after work -> inactive.

**Step 2: Run test to verify it fails**

Run: `swift test --filter ScheduleEvaluatorTests`
Expected: FAIL with missing APIs.

**Step 3: Write minimal implementation**

- Implement `isReminderActive(now:schedule:)` with deterministic calendar math.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ScheduleEvaluatorTests`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/HydrationAssistantDomain/ScheduleEvaluator.swift Tests/HydrationAssistantDomainTests/ScheduleEvaluatorTests.swift
git commit -m "feat: add work-hour and lunch quiet period evaluation"
```

### Task 4: Drink/Refill State Machine (TDD)

**Files:**
- Create: `Sources/HydrationAssistantDomain/HydrationEngine.swift`
- Create: `Tests/HydrationAssistantDomainTests/HydrationEngineTests.swift`

**Step 1: Write failing test**

- Log half-cup increments consumed and decrements cup remaining.
- Refill resets remaining to cup capacity.
- Refill reminder triggers below threshold.
- Goal reached flag when consumed >= target.

**Step 2: Run test to verify it fails**

Run: `swift test --filter HydrationEngineTests`
Expected: FAIL with missing engine logic.

**Step 3: Write minimal implementation**

- Implement pure-state functions for drink/refill and reminder flags.

**Step 4: Run test to verify it passes**

Run: `swift test --filter HydrationEngineTests`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/HydrationAssistantDomain/HydrationEngine.swift Tests/HydrationAssistantDomainTests/HydrationEngineTests.swift
git commit -m "feat: implement hydration state transitions"
```

### Task 5: Reminder Interval Strategy (TDD)

**Files:**
- Create: `Sources/HydrationAssistantDomain/ReminderScheduler.swift`
- Create: `Tests/HydrationAssistantDomainTests/ReminderSchedulerTests.swift`

**Step 1: Write failing test**

- Remaining target and remaining active minutes produce valid positive interval.
- Goal reached -> no next reminder.
- Snooze applies fixed delay.

**Step 2: Run test to verify it fails**

Run: `swift test --filter ReminderSchedulerTests`
Expected: FAIL with missing scheduler.

**Step 3: Write minimal implementation**

- Implement interval math with lower and upper bounds.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ReminderSchedulerTests`
Expected: PASS.

**Step 5: Commit**

```bash
git add Sources/HydrationAssistantDomain/ReminderScheduler.swift Tests/HydrationAssistantDomainTests/ReminderSchedulerTests.swift
git commit -m "feat: implement reminder interval scheduler"
```

### Task 6: Minimal Menu Bar UI Wiring

**Files:**
- Modify: `Sources/HydrationAssistantApp/HydrationAssistantApp.swift`
- Create: `Sources/HydrationAssistantApp/AppStore.swift`
- Create: `Sources/HydrationAssistantApp/MenuBarContentView.swift`
- Create: `Sources/HydrationAssistantApp/SettingsView.swift`

**Step 1: Write failing test**

- Add lightweight view-model unit test for quick actions updating state.

**Step 2: Run test to verify it fails**

Run: `swift test --filter AppStoreTests`
Expected: FAIL with missing store/actions.

**Step 3: Write minimal implementation**

- Add menu bar UI with:
  - progress text
  - buttons: half cup / one cup / refill / snooze
  - open settings window
- Add cute animal status text/icon mapping by progress.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS all tests.

**Step 5: Commit**

```bash
git add Sources/HydrationAssistantApp Tests
git commit -m "feat: add menu bar MVP UI with quick actions"
```

### Task 7: Notification Integration + Verification

**Files:**
- Create: `Sources/HydrationAssistantApp/NotificationManager.swift`
- Modify: `Sources/HydrationAssistantApp/AppStore.swift`
- Create: `Tests/HydrationAssistantDomainTests/NotificationDecisionTests.swift`

**Step 1: Write failing test**

- Verify decision logic chooses drink vs refill prompt correctly.

**Step 2: Run test to verify it fails**

Run: `swift test --filter NotificationDecisionTests`
Expected: FAIL.

**Step 3: Write minimal implementation**

- Encapsulate notification payload creation and schedule trigger.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS all tests.

**Step 5: Final verification + commit**

```bash
swift test
swift build
git add Sources Tests Package.swift
git commit -m "feat: complete m1 hydration assistant workflow"
```

### Task 8: Documentation Update

**Files:**
- Create: `README.md`

**Step 1: Write failing test**

- N/A (documentation task)

**Step 2: Write minimal implementation**

- Add run instructions, feature list, limitations, and next milestones.

**Step 3: Verify**

Run: `swift test && swift build`
Expected: PASS.

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add setup and usage guide"
```

