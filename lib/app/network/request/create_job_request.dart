class CreateJobRequest {
  CreateJobRequest({
    // this.jobTitle,
    this.propertyId,
    this.date,
    this.startTime,
    this.endTime,
    this.jobType,
    this.numberOfCleaners,
    this.cleaningType,
    this.accessToProperty,
    this.provideCleaningProducts,
    this.provideWashingMachine,
    this.provideDryer,
    this.hoover,
    this.staffPreference,
    this.additionalDetails,
  });

  CreateJobRequest.fromJson(dynamic json) {
    // jobTitle = json['job_title'];
    propertyId = json['property_id'];
    date = json['date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    jobType = json['job_type'];
    numberOfCleaners = json['number_of_cleaners'];
    cleaningType = json['cleaning_type'];
    accessToProperty = json['access_to_property'];
    provideCleaningProducts = json['provide_cleaning_products'];
    provideWashingMachine = json['provide_washing_machine'];
    provideDryer = json['provide_dryer'];
    hoover = json['hoover'];
    staffPreference = json['staff_preference'];
    additionalDetails = json['additional_details'];
  }

  // String? jobTitle;
  num? propertyId;
  String? date;
  String? startTime;
  String? endTime;
  String? jobType;
  num? numberOfCleaners;
  num? cleaningType;
  String? accessToProperty;
  bool? provideCleaningProducts;
  bool? provideWashingMachine;
  bool? provideDryer;
  String? hoover;
  String? staffPreference;
  String? additionalDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    // map['job_title'] = jobTitle;
    map['property_id'] = propertyId;
    map['date'] = date;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['job_type'] = jobType;
    map['number_of_cleaners'] = numberOfCleaners;
    map['cleaning_type'] = cleaningType;
    map['access_to_property'] = accessToProperty;
    map['provide_cleaning_products'] = provideCleaningProducts;
    map['provide_washing_machine'] = provideWashingMachine;
    map['provide_dryer'] = provideDryer;
    map['hoover'] = hoover;
    map['staff_preference'] = staffPreference;
    map['additional_details'] = additionalDetails;
    return map;
  }
}
