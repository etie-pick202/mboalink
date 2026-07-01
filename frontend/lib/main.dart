import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MboaLinkApp()));
}

class MboaLinkApp extends StatelessWidget {
  const MboaLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MboaLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // La navigation go_router sera branchée ici (app.dart) au Workflow A.
      home: const Scaffold(
        body: Center(child: Text('MboaLink — setup OK')),
      ),
    );
  }
}
