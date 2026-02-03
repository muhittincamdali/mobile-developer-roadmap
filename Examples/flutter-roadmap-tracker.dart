// Flutter Learning Roadmap Tracker
// A cross-platform app to track your mobile development learning progress

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// MARK: - Main Entry Point

void main() {
  runApp(const LearningTrackerApp());
}

class LearningTrackerApp extends StatelessWidget {
  const LearningTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LearningTrackerScreen(),
    );
  }
}

// MARK: - Data Models

enum SkillCategory {
  dart('Dart', Color(0xFF0175C2), Icons.code),
  flutter('Flutter', Color(0xFF02569B), Icons.flutter_dash),
  stateManagement('State', Color(0xFF9C27B0), Icons.sync),
  networking('Network', Color(0xFFF44336), Icons.cloud),
  persistence('Storage', Color(0xFFFF9800), Icons.storage),
  testing('Testing', Color(0xFF4CAF50), Icons.bug_report),
  architecture('Arch', Color(0xFF795548), Icons.architecture);

  const SkillCategory(this.displayName, this.color, this.icon);
  final String displayName;
  final Color color;
  final IconData icon;
}

enum SkillLevel {
  beginner('Beginner', 10),
  intermediate('Intermediate', 25),
  advanced('Advanced', 50),
  expert('Expert', 100);

  const SkillLevel(this.displayName, this.points);
  final String displayName;
  final int points;

  Color get color {
    switch (this) {
      case SkillLevel.beginner:
        return Colors.green;
      case SkillLevel.intermediate:
        return Colors.blue;
      case SkillLevel.advanced:
        return Colors.orange;
      case SkillLevel.expert:
        return Colors.red;
    }
  }
}

class Skill {
  final String id;
  final String name;
  final SkillCategory category;
  final SkillLevel level;
  bool isCompleted;
  String notes;
  DateTime? completedDate;

  Skill({
    String? id,
    required this.name,
    required this.category,
    required this.level,
    this.isCompleted = false,
    this.notes = '',
    this.completedDate,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.index,
        'level': level.index,
        'isCompleted': isCompleted,
        'notes': notes,
        'completedDate': completedDate?.toIso8601String(),
      };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'],
        name: json['name'],
        category: SkillCategory.values[json['category']],
        level: SkillLevel.values[json['level']],
        isCompleted: json['isCompleted'] ?? false,
        notes: json['notes'] ?? '',
        completedDate: json['completedDate'] != null
            ? DateTime.parse(json['completedDate'])
            : null,
      );
}

// MARK: - Default Skills

List<Skill> getDefaultSkills() => [
      // Dart
      Skill(
          name: 'Variables & Types',
          category: SkillCategory.dart,
          level: SkillLevel.beginner),
      Skill(
          name: 'Null Safety',
          category: SkillCategory.dart,
          level: SkillLevel.beginner),
      Skill(
          name: 'Collections (List, Map, Set)',
          category: SkillCategory.dart,
          level: SkillLevel.beginner),
      Skill(
          name: 'Functions & Closures',
          category: SkillCategory.dart,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Async/Await & Futures',
          category: SkillCategory.dart,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Streams',
          category: SkillCategory.dart,
          level: SkillLevel.advanced),
      Skill(
          name: 'Extension Methods',
          category: SkillCategory.dart,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Generics',
          category: SkillCategory.dart,
          level: SkillLevel.advanced),

      // Flutter
      Skill(
          name: 'Widget Basics',
          category: SkillCategory.flutter,
          level: SkillLevel.beginner),
      Skill(
          name: 'Layouts (Row, Column, Stack)',
          category: SkillCategory.flutter,
          level: SkillLevel.beginner),
      Skill(
          name: 'StatefulWidget',
          category: SkillCategory.flutter,
          level: SkillLevel.beginner),
      Skill(
          name: 'ListView & GridView',
          category: SkillCategory.flutter,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Navigation & Routing',
          category: SkillCategory.flutter,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Animations',
          category: SkillCategory.flutter,
          level: SkillLevel.advanced),
      Skill(
          name: 'Custom Painters',
          category: SkillCategory.flutter,
          level: SkillLevel.expert),
      Skill(
          name: 'Platform Channels',
          category: SkillCategory.flutter,
          level: SkillLevel.expert),

      // State Management
      Skill(
          name: 'setState',
          category: SkillCategory.stateManagement,
          level: SkillLevel.beginner),
      Skill(
          name: 'InheritedWidget',
          category: SkillCategory.stateManagement,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Provider',
          category: SkillCategory.stateManagement,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Riverpod',
          category: SkillCategory.stateManagement,
          level: SkillLevel.advanced),
      Skill(
          name: 'Bloc/Cubit',
          category: SkillCategory.stateManagement,
          level: SkillLevel.advanced),

      // Networking
      Skill(
          name: 'HTTP Basics',
          category: SkillCategory.networking,
          level: SkillLevel.beginner),
      Skill(
          name: 'Dio Package',
          category: SkillCategory.networking,
          level: SkillLevel.intermediate),
      Skill(
          name: 'JSON Serialization',
          category: SkillCategory.networking,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Error Handling',
          category: SkillCategory.networking,
          level: SkillLevel.advanced),

      // Testing
      Skill(
          name: 'Unit Testing',
          category: SkillCategory.testing,
          level: SkillLevel.beginner),
      Skill(
          name: 'Widget Testing',
          category: SkillCategory.testing,
          level: SkillLevel.intermediate),
      Skill(
          name: 'Integration Testing',
          category: SkillCategory.testing,
          level: SkillLevel.advanced),
      Skill(
          name: 'Mocking with Mockito',
          category: SkillCategory.testing,
          level: SkillLevel.advanced),
    ];

