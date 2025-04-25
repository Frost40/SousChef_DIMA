import 'package:flutter/material.dart';

class CustomAlertDialog {
  /// Access the current theme's color scheme more easily
  static late ColorScheme _colorScheme;

  /// Shows a confirmation dialog with yes/no options
  /// Returns true if 'Yes' is selected, false otherwise
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    Color? confirmColor,
    Widget? icon,
  }) async {
    // Set the color scheme for easy access
    _colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Default value is false (represents "No")
    bool result = false;
    
    await showDialog(
      context: context,
      barrierDismissible: true, // Dismiss when tapping outside
      barrierColor: Colors.black54, // Semi-transparent barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(width: 10),
              ],
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isDarkMode ? BorderSide(
              color: _colorScheme.surfaceContainerHighest,
              width: 2.0,
            ) : BorderSide.none,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // No action needed as result remains false
              },
              child: Text(
                cancelText,
                style: TextStyle(
                  color: _colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                result = true;
                Navigator.of(context).pop();
              },
              child: Text(
                confirmText,
                style: TextStyle(
                  color: confirmColor ?? _colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    // Return result - true if confirmed, false if canceled or dismissed
    return result;
  }
  
  /// Shows a simple information alert dialog with a single button
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    Widget? icon,
  }) async {
    // Set the color scheme for easy access
    _colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(width: 10),
              ],
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isDarkMode ? BorderSide(
              color: _colorScheme.surfaceContainerHighest,
              width: 2.0,
            ) : BorderSide.none,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                buttonText,
                style: TextStyle(
                  color: _colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
