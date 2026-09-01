class CreateJobRequest {
  CreateJobRequest({
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
    this.endOfTenancyRuleId,
    this.customAddOns,
    this.omitEndTime = false,
  });

  CreateJobRequest.fromJson(dynamic json) {
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
    endOfTenancyRuleId = json['end_of_tenancy_rule_id'];
    omitEndTime = json['end_time'] == null && json['end_of_tenancy_rule_id'] != null;
    if (json['custom_add_ons'] != null) {
      customAddOns = [];
      json['custom_add_ons'].forEach((v) {
        customAddOns?.add(JobCustomAddOnRequest.fromJson(v));
      });
    }
  }

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
  num? endOfTenancyRuleId;
  List<JobCustomAddOnRequest>? customAddOns;
  bool omitEndTime = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['property_id'] = propertyId;
    map['date'] = date;
    map['start_time'] = startTime;
    if (!omitEndTime) {
      map['end_time'] = endTime;
    }
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
    if (endOfTenancyRuleId != null) {
      map['end_of_tenancy_rule_id'] = endOfTenancyRuleId;
    }
    if (customAddOns != null) {
      map['custom_add_ons'] = customAddOns?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class JobCustomAddOnRequest {
  JobCustomAddOnRequest({
    this.label,
    this.note,
  });

  JobCustomAddOnRequest.fromJson(dynamic json) {
    label = json['label'];
    note = json['note'];
  }

  String? label;
  String? note;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    if (note != null && note!.trim().isNotEmpty) {
      map['note'] = note;
    }
    return map;
  }
}
