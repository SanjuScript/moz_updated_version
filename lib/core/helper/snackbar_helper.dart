import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AppSnackBar {
  // ----------- CORE METHOD -----------
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType type,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        color: type == ContentType.success
            ? Theme.of(context).primaryColor
            : null,
        message: message,
        contentType: type,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // ----------- SHORTCUT HELPERS -----------
  static void success(
    BuildContext context,
    String message, {
    String title = "Success",
  }) {
    show(context, title: title, message: message, type: ContentType.success);
  }

  static void error(
    BuildContext context,
    String message, {
    String title = "Error",
  }) {
    show(context, title: title, message: message, type: ContentType.failure);
  }

  static void warning(
    BuildContext context,
    String message, {
    String title = "Warning",
  }) {
    show(context, title: title, message: message, type: ContentType.warning);
  }

  static void info(
    BuildContext context,
    String message, {
    String title = "Info",
  }) {
    show(context, title: title, message: message, type: ContentType.help);
  }
}
