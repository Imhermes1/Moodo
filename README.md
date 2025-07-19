# MooDo - Mood-Based Task Management

A revolutionary iOS app that intelligently adapts your task management experience based on your current mood and emotional state.

## 🌟 Features

### Core Functionality
- **Mood-Driven Task Prioritization**: Tasks are automatically optimized and sorted based on your current emotional state
- **Smart Task Scheduling**: AI-powered scheduling that adapts to your mood patterns
- **Natural Language Processing**: Create tasks using conversational input
- **Voice Check-ins**: Record voice notes and extract tasks and mood insights
- **Cross-Device Sync**: CloudKit integration for seamless synchronization across devices

### Task Management
- **Intelligent Priority System**: Low, Medium, High priority with mood-based optimization
- **Emotion-Based Categorization**: Tasks tagged with emotions (Positive, Calm, Urgent, Creative, Focused)
- **EventKit Integration**: Automatic reminder creation in iOS Reminders app
- **Subtasks & Organization**: Hierarchical task structure with custom lists
- **Recurring Tasks**: Support for repeating tasks

### Mood Tracking
- **Daily Mood Logging**: Track your emotional state throughout the day
- **Mood History**: Visual insights into your mood patterns over time
- **Adaptive UI**: Interface colors and suggestions change based on your mood
- **Mood-Task Correlation**: Analytics showing how mood affects productivity

### Smart Features
- **Contextual Suggestions**: AI-powered task recommendations based on mood
- **Optimal Task Count**: Dynamic adjustment of daily task load based on emotional capacity
- **Mood Compatibility**: Tasks are filtered and prioritized based on emotional alignment

## 📱 Screenshots

*Coming soon - App currently in development*

## 💻 Code Examples

### Basic Task Creation

```swift
// Creating a mood-aware task
let task = Task(
    title: "Complete project presentation", 
    description: "Finish slides for tomorrow's meeting",
    priority: .high,
    emotion: .focused,
    reminderAt: Calendar.current.date(byAdding: .hour, value: 2, to: Date())
)

// Add to task manager
taskManager.addTask(task)
```

### Mood-Based UI Adaptation

```swift
// UI colors adapt based on current mood
struct MoodAwareBackground: View {
    let mood: MoodType
    
    var body: some View {
        Rectangle()
            .fill(mood.color.opacity(0.1))
            .background(
                LinearGradient(
                    colors: [mood.color.opacity(0.3), mood.color.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
```

### Smart Task Filtering

```swift
// Mood compatibility algorithm
private func isMoodCompatible(task: Task) -> Bool {
    switch currentMood {
    case .positive:
        return task.emotion == .positive || task.emotion == .creative || task.emotion == .focused
    case .calm:
        return task.emotion == .calm || task.emotion == .positive || task.emotion == .focused
    case .focused:
        return task.emotion == .focused || task.emotion == .positive || task.emotion == .creative
    case .stressed:
        return task.emotion == .calm || task.emotion == .positive || task.emotion == .focused
    case .creative:
        return task.emotion == .creative || task.emotion == .positive || task.emotion == .focused
    }
}
```

### Natural Language Processing

```swift
// Convert natural language to structured tasks
func processNaturalLanguage(_ input: String) -> ProcessedTask {
    let processor = NaturalLanguageProcessor()
    return processor.analyzeTextForTask(input)
}

// Example: "Remind me to call mom tomorrow at 3pm when I'm feeling positive"
// Result: Task(title: "Call mom", emotion: .positive, reminderAt: tomorrow3pm)
```

## 🛠 Technology Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Minimum iOS**: iOS 15.0+
- **Cloud Storage**: CloudKit
- **Local Storage**: UserDefaults, Core Data ready
- **Integrations**: EventKit, UserNotifications
- **Architecture**: MVVM with ObservableObject

### Key SwiftUI Features Used

