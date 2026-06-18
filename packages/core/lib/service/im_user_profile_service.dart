import 'package:module_core/model/im/im_user_profile.dart';

abstract class ImUserProfileService {
  Future<ImUserProfile?> getProfile(String imUserId);

  Future<Map<String, ImUserProfile>> getProfiles(List<String> imUserIds);

  Future<void> prefetch(List<String> imUserIds);
}
