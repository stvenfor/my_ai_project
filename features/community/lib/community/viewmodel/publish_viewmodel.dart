import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/repository/post_repository.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';

class PublishViewModel extends GetxController {
  PublishViewModel({PostRepository? repository})
      : _repository = repository ?? Get.find<PostRepository>();

  final PostRepository _repository;

  final content = ''.obs;
  final mediaType = 'none'.obs; // none | image | video
  final selectedTopic = Rxn<TopicModel>();
  final publishing = false.obs;

  void setMediaType(String type) {
    mediaType.value = type;
  }

  void setTopic(TopicModel? topic) {
    selectedTopic.value = topic;
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
