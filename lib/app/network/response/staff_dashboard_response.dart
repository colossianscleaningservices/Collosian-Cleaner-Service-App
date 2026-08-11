class StaffDashboardResponse {
  StaffDashboardResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  StaffDashboardResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? StaffDashModel.fromJson(json['data']) : null;
  }

  String? message;
  String? version;
  num? code;
  StaffDashModel? data;

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

class StaffDashModel {
  StaffDashModel({this.totalSchedules, this.upcomingJob, this.totalEarnings, this.profileCompletion, this.actionNeededCount, this.isDocumentAdded, this.unreadNotifications});

  StaffDashModel.fromJson(dynamic json) {
    totalSchedules = json['total_schedules'];
    upcomingJob = json['upcoming_job'] != null ? UpcomingJob.fromJson(json['upcoming_job']) : null;
    totalEarnings = json['total_earnings'];
    profileCompletion = json['profile_completion'] != null ? ProfileCompletion.fromJson(json['profile_completion']) : null;
    actionNeededCount = json['action_needed_count'];
    studentWeeklyHours = json['student_weekly_hours'] != null ? StudentWeeklyHours.fromJson(json['student_weekly_hours']) : null;
    studentWeeklyHoursUsed = json['student_weekly_hours_used'];
    unreadNotifications = json['unread_notifications'];
    isDocumentAdded = json['is_document_added'];
  }

  num? totalSchedules;
  UpcomingJob? upcomingJob;
  num? totalEarnings;
  ProfileCompletion? profileCompletion;
  num? actionNeededCount;
  bool? isDocumentAdded;
  StudentWeeklyHours? studentWeeklyHours;
  num? studentWeeklyHoursUsed;
  num? unreadNotifications;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_schedules'] = totalSchedules;
    if (upcomingJob != null) {
      map['upcoming_job'] = upcomingJob?.toJson();
    }
    map['total_earnings'] = totalEarnings;
    if (profileCompletion != null) {
      map['profile_completion'] = profileCompletion?.toJson();
    }
    map['action_needed_count'] = actionNeededCount;
    map['is_document_added'] = isDocumentAdded;
    if (studentWeeklyHours != null) {
      map['student_weekly_hours'] = studentWeeklyHours?.toJson();
    }
    map['student_weekly_hours_used'] = studentWeeklyHoursUsed;
    map['unread_notifications'] = unreadNotifications;
    return map;
  }
}

class StudentWeeklyHours {
  StudentWeeklyHours({
    this.weekStart,
    this.weekEnd,
    this.hoursWorked,
    this.weeklyLimit,
    this.hoursRemaining,
    this.limitExceeded,});

  StudentWeeklyHours.fromJson(dynamic json) {
    weekStart = json['week_start'];
    weekEnd = json['week_end'];
    hoursWorked = json['hours_worked'];
    weeklyLimit = json['weekly_limit'];
    hoursRemaining = json['hours_remaining'];
    limitExceeded = json['limit_exceeded'];
  }
  String? weekStart;
  String? weekEnd;
  num? hoursWorked;
  num? weeklyLimit;
  num? hoursRemaining;
  bool? limitExceeded;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['week_start'] = weekStart;
    map['week_end'] = weekEnd;
    map['hours_worked'] = hoursWorked;
    map['weekly_limit'] = weeklyLimit;
    map['hours_remaining'] = hoursRemaining;
    map['limit_exceeded'] = limitExceeded;
    return map;
  }

}

class ProfileCompletion {
  ProfileCompletion({
    this.percentage,
    this.status,
  });

  ProfileCompletion.fromJson(dynamic json) {
    percentage = json['percentage'];
    status = json['status'];
  }

  num? percentage;
  String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['percentage'] = percentage;
    map['status'] = status;
    return map;
  }
}

class UpcomingJob {
  UpcomingJob({
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
    this.numberOfCleaners,
    this.numberOfGuests,
    this.celebrationType,
    this.venueAddress,
    this.createdAt,
    this.updatedAt,
    this.property,
  });

