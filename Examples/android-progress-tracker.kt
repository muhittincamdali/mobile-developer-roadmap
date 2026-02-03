// Android Learning Progress Tracker
// A Jetpack Compose app to track your mobile development learning progress

package com.example.learningtracker

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import java.util.*

// MARK: - Data Models

data class Skill(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val category: SkillCategory,
    val level: SkillLevel,
    val isCompleted: Boolean = false,
    val notes: String = "",
    val completedDate: Long? = null
)

enum class SkillCategory(val displayName: String, val color: Color, val icon: ImageVector) {
    KOTLIN("Kotlin", Color(0xFF7F52FF), Icons.Default.Code),
    COMPOSE("Compose", Color(0xFF4285F4), Icons.Default.Brush),
    ARCHITECTURE("Architecture", Color(0xFF34A853), Icons.Default.AccountTree),
    NETWORKING("Networking", Color(0xFFEA4335), Icons.Default.Cloud),
    PERSISTENCE("Persistence", Color(0xFFFBBC04), Icons.Default.Storage),
    TESTING("Testing", Color(0xFF9C27B0), Icons.Default.BugReport),
    CICD("CI/CD", Color(0xFF00BCD4), Icons.Default.Build)
}

enum class SkillLevel(val displayName: String, val points: Int) {
    BEGINNER("Beginner", 10),
    INTERMEDIATE("Intermediate", 25),
    ADVANCED("Advanced", 50),
    EXPERT("Expert", 100)
}

// MARK: - ViewModel

class LearningViewModel : ViewModel() {
    private val _skills = MutableStateFlow(getDefaultSkills())
    val skills: StateFlow<List<Skill>> = _skills.asStateFlow()
    
    private val _selectedCategory = MutableStateFlow<SkillCategory?>(null)
    val selectedCategory: StateFlow<SkillCategory?> = _selectedCategory.asStateFlow()
    
    val filteredSkills: List<Skill>
        get() {
            val category = _selectedCategory.value
            return if (category == null) {
                _skills.value
            } else {
                _skills.value.filter { it.category == category }
            }
        }
    
    val completedCount: Int
        get() = _skills.value.count { it.isCompleted }
    
    val totalPoints: Int
        get() = _skills.value
            .filter { it.isCompleted }
            .sumOf { it.level.points }
    
    val progressPercentage: Float
        get() = if (_skills.value.isEmpty()) 0f 
                else completedCount.toFloat() / _skills.value.size
    
    fun toggleSkillCompletion(skillId: String) {
        _skills.update { currentSkills ->
            currentSkills.map { skill ->
                if (skill.id == skillId) {
                    skill.copy(
                        isCompleted = !skill.isCompleted,
                        completedDate = if (!skill.isCompleted) System.currentTimeMillis() else null
                    )
                } else {
                    skill
                }
            }
        }
    }
    
    fun setSelectedCategory(category: SkillCategory?) {
        _selectedCategory.value = category
    }
    
    fun addSkill(skill: Skill) {
        _skills.update { it + skill }
    }
    
    fun deleteSkill(skillId: String) {
        _skills.update { currentSkills ->
            currentSkills.filter { it.id != skillId }
        }
    }
    
