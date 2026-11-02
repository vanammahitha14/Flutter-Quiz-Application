import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  int? _correctAnswerIndex; // 0 for A, 1 for B, 2 for C, 3 for D
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = 'custom';
    _selectedCategoryName = 'Custom Questions';
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    setState(() {
      _submitted = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select which option is the correct answer.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final newQuestion = Question(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: _selectedCategoryId ?? 'custom',
      categoryName: _selectedCategoryName ?? 'Custom Questions',
      question: _questionController.text.trim(),
      options: [
        _optionAController.text.trim(),
        _optionBController.text.trim(),
        _optionCController.text.trim(),
        _optionDController.text.trim(),
      ],
      correctAnswerIndex: _correctAnswerIndex!,
      difficulty: 'medium',
    );

    final provider = context.read<QuizProvider>();
    await provider.addCustomQuestion(newQuestion);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question successfully saved!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = context.watch<QuizProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Custom Question'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fill out all 4 options, then choose which letter is the correct answer.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Category Field (Validation: Must be selected)
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                    hintText: 'Select a Category',
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      final match = categories.firstWhere(
                        (c) => c.id == value,
                        orElse: () => categories.first,
                      );
                      _selectedCategoryName = match.name;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a quiz category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // 2. Question Field (Validation: Cannot be empty)
                const Text(
                  'Question Text',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _questionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type your quiz question here...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Question text cannot be empty';
                    }
                    if (value.trim().length < 5) {
                      return 'Question must be at least 5 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Options (Option A, Option B, Option C, Option D)
                const Text(
                  'Options (Enter 4 Options)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                _buildOptionField(
                  controller: _optionAController,
                  label: 'Option A',
                  letter: 'A',
                  index: 0,
                ),
                const SizedBox(height: 10),
                _buildOptionField(
                  controller: _optionBController,
                  label: 'Option B',
                  letter: 'B',
                  index: 1,
                ),
                const SizedBox(height: 10),
                _buildOptionField(
                  controller: _optionCController,
                  label: 'Option C',
                  letter: 'C',
                  index: 2,
                ),
                const SizedBox(height: 10),
                _buildOptionField(
                  controller: _optionDController,
                  label: 'Option D',
                  letter: 'D',
                  index: 3,
                ),
                const SizedBox(height: 18),

                // 4. Correct Answer Selection (Validation: Must be selected)
                const Text(
                  'Correct Answer Selection',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [0, 1, 2, 3].map((idx) {
                    final letter = String.fromCharCode(65 + idx);
                    final isSelected = _correctAnswerIndex == idx;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _correctAnswerIndex = idx;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AppTheme.successColor
                                : Colors.white,
                            foregroundColor:
                                isSelected ? Colors.white : AppTheme.textPrimary,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.successColor
                                  : AppTheme.borderColor,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Option $letter',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_submitted && _correctAnswerIndex == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Text(
                      'Please select which option is the correct answer.',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Save Question Button
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Save Custom Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionField({
    required TextEditingController controller,
    required String label,
    required String letter,
    required int index,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter text for $label',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _correctAnswerIndex == index
                ? AppTheme.successColor.withValues(alpha: 0.15)
                : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Text(
            letter,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _correctAnswerIndex == index
                  ? AppTheme.successColor
                  : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label cannot be empty';
        }
        return null;
      },
    );
  }
}
