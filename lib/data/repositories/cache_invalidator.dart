/// Interface for cache invalidation, decoupling write repositories from
/// StatisticsRepository to avoid circular constructor dependencies.
///
/// Methods return Future<void> so callers can await Hive box clears.
abstract class CacheInvalidator {
  Future<void> invalidateMeetingsCache();
  Future<void> invalidateCategoriesCache();
  Future<void> invalidatePersonsCache();
}
