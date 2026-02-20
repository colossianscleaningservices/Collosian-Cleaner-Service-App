class StaffEditProfileRequest {
  StaffEditProfileRequest({
      this.firstName, 
      this.lastName, 
      this.email, 
      this.phoneNumber, 
      this.address, 
      this.city, 
      this.postalCode, 
      this.dob, 
      this.gender, 
      this.nationalInsuranceNumber, 
      this.shareCode, 
      this.nextOfKinName, 
      this.nextOfKinRelationship, 
      this.nextOfKinContact, 
      this.preferredStartDate, 
      this.drives, 
      this.localAreas, 
      this.hasChildren, 
      this.cleaningServices, 
      this.hobbies, 
      this.immigrationStatus, 
      this.imageUrl, 
      this.enableReminder, 
      this.isStudent, 
      this.bankName, 
      this.accountHolderName, 
      this.accountNumber, 
      this.sortCode,});

  StaffEditProfileRequest.fromJson(dynamic json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
    dob = json['dob'];
    gender = json['gender'];
    nationalInsuranceNumber = json['national_insurance_number'];
    shareCode = json['share_code'];
    nextOfKinName = json['next_of_kin_name'];
    nextOfKinRelationship = json['next_of_kin_relationship'];
    nextOfKinContact = json['next_of_kin_contact'];
    preferredStartDate = json['preferred_start_date'];
    drives = json['drives'];
    localAreas = json['local_areas'];
    hasChildren = json['has_children'];
    cleaningServices = json['cleaning_services'] != null ? json['cleaning_services'].cast<num>() : [];
    hobbies = json['hobbies'];
    immigrationStatus = json['immigration_status'];
    imageUrl = json['image_url'];
    enableReminder = json['enable_reminder'];
    isStudent = json['is_student'];
    bankName = json['bank_name'];
    accountHolderName = json['account_holder_name'];
    accountNumber = json['account_number'];
    sortCode = json['sort_code'];
  }
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? address;
  String? city;
  String? postalCode;
  String? dob;
  String? gender;
  String? nationalInsuranceNumber;
  String? shareCode;
  String? nextOfKinName;
  String? nextOfKinRelationship;
  String? nextOfKinContact;
  String? preferredStartDate;
  String? drives;
  String? localAreas;
  String? hasChildren;
  List<num>? cleaningServices;
  String? hobbies;
  num? immigrationStatus;
  String? imageUrl;
  bool? enableReminder;
  bool? isStudent;
  String? bankName;
  String? accountHolderName;
  String? accountNumber;
  String? sortCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    map['address'] = address;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['dob'] = dob;
    map['gender'] = gender;
    map['national_insurance_number'] = nationalInsuranceNumber;
    map['share_code'] = shareCode;
    map['next_of_kin_name'] = nextOfKinName;
    map['next_of_kin_relationship'] = nextOfKinRelationship;
    map['next_of_kin_contact'] = nextOfKinContact;
    map['preferred_start_date'] = preferredStartDate;
    map['drives'] = drives;
    map['local_areas'] = localAreas;
    map['has_children'] = hasChildren;
    map['cleaning_services'] = cleaningServices;
    map['hobbies'] = hobbies;
    map['immigration_status'] = immigrationStatus;
    map['image_url'] = imageUrl;
    map['enable_reminder'] = enableReminder;
    map['is_student'] = isStudent;
    map['bank_name'] = bankName;
    map['account_holder_name'] = accountHolderName;
    map['account_number'] = accountNumber;
    map['sort_code'] = sortCode;
    return map;
  }

}