```swift
// Observable data flow
class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var currentMood: MoodType = .positive
}

// State management
struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(taskManager)
                .environmentObject(moodManager)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
        }
    }
}
```

### Custom View Modifiers

```swift
// Mood-aware styling
struct MoodAwareModifier: ViewModifier {
    let mood: MoodType
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(mood.color)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(mood.color.opacity(0.1))
            )
    }
}

extension View {
    func moodAware(_ mood: MoodType) -> some View {
        modifier(MoodAwareModifier(mood: mood))
    }
}
```

### Async/Await Integration

```swift
// Modern concurrency for CloudKit and EventKit
func addTask(_ task: Task) {
    var newTask = task
    
    if task.reminderAt != nil {
        _Concurrency.Task {
            let eventKitID = await eventKitManager.createReminder(for: task)
            await MainActor.run {
                newTask.eventKitIdentifier = eventKitID
                self.tasks.append(newTask)
                self.saveTasks()
                self.saveToCloud()
            }
        }
    } else {
        tasks.append(newTask)
        saveTasks()
        saveToCloud()
    }
}
```

## 🏗 Project Structure

```
MooDo/
├── Models.swift              # Core data models and managers
├── CloudKitManager.swift     # Cloud synchronization  
├── EventKitManager.swift     # iOS Reminders integration
├── SmartFeatures.swift       # AI and natural language processing
├── Components.swift          # Reusable UI components
├── Views/
│   ├── Screens/             # Main app screens
│   │   ├── HomeView.swift   # Dashboard with mood-optimized tasks
│   │   ├── TasksView.swift  # Task list management
│   │   ├── InsightsView.swift # Mood analytics and trends
│   │   └── VoiceView.swift  # Voice check-in interface
│   ├── Tasks/               # Task-related views
│   │   ├── TaskComponents.swift # Individual task cards
│   │   ├── TaskListViews.swift # List containers
│   │   └── EnhancedTaskViews.swift # Advanced task UI
│   ├── Navigation/          # Navigation components
│   │   ├── TopNavigationView.swift # Header navigation
│   │   └── BottomNavigationView.swift # Tab bar
│   ├── Components/          # Specialized UI components
│   │   ├── GlassPanelBackground.swift # Glassmorphism effects
│   │   ├── LensflareView.swift # Visual effects
│   │   └── UniversalBackground.swift # Adaptive backgrounds
│   └── Settings/            # App settings
│       └── SettingsViews.swift # Configuration screens
└── Assets.xcassets/         # App icons and images
```

## 🎨 UI Components

### Mood Selection Interface

```swift
struct MoodSelectionView: View {
    @Binding var selectedMood: MoodType
    
    let moodOptions: [(type: MoodType, icon: String, label: String)] = [
        (MoodType.positive, "face.smiling", "Positive"),
        (MoodType.calm, "leaf", "Calm"),
        (MoodType.focused, "brain.head.profile", "Focused"),
        (MoodType.stressed, "face.dashed", "Stressed"),
        (MoodType.creative, "lightbulb", "Creative")
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
            ForEach(moodOptions, id: \.type) { mood in
                MoodSelectionCard(
                    mood: mood,
                    isSelected: selectedMood == mood.type
                ) {
                    selectedMood = mood.type
                }
            }
        }
    }
}
```

### Adaptive Task Card

```swift
struct TaskCard: View {
    let task: Task
    let currentMood: MoodType
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        HStack {
            // Priority indicator with mood-aware colors
            Circle()
                .fill(task.priority.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(task.emotion.color)
                
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Mood compatibility indicator
            if isMoodCompatible(task: task, currentMood: currentMood) {
                Image(systemName: "heart.fill")
                    .foregroundColor(currentMood.color)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(task.emotion.color.opacity(0.1))
        )
    }
}
```

### Advanced Glassmorphism Effects

MooDo features sophisticated glassmorphism design throughout the interface with animated light effects, multi-layer transparency, and dynamic visual depth.

