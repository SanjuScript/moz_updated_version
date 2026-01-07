import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';

void betaInfo(BuildContext context) {
  AppSnackBar.info(
    context,
    "You are in beta version. This option will available after production ",
  );
}