// MARK: - Main Screen

class LearningTrackerScreen extends StatefulWidget {
  const LearningTrackerScreen({super.key});

  @override
  State<LearningTrackerScreen> createState() => _LearningTrackerScreenState();
}

class _LearningTrackerScreenState extends State<LearningTrackerScreen> {
  List<Skill> _skills = [];
  SkillCategory? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final skillsJson = prefs.getString('skills');

    if (skillsJson != null) {
      final List<dynamic> decoded = json.decode(skillsJson);
      setState(() {
        _skills = decoded.map((e) => Skill.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _skills = getDefaultSkills();
        _isLoading = false;
      });
      _saveSkills();
    }
  }

  Future<void> _saveSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_skills.map((s) => s.toJson()).toList());
    await prefs.setString('skills', encoded);
  }

  void _toggleSkillCompletion(Skill skill) {
    setState(() {
      skill.isCompleted = !skill.isCompleted;
      skill.completedDate = skill.isCompleted ? DateTime.now() : null;
    });
    _saveSkills();
  }

  void _deleteSkill(Skill skill) {
    setState(() {
      _skills.removeWhere((s) => s.id == skill.id);
    });
    _saveSkills();
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Defaults?'),
        content: const Text('This will replace all skills with the default list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _skills = getDefaultSkills();
              });
              _saveSkills();
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  List<Skill> get _filteredSkills {
    if (_selectedCategory == null) return _skills;
    return _skills.where((s) => s.category == _selectedCategory).toList();
  }

  int get _completedCount => _skills.where((s) => s.isCompleted).length;

  int get _totalPoints => _skills
      .where((s) => s.isCompleted)
      .fold(0, (sum, s) => sum + s.level.points);

  double get _progressPercentage =>
      _skills.isEmpty ? 0 : _completedCount / _skills.length;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Tracker'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset to Defaults'),
              ),
            ],
            onSelected: (value) {
              if (value == 'reset') _resetToDefaults();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          _buildCategoryFilter(),
          Expanded(child: _buildSkillsList()),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        children: [
          // Progress Ring
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _progressPercentage),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_progressPercentage * 100).toInt()}%',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '$_completedCount/${_skills.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(icon: Icons.list, label: 'Skills', value: '${_skills.length}'),
              _StatItem(icon: Icons.check_circle, label: 'Done', value: '$_completedCount'),
              _StatItem(icon: Icons.star, label: 'Points', value: '$_totalPoints'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          FilterChip(
            selected: _selectedCategory == null,
            label: const Text('All'),
            onSelected: (_) => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: 8),
          ...SkillCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: _selectedCategory == category,
                label: Text(category.displayName),
                avatar: _selectedCategory == category
                    ? const Icon(Icons.check, size: 18)
                    : null,
                onSelected: (_) => setState(() => _selectedCategory = category),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSkills.length,
      itemBuilder: (context, index) {
        final skill = _filteredSkills[index];
        return Dismissible(
          key: Key(skill.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _deleteSkill(skill),
          child: _SkillCard(
            skill: skill,
            onToggle: () => _toggleSkillCompletion(skill),
          ),
        );
      },
    );
  }
}

// MARK: - Widget Components

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onToggle;

  const _SkillCard({
    required this.skill,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: skill.isCompleted,
                onChanged: (_) => onToggle(),
              ),

              const SizedBox(width: 12),

              // Skill Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: skill.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: skill.isCompleted
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5)
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: skill.category.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            skill.category.displayName,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: skill.category.color,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          skill.level.displayName,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${skill.level.points} pts',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.orange,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Level Badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: skill.level.color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    skill.level.displayName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
