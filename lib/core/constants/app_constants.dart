/// Application-wide constants shared across the presentation layer.
class AppConstants {
  AppConstants._();

  /// Duration used for bar chart entrance and change animations.
  /// Applies to ActivityBreakdownWidget, InteractionDistributionWidget,
  /// and WhoPerActivityWidget to keep all three in sync visually.
  static const Duration chartAnimationDuration = Duration(milliseconds: 1000);

  /// Normalized Levenshtein distance threshold for fuzzy activity name matching.
  /// Activities with distance <= this value are shown as potential matches.
  static const double fuzzyActivityMatchThreshold = 0.4;
}
