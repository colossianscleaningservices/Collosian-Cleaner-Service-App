import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    FontWeight weight = switch (type) {
      TextType.extraBold => fontWeight ?? FontWeight.w800,
      TextType.bold => fontWeight ?? FontWeight.w700,
      TextType.semiBold => fontWeight ?? FontWeight.w600,
      TextType.medium => fontWeight ?? FontWeight.w500,
      TextType.regular => fontWeight ?? FontWeight.w400,
      TextType.light => fontWeight ?? FontWeight.w300
    };

    final style = GoogleFonts.manrope(
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

