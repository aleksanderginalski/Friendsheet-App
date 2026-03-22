import 'dart:math';

/// Returns the normalized Levenshtein distance between [s1] and [s2].
/// Comparison is case-insensitive.
/// Returns 0.0 for identical strings, 1.0 for completely different strings.
double normalizedLevenshtein(String s1, String s2) {
  final a = s1.toLowerCase();
  final b = s2.toLowerCase();
  if (a == b) return 0.0;
  if (a.isEmpty || b.isEmpty) return 1.0;
  final dist = _levenshtein(a, b);
  return dist / max(a.length, b.length);
}

int _levenshtein(String s, String t) {
  final m = s.length;
  final n = t.length;
  // dp[i][j] = edit distance between s[0..i-1] and t[0..j-1]
  final dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));
  for (var i = 0; i <= m; i++) {
    dp[i][0] = i;
  }
  for (var j = 0; j <= n; j++) {
    dp[0][j] = j;
  }
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      if (s[i - 1] == t[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = 1 + min(dp[i - 1][j], min(dp[i][j - 1], dp[i - 1][j - 1]));
      }
    }
  }
  return dp[m][n];
}
