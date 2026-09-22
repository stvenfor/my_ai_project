import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/repository/post_repository.dart';
import 'package:module_community/community/view/image_preview_page.dart';
import 'package:module_community/community/view/video_play_page.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_utils/module_utils.dart';

class PublishViewModel extends GetxController {
  PublishViewModel({PostRepository? repository})
      : _repository = repository ?? Get.find<PostRepository>();

  final PostRepository _repository;

  static const maxImages = 9;

  final content = ''.obs;
  final mediaType = 'none'.obs; // none | image | video
  /// 本地图片路径（最多 9；仅预览，不上传）。
  final imagePaths = <String>[].obs;
  /// 本地视频路径。
  final videoPath = RxnString();
  /// 本地视频封面路径。
  final videoCoverPath = RxnString();
  final selectedTopic = Rxn<TopicModel>();
  final publishing = false.obs;

  void clearMedia() {
    mediaType.value = 'none';
    imagePaths.clear();
    videoPath.value = null;
    videoCoverPath.value = null;
  }

  void _clearImages() {
    imagePaths.clear();
  }

  void _clearVideo() {
    videoPath.value = null;
    videoCoverPath.value = null;
  }

  void setTopic(TopicModel? topic) {
    selectedTopic.value = topic;
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= imagePaths.length) return;
    imagePaths.removeAt(index);
    if (imagePaths.isEmpty) {
      mediaType.value = 'none';
    }
  }

  /// 相册多选续选 / 相机单张追加；切到图片时清空视频。
  Future<void> pickImageMedia() async {
    if (imagePaths.length >= maxImages) {
      UiKitInitializer.toastError('最多选择 $maxImages 张图片');
      return;
    }
    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;
    try {
      if (source == MediaPickSource.camera) {
        final granted = await ImagePickerUtils.ensureCameraPermission();
        if (!granted) {
          UiKitInitializer.toastError('需要相机权限才能拍摄');
          return;
        }
        final path = await ImagePickerUtils.pickImage(source);
        if (path == null || path.isEmpty) return;
        _clearVideo();
        mediaType.value = 'image';
        _appendImages([path]);
        return;
      }

      final remain = maxImages - imagePaths.length;
      final picked = await ImagePickerUtils.pickMultiImages(limit: remain);
      if (picked.isEmpty) return;
      _clearVideo();
      mediaType.value = 'image';
      _appendImages(picked);
    } on PlatformException catch (_) {
      UiKitInitializer.toastError('无法选择图片，请检查相册或相机权限');
    } catch (_) {
      UiKitInitializer.toastError('选择图片失败');
    }
  }

  void _appendImages(List<String> paths) {
    final existing = imagePaths.toSet();
    var added = 0;
    for (final p in paths) {
      if (p.isEmpty || existing.contains(p)) continue;
      if (imagePaths.length >= maxImages) break;
      imagePaths.add(p);
      existing.add(p);
      added++;
    }
    if (imagePaths.length >= maxImages && paths.length > added) {
      UiKitInitializer.toast('已达 $maxImages 张上限');
    }
  }

  /// 选视频；切到视频时清空图片。
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
      _clearImages();
      mediaType.value = 'video';
      videoPath.value = path;
      videoCoverPath.value = null;
    } on PlatformException catch (_) {
      UiKitInitializer.toastError('无法选择视频，请检查相册或相机权限');
    } catch (_) {
      UiKitInitializer.toastError('选择视频失败');
    }
  }

  /// 为已选视频设置封面图。
  Future<void> pickVideoCover() async {
    if (mediaType.value != 'video' || (videoPath.value?.isEmpty ?? true)) {
      UiKitInitializer.toastError('请先选择视频');
      return;
    }
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
      videoCoverPath.value = path;
    } on PlatformException catch (_) {
      UiKitInitializer.toastError('无法选择封面');
    } catch (_) {
      UiKitInitializer.toastError('选择封面失败');
    }
  }

  void previewImages(int initialIndex) {
    if (imagePaths.isEmpty) return;
    Get.to<void>(
      () => ImagePreviewPage(
        images: List<String>.from(imagePaths),
        initialIndex: initialIndex.clamp(0, imagePaths.length - 1),
      ),
      transition: Transition.fadeIn,
    );
  }

  void previewVideo() {
    final path = videoPath.value;
    if (path == null || path.isEmpty) return;
    Get.to<void>(
      () => VideoPlayPage(videoUrl: path),
      transition: Transition.fadeIn,
    );
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
