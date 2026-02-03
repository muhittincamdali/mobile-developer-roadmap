// iOS Learning Tracker Example
// A simple SwiftUI app to track your mobile development learning progress

import SwiftUI

// MARK: - Models

/// Represents a skill in the roadmap
struct Skill: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: SkillCategory
    var level: SkillLevel
    var isCompleted: Bool
    var notes: String
    var completedDate: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        category: SkillCategory,
        level: SkillLevel,
        isCompleted: Bool = false,
        notes: String = "",
        completedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.level = level
        self.isCompleted = isCompleted
        self.notes = notes
        self.completedDate = completedDate
    }
}

/// Skill categories
enum SkillCategory: String, Codable, CaseIterable {
    case swift = "Swift"
    case uikit = "UIKit"
    case swiftui = "SwiftUI"
    case combine = "Combine"
    case networking = "Networking"
    case persistence = "Persistence"
    case testing = "Testing"
    case architecture = "Architecture"
    case cicd = "CI/CD"
    
    var color: Color {
        switch self {
        case .swift: return .orange
        case .uikit: return .blue
        case .swiftui: return .purple
        case .combine: return .pink
        case .networking: return .green
        case .persistence: return .brown
        case .testing: return .red
        case .architecture: return .indigo
        case .cicd: return .teal
        }
    }
    
    var icon: String {
        switch self {
        case .swift: return "swift"
        case .uikit: return "uikit"
        case .swiftui: return "rectangle.on.rectangle"
        case .combine: return "arrow.triangle.merge"
        case .networking: return "network"
        case .persistence: return "externaldrive"
        case .testing: return "checkmark.seal"
        case .architecture: return "building.columns"
        case .cicd: return "gearshape.2"
        }
    }
}

/// Skill difficulty levels
enum SkillLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var pointValue: Int {
        switch self {
        case .beginner: return 10
        case .intermediate: return 25
        case .advanced: return 50
        case .expert: return 100
        }
    }
}

// MARK: - View Model

/// Manages the learning progress state
@MainActor
class LearningProgressViewModel: ObservableObject {
    @Published var skills: [Skill] = []
    @Published var selectedCategory: SkillCategory?
    
    private let storageKey = "learning_progress"
    
    init() {
        loadSkills()
    }
    
    var filteredSkills: [Skill] {
        guard let category = selectedCategory else { return skills }
        return skills.filter { $0.category == category }
    }
    
    var completedSkillsCount: Int {
        skills.filter { $0.isCompleted }.count
    }
    
    var totalPoints: Int {
        skills.filter { $0.isCompleted }.reduce(0) { $0 + $1.level.pointValue }
    }
    
    var progressPercentage: Double {
        guard !skills.isEmpty else { return 0 }
        return Double(completedSkillsCount) / Double(skills.count)
    }
    
    func toggleSkillCompletion(_ skill: Skill) {
        guard let index = skills.firstIndex(where: { $0.id == skill.id }) else { return }
        skills[index].isCompleted.toggle()
        skills[index].completedDate = skills[index].isCompleted ? Date() : nil
        saveSkills()
    }
    
    func addSkill(_ skill: Skill) {
        skills.append(skill)
        saveSkills()
    }
    
    func deleteSkill(_ skill: Skill) {
        skills.removeAll { $0.id == skill.id }
        saveSkills()
    }
    
    func loadDefaultSkills() {
        let defaultSkills: [Skill] = [
            // Swift
            Skill(name: "Variables & Constants", category: .swift, level: .beginner),
            Skill(name: "Optionals", category: .swift, level: .beginner),
            Skill(name: "Collections (Array, Dictionary, Set)", category: .swift, level: .beginner),
            Skill(name: "Control Flow", category: .swift, level: .beginner),
            Skill(name: "Functions & Closures", category: .swift, level: .intermediate),
            Skill(name: "Protocols & Extensions", category: .swift, level: .intermediate),
            Skill(name: "Generics", category: .swift, level: .advanced),
            Skill(name: "Error Handling", category: .swift, level: .intermediate),
            Skill(name: "Memory Management (ARC)", category: .swift, level: .advanced),
            
            // SwiftUI
            Skill(name: "Views & Modifiers", category: .swiftui, level: .beginner),
            Skill(name: "State & Binding", category: .swiftui, level: .beginner),
            Skill(name: "Lists & Navigation", category: .swiftui, level: .intermediate),
            Skill(name: "Custom Views", category: .swiftui, level: .intermediate),
            Skill(name: "Animations", category: .swiftui, level: .advanced),
            Skill(name: "GeometryReader", category: .swiftui, level: .advanced),
            
            // Networking
            Skill(name: "URLSession Basics", category: .networking, level: .beginner),
            Skill(name: "JSON Parsing (Codable)", category: .networking, level: .beginner),
            Skill(name: "REST API Integration", category: .networking, level: .intermediate),
            Skill(name: "Authentication (OAuth, JWT)", category: .networking, level: .advanced),
            Skill(name: "WebSockets", category: .networking, level: .advanced),
            
            // Testing
            Skill(name: "Unit Testing Basics", category: .testing, level: .beginner),
            Skill(name: "XCTest Framework", category: .testing, level: .intermediate),
            Skill(name: "Mock Objects", category: .testing, level: .intermediate),
            Skill(name: "UI Testing", category: .testing, level: .advanced),
            Skill(name: "Test-Driven Development", category: .testing, level: .expert),
            
            // Architecture
            Skill(name: "MVC Pattern", category: .architecture, level: .beginner),
            Skill(name: "MVVM Pattern", category: .architecture, level: .intermediate),
            Skill(name: "Clean Architecture", category: .architecture, level: .advanced),
            Skill(name: "Dependency Injection", category: .architecture, level: .advanced),
            Skill(name: "Modular Architecture", category: .architecture, level: .expert)
        ]
        
        skills = defaultSkills
        saveSkills()
    }
    