```swift
struct GlassPanelBackground: View {
    @State private var lightSweepOffset: CGFloat = -200
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            // Base glass layer with complex gradient
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.15), location: 0.0),  // Darker top
                        .init(color: .black.opacity(0.05), location: 0.3),  // Light middle-top
                        .init(color: .black.opacity(0.02), location: 0.7),  // Very light middle-bottom
                        .init(color: .black.opacity(0.08), location: 1.0)   // Slightly darker bottom
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                // SwiftUI's built-in material blur effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)  // Creates backdrop blur
                    .opacity(0.3)
            )
            .overlay(
                // ✨ Animated light sweep effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .black.opacity(0.05), location: 0.45),
                                .init(color: .black.opacity(0.08), location: 0.5),   // Peak brightness
                                .init(color: .black.opacity(0.05), location: 0.55),
                                .init(color: .clear, location: 1.0)
                            ]),
                            // Dynamic start/end points based on animation
                            startPoint: .init(x: lightSweepOffset / 300, y: 0),
                            endPoint: .init(x: (lightSweepOffset + 100) / 300, y: 1)
                        )
                    )
                    .clipped()
            )
            .overlay(
                // 💎 Inner liquid glass highlight border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.15),  // Bright top-left
                                .white.opacity(0.05),  // Fade middle
                                .white.opacity(0.02),  // Very subtle
                                .white.opacity(0.1)    // Slight bottom-right
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .overlay(
                // 🌟 Outer glow for depth perception
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.02), lineWidth: 0.3)
                    .blur(radius: 2)  // Soft glow effect
            )
            // Multiple shadow layers for realistic depth
            .shadow(color: .white.opacity(0.03), radius: 2, x: 0, y: -1)    // Top highlight
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)    // Bottom shadow
            .onAppear {
                // 🎭 Continuous light sweep animation
                withAnimation(
                    .linear(duration: 5.0)
                    .delay(Double.random(in: 0...3))  // Random start delay
                    .repeatForever(autoreverses: false)
                ) {
                    lightSweepOffset = 400  // Move light across panel
                }
            }
    }
}
```

#### Glassmorphism Breakdown:

1. **Base Layer**: Multi-stop gradient with varying opacity creates glass-like depth
2. **Material Blur**: SwiftUI's `.thinMaterial` provides authentic backdrop blur
3. **Light Sweep**: Animated gradient that moves across the surface every 5 seconds
4. **Border Highlights**: Subtle white gradients simulate light refraction on glass edges
5. **Depth Shadows**: Multiple shadow layers create realistic 3D appearance
6. **Random Timing**: Each panel has slightly different animation timing for organic feel

### Task Card Glassmorphism

```swift
// Sophisticated task card with glassmorphism
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(.ultraThinMaterial)  // Lighter glass effect for cards
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.6),   // Bright highlight
                            .white.opacity(0.2),   // Fade to subtle
                            .white.opacity(0.1),   // Nearly transparent
                            .white.opacity(0.3)    // Gentle bottom accent
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
)
```

#### Material Types Used Throughout MooDo:

- **`.ultraThinMaterial`** - Very light glass effect for task cards and overlays
- **`.thinMaterial`** - Standard glassmorphism for navigation and main panels  
- **`.regularMaterial`** - Heavier glass effect for prominent interface elements

### Usage Examples in Context

```swift
// Main interface panel with custom glass
VStack {
    Text("Today's Tasks")
        .font(.title2)
        .fontWeight(.semibold)
    
    TaskListView()
}
.padding(24)
.background(
    GlassPanelBackground()  // Animated glass with light sweep
)
.clipShape(RoundedRectangle(cornerRadius: 24))

// Navigation with built-in materials
TabView {
    HomeView()
        .tabItem { Label("Home", systemImage: "house") }
}
.background(.thinMaterial)  // Glass navigation background
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ device or simulator
- Apple Developer account (for EventKit and CloudKit features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/MooDo.git
   cd MooDo
   ```

