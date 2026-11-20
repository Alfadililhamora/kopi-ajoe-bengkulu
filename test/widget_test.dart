import 'package:flutter_test/flutter_test.dart';
import 'package:kopi_ajoe/app.dart';

void main() {
  testWidgets('Aplikasi bisa dibuka', (WidgetTester tester) async {
    await tester.pumpWidget(const KopiAjoeApp());
    expect(find.text('Masuk'), findsWidgets);
  });
}