    private func saveSkills() {
        if let encoded = try? JSONEncoder().encode(skills) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadSkills() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Skill].self, from: data) else {
            loadDefaultSkills()
            return
        }
        skills = decoded
    }
}

// MARK: - Views

/// Main content view
struct ContentView: View {
    @StateObject private var viewModel = LearningProgressViewModel()
    @State private var showingAddSkill = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Header
                ProgressHeaderView(viewModel: viewModel)
                
                // Category Filter
                CategoryFilterView(selectedCategory: $viewModel.selectedCategory)
                
                // Skills List
                SkillsListView(viewModel: viewModel)
            }
            .navigationTitle("Learning Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSkill = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Button("Reset to Defaults") {
                        viewModel.loadDefaultSkills()
                    }
                }
            }
            .sheet(isPresented: $showingAddSkill) {
                AddSkillView(viewModel: viewModel)
            }
        }
    }
}

/// Progress header showing overall stats
struct ProgressHeaderView: View {
    @ObservedObject var viewModel: LearningProgressViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: viewModel.progressPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: viewModel.progressPercentage)
                
                VStack {
                    Text("\(Int(viewModel.progressPercentage * 100))%")
                        .font(.title.bold())
                    Text("\(viewModel.completedSkillsCount)/\(viewModel.skills.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            
            // Stats Row
            HStack(spacing: 40) {
                StatView(title: "Skills", value: "\(viewModel.skills.count)", icon: "list.bullet")
                StatView(title: "Completed", value: "\(viewModel.completedSkillsCount)", icon: "checkmark.circle")
                StatView(title: "Points", value: "\(viewModel.totalPoints)", icon: "star.fill")
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

/// Individual stat view
struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// Category filter chips
struct CategoryFilterView: View {
    @Binding var selectedCategory: SkillCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: .gray
                ) {
                    selectedCategory = nil
                }
                
                ForEach(SkillCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

/// Individual filter chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

/// Skills list view
struct SkillsListView: View {
    @ObservedObject var viewModel: LearningProgressViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.filteredSkills) { skill in
                SkillRowView(skill: skill) {
                    viewModel.toggleSkillCompletion(skill)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteSkill(skill)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

/// Individual skill row
struct SkillRowView: View {
    let skill: Skill
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Toggle
            Button(action: onToggle) {
                Image(systemName: skill.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(skill.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Skill Info
            VStack(alignment: .leading, spacing: 4) {
                Text(skill.name)
                    .font(.body.weight(.medium))
                    .strikethrough(skill.isCompleted, color: .gray)
                    .foregroundStyle(skill.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    Label(skill.category.rawValue, systemImage: "folder")
                        .font(.caption)
                        .foregroundStyle(skill.category.color)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(skill.level.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text("\(skill.level.pointValue) pts")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            // Level Indicator
            LevelBadge(level: skill.level)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: skill.isCompleted)
    }
}

/// Level badge indicator
struct LevelBadge: View {
    let level: SkillLevel
    
    var color: Color {
        switch level {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
        }
    }
    
    var body: some View {
        Text(String(level.rawValue.prefix(1)))
            .font(.caption.bold())
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(color)
            .clipShape(Circle())
    }
}

/// Add new skill sheet
struct AddSkillView: View {
    @ObservedObject var viewModel: LearningProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category: SkillCategory = .swift
    @State private var level: SkillLevel = .beginner
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Skill Details") {
                    TextField("Skill Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(SkillCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    
                    Picker("Level", selection: $level) {
                        ForEach(SkillLevel.allCases, id: \.self) { lvl in
                            Text("\(lvl.rawValue) (\(lvl.pointValue) pts)").tag(lvl)
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Skill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let skill = Skill(
                            name: name,
                            category: category,
                            level: level,
                            notes: notes
                        )
                        viewModel.addSkill(skill)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
