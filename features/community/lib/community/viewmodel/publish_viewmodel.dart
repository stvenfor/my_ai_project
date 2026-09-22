import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/repository/post_repository.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_utils/module_utils.dart';

class PublishViewModel extends GetxController {
  PublishViewModel({PostRepository? repository})
      : _repository = repository ?? Get.find<PostRepository>();

  final PostRepository _repository;

  final content = ''.obs;
  final mediaType = 'none'.obs; // none | image | video
  /// 本地预览路径（仅 UI；发帖不上传）。
  final localPreviewPath = RxnString();
  final selectedTopic = Rxn<TopicModel>();
  final publishing = false.obs;

  void clearMedia() {
    mediaType.value = 'none';
    localPreviewPath.value = null;
  }

  void setTopic(TopicModel? topic) {
    selectedTopic.value = topic;
  }

  /// 弹出相册/相机，选图；取消或失败不改动已有草稿。
  Future<void> pickImageMedia() async {
    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;
    try {
      if (source == MediaPickSource.camera) {
        final granted = await ImagePickerUtils.ensureCameraPermission();
        if (!granted) {
          UiKitInitializer.toastError('需要相机权限才能拍摄');
          return;
        }
      }
      final path = await ImagePickerUtils.pickImage(source);
      if (path == null || path.isEmpty) return;
      mediaType.value = 'image';
      localPreviewPath.value = path;
    } on PlatformException catch (_) {
      UiKitInitializer.toastError('无法选择图片，请检查相册或相机权限');
    } catch (_) {
      UiKitInitializer.toastError('选择图片失败');
    }
  }

  /// 弹出相册/相机，选视频；取消或失败不改动已有草稿。
  Future<void> pickVideoMedia() async {
    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;
    try {
      if (source == MediaPickSource.camera) {
        final granted = await ImagePickerUtils.ensureCameraPermission();
        if (!granted) {
          UiKitInitializer.toastError('需要相机权限才能拍摄');
          return;
        }
      }
      final path = await ImagePickerUtils.pickVideo(source);
      if (path == null || path.isEmpty) return;
      mediaType.value = 'video';
      localPreviewPath.value = path;
    } on PlatformException catch (_) {
      UiKitInitializer.toastError('无法选择视频，请检查相册或相机权限');
    } catch (_) {
      UiKitInitializer.toastError('选择视频失败');
    }
  }

  Future<bool> publish() async {
    final text = content.value.trim();
    if (text.isEmpty && mediaType.value == 'none') {
      UiKitInitializer.toastError('请输入内容或选择图片/视频');
      return false;
    }
    if (publishing.value) return false;
    publishing.value = true;
    try {
      final topic = selectedTopic.value;
      // 仅传 media_type；本地路径不入库，由 BFF 填默认外链。
      final post = await _repository.createPost(
        content: text,
        mediaType: mediaType.value,
        topicId: topic?.id,
        isAskEveryone: topic?.isAskEveryone ?? false,
      );
      if (Get.isRegistered<CommunityViewModel>()) {
        final feed = Get.find<CommunityViewModel>();
        feed.posts.insert(0, post);
        feed.update();
      }
      UiKitInitializer.toast('发布成功');
      return true;
    } catch (e) {
      UiKitInitializer.toastError('发布失败');
      return false;
    } finally {
      publishing.value = false;
    }
  }
}
