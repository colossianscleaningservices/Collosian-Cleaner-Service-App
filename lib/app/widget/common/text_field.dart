import 'package:ccs_app/export.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

InputDecoration buildCommonDecoration({
  required BuildContext context,
  required String hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  double? radius,
  Color? borderColor,
  Color? fillColor,
  EdgeInsets? contentPadding,
  TextStyle? labelStyle,
  TextStyle? hintStyle,
}) {
  final scheme = context.colorScheme;
  final normalOutlineColor = borderColor ?? scheme.outline.withValues(alpha: 0.3);
  final focusedOutlineColor = borderColor ?? scheme.primary;
  final borderRadius = BorderRadius.circular(radius ?? UiConstants.radiusDefault);

  return InputDecoration(
    labelStyle: labelStyle,
    hintStyle: hintStyle,
    fillColor: fillColor ?? scheme.surfaceTint.withValues(alpha: 0.04),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: focusedOutlineColor, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: normalOutlineColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
    contentPadding: contentPadding ?? const EdgeInsets.all(12),
    filled: true,
    hintText: hint,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  );
}

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    required this.controller,
    super.key,
    this.hint = '',
    this.label = '',
    this.obscure = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.action = TextInputAction.next,
    this.onChanged,
    this.validator,
    this.onSubmitted,
    this.focus,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.isReadOnly = false,
    this.borderRadius,
    this.borderColor,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.inputFormatters = const [],
    this.textCapitalization,
    this.inputAction,
    this.autofillHints,
    this.contentPadding,
  });

  final TextEditingController controller;
  final String hint;
  final String label;
  final bool obscure;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextInputAction action;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool isReadOnly;
  final double? borderRadius;
  final Color? borderColor;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final List<TextInputFormatter> inputFormatters;
  final TextCapitalization? textCapitalization;
  final TextInputAction? inputAction;
  final List<String>? autofillHints;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    final defaultTextColor = textColor ?? scheme.onSurface;
    final defaultHintColor = hintColor ?? scheme.onSurface.withValues(alpha: 0.4);

    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, color: defaultTextColor, fontWeight: FontWeight.w600);
    final hintStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, color: defaultHintColor, fontWeight: FontWeight.w400);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[Text(label, style: labelStyle), const SizedBox(height: 6)],
        TextFormField(
          controller: controller,
          focusNode: focus,
          obscureText: obscure,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          maxLength: maxLength,
          readOnly: isReadOnly,
          maxLines: maxLines,
          minLines: minLines,
          onTap: onTap,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          textInputAction: inputAction ?? action,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          autofillHints: autofillHints,
          cursorColor: scheme.primary,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: defaultTextColor, fontSize: 14),
          decoration: buildCommonDecoration(
            context: context,
            hint: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            radius: borderRadius,
            borderColor: borderColor,
            fillColor: fillColor,
            labelStyle: labelStyle,
            hintStyle: hintStyle,
            contentPadding: contentPadding,
          ),
        ),
      ],
    );
  }
}

class CommonDropDownField<T> extends StatelessWidget {
  const CommonDropDownField({
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    super.key,
    this.value,
    this.hint = '',
    this.label = '',
    this.prefixIcon,
    this.borderRadius,
    this.borderColor,
    this.textColor,
    this.hintColor,
    this.fillColor,
    this.validator,
  });

  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String hint;
  final String label;
  final Widget? prefixIcon;
  final double? borderRadius;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? fillColor;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final defaultTextColor = textColor ?? colorScheme.onSurface;
    final defaultHintColor = hintColor ?? colorScheme.onSurface.withValues(alpha: 0.4);

    final labelStyle = context.textTheme.bodyMedium?.copyWith(fontSize: 14, color: defaultTextColor, fontWeight: FontWeight.w600);
    final hintStyle = context.textTheme.bodyMedium?.copyWith(fontSize: 14, color: defaultHintColor, fontWeight: FontWeight.w400);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[Text(label, style: labelStyle), const SizedBox(height: 6)],
        DropdownButtonFormField2<T>(
          hint: Text(
            hint,
            style: hintStyle,
          ),
          validator: validator,
          onChanged: onChanged,
          value: value,
          decoration: buildCommonDecoration(
            borderColor: borderColor,
            prefixIcon: prefixIcon,
            radius: borderRadius,
            fillColor: fillColor,
            hintStyle: hintStyle,
            context: context,
            hint: hint,
            contentPadding: EdgeInsets.only(right: 8),
          ),
          iconStyleData: IconStyleData(icon: Icon(IconsaxPlusLinear.arrow_down, color: context.colorScheme.primary).marginOnly(right: 8)),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: CommonText.regular(itemLabel(e), maxLines: 2, overflow: TextOverflow.ellipsis, size: 14, color: colorScheme.onSurface),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class CommonTypeAheadField<T> extends StatelessWidget {
  const CommonTypeAheadField({
    required this.controller,
    required this.suggestionsController,
    required this.focusNode,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSelected,
    super.key,
    this.hint = '',
    this.validator,
    this.suffixIcon,
    this.borderRadius,
    this.borderColor,
    this.fillColor,
    this.maxHeight = 240,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final SuggestionsController<T> suggestionsController;
  final List<T> Function(String pattern) suggestionsCallback;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T) onSelected;

  final String hint;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final double? borderRadius;
  final Color? borderColor;
  final Color? fillColor;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TypeAheadField<T>(
      controller: controller,
      focusNode: focusNode,
      hideOnEmpty: true,
      autoFlipDirection: false,
      direction: VerticalDirection.down,
      suggestionsController: suggestionsController,
      constraints: BoxConstraints(maxHeight: maxHeight),
      decorationBuilder: (context, child) => Material(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        shadowColor: Colors.black.withValues(alpha: .08),
        color: colorScheme.onPrimary,
        elevation: 8,
        type: MaterialType.card,
        clipBehavior: Clip.hardEdge,
        child: child,
      ),
      builder: (context, textCtrl, node) => CommonTextField(
        controller: textCtrl,
        focus: node,
        hint: hint,
        validator: validator,
        suffixIcon: suffixIcon,
        borderRadius: borderRadius,
        borderColor: borderColor,
        fillColor: fillColor,
        keyboardType: TextInputType.text,
      ),
      suggestionsCallback: suggestionsCallback,
      itemBuilder: (context, item) => Container(
        padding: const EdgeInsets.all(12),
        color: colorScheme.onPrimary,
        child: Text(item.toString(), style: const TextStyle(fontSize: 14)),
      ),
      onSelected: (selected) {
        FocusScope.of(context).unfocus();
        onSelected(selected);
      },
    );
  }
}