  UpcomingJob.fromJson(dynamic json) {
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
    jobStartDate = json['job_start_Date'];
    jobEndDate = json['job_end_date'];
    jobType = json['job_type'];
    numberOfCleaners = json['number_of_cleaners'];
    numberOfGuests = json['number_of_guests'];
    celebrationType = json['celebration_type'];
    venueAddress = json['venue_address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    property = json['property'] != null ? Property.fromJson(json['property']) : null;
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
  dynamic additionalDetails;
  String? hoover;
  bool? provideWashingMachine;
  bool? provideDryer;
  dynamic additionalData;
  dynamic notified;
  dynamic scheduleId;
  dynamic jobStartDate;
  dynamic jobEndDate;
  String? jobType;
  num? numberOfCleaners;
  dynamic numberOfGuests;
  dynamic celebrationType;
  dynamic venueAddress;
  String? createdAt;
  String? updatedAt;
  Property? property;

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
    map['job_start_Date'] = jobStartDate;
    map['job_end_date'] = jobEndDate;
    map['job_type'] = jobType;
    map['number_of_cleaners'] = numberOfCleaners;
    map['number_of_guests'] = numberOfGuests;
    map['celebration_type'] = celebrationType;
    map['venue_address'] = venueAddress;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (property != null) {
      map['property'] = property?.toJson();
    }
    return map;
  }
}

class Property {
  Property({
    this.id,
    this.propertyName,
    this.city,
    this.postalCode,
    this.animalProperty,
    this.userId,
    this.propertyType,
    this.subType,
    this.isDeleted,
    this.address,
    this.additionalDetails,
    this.accessToProperty,
    this.hoover,
    this.provideCleaningProducts,
    this.provideWashingMachine,
    this.provideDryer,
    this.staffPreference,
    this.bussinessType,
    this.createdAt,
    this.updatedAt,
    this.bedrooms,
    this.bathrooms,
    this.separateGuestToilet,
    this.livingRooms,
    this.office,
    this.conservatory,
    this.diningRoom,
  });

  Property.fromJson(dynamic json) {
    id = json['id'];
    propertyName = json['property_name'];
    city = json['city'];
    postalCode = json['postal_code'];
    animalProperty = json['animal_property'];
    userId = json['user_id'];
    propertyType = json['property_type'];
    subType = json['sub_type'];
    isDeleted = json['is_deleted'];
    address = json['address'];
    additionalDetails = json['additional_details'];
    accessToProperty = json['access_to_property'];
    hoover = json['hoover'];
    provideCleaningProducts = json['provide_cleaning_products'];
    provideWashingMachine = json['provide_washing_machine'];
    provideDryer = json['provide_dryer'];
    staffPreference = json['staff_preference'];
    bussinessType = json['bussiness_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    separateGuestToilet = json['separate_guest_toilet'];
    livingRooms = json['living_rooms'];
    office = json['office'];
    conservatory = json['conservatory'];
    diningRoom = json['dining_room'];
  }

  num? id;
  String? propertyName;
  String? city;
  String? postalCode;
  String? animalProperty;
  num? userId;
  String? propertyType;
  String? subType;
  bool? isDeleted;
  String? address;
  dynamic additionalDetails;
  String? accessToProperty;
  String? hoover;
  bool? provideCleaningProducts;
  bool? provideWashingMachine;
  bool? provideDryer;
  String? staffPreference;
  String? bussinessType;
  String? createdAt;
  String? updatedAt;
  num? bedrooms;
  num? bathrooms;
  num? separateGuestToilet;
  num? livingRooms;
  num? office;
  num? conservatory;
  num? diningRoom;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['property_name'] = propertyName;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['animal_property'] = animalProperty;
    map['user_id'] = userId;
    map['property_type'] = propertyType;
    map['sub_type'] = subType;
    map['is_deleted'] = isDeleted;
    map['address'] = address;
    map['additional_details'] = additionalDetails;
    map['access_to_property'] = accessToProperty;
    map['hoover'] = hoover;
    map['provide_cleaning_products'] = provideCleaningProducts;
    map['provide_washing_machine'] = provideWashingMachine;
    map['provide_dryer'] = provideDryer;
    map['staff_preference'] = staffPreference;
    map['bussiness_type'] = bussinessType;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['bedrooms'] = bedrooms;
    map['bathrooms'] = bathrooms;
    map['separate_guest_toilet'] = separateGuestToilet;
    map['living_rooms'] = livingRooms;
    map['office'] = office;
    map['conservatory'] = conservatory;
    map['dining_room'] = diningRoom;
    return map;
  }
}

class CleaningType {
  CleaningType({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.isDeleted,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  CleaningType.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    isActive = json['is_active'];
    isDeleted = json['is_deleted'];
    sortOrder = json['sort_order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? name;
  String? description;
  bool? isActive;
  bool? isDeleted;
  num? sortOrder;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['description'] = description;
    map['is_active'] = isActive;
    map['is_deleted'] = isDeleted;
    map['sort_order'] = sortOrder;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
