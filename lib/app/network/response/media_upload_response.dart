class MediaUploadResponse {
  MediaUploadResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  MediaUploadResponse.fromJson(dynamic json) {
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
      this.id, 
      this.fileName, 
      this.filePath, 
      this.fileUrl, 
      this.fileType, 
      this.mediaType, 
      this.mimeType, 
      this.fileSize, 
      this.disk, 
      this.mediaableType, 
      this.mediaableId, 
      this.uploadedBy, 
      this.description, 
      this.metadata, 
      this.isActive, 
      this.createdAt, 
      this.updatedAt,});

  Data.fromJson(dynamic json) {
    id = json['id'];
    fileName = json['file_name'] != null ? json['file_name'].cast<String>() : [];
    filePath = json['file_path'] != null ? json['file_path'].cast<String>() : [];
    fileUrl = json['file_url'] != null ? json['file_url'].cast<String>() : [];
    fileType = json['file_type'];
    mediaType = json['media_type'];
    mimeType = json['mime_type'];
    fileSize = json['file_size'];
    disk = json['disk'];
    mediaableType = json['mediaable_type'];
    mediaableId = json['mediaable_id'];
    uploadedBy = json['uploaded_by'];
    description = json['description'];
    metadata = json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  List<String>? fileName;
  List<String>? filePath;
  List<String>? fileUrl;
  String? fileType;
  String? mediaType;
  String? mimeType;
  num? fileSize;
  String? disk;
  String? mediaableType;
  String? mediaableId;
  num? uploadedBy;
  dynamic description;
  Metadata? metadata;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['file_name'] = fileName;
    map['file_path'] = filePath;
    map['file_url'] = fileUrl;
    map['file_type'] = fileType;
    map['media_type'] = mediaType;
    map['mime_type'] = mimeType;
    map['file_size'] = fileSize;
    map['disk'] = disk;
    map['mediaable_type'] = mediaableType;
    map['mediaable_id'] = mediaableId;
    map['uploaded_by'] = uploadedBy;
    map['description'] = description;
    if (metadata != null) {
      map['metadata'] = metadata?.toJson();
    }
    map['is_active'] = isActive;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}

class Metadata {
  Metadata({
      this.count,});

  Metadata.fromJson(dynamic json) {
    count = json['count'];
  }
  num? count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['count'] = count;
    return map;
  }

}