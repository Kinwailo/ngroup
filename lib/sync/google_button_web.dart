import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart';

Widget googleSignInButton() {
  return renderButton(
      configuration: GSIButtonConfiguration(
    theme: GSIButtonTheme.filledBlack,
    shape: GSIButtonShape.pill,
  ));
}

Widget googleSignInCircle() {
  return renderButton(
      configuration: GSIButtonConfiguration(
    type: GSIButtonType.icon,
    shape: GSIButtonShape.pill,
    size: GSIButtonSize.medium,
  ));
}
