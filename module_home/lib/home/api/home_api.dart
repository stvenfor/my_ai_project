import 'package:module_home/home/api/home_http_config.dart';
import 'package:module_home/home/model/banner_model.dart';
import 'package:module_http/module_http.dart';

class HomeApi {
  static const String bannerPath = 'banner/json';

  Future<List<BannerModel>> fetchBanners() async {
    HomeHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<List<BannerModel>>(
      bannerPath,
      converter: (json) {
        if (json is! List) return <BannerModel>[];
        return json
            .whereType<Map<String, dynamic>>()
            .map(BannerModel.fromJson)
            .toList();
      },
    );
    return result.data ?? [];
  }
}
