import 'package:module_home/home/model/all_services_data.dart';
import 'package:module_home/home/model/all_services_model.dart';
import 'package:module_utils/module_utils.dart';

class AllServicesRepository {
  AllServicesRepository._();

  static const _favoriteIdsKey = 'home_favorite_service_ids_v2';

  static Future<List<String>> loadFavoriteIds() async {
    final stored = SpUtils.getStringList(_favoriteIdsKey);
    if (stored.isEmpty) {
      return AllServicesData.defaultFavoriteIds;
    }
    return stored;
  }

  static Future<void> saveFavoriteIds(List<String> ids) async {
    await SpUtils.setStringList(_favoriteIdsKey, ids);
  }

  static List<AllServiceItem> resolveItems(List<String> ids) {
    final resolved = AllServicesData.resolveItems(ids);
    if (resolved.isEmpty) {
      return List<AllServiceItem>.from(AllServicesData.defaultFavoriteItems);
    }
    return resolved;
  }

  static List<AllServiceItem> normalizeFavorites(List<AllServiceItem> items) {
    var normalized = List<AllServiceItem>.from(items);

    if (normalized.length > AllServicesData.maxFavoriteCount) {
      normalized = normalized.take(AllServicesData.maxFavoriteCount).toList();
    }

    if (normalized.length < AllServicesData.minFavoriteCount) {
      final existingIds = normalized.map((item) => item.id).toSet();
      for (final candidate in AllServicesData.defaultFavoriteItems) {
        if (normalized.length >= AllServicesData.minFavoriteCount) break;
        if (existingIds.add(candidate.id)) {
          normalized.add(candidate);
        }
      }
    }

    if (normalized.length < AllServicesData.minFavoriteCount) {
      return List<AllServiceItem>.from(AllServicesData.defaultFavoriteItems);
    }

    return normalized;
  }

  static Future<List<AllServiceItem>> loadFavoriteItems() async {
    final stored = SpUtils.getStringList(_favoriteIdsKey);
    if (stored.isEmpty) {
      await saveFavoriteIds(AllServicesData.defaultFavoriteIds);
      return List<AllServiceItem>.from(AllServicesData.defaultFavoriteItems);
    }

    final items = normalizeFavorites(resolveItems(stored));
    final normalizedIds = items.map((item) => item.id).toList();
    if (normalizedIds.length != stored.length ||
        !_sameIds(normalizedIds, stored)) {
      await saveFavoriteIds(normalizedIds);
    }
    return items;
  }

  static bool _sameIds(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static Future<void> saveFavoriteItems(List<AllServiceItem> items) async {
    await saveFavoriteIds(items.map((item) => item.id).toList());
  }
}
