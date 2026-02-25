import 'package:flutter/material.dart';

// Predefined set of 20 icons available for activity categories.
const List<String> kActivityIconIdentifiers = [
  'sports_tennis',
  'restaurant',
  'local_cafe',
  'movie',
  'hiking',
  'fitness_center',
  'music_note',
  'travel_explore',
  'home',
  'people',
  'book',
  'shopping_cart',
  'beach_access',
  'park',
  'videogame_asset',
  'directions_car',
  'flight',
  'celebration',
  'sports_basketball',
  'spa',
];

const Map<String, IconData> _iconMap = {
  'sports_tennis': Icons.sports_tennis,
  'restaurant': Icons.restaurant,
  'local_cafe': Icons.local_cafe,
  'movie': Icons.movie,
  'hiking': Icons.hiking,
  'fitness_center': Icons.fitness_center,
  'music_note': Icons.music_note,
  'travel_explore': Icons.travel_explore,
  'home': Icons.home,
  'people': Icons.people,
  'book': Icons.book,
  'shopping_cart': Icons.shopping_cart,
  'beach_access': Icons.beach_access,
  'park': Icons.park,
  'videogame_asset': Icons.videogame_asset,
  'directions_car': Icons.directions_car,
  'flight': Icons.flight,
  'celebration': Icons.celebration,
  'sports_basketball': Icons.sports_basketball,
  'spa': Icons.spa,
};

// Returns the IconData for [identifier], falling back to Icons.label if unknown.
IconData resolveActivityIcon(String identifier) =>
    _iconMap[identifier] ?? Icons.label;
