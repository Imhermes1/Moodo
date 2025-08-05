# TODO: Moodo App Next Steps

## 1. Fix Insights Tab Functionality
- Review `InsightsView` logic and ensure all data is correctly passed and displayed.
- Debug any issues with data loading, chart rendering, or navigation.
- Ensure the tab updates in real-time with new mood/task/voice data.

## 2. Add Supabase Account Linking
- Integrate Supabase SDK for authentication and user management.
- Add UI for account linking and login/logout.
- Sync user data (tasks, moods, etc.) with Supabase backend.
- Handle error states and provide user feedback.

## 3. ✅ Smart Tasks & Recommendations (IMPLEMENTED)
- ✅ Enhanced task recommendation algorithms based on user mood, history, and preferences.
- ✅ Implemented local AI/ML logic for intelligent suggestions using Core ML and Natural Language frameworks.
- ✅ Added AI-powered recommendations displayed contextually in `HomeView` via enhanced `MoodBasedTasksView`.
- ✅ Created `SmartTaskRecommendationEngine` with privacy-first, on-device ML processing.
- ✅ Added maximum 2 AI backup recommendations to complement user's existing tasks.
- ✅ Implemented separate AI refresh button and enhanced UI with confidence indicators.
- ✅ Added comprehensive user behavior learning and pattern recognition.
- ✅ Enhanced task model with `category`, `estimatedTime`, and `completedAt` for better AI analysis.

## 3.1. 🔮 Enhanced AI Task Generation System (FUTURE)
- **Phase 1**: Create comprehensive mood-to-tasks mapping system
  - Build dedicated `MoodTaskDatabase.swift` file with extensive task variations per mood
  - Expand from current 3-6 tasks per mood to 15-20+ variations 
  - Add intelligent randomization based on time, day, user history, context
  - Mix and match task components (titles, descriptions, tips) for variety
  - Add seasonal/contextual variations (weather, holidays, work patterns)
  
- **Phase 2**: Real AI Integration Options
  - **Option A**: OpenAI API integration for truly generative tasks (~$5-20/month)
  - **Option B**: Local AI model (TinyLlama, Phi-3) for offline generation  
  - **Option C**: Hybrid approach - enhanced local + optional API for "Super AI" mode
  
- **Benefits**: Unlimited task variety, personalized recommendations, reduced repetition
- **Priority**: Medium (after core features stable)
- **Estimated Effort**: Phase 1: 4-6 hours, Phase 2: 2-3 days

## 4. Clean Up the UI
- Audit all views for consistency in padding, spacing, and color usage.
- Remove unused or redundant UI elements.
- Ensure accessibility (font sizes, contrast, VoiceOver support).

## 5. Center Moodo Text & Logo
- Update the main screen to center the Moodo logo and text.
- Ensure centering works on all device sizes and orientations.

## 6. Change the Font
- Choose and import a new font (e.g., via `.font()` modifier or custom font assets).
- Apply the new font globally or to key UI elements.

## 7. Implement Infinite Scrolling on Home Screen (and Check Other Views)
- Add infinite scroll logic to `HomeView` task/mood lists.
- Fetch more data as the user scrolls.
- Ensure smooth performance and loading indicators.
- Review `TasksView` and other list-based views for similar improvements.

## 8. Update Today's Progress
- Ensure "Today's Progress" section updates in real-time as tasks/moods are added or completed.
- Add visual indicators (progress bars, checkmarks, etc.).

## 9. Properly Implement the Voice Tab
- Finalize `VoiceView` functionality for voice check-ins.
- Integrate speech recognition and sentiment analysis.
- Store and display voice entries in Insights and Home.

## 10. Develop Notification System with Haptic Feedback
- Implement local notifications for reminders, achievements, etc.
- Add haptic feedback for key actions (task completion, mood check-in, etc.).
- Use `UNUserNotificationCenter` and `UIImpactFeedbackGenerator`.

## 11. Review System Settings
- Audit `SettingsView` for completeness and usability.
- Add toggles for notifications, theme, account management, etc.
- Ensure settings persist and sync with backend.

## 12. Create Introductory Onboarding Screen
- Design and implement a welcome/onboarding screen for first-time users.
- Include app introduction, key features overview, and mood tracking explanation.
- Guide users through initial setup and first mood entry.
- Show "Feel. Plan. Do." philosophy and how the Focus List works.
- Add smooth transitions from onboarding to main app experience.
- Store onboarding completion status to avoid showing again.

## 13. Review & Fix Haptic Feedback System
- Audit all uses of `HapticManager` and haptic feedback throughout the app
- Ensure haptics trigger reliably on all supported devices (task completion, add, delete, AI, etc.)
- Test on real hardware (not just simulator)
- Consider user settings for enabling/disabling haptics
- Add fallback or error handling for unsupported devices

## 14. Add Sections to All Tasks View
- Organize tasks into logical sections (Today, Tomorrow, This Week, Overdue, etc.)
- Add collapsible section headers with task counts
- Improve navigation and overview of task organization
- Consider grouping by priority, category, or due date
- Add smooth animations for expanding/collapsing sections


## Codebase Analysis & Further Suggestions

- **Architecture:** Consider modularizing code further (e.g., separate folders for Views, ViewModels, Services).
- **State Management:** Evaluate if `@StateObject` usage is optimal; consider using `ObservableObject` and `EnvironmentObject` for shared data.
- **Testing:** Add unit and UI tests for critical features (task management, mood tracking, voice input).
- **Performance:** Profile app for memory leaks and slow UI updates, especially with large data sets.
- **Accessibility:** Audit for VoiceOver, Dynamic Type, and color contrast.
- **Documentation:** Add docstrings and comments to complex logic and public APIs.
- **Error Handling:** Ensure all async operations (network, database) have robust error handling and user feedback.
- **Analytics:** Integrate analytics to track feature usage and user engagement.
- **Localization:** Prepare for multi-language support if needed.

---

**Next Steps:**  
Prioritize the above tasks, assign owners, and create issues/tickets for each. Regularly review progress and update this TODO as features are completed or requirements change.