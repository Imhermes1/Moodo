import SwiftUI

struct AllThoughtsListView: View {
    @ObservedObject var thoughtsManager: ThoughtsManager
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedMoodFilter: MoodType?
    @State private var showingAddThought = false
    @State private var editingThought: Thought?
    @State private var convertingThought: Thought?
    
    var filteredThoughts: [Thought] {
        // Step 1: Filter by search text
        let searchFiltered: [Thought]
        if !searchText.isEmpty {
            searchFiltered = thoughtsManager.thoughts.filter { thought in
                thought.title.localizedCaseInsensitiveContains(searchText) ||
                thought.content.localizedCaseInsensitiveContains(searchText)
            }
        } else {
            searchFiltered = thoughtsManager.thoughts
        }
        
        // Step 2: Filter by selected mood
        let moodFiltered: [Thought]
        if let moodFilter = selectedMoodFilter {
            moodFiltered = searchFiltered.filter { $0.mood == moodFilter }
        } else {
            moodFiltered = searchFiltered
        }
        
        // Step 3: Sort by dateCreated descending
        let sorted = moodFiltered.sorted { $0.dateCreated > $1.dateCreated }
        
        return sorted
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchAndFilterHeader
                thoughtsList
            }
            .background(UniversalBackground())
            .navigationTitle("All Thoughts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddThought = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddThought) {
            AddThoughtView(
                thoughtsManager: thoughtsManager,
                taskManager: taskManager,
                moodManager: moodManager
            )
        }
        .sheet(item: $editingThought) { thought in
            EditThoughtView(thought: thought, thoughtsManager: thoughtsManager)
        }
        .sheet(item: $convertingThought) { thought in
            ConvertThoughtToTaskView(
                thought: thought,
                thoughtsManager: thoughtsManager,
                taskManager: taskManager,
                moodManager: moodManager,
                deleteOriginalThoughtDefault: false
            )
        }
    }
    
    private var searchAndFilterHeader: some View {
        VStack(spacing: 12) {
            ThoughtsSearchBar(text: $searchText)
            moodFilterRow
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
    
    private var moodFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                allMoodButton
                moodFilterButtons
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var allMoodButton: some View {
        MoodFilterButton(
            title: "All",
            titleView: { AnyView(Text("All")) },
            isSelected: selectedMoodFilter == nil,
            action: { selectedMoodFilter = nil }
        )
    }
    
    private var moodFilterButtons: some View {
        let buttons: [MoodFilterButton] = MoodType.allCases.map { mood in
            MoodFilterButton(
                title: mood.displayName,
                titleView: { AnyView(HStack {
                    Image(systemName: mood.icon)
                        .foregroundColor(mood.color)
                    Text(mood.displayName)
                }) },
                isSelected: selectedMoodFilter == mood,
                action: { selectedMoodFilter = selectedMoodFilter == mood ? nil : mood }
            )
        }
        return Group {
            ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
                button
            }
        }
    }
    
    private var thoughtsList: some View {
        Group {
            if filteredThoughts.isEmpty {
                EmptyThoughtsView(hasFilter: !searchText.isEmpty || selectedMoodFilter != nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredThoughts) { thought in
                        AllThoughtsRowView(
                            thought: thought,
                            onEdit: { editingThought = thought },
                            onConvert: { convertingThought = thought },
                            onDelete: { thoughtsManager.deleteThought(thought) }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct ThoughtsSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search thoughts...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
        .padding(.horizontal, 20)
    }
}

struct MoodFilterButton: View {
    let title: String
    let titleView: (() -> AnyView)?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String,
         titleView: (() -> AnyView)? = nil,
         isSelected: Bool,
         action: @escaping () -> Void) {
        self.title = title
        self.titleView = titleView
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let titleView = titleView {
                    titleView()
                } else {
                    Text(title)
                }
            }
            .font(.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyThoughtsView: View {
    let hasFilter: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: hasFilter ? "magnifyingglass" : "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(hasFilter ? "No matching thoughts" : "No thoughts yet")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(hasFilter ? "Try adjusting your search or filters" : "Tap the + button to add your first thought")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    AllThoughtsListView(
        thoughtsManager: ThoughtsManager(),
        taskManager: TaskManager(),
        moodManager: MoodManager()
    )
}

struct AllThoughtsRowView: View {
    let thought: Thought
    let onEdit: () -> Void
    let onConvert: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(thought.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: thought.mood.icon)
                    .foregroundColor(thought.mood.color)
                    .font(.title3)
            }
            
            if !thought.content.isEmpty {
                Text((try? AttributedString(markdown: thought.content)) ?? AttributedString(thought.content))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                Text(thought.dateCreated, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("Convert", action: onConvert)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Button("Edit", action: onEdit)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(16)
        .background(
            GlassPanelBackground()
        )
        .cornerRadius(12)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button {
                onConvert()
            } label: {
                Label("Convert to Task", systemImage: "arrow.right.circle")
            }
            
            Divider()
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
