# Repository Guidelines

## Project Structure & Module Organization
- `MooDo/`: SwiftUI app source. Key areas: `Views/` (screens/components), `Utils/` (helpers like `DateFormatting`, `HapticManager`), `AI/` (`MLTaskEngine.swift`), `Tags/`, and `Assets.xcassets/`.
- Root files: `MoodoApp.swift`, `Models.swift`, `CloudKitManager.swift`, `EventKitManager.swift`, `Components.swift`, plus `Info.plist` and entitlements.

## Build, Test, and Development Commands
- Build (Xcode): open `MooDo.xcodeproj`, select the `MooDo` scheme, build/run on a simulator.
- Build (CLI): `xcodebuild -scheme MooDo -destination 'platform=iOS Simulator,name=iPhone 16' build`
- Open in Xcode: `xed .`
- Test (when tests exist): `xcodebuild test -scheme MooDo -destination 'platform=iOS Simulator,name=iPhone 15'`

## Coding Style & Naming Conventions
- Swift 5, 4-space indentation; prefer one type per file.
- Naming: Types `UpperCamelCase` (e.g., `CloudKitManager`), methods/vars `lowerCamelCase`; views end with `View` (e.g., `MoodBasedTasksView`).
- Organize with `// MARK: -` and keep feature code in its folder (`Views/Tasks`, `Views/Settings`, etc.).
- Lint/format: No enforced tool in repo; if added, prefer SwiftFormat/SwiftLint (e.g., `swiftformat .`).

## Testing Guidelines
- Framework: XCTest. Create a `MooDoTests` target; name files like `FeatureNameTests.swift` and methods `test_scenario_expectation`.
- Scope: Focus on `Utils/` and model logic; UI with SwiftUI should rely on view-model tests where possible.
- Run: `xcodebuild test -scheme MooDo -destination 'platform=iOS Simulator,name=iPhone 15'`. Aim for 70%+ coverage of non-UI code.

## Commit & Pull Request Guidelines
- Commits: Use imperative tone (e.g., “Add mood filter”). Conventional prefixes like `feat:`/`fix:` appear in history—use when helpful. Keep subjects ≤72 chars.
- PRs: Include a clear summary, linked issues, and screenshots/GIFs for UI changes. Note risk areas (CloudKit/EventKit) and how you validated.

## Security & Configuration Tips
- Do not commit personal Apple IDs or secrets. Respect entitlements in `Moodo.entitlements` and Info.plist privacy strings.
- Keep heavy/AI work off the main thread and behind user actions; avoid auto-running AI on launch.

## Agent Defaults (Codex CLI)
- Plan-first: Propose a concise 3–6 step plan and wait for approval before running commands or applying patches.
- Scope control: Only modify files explicitly listed in the task; ask before touching others.
- Output style: Be concise, prefer bullets, include file paths/commands in backticks.
- Search/reads: Prefer `rg`; read files in chunks ≤250 lines.
- Planning tool: Use `update_plan` to track steps; keep exactly one `in_progress` step until done.
- Runtime: Ask before running `xcodebuild` or tests; no installs or network access unless explicitly approved.
- iOS target: Use `-scheme MooDo -destination 'platform=iOS Simulator,name=iPhone 16'` when building/testing.
- Code style: Swift 5, 4-space indentation, one type per file, organize with `// MARK:`; keep diffs minimal and focused.
- UI overlays: Place cross-section overlays at the screen container level (e.g., `HomeView`); avoid `.zIndex` unless necessary.
- Safety: No destructive commands; do not commit secrets; respect entitlements and privacy strings.
- VCS: Do not create branches or commit unless requested.
- Formatting: If configured, use existing tools (e.g., `swiftformat .`); do not add new formatters.

## Task Template
- Goal: <what to achieve>
- Files: <paths to modify>
- Constraints: <perf/UX/deps limits>
- Out of scope: <exclude list>
- Definition of done: <visual/behavioral checks>
- Process: <plan-first / pause after step N>
- Run: <build/test commands to run or avoid>
