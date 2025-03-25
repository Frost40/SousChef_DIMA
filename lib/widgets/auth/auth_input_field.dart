import 'package:flutter/material.dart';
    import 'package:flutter_svg/svg.dart';

    class AuthInputField extends StatefulWidget {
      final String hintText;
      final TextEditingController textEditingController;
      final bool isPassword;
      final String? leftIconPath;
      final IconData? leftIcon;
      final Color? iconColor;

      const AuthInputField({
        required this.textEditingController,
        required this.hintText,
        this.isPassword = false,
        this.leftIconPath,
        this.leftIcon,
        this.iconColor,
        super.key,
      });

      @override
      State<AuthInputField> createState() => _AuthInputFieldState();
    }

    class _AuthInputFieldState extends State<AuthInputField> {
      bool pwdVisibility = false;

      @override
      Widget build(BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: TextFormField(
            controller: widget.textEditingController,
            obscureText: widget.isPassword && !pwdVisibility,
            decoration: InputDecoration(
              hintText: widget.hintText,
              enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          prefixIcon: _buildPrefixIcon(),
          suffixIcon: widget.isPassword
              ? InkWell(
                  onTap: () => setState(() => pwdVisibility = !pwdVisibility),
                  child: Icon(
                    pwdVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                )
              : null,
        ),
        validator: (val) {
          if (val!.isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    // Use icon if provided
    if (widget.leftIcon != null) {
      return Icon(
        widget.leftIcon,
        color: widget.iconColor ?? Theme.of(context).colorScheme.primary,
        size: 20,
      );
    }
    // Otherwise use SVG if provided
    else if (widget.leftIconPath != null) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          widget.leftIconPath!,
          height: 20,
          width: 20,
        ),
      );
    }
    return null;
  }
}