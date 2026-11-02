import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int defaultQuestionCount;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.defaultQuestionCount = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.toARGB32(),
      'defaultQuestionCount': defaultQuestionCount,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final code = json['iconCodePoint'] as int?;
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      icon: _resolveIcon(code),
      color: Color(json['colorValue'] as int? ?? 0xFF6200EE),
      defaultQuestionCount: json['defaultQuestionCount'] as int? ?? 10,
    );
  }

  static IconData _resolveIcon(int? code) {
    if (code == Icons.computer.codePoint) return Icons.computer;
    if (code == Icons.sports_soccer.codePoint) return Icons.sports_soccer;
    if (code == Icons.history_edu.codePoint) return Icons.history_edu;
    if (code == Icons.public.codePoint) return Icons.public;
    if (code == Icons.edit_note.codePoint) return Icons.edit_note;
    if (code == Icons.lightbulb_outline.codePoint) return Icons.lightbulb_outline;
    return Icons.quiz;
  }

  static List<Category> get predefinedCategories => [
    const Category(
      id: '9',
      name: 'General Knowledge',
      description: 'Test your broad knowledge of trivia, culture, and facts.',
      icon: Icons.lightbulb_outline,
      color: Color(0xFF6C5CE7),
      defaultQuestionCount: 10,
    ),
    const Category(
      id: '18',
      name: 'Science & Computers',
      description: 'Explore programming, technology, software, and hardware.',
      icon: Icons.computer,
      color: Color(0xFF0984E3),
      defaultQuestionCount: 10,
    ),
    const Category(
      id: '21',
      name: 'Sports',
      description: 'Trivia on world sports, champions, football, and events.',
      icon: Icons.sports_soccer,
      color: Color(0xFF00B894),
      defaultQuestionCount: 10,
    ),
    const Category(
      id: '23',
      name: 'History',
      description: 'Journey across ancient events, revolutions, and world leaders.',
      icon: Icons.history_edu,
      color: Color(0xFFE17055),
      defaultQuestionCount: 10,
    ),
    const Category(
      id: '22',
      name: 'Geography',
      description: 'Explore countries, capitals, mountains, and global landmarks.',
      icon: Icons.public,
      color: Color(0xFFF39C12),
      defaultQuestionCount: 10,
    ),
    const Category(
      id: 'custom',
      name: 'Custom Questions',
      description: 'Questions crafted and saved locally on your device.',
      icon: Icons.edit_note,
      color: Color(0xFFE84393),
      defaultQuestionCount: 5,
    ),
  ];
}
