# MoodLensTracker iOS App

A native iOS/macOS app built with SwiftUI that helps you track your mood, manage tasks, and maintain wellness through voice check-ins and insights.

## 🎯 Features

### 📱 Core Functionality
- **Mood Tracking**: Log your daily mood with intensity levels and notes
- **Task Management**: Create, organize, and track tasks with priorities and categories
- **Voice Check-ins**: Record voice notes for mood and task updates
- **Wellness Prompts**: Daily prompts to encourage self-reflection
- **Quick Stats**: Overview of your mood trends and task completion

### 🎨 Design
- Beautiful gradient background with glass-morphism effects
- Intuitive tab-based navigation (Home, Voice, Insights)
- Modern iOS design patterns with SwiftUI
- Responsive layout that works on iPhone and iPad

### 📊 Data Management
- Local data storage with sample data for demonstration
- Structured data models for tasks, mood entries, and voice check-ins
- Category-based task organization (Personal, Work, Health, Finance, Education)
- Priority levels (Low, Medium, High) with color coding

## 🚀 Getting Started

### Prerequisites
- Xcode 16.0 or later
- iOS 18.5+ or macOS 15.0+
- Swift 5.0+

### Installation
1. Clone or download the project
2. Open `Moodo.xcodeproj` in Xcode
3. Select your target device (iPhone/iPad simulator or physical device)
4. Build and run the project (⌘+R)

### Running the App
```bash
# Build the project
xcodebuild -project Moodo.xcodeproj -scheme Moodo -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run in simulator
xcrun simctl boot "iPhone 16"
xcrun simctl install booted DerivedData/Build/Products/Debug-iphonesimulator/Moodo.app
xcrun simctl launch booted Harmoniq.Moodo
```

## 📁 Project Structure

```
Moodo/
├── MoodoApp.swift          # Main app entry point
├── ContentView.swift       # Main app interface with tab navigation
├── Models.swift           # Data models and managers
├── Components.swift       # Reusable UI components
└── Assets.xcassets/       # App icons and assets
```

### Key Components

#### Data Models (`Models.swift`)
- `Task`: Task management with title, description, priority, category
- `MoodEntry`: Mood tracking with type, intensity, notes, activities
- `VoiceCheckin`: Voice recording with transcript and metadata
- `TaskManager`, `MoodManager`, `VoiceCheckinManager`: Data management

#### UI Components (`Components.swift`)
- `MoodCheckinView`: Mood selection and logging interface
- `TaskListView`: Task display and management
- `WellnessPromptView`: Daily wellness prompts
- `VoiceCheckinView`: Voice recording interface
- `QuickStatsView`: Statistics overview
- `AddTaskModalView`: Task creation modal

## 🎮 How to Use

### Home Tab
1. **Mood Check-in**: Tap "Select your mood" to choose from 10 different mood types
2. **Wellness Prompt**: Read daily prompts and tap the refresh button for new ones
3. **Task List**: View your tasks and tap the + button to add new ones
4. **Quick Stats**: See your task completion rate and average mood

### Voice Tab
1. **Voice Check-in**: Tap the microphone button to start recording
2. **Voice History**: View your previous voice recordings with timestamps

### Insights Tab
1. **Mood History**: Review your mood entries over time
2. **Voice History**: Access your voice check-in history

### Adding Tasks
1. Tap the "Add Task" button in the bottom navigation
2. Fill in task details (title, description, priority, category)
3. Optionally set a due date
4. Tap "Save" to create the task

## 🔧 Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Model-View-ViewModel architecture
- **ObservableObject**: Reactive data binding
- **@StateObject**: State management for data managers

### Data Persistence
- Currently uses in-memory storage with sample data
- Ready for Core Data or UserDefaults integration
- Structured for easy backend API integration

### Platform Support
- **iOS**: iPhone and iPad (Universal app)
- **macOS**: Native macOS app support
- **SwiftUI**: Cross-platform compatibility

## 🎨 Design System

### Colors
- Primary gradient: Blue to Purple
- Mood colors: Each mood type has its own color
- Priority colors: Green (Low), Orange (Medium), Red (High)

### Typography
- System fonts with appropriate weights
- Hierarchical text sizing
- High contrast for accessibility

### Layout
- Glass-morphism effects with `.ultraThinMaterial`
- Rounded corners and modern spacing
- Responsive design for different screen sizes

## 🔮 Future Enhancements

### Planned Features
- **Core Data Integration**: Persistent local storage
- **Cloud Sync**: iCloud integration for data backup
- **Notifications**: Reminders for mood check-ins and tasks
- **Analytics**: Detailed mood and productivity insights
- **Export**: Data export functionality
- **Widgets**: iOS home screen widgets

### Technical Improvements
- **Speech Recognition**: Real voice-to-text for check-ins
- **Machine Learning**: Mood pattern analysis
- **HealthKit Integration**: Health data correlation
- **Siri Shortcuts**: Voice commands for quick actions

## 📱 Screenshots

The app features:
- Beautiful gradient background
- Glass-morphism UI elements
- Intuitive tab navigation
- Mood selection with emojis
- Task management interface
- Voice recording capabilities
- Statistics and insights

## 🤝 Contributing

This project was converted from a React/TypeScript web application to a native iOS app. The original web app structure and functionality have been preserved while adapting to iOS design patterns and SwiftUI conventions.

## 📄 License

This project is part of the MoodLensTracker application suite, designed to help users track their mental wellness and productivity.

---

**Built with ❤️ using SwiftUI for iOS/macOS** 