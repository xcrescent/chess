import 'package:flutter/material.dart';
import 'package:chess/app/app.dart';
import 'package:chess/bootstrap.dart';

/// This entry point should be used for production only
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ///You can override your environment variable in bootstrap method here for providers
  bootstrap(() => const App());
}
