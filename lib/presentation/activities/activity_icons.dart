import 'package:flutter/material.dart';

// Maps string identifier to PNG asset path
const Map<String, String> kActivityIcons = {
  'backpack': 'assets/icons/activities/backpack.png',
  'bicycle': 'assets/icons/activities/bicycle.png',
  'boat': 'assets/icons/activities/boat.png',
  'book': 'assets/icons/activities/book.png',
  'bootles': 'assets/icons/activities/bootles.png',
  'cake': 'assets/icons/activities/cake.png',
  'camera': 'assets/icons/activities/camera.png',
  'cinema': 'assets/icons/activities/cinema.png',
  'city': 'assets/icons/activities/city.png',
  'coffee': 'assets/icons/activities/coffee.png',
  'cook': 'assets/icons/activities/cook.png',
  'dance': 'assets/icons/activities/dance.png',
  'date': 'assets/icons/activities/date.png',
  'drink': 'assets/icons/activities/drink.png',
  'drink2': 'assets/icons/activities/drink2.png',
  'family': 'assets/icons/activities/family.png',
  'fire': 'assets/icons/activities/fire.png',
  'fire2': 'assets/icons/activities/fire2.png',
  'forrest': 'assets/icons/activities/forrest.png',
  'game': 'assets/icons/activities/game.png',
  'guitar': 'assets/icons/activities/guitar.png',
  'gym': 'assets/icons/activities/gym.png',
  'holiday': 'assets/icons/activities/holiday.png',
  'house': 'assets/icons/activities/house.png',
  'house2': 'assets/icons/activities/house2.png',
  'laptop': 'assets/icons/activities/laptop.png',
  'map': 'assets/icons/activities/map.png',
  'map2': 'assets/icons/activities/map2.png',
  'meal': 'assets/icons/activities/meal.png',
  'meeting': 'assets/icons/activities/meeting.png',
  'money': 'assets/icons/activities/money.png',
  'mountain': 'assets/icons/activities/mountain.png',
  'mountain2': 'assets/icons/activities/mountain2.png',
  'museum': 'assets/icons/activities/museum.png',
  'paint': 'assets/icons/activities/paint.png',
  'party': 'assets/icons/activities/party.png',
  'phone': 'assets/icons/activities/phone.png',
  'plane': 'assets/icons/activities/plane.png',
  'plant': 'assets/icons/activities/plant.png',
  'plant2': 'assets/icons/activities/plant2.png',
  'pool': 'assets/icons/activities/pool.png',
  'rest': 'assets/icons/activities/rest.png',
  'ring': 'assets/icons/activities/ring.png',
  'running': 'assets/icons/activities/running.png',
  'sauna': 'assets/icons/activities/sauna.png',
  'sing': 'assets/icons/activities/sing.png',
  'ski': 'assets/icons/activities/ski.png',
  'sport': 'assets/icons/activities/sport.png',
  'suit': 'assets/icons/activities/suit.png',
  'superhero': 'assets/icons/activities/superhero.png',
  'walk': 'assets/icons/activities/walk.png',
};

// Returns asset path for identifier, null if unknown or empty
String? resolveActivityIcon(String? identifier) {
  if (identifier == null || identifier.isEmpty) return null;
  return kActivityIcons[identifier];
}

// Renders activity icon — PNG asset if available, fallback to Icons.category
class ActivityIcon extends StatelessWidget {
  const ActivityIcon({
    super.key,
    required this.identifier,
    this.size = 24.0,
  });

  final String? identifier;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = resolveActivityIcon(identifier);
    if (path != null) {
      return Image.asset(path, width: size, height: size);
    }
    return Icon(
      Icons.category,
      size: size,
      color: Theme.of(context).colorScheme.outline,
    );
  }
}
