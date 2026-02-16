import 'package:ccs_app/app/network/response/base_response.dart';

class PropertyListResponse extends BaseResponse {
  PropertyListResponse({
    this.data,
  });

  PropertyListResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(PropertyModel.fromJson(v));
      });
    }
  }

  List<PropertyModel>? data;

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['version'] = version;
    map['code'] = code;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
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
    this.updatedAt,
  });

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
  String? subType;
  String? animalProperty;
  String? hoover;
  bool? provideCleaningProducts;
  bool? provideWashingMachine;
  bool? provideDryer;
  String? staffPreference;
  String? accessToProperty;
  String? additionalDetails;
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
