/// A single reference entry matching the add-reference form fields.
class ReferenceItem {
  const ReferenceItem({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.companyName,
    this.relationship,
  });

  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? companyName;
  final String? relationship;
}