2. **Open in Xcode**
   ```bash
   open MooDo.xcodeproj
   ```

3. **Configure CloudKit**
   - Ensure your Apple Developer account is configured
   - Enable CloudKit capability in project settings
   - Configure CloudKit containers as needed

4. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd+R` to build and run

## 📋 Usage

### Basic Workflow

1. **Set Your Mood**: Start by logging your current emotional state
2. **Add Tasks**: Use natural language or structured input to create tasks
3. **Smart Optimization**: Let MooDo automatically prioritize based on your mood
4. **Complete Tasks**: Check off completed items and watch your productivity insights grow
5. **Voice Check-ins**: Record voice notes for quick task capture and mood tracking

### Mood-Based Task Management

MooDo adapts your task list based on five core emotional states:

- **🏆 Positive**: High-energy tasks, challenges, and creative work
- **🍃 Calm**: Routine tasks, organization, and peaceful activities  
- **🧠 Focused**: Deep work, analytical tasks, and concentration-heavy items
- **😟 Stressed**: Simple tasks, stress-relief activities, and manageable goals
- **💡 Creative**: Brainstorming, artistic work, and innovative projects

### Task Optimization Algorithm

```swift
func optimizeTaskSchedule(tasks: [Task], maxTasks: Int? = nil) -> [Task] {
    let today = Calendar.current.startOfDay(for: Date())
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    
    // Filter tasks based on mood compatibility and relevance
    let relevantTasks = tasks.filter { task in
        let isToday = task.reminderAt != nil && 
                     task.reminderAt! >= today && 
                     task.reminderAt! < tomorrow
        let isHighPriority = task.priority == .high && !task.isCompleted
        let matchesMood = isMoodCompatible(task: task)
        
        return (isToday || isHighPriority) && matchesMood
    }
    
    // Sort by mood compatibility, priority, and time
    let optimizedTasks = relevantTasks.sorted { task1, task2 in
        let task1MoodMatch = isMoodCompatible(task: task1)
        let task2MoodMatch = isMoodCompatible(task: task2)
        
        if task1MoodMatch && !task2MoodMatch {
            return true
        } else if !task1MoodMatch && task2MoodMatch {
            return false
        }
        
        // Then by priority
        if task1.priority == .high && task2.priority != .high {
            return true
        } else if task1.priority != .high && task2.priority == .high {
            return false
        }
        
        return (task1.reminderAt ?? Date.distantFuture) < (task2.reminderAt ?? Date.distantFuture)
    }
    
    if let maxTasks = maxTasks {
        return Array(optimizedTasks.prefix(maxTasks))
    }
    
    return optimizedTasks
}
```

## 🔧 Configuration

### EventKit Integration

```swift
// EventKit setup for iOS Reminders integration
@MainActor
class EventKitManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var isAuthorized = false
    
    func requestAuthorization() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            isAuthorized = granted
        } catch {
            print("Failed to request EventKit authorization: \(error)")
        }
    }
    
    func createReminder(for task: Task) async -> String? {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = task.title
        reminder.notes = task.description
        reminder.priority = task.priority.eventKitPriority
        
        if let reminderDate = task.reminderAt {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], 
                from: reminderDate
            )
            let alarm = EKAlarm(absoluteDate: reminderDate)
            reminder.addAlarm(alarm)
        }
        
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(reminder, commit: true)
            return reminder.calendarItemIdentifier
        } catch {
            print("Failed to save reminder: \(error)")
            return nil
        }
    }
}
```

### CloudKit Data Models

```swift
// CloudKit extensions for seamless sync
extension Task {
    init?(from record: CKRecord) {
        guard let title = record["title"] as? String,
              let priorityRaw = record["priority"] as? String,
              let emotionRaw = record["emotion"] as? String,
              let priority = TaskPriority(rawValue: priorityRaw),
              let emotion = EmotionType(rawValue: emotionRaw),
              let id = UUID(uuidString: record.recordID.recordName) else {
            return nil
        }
        
        self.init(
            id: id,
            title: title,
            description: record["description"] as? String,
            isCompleted: record["isCompleted"] as? Bool ?? false,
            priority: priority,
            emotion: emotion,
            reminderAt: record["reminderAt"] as? Date
        )
    }
    
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Task", recordID: CKRecord.ID(recordName: id.uuidString))
        record["title"] = title
        record["description"] = description
        record["isCompleted"] = isCompleted
        record["priority"] = priority.rawValue
        record["emotion"] = emotion.rawValue
        record["reminderAt"] = reminderAt
        record["createdAt"] = createdAt
        return record
    }
}
```

### Data Persistence

```swift
// Local storage with UserDefaults
class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "SavedTasks")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "SavedTasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
}
```

## 🎯 Roadmap

### Upcoming Features
- [ ] Apple Watch companion app
- [ ] Siri Shortcuts integration
- [ ] Advanced analytics and insights
- [ ] Team collaboration features
- [ ] Calendar integration
- [ ] Location-based task suggestions
- [ ] Habit tracking integration

### Planned Improvements
- [ ] Machine learning mood prediction
- [ ] Advanced natural language understanding
- [ ] Social features and mood sharing
- [ ] Integration with health apps
- [ ] Custom mood categories

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines
- Follow Swift style conventions
- Write unit tests for new features
- Update documentation as needed
- Ensure CloudKit compatibility

### Key Enums and Data Structures

```swift
// Core data models
enum MoodType: String, CaseIterable, Codable {
    case positive = "positive"
    case calm = "calm"
    case focused = "focused"
    case stressed = "stressed"
    case creative = "creative"
    
