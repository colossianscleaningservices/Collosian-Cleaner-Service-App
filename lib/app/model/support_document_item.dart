/// Represents a single supporting document for the list view.
class SupportDocumentItem {
  const SupportDocumentItem({
    required this.type,
    required this.number,
    this.expiry,
    this.fileUrl,
  });

  final String type;
  final String number;
  final DateTime? expiry;
  final String? fileUrl;
}
