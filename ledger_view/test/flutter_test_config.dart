import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Initialize bindings
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Configure google_fonts to not load fonts during testing
  GoogleFonts.config.allowRuntimeFetching = false;
  
  await testMain();
}
