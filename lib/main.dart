import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cwcxyiyzmrjhtpyfumho.supabase.co',
    anonKey: 'sb_publishable_OugRULWLsW2A1n57o2i4Jg_HWrizKQ2',
  );

  runApp(const KopiAjoeApp());
}
