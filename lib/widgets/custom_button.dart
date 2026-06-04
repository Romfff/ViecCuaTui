import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color? enabledColor;
  final Color? disabledColor;
  final Color? textColor;
  final double? padding;
  final double? borderRadius;
  final IconData? icon;
  final bool isLoading;
  final FontWeight? fontWeight;
  final double? fontSize;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isEnabled = true,
    this.enabledColor,
    this.disabledColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.icon,
    this.isLoading = false,
    this.fontWeight,
    this.fontSize,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    const kGreenAccent = Color(0xFF0FB488);
    const kTextSub = Color(0xFF8E8E93);

    final buttonColor = isEnabled 
        ? (enabledColor ?? kGreenAccent) 
        : (disabledColor ?? Colors.grey.shade300);
    
    final textButtonColor = isEnabled 
        ? (textColor ?? Colors.white) 
        : kTextSub;

    final button = ElevatedButton.icon(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textButtonColor),
              ),
            )
          : Icon(icon ?? Icons.check, size: 18),
      label: Text(
        label,
        style: TextStyle(
          color: textButtonColor,
          fontWeight: fontWeight ?? FontWeight.w600,
          fontSize: fontSize ?? 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        disabledBackgroundColor: disabledColor ?? Colors.grey.shade300,
        foregroundColor: textButtonColor,
        disabledForegroundColor: kTextSub,
        padding: EdgeInsets.symmetric(vertical: padding ?? 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
        ),
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color? borderColor;
  final Color? textColor;
  final double? padding;
  final double? borderRadius;
  final IconData? icon;
  final bool isLoading;
  final FontWeight? fontWeight;
  final double? fontSize;
  final bool isFullWidth;

  const CustomOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isEnabled = true,
    this.borderColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.icon,
    this.isLoading = false,
    this.fontWeight,
    this.fontSize,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    const kGreenAccent = Color(0xFF0FB488);
    const kTextSub = Color(0xFF8E8E93);

    final color = isEnabled 
        ? (textColor ?? kGreenAccent) 
        : kTextSub;
    
    final border = isEnabled
        ? (borderColor ?? kGreenAccent)
        : Colors.grey.shade300;

    final button = OutlinedButton.icon(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Icon(icon ?? Icons.close, size: 18),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: fontWeight ?? FontWeight.w600,
          fontSize: fontSize ?? 14,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: border, width: 1.5),
        padding: EdgeInsets.symmetric(vertical: padding ?? 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
        ),
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
