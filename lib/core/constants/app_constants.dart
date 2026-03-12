/// Application-wide constants shared across the presentation layer.
class AppConstants {
  AppConstants._();

  /// Duration used for bar chart entrance and change animations.
  /// Applies to ActivityBreakdownWidget, InteractionDistributionWidget,
  /// and WhoPerActivityWidget to keep all three in sync visually.
  static const Duration chartAnimationDuration = Duration(milliseconds: 1000);
}
