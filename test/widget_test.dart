import 'package:flutter_test/flutter_test.dart';
import 'package:shild_constructor/app.dart';

void main() {
  testWidgets('app loads tabs', (tester) async {
    await tester.pumpWidget(const ShildConstructorApp());

    expect(find.text('Shild Constructor'), findsOneWidget);
    expect(find.text('Проект'), findsOneWidget);
    expect(find.text('Смета'), findsOneWidget);
    expect(find.text('Экспорт'), findsOneWidget);
    expect(find.text('Версии'), findsOneWidget);
  });
}