    var color: Color {
        switch self {
        case .positive: return Color(red: 0.22, green: 0.69, blue: 0.42) // Green
        case .calm: return Color(red: 0.22, green: 0.56, blue: 0.94) // Blue
        case .focused: return Color(red: 0.4, green: 0.49, blue: 0.92) // Purple
        case .stressed: return Color(red: 0.91, green: 0.3, blue: 0.24) // Red
        case .creative: return Color(red: 0.56, green: 0.27, blue: 0.68) // Purple
        }
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

enum EmotionType: String, CaseIterable, Codable {
    case positive = "positive"
    case calm = "calm"
    case urgent = "urgent"
    case creative = "creative"
    case focused = "focused"
}
```

### Sample Usage Patterns

```swift
// Creating and managing tasks with mood awareness
struct TaskCreationExample {
    func createMoodBasedTask() {
        let task = Task(
            title: "Design new feature",
            description: "Create mockups for the mood-based UI",
            priority: .high,
            emotion: .creative,
            reminderAt: Date().addingTimeInterval(3600) // 1 hour from now
        )
        
        // Task automatically gets optimized based on current mood
        taskManager.addTask(task)
    }
    
    func optimizeForCurrentMood(_ mood: MoodType) {
        // Get optimal task count for this mood
        let optimalCount = taskScheduler.getOptimalTaskCount(for: mood)
        
        // Filter and sort tasks
        let optimizedTasks = taskScheduler.optimizeTaskSchedule(
            tasks: allTasks, 
            maxTasks: optimalCount
        )
        
        // Update UI
        displayedTasks = optimizedTasks
    }
}
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Luke Fornieri**
- GitHub: [@lukefornieri](https://github.com/lukefornieri)

## 🙏 Acknowledgments

- Apple's HIG for design inspiration
- SwiftUI community for best practices
- Beta testers for valuable feedback

## 📞 Support

For support, email lukefornieri@example.com or open an issue on GitHub.

---

*MooDo - Where productivity meets emotional intelligence* ✨ 