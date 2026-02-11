class AssessmentCategoryResponse {
  AssessmentCategoryResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  AssessmentCategoryResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  String? message;
  String? version;
  num? code;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['version'] = version;
    map['code'] = code;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    this.categories,
    this.pagination,
  });

  Data.fromJson(dynamic json) {
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) {
        categories?.add(Categories.fromJson(v));
      });
    }
    pagination = json['pagination'];
  }

  List<Categories>? categories;
  dynamic pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (categories != null) {
      map['categories'] = categories?.map((v) => v.toJson()).toList();
    }
    map['pagination'] = pagination;
    return map;
  }
}

class Categories {
  Categories({
    this.id,
    this.name,
    this.slug,
  });

  Categories.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  num? id;
  String? name;
  String? slug;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['slug'] = slug;
    return map;
  }
}
