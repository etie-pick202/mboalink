import "package:flutter/material.dart";

/// Écran temporaire affiché pour les routes pas encore développées.
/// Sera remplacé progressivement par le vrai écran de chaque workflow.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
