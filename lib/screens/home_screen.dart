import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import 'quiz_details_screen.dart';
import 'add_question_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load categories after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'QuizMaster',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          // Demonstration quick-switcher menu for the 4 mandatory states (GP3)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            tooltip: 'Demonstrate List States (GP3)',
            onSelected: (value) {
              final provider = context.read<QuizProvider>();
              if (value == 'loading') {
                provider.loadCategories();
              } else if (value == 'error') {
                provider.loadCategories(forceError: true);
              } else if (value == 'empty') {
                provider.loadCategories(forceEmpty: true);
              } else if (value == 'data') {
                provider.loadCategories();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'data',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 20),
                    SizedBox(width: 8),
                    Text('1. Data State (Loaded)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'loading',
                child: Row(
                  children: [
                    Icon(Icons.sync, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text('2. Loading State'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'error',
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                    SizedBox(width: 8),
                    Text('3. Error State'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'empty',
                child: Row(
                  children: [
                    Icon(Icons.inbox, color: AppTheme.warningColor, size: 20),
                    SizedBox(width: 8),
                    Text('4. Empty State'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          switch (provider.categoryStatus) {
            case CategoryListStatus.loading:
              return _buildLoadingState();

            case CategoryListStatus.error:
              return _buildErrorState(provider);

            case CategoryListStatus.empty:
              return _buildEmptyState(provider);

            case CategoryListStatus.loaded:
              return _buildDataState(provider);
          }
        },
      ),
    );
  }

  // 1. Loading state (GP3)
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading Quiz Categories...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Connecting to Open Trivia Database',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Error state (GP3)
  Widget _buildErrorState(QuizProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Failed to Load Categories',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.categoryError ??
                  'An unexpected error occurred while contacting the server.',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.loadCategories();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 48),
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Empty state (GP3)
  Widget _buildEmptyState(QuizProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Quiz Categories Available',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no quiz categories available right now. Tap reload to restore the standard categories.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.loadCategories();
              },
              icon: const Icon(Icons.restore),
              label: const Text('Reload Categories'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 48),
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Data state (GP3)
  Widget _buildDataState(QuizProvider provider) {
    final filteredCategories = provider.categories.where((cat) {
      if (_searchQuery.isEmpty) return true;
      return cat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cat.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadCategories();
      },
      color: AppTheme.primaryColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          // Banner / Welcome Header
          _buildWelcomeBanner(provider),
          const SizedBox(height: 16),

          // Search Filter Field
          TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 18),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Explore Quizzes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${filteredCategories.length} Available',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grid of Category Cards
          if (filteredCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No categories match "$_searchQuery"',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                final best = provider.getBestScoreFor(category.id);
                return CategoryCard(
                  category: category,
                  bestScore: best,
                  onTap: () {
                    provider.selectCategory(category);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizDetailsScreen(category: category),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(QuizProvider provider) {
    int totalBest = 0;
    for (final score in provider.bestScores.values) {
      totalBest += score;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to Test Your Skills?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pick a topic and challenge yourself!',
                    style: TextStyle(
                      color: Color(0xFFE0E7FF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$totalBest pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
