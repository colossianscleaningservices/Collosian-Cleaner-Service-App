/// Minimal model for property list items.
class PropertyListItem {
  const PropertyListItem({
    required this.id,
    required this.name,
    required this.addressLine,
    this.propertyType,
    this.city,
    this.postalCode,
  });

  final String id;
  final String name;
  final String addressLine;
  final String? propertyType;
  final String? city;
  final String? postalCode;
}