    private fun getDefaultSkills(): List<Skill> = listOf(
        // Kotlin
        Skill(name = "Variables & Types", category = SkillCategory.KOTLIN, level = SkillLevel.BEGINNER),
        Skill(name = "Null Safety", category = SkillCategory.KOTLIN, level = SkillLevel.BEGINNER),
        Skill(name = "Collections", category = SkillCategory.KOTLIN, level = SkillLevel.BEGINNER),
        Skill(name = "Functions & Lambdas", category = SkillCategory.KOTLIN, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Coroutines Basics", category = SkillCategory.KOTLIN, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Flow", category = SkillCategory.KOTLIN, level = SkillLevel.ADVANCED),
        Skill(name = "Extension Functions", category = SkillCategory.KOTLIN, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Sealed Classes", category = SkillCategory.KOTLIN, level = SkillLevel.ADVANCED),
        
        // Compose
        Skill(name = "Composable Functions", category = SkillCategory.COMPOSE, level = SkillLevel.BEGINNER),
        Skill(name = "State Management", category = SkillCategory.COMPOSE, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Layouts (Row, Column, Box)", category = SkillCategory.COMPOSE, level = SkillLevel.BEGINNER),
        Skill(name = "Lists (LazyColumn)", category = SkillCategory.COMPOSE, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Navigation", category = SkillCategory.COMPOSE, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Animations", category = SkillCategory.COMPOSE, level = SkillLevel.ADVANCED),
        Skill(name = "Custom Layouts", category = SkillCategory.COMPOSE, level = SkillLevel.EXPERT),
        
        // Architecture
        Skill(name = "MVVM Pattern", category = SkillCategory.ARCHITECTURE, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Clean Architecture", category = SkillCategory.ARCHITECTURE, level = SkillLevel.ADVANCED),
        Skill(name = "Dependency Injection (Hilt)", category = SkillCategory.ARCHITECTURE, level = SkillLevel.ADVANCED),
        Skill(name = "Repository Pattern", category = SkillCategory.ARCHITECTURE, level = SkillLevel.INTERMEDIATE),
        
        // Networking
        Skill(name = "Retrofit Basics", category = SkillCategory.NETWORKING, level = SkillLevel.BEGINNER),
        Skill(name = "OkHttp Interceptors", category = SkillCategory.NETWORKING, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Error Handling", category = SkillCategory.NETWORKING, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Authentication", category = SkillCategory.NETWORKING, level = SkillLevel.ADVANCED),
        
        // Testing
        Skill(name = "Unit Testing", category = SkillCategory.TESTING, level = SkillLevel.BEGINNER),
        Skill(name = "MockK", category = SkillCategory.TESTING, level = SkillLevel.INTERMEDIATE),
        Skill(name = "Compose Testing", category = SkillCategory.TESTING, level = SkillLevel.ADVANCED),
        Skill(name = "Integration Testing", category = SkillCategory.TESTING, level = SkillLevel.ADVANCED)
    )
}

// MARK: - MainActivity

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                LearningTrackerApp()
            }
        }
    }
}

// MARK: - Composables

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LearningTrackerApp(
    viewModel: LearningViewModel = viewModel()
) {
    val skills by viewModel.skills.collectAsState()
    val selectedCategory by viewModel.selectedCategory.collectAsState()
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Learning Tracker") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // Progress Header
            ProgressHeader(
                progress = viewModel.progressPercentage,
                completedCount = viewModel.completedCount,
                totalCount = skills.size,
                totalPoints = viewModel.totalPoints
            )
            
            // Category Filter
            CategoryFilter(
                selectedCategory = selectedCategory,
                onCategorySelected = { viewModel.setSelectedCategory(it) }
            )
            
            // Skills List
            SkillsList(
                skills = viewModel.filteredSkills,
                onToggleCompletion = { viewModel.toggleSkillCompletion(it) },
                onDeleteSkill = { viewModel.deleteSkill(it) }
            )
        }
    }
}

@Composable
fun ProgressHeader(
    progress: Float,
    completedCount: Int,
    totalCount: Int,
    totalPoints: Int
) {
    val animatedProgress by animateFloatAsState(
        targetValue = progress,
        animationSpec = tween(durationMillis = 500),
        label = "progress"
    )
    
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.surfaceVariant
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Circular Progress
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.size(120.dp)
            ) {
                CircularProgressIndicator(
                    progress = { 1f },
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f),
                    strokeWidth = 10.dp,
                )
                CircularProgressIndicator(
                    progress = { animatedProgress },
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.primary,
                    strokeWidth = 10.dp,
                    strokeCap = StrokeCap.Round
                )
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "${(progress * 100).toInt()}%",
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "$completedCount/$totalCount",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Stats Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatItem(icon = Icons.Default.List, label = "Skills", value = "$totalCount")
                StatItem(icon = Icons.Default.CheckCircle, label = "Done", value = "$completedCount")
                StatItem(icon = Icons.Default.Star, label = "Points", value = "$totalPoints")
            }
        }
    }
}

