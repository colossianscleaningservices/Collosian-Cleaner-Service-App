class PropertyListResponse {
  PropertyListResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  PropertyListResponse.fromJson(dynamic json) {
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
      this.properties, 
      this.pagination,});

  Data.fromJson(dynamic json) {
    if (json['properties'] != null) {
      properties = [];
      json['properties'].forEach((v) {
        properties?.add(PropertyModel.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  List<PropertyModel>? properties;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (properties != null) {
      map['properties'] = properties?.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      map['pagination'] = pagination?.toJson();
    }
    return map;
  }

}

class Pagination {
  Pagination({
      this.currentPage, 
      this.perPage, 
      this.total, 
      this.lastPage, 
      this.totalPages,});

  Pagination.fromJson(dynamic json) {
    currentPage = json['current_page'];
    perPage = json['per_page'];
    total = json['total'];
    lastPage = json['last_page'];
    totalPages = json['total_pages'];
  }
  num? currentPage;
  num? perPage;
  num? total;
  num? lastPage;
  num? totalPages;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = currentPage;
    map['per_page'] = perPage;
    map['total'] = total;
    map['last_page'] = lastPage;
    map['total_pages'] = totalPages;
    return map;
  }

}

class PropertyModel {
  PropertyModel({
      this.id, 
      this.userId, 
      this.propertyName, 
      this.address, 
      this.city, 
      this.postalCode, 
      this.businessType,
      this.propertyType, 
      this.subType, 
      this.animalProperty, 
      this.hoover, 
      this.provideCleaningProducts, 
      this.provideWashingMachine, 
      this.provideDryer, 
      this.staffPreference, 
      this.accessToProperty, 
      this.additionalDetails, 
      this.isDeleted, 
      this.bedrooms, 
      this.bathrooms, 
      this.separateGuestToilet, 
      this.livingRooms, 
      this.office, 
      this.conservatory, 
      this.diningRoom, 
      this.createdAt, 
      this.updatedAt,});

  PropertyModel.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    propertyName = json['property_name'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
    businessType = json['bussiness_type'];
    propertyType = json['property_type'];
    subType = json['sub_type'];
    animalProperty = json['animal_property'];
    hoover = json['hoover'];
    provideCleaningProducts = json['provide_cleaning_products'];
    provideWashingMachine = json['provide_washing_machine'];
    provideDryer = json['provide_dryer'];
    staffPreference = json['staff_preference'];
    accessToProperty = json['access_to_property'];
    additionalDetails = json['additional_details'];
    isDeleted = json['is_deleted'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    separateGuestToilet = json['separate_guest_toilet'];
    livingRooms = json['living_rooms'];
    office = json['office'];
    conservatory = json['conservatory'];
    diningRoom = json['dining_room'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? userId;
  String? propertyName;
  String? address;
  String? city;
  String? postalCode;
  String? businessType;
  String? propertyType;
  dynamic subType;
  String? animalProperty;
  String? hoover;
  bool? provideCleaningProducts;
  bool? provideWashingMachine;
  bool? provideDryer;
  dynamic staffPreference;
  String? accessToProperty;
  dynamic additionalDetails;
  bool? isDeleted;
  num? bedrooms;
  num? bathrooms;
  num? separateGuestToilet;
  num? livingRooms;
  num? office;
  num? conservatory;
  num? diningRoom;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['property_name'] = propertyName;
    map['address'] = address;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['bussiness_type'] = businessType;
    map['property_type'] = propertyType;
    map['sub_type'] = subType;
    map['animal_property'] = animalProperty;
    map['hoover'] = hoover;
    map['provide_cleaning_products'] = provideCleaningProducts;
    map['provide_washing_machine'] = provideWashingMachine;
    map['provide_dryer'] = provideDryer;
    map['staff_preference'] = staffPreference;
    map['access_to_property'] = accessToProperty;
    map['additional_details'] = additionalDetails;
    map['is_deleted'] = isDeleted;
    map['bedrooms'] = bedrooms;
    map['bathrooms'] = bathrooms;
    map['separate_guest_toilet'] = separateGuestToilet;
    map['living_rooms'] = livingRooms;
    map['office'] = office;
    map['conservatory'] = conservatory;
    map['dining_room'] = diningRoom;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}