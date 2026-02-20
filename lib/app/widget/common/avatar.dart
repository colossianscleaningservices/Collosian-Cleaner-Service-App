import 'package:ccs_app/export.dart';

/// Common avatar: 48×48 with 16px rounded corners.
/// Shows [imageUrl] when set, otherwise [initial] (or first character of [name]).
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initial,
    this.name,
    this.radius = 16,
  });

  final String? imageUrl;
  final String? initial;
  final String? name;

  static const double size = 48;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final letter = initial ??
        (name != null && name!.isNotEmpty ? name!.trim()[0].toUpperCase() : '?');

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(radius ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initialChild(scheme, letter),
            )
          : _initialChild(scheme, letter),
    );
  }

  Widget _initialChild(ColorScheme scheme, String letter) {
    return Center(
      child: CommonText.semiBold(letter, size: 18, color: scheme.primary),
    );
  }
}
