import 'package:flutter/material.dart';

class _ChartColor {
  final String name;
  final Color edge;
  final Color center;

  const _ChartColor({
    required this.name,
    required this.edge,
    required this.center,
  });
}

/// Centralized chart color palette and stable ID→color assignment.
/// Colors are independent of AppTheme — used only in chart widgets.
abstract class ChartColors {
  static const List<_ChartColor> _palette = [
    _ChartColor(
      name: 'Forest Green',
      edge: Color(0xFF2E7D32),
      center: Color(0xFFF5F0E8),
    ),
    _ChartColor(
      name: 'Lime Green',
      edge: Color(0xFF558B2F),
      center: Color(0xFFF5F0E8),
    ),
    _ChartColor(
      name: 'Mint Green',
      edge: Color(0xFF00796B),
      center: Color(0xFFF5F0E8),
    ),
    _ChartColor(
      name: 'Deep Orange',
      edge: Color(0xFFE65100),
      center: Color(0xFFF5F0E8),
    ),
    _ChartColor(
      name: 'Warm Amber',
      edge: Color(0xFFF57F17),
      center: Color(0xFFF5F0E8),
    ),
    _ChartColor(
      name: 'Burnt Orange',
      edge: Color(0xFFBF360C),
      center: Color(0xFFF5F0E8),
    ),
    _ChartColor(
      name: 'Coral',
      edge: Color(0xFFC62828),
      center: Color(0xFFF5F0E8),
    ),
    _ChartColor(
      name: 'Sky',
      edge: Color(0xFF1565C0),
      center: Color(0xFFF5F0E8),
    ),
  ];

  /// Returns a stable palette index for [id] — same id always returns the same index.
  static int _indexFor(String id) => id.hashCode.abs() % _palette.length;

  /// Returns the edge (base) color for [id].
  static Color getBaseColor(String id) => _palette[_indexFor(id)].edge;

  /// Returns the stroke color for [id] at 60% opacity.
  static Color getStrokeColor(String id) =>
      _palette[_indexFor(id)].edge.withValues(alpha: 0.6);

  /// Returns a horizontal 4-stop gradient producing a cylinder/glass reflection effect.
  /// Stops: edge → center → center → edge.
  static LinearGradient getGradient(String id) {
    final color = _palette[_indexFor(id)];
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.0, 0.3, 0.7, 1.0],
      colors: [color.edge, color.center, color.center, color.edge],
    );
  }
}
