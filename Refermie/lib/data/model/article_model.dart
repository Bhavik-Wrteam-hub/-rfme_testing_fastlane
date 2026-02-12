class ArticleModel {
  ArticleModel({
    this.id,
    this.slugId,
    this.image,
    this.title,
    this.description,
    this.date,
    this.postedOn,
  });

  ArticleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    slugId = json['slug_id']?.toString() ?? '';
    image = json['image']?.toString() ?? '';
    title = json['title']?.toString() ?? '';
    translatedTitle = json['translated_title']?.toString() ?? '';
    translatedDescription = json['translated_description']?.toString() ?? '';
    description = json['description']?.toString() ?? '';
    date = json['created_at']?.toString() ?? '';
    viewCount = json['view_count']?.toString() ?? '';
    postedOn = json['posted_on']?.toString() ?? '';
  }
  int? id;
  String? slugId;
  String? image;
  String? title;
  String? translatedTitle;
  String? translatedDescription;
  String? description;
  String? date;
  String? postedOn;
  String? viewCount;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['slug_id'] = slugId;
    data['image'] = image;
    data['title'] = title;
    data['translated_title'] = translatedTitle;
    data['translated_description'] = translatedDescription;
    data['description'] = description;
    data['created_at'] = date;
    data['view_count '] = viewCount;
    data['posted_on'] = postedOn;
    return data;
  }
}
