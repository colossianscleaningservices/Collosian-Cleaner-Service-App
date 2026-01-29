import 'package:flutter/material.dart';

import '../../utils/extension.dart';

enum TextType { extraBold, bold, semiBold, medium, regular, light }

class CommonText extends StatelessWidget {
  const CommonText._(
    this.text, {
    required this.type,
    super.key,
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.letterSpacing,
    this.onTap,
    this.isUnderLine = false,
    this.fontWeight,
  });

  const CommonText.extraBold(
    String text, {
    Key? key,
    double size = 14,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isItalic = false,
    double? letterSpacing,
    VoidCallback? onTap,
    bool isUnderLine = false,
    FontWeight? fontWeight,
  }) : this._(
          text,
          type: TextType.extraBold,
          key: key,
          size: size,
          color: color,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          isItalic: isItalic,
          letterSpacing: letterSpacing,
          onTap: onTap,
          isUnderLine: isUnderLine,
          fontWeight: fontWeight,
        );

  const CommonText.bold(
    String text, {
    Key? key,
    double size = 14,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isItalic = false,
    double? letterSpacing,
    VoidCallback? onTap,
    bool isUnderLine = false,
    FontWeight? fontWeight,
  }) : this._(
          text,
          type: TextType.bold,
          key: key,
          size: size,
          color: color,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          isItalic: isItalic,
          letterSpacing: letterSpacing,
          onTap: onTap,
          isUnderLine: isUnderLine,
          fontWeight: fontWeight,
        );

  const CommonText.semiBold(
    String text, {
    Key? key,
    double size = 14,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isItalic = false,
    double? letterSpacing,
    VoidCallback? onTap,
    bool isUnderLine = false,
    FontWeight? fontWeight,
  }) : this._(
          text,
          type: TextType.semiBold,
          key: key,
          size: size,
          color: color,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          isItalic: isItalic,
          letterSpacing: letterSpacing,
          onTap: onTap,
          isUnderLine: isUnderLine,
          fontWeight: fontWeight,
        );

  const CommonText.medium(
    String text, {
    Key? key,
    double size = 14,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isItalic = false,
    double? letterSpacing,
    VoidCallback? onTap,
    bool isUnderLine = false,
    FontWeight? fontWeight,
  }) : this._(
          text,
          type: TextType.medium,
          key: key,
          size: size,
          color: color,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          isItalic: isItalic,
          letterSpacing: letterSpacing,
          onTap: onTap,
          isUnderLine: isUnderLine,
          fontWeight: fontWeight,
        );

  const CommonText.regular(
    String text, {
    Key? key,
    double size = 14,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isItalic = false,
    double? letterSpacing,
    VoidCallback? onTap,
    bool isUnderLine = false,
    FontWeight? fontWeight,
  }) : this._(
          text,
          type: TextType.regular,
          key: key,
          size: size,
          color: color,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          isItalic: isItalic,
          letterSpacing: letterSpacing,
          onTap: onTap,
          isUnderLine: isUnderLine,
          fontWeight: fontWeight,
        );

  const CommonText.light(
    String text, {
    Key? key,
    double size = 14,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isItalic = false,
    double? letterSpacing,
    VoidCallback? onTap,
    bool isUnderLine = false,
    FontWeight? fontWeight,
  }) : this._(
          text,
          type: TextType.light,
          key: key,
          size: size,
          color: color,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          isItalic: isItalic,
          letterSpacing: letterSpacing,
          onTap: onTap,
          isUnderLine: isUnderLine,
          fontWeight: fontWeight,
        );

  final String text;
  final TextType type;
  final double size;
  final Color? color;
  final int? maxLines;
  final bool isItalic;
  final bool isUnderLine;
  final VoidCallback? onTap;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    FontWeight weight;
    switch (type) {
      case TextType.extraBold:
        weight = fontWeight ?? FontWeight.w800;
        break;
      case TextType.bold:
        weight = fontWeight ?? FontWeight.w700;
        break;
      case TextType.semiBold:
        weight = fontWeight ?? FontWeight.w600;
        break;
      case TextType.medium:
        weight = fontWeight ?? FontWeight.w500;
        break;
      case TextType.regular:
        weight = fontWeight ?? FontWeight.w400;
        break;
      case TextType.light:
        weight = fontWeight ?? FontWeight.w300;
        break;
    }

    final style = TextStyle(
      color: color ?? context.colorScheme.onSurface,
      fontSize: size,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      fontWeight: weight,
      letterSpacing: letterSpacing ?? 0.15,
      decoration: isUnderLine ? TextDecoration.underline : null,
      height: 1.35,
    );

    final textWidget = Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: style,
    );

    if (onTap == null) return textWidget;

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: textWidget,
      ),
    );
  }
}
