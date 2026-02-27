import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/statistics_provider.dart';
import '../widgets/statistics_section.dart';

/// Home tab showing year-filtered statistics for the authenticated user.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, _, __) => const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: StatisticsSection(),
          ),
        ),
      ),
    );
  }
}
