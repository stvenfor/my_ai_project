import 'package:module_home/home/api/home_api.dart';
import 'package:module_home/home/model/banner_model.dart';

class HomeRepository {
  HomeRepository({HomeApi? api}) : _api = api ?? HomeApi();

  final HomeApi _api;

  Future<List<BannerModel>> loadBanners() => _api.fetchBanners();
}
