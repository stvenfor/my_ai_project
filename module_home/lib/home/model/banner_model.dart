class BannerModel {
  const BannerModel({
    this.id,
    this.title,
    this.url,
    this.imagePath,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title']?.toString(),
      url: json['url']?.toString(),
      imagePath: json['imagePath']?.toString(),
    );
  }

  final num? id;
  final String? title;
  final String? url;
  final String? imagePath;
}
