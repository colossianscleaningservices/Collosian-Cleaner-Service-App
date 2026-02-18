class EditProfileRequest {
  EditProfileRequest({
      this.firstName, 
      this.lastName, 
      this.phoneNumber, 
      this.address, 
      this.city, 
      this.postalCode, 
      this.dob, 
      this.gender, 
      this.company,
      this.imageUrl,
      this.enableReminder,
     });

  EditProfileRequest.fromJson(dynamic json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
    dob = json['dob'];
    gender = json['gender'];
    company = json['company'];
    imageUrl = json['image_url'];
    enableReminder = json['enable_reminder'];
  }
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? address;
  String? city;
  String? postalCode;
  String? dob;
  String? gender;
  String? company;
  String? imageUrl;
  bool? enableReminder;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['phone_number'] = phoneNumber;
    map['address'] = address;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['dob'] = dob;
    map['gender'] = gender;
    map['company'] = company;
    map['enable_reminder'] = enableReminder;
    map['image_url'] = imageUrl;
    return map;
  }

}