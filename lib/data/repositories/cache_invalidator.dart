/// Interface for cache invalidation, decoupling write repositories from
/// StatisticsRepository to avoid circular constructor dependencies.
abstract class CacheInvalidator {
  void invalidateMeetingsCache();
  void invalidateCategoriesCache();
  void invalidatePersonsCache();
}
