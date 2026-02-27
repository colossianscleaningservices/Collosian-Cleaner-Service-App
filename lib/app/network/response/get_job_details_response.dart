import 'package:ccs_app/app/network/response/get_client_job_response.dart';

class GetJobDetailsResponse {
  GetJobDetailsResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  GetJobDetailsResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? JobDetails.fromJson(json['data']) : null;
  }

  String? message;
  String? version;
  num? code;
  JobDetails? data;

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

class JobDetails {
  JobDetails({
    this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.areaRequirement,
    this.accessToProperty,
    this.provideCleaningProducts,
    this.staffPreference,
    this.before,
    this.after,
    this.status,
    this.propertyId,
    this.userId,
    this.pricingChartId,
    this.isDeleted,
    this.cleaningType,
    this.additionalDetails,
    this.hoover,
    this.provideWashingMachine,
    this.provideDryer,
    this.additionalData,
    this.notified,
    this.scheduleId,
    this.jobStartDate,
    this.jobEndDate,
    this.jobType,
    this.jobCleaners,
    this.numberOfCleaners,
    this.numberOfGuests,
    this.celebrationType,
    this.venueAddress,
    this.property,
    this.pricingChart,
    this.cleaners,
    this.createdAt,
    this.updatedAt,
  });

  /// True when status is Scheduled (job has been given a date/time).
  bool get isScheduled => status?.toLowerCase() == 'scheduled';

  JobDetails.fromJson(dynamic json) {
    id = json['id'];
    date = json['date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    areaRequirement = json['area_requirement'];
    accessToProperty = json['access_to_property'];
    provideCleaningProducts = json['provide_cleaning_products'];
    staffPreference = json['staff_preference'];
    before = json['before'];
    after = json['after'];
    status = json['status'];
    propertyId = json['property_id'];
    userId = json['user_id'];
    pricingChartId = json['pricing_chart_id'];
    isDeleted = json['is_deleted'];
    cleaningType = json['cleaning_type'] != null ? CleaningType.fromJson(json['cleaning_type']) : null;
    additionalDetails = json['additional_details'];
    hoover = json['hoover'];
    provideWashingMachine = json['provide_washing_machine'];
    provideDryer = json['provide_dryer'];
    additionalData = json['additional_data'];
    notified = json['notified'];
    scheduleId = json['schedule_id'];
    jobStartDate = json['job_start_date'];
    jobEndDate = json['job_end_date'];
    jobType = json['job_type'];
    numberOfCleaners = json['number_of_cleaners'];
    numberOfGuests = json['number_of_guests'];
    celebrationType = json['celebration_type'];
    venueAddress = json['venue_address'];
    property = json['property'] != null ? Property.fromJson(json['property']) : null;
    pricingChart = json['pricing_chart'];
    if (json['cleaners'] != null) {
      cleaners = [];
      json['cleaners'].forEach((v) {
        cleaners?.add(Cleaners.fromJson(v));
      });
    }
    if (json['job_cleaners'] != null) {
      jobCleaners = [];
      json['job_cleaners'].forEach((v) {
        jobCleaners?.add(JobCleaners.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? date;
  String? startTime;
  String? endTime;
  dynamic areaRequirement;
  String? accessToProperty;
  bool? provideCleaningProducts;
  String? staffPreference;
  dynamic before;
  dynamic after;
  String? status;
  num? propertyId;
  num? userId;
  dynamic pricingChartId;
  bool? isDeleted;
  CleaningType? cleaningType;
  String? additionalDetails;
  String? hoover;
  bool? provideWashingMachine;
  bool? provideDryer;
  dynamic additionalData;
  dynamic notified;
  dynamic scheduleId;
  String? jobStartDate;
  String? jobEndDate;
  String? jobType;
  num? numberOfCleaners;
  dynamic numberOfGuests;
  dynamic celebrationType;
  dynamic venueAddress;
  Property? property;
  dynamic pricingChart;
  List<Cleaners>? cleaners;
  String? createdAt;
  String? updatedAt;
  List<JobCleaners>? jobCleaners;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['date'] = date;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['area_requirement'] = areaRequirement;
    map['access_to_property'] = accessToProperty;
    map['provide_cleaning_products'] = provideCleaningProducts;
    map['staff_preference'] = staffPreference;
    map['before'] = before;
    map['after'] = after;
    map['status'] = status;
    map['property_id'] = propertyId;
    map['user_id'] = userId;
    map['pricing_chart_id'] = pricingChartId;
    map['is_deleted'] = isDeleted;
    if (cleaningType != null) {
      map['cleaning_type'] = cleaningType?.toJson();
    }
    map['additional_details'] = additionalDetails;
    map['hoover'] = hoover;
    map['provide_washing_machine'] = provideWashingMachine;
    map['provide_dryer'] = provideDryer;
    map['additional_data'] = additionalData;
    map['notified'] = notified;
    map['schedule_id'] = scheduleId;
    map['job_start_date'] = jobStartDate;
    map['job_end_date'] = jobEndDate;
    map['job_type'] = jobType;
    map['number_of_cleaners'] = numberOfCleaners;
    map['number_of_guests'] = numberOfGuests;
    map['celebration_type'] = celebrationType;
    map['venue_address'] = venueAddress;
    if (property != null) {
      map['property'] = property?.toJson();
    }
    map['pricing_chart'] = pricingChart;
    if (cleaners != null) {
      map['cleaners'] = cleaners?.map((v) => v.toJson()).toList();
    }
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (jobCleaners != null) {
      map['job_cleaners'] = jobCleaners?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Property {
  Property({
    this.id,
    this.userId,
    this.propertyName,
    this.address,
    this.city,
    this.postalCode,
    this.bussinessType,
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

  Property.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    propertyName = json['property_name'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
    bussinessType = json['bussiness_type'];
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
  String? bussinessType;
  String? propertyType;
  String? subType;
  String? animalProperty;
  String? hoover;
  bool? provideCleaningProducts;
  bool? provideWashingMachine;
  bool? provideDryer;
  String? staffPreference;
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
    map['bussiness_type'] = bussinessType;
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

class JobCleaners {
  JobCleaners({
    this.id,
    this.status,
    this.reason,
    this.startTime,
    this.endTime,
    this.jobId,
    this.userId,
    this.isReviewed,
    this.checkInDate,
    this.checkOutDate,
    this.createdAt,
    this.updatedAt,});

  JobCleaners.fromJson(dynamic json) {
    id = json['id'];
    status = json['status'];
    reason = json['reason'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    jobId = json['job_id'];
    userId = json['user_id'];
    isReviewed = json['is_reviewed'];
    checkInDate = json['check_in_date'];
    checkOutDate = json['check_out_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? status;
  String? reason;
  String? startTime;
  String? endTime;
  num? jobId;
  num? userId;
  bool? isReviewed;
  dynamic checkInDate;
  dynamic checkOutDate;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['status'] = status;
    map['reason'] = reason;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['job_id'] = jobId;
    map['user_id'] = userId;
    map['is_reviewed'] = isReviewed;
    map['check_in_date'] = checkInDate;
    map['check_out_date'] = checkOutDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}