@Composable
fun StatItem(icon: ImageVector, label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
            modifier = Modifier.size(28.dp)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = label,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun CategoryFilter(
    selectedCategory: SkillCategory?,
    onCategorySelected: (SkillCategory?) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        FilterChip(
            selected = selectedCategory == null,
            onClick = { onCategorySelected(null) },
            label = { Text("All") }
        )
        
        SkillCategory.entries.forEach { category ->
            FilterChip(
                selected = selectedCategory == category,
                onClick = { onCategorySelected(category) },
                label = { Text(category.displayName) },
                leadingIcon = if (selectedCategory == category) {
                    { Icon(Icons.Default.Check, contentDescription = null, Modifier.size(18.dp)) }
                } else null
            )
        }
    }
}

@Composable
fun SkillsList(
    skills: List<Skill>,
    onToggleCompletion: (String) -> Unit,
    onDeleteSkill: (String) -> Unit
) {
    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(skills, key = { it.id }) { skill ->
            SkillCard(
                skill = skill,
                onToggleCompletion = { onToggleCompletion(skill.id) },
                onDelete = { onDeleteSkill(skill.id) }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SkillCard(
    skill: Skill,
    onToggleCompletion: () -> Unit,
    onDelete: () -> Unit
) {
    val dismissState = rememberSwipeToDismissBoxState(
        confirmValueChange = { value ->
            if (value == SwipeToDismissBoxValue.EndToStart) {
                onDelete()
                true
            } else {
                false
            }
        }
    )
    
    SwipeToDismissBox(
        state = dismissState,
        backgroundContent = {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Red)
                    .padding(horizontal = 16.dp),
                contentAlignment = Alignment.CenterEnd
            ) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = Color.White
                )
            }
        }
    ) {
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = if (skill.isCompleted) 
                    MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                else MaterialTheme.colorScheme.surface
            )
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onToggleCompletion() }
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Checkbox
                Checkbox(
                    checked = skill.isCompleted,
                    onCheckedChange = { onToggleCompletion() }
                )
                
                Spacer(modifier = Modifier.width(12.dp))
                
                // Skill Info
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = skill.name,
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Medium,
                        textDecoration = if (skill.isCompleted) TextDecoration.LineThrough else null,
                        color = if (skill.isCompleted) 
                            MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                        else MaterialTheme.colorScheme.onSurface
                    )
                    
                    Spacer(modifier = Modifier.height(4.dp))
                    
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Category Badge
                        Box(
                            modifier = Modifier
                                .background(
                                    color = skill.category.color.copy(alpha = 0.2f),
                                    shape = RoundedCornerShape(4.dp)
                                )
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(
                                text = skill.category.displayName,
                                style = MaterialTheme.typography.labelSmall,
                                color = skill.category.color
                            )
                        }
                        
                        Text(
                            text = "•",
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        
                        Text(
                            text = skill.level.displayName,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        
                        Text(
                            text = "•",
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        
                        Text(
                            text = "${skill.level.points} pts",
                            style = MaterialTheme.typography.labelSmall,
                            color = Color(0xFFFFA000)
                        )
                    }
                }
                
                // Level Badge
                LevelBadge(level = skill.level)
            }
        }
    }
}

@Composable
fun LevelBadge(level: SkillLevel) {
    val color = when (level) {
        SkillLevel.BEGINNER -> Color(0xFF4CAF50)
        SkillLevel.INTERMEDIATE -> Color(0xFF2196F3)
        SkillLevel.ADVANCED -> Color(0xFFFF9800)
        SkillLevel.EXPERT -> Color(0xFFF44336)
    }
    
    Box(
        modifier = Modifier
            .size(28.dp)
            .clip(CircleShape)
            .background(color),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = level.displayName.first().toString(),
            style = MaterialTheme.typography.labelMedium,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
    }
}
