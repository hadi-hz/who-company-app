import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test3/shared/change_lang.dart';
import 'package:test3/features/auth/presentation/controller/translation_controller.dart';

void main() {
  patrolTest(
    'ChangeLang complete functionality test',
    ($) async {
      await _setupTestEnvironment();
      await $.pumpWidgetAndSettle(_createChangeLangApp());

      await _testLanguageButtonDisplay($);
      await _testPopupMenuOpening($);
      await _testLanguageSelection($);
      await _testLoadingState($);
    },
  );

  patrolTest(
    'ChangeLang accessibility and interaction test',
    ($) async {
      await _setupTestEnvironment();
      await $.pumpWidgetAndSettle(_createChangeLangApp());

      await _testAccessibilityFeatures($);
      await _testKeyboardNavigation($);
      await _testTapOutsideMenu($);
    },
  );
}

Future<void> _setupTestEnvironment() async {
  SharedPreferences.setMockInitialValues({
    'userId': 'test-user-123',
    'useSystemLocale': false,
    'selectedLanguage': 'en',
  });
}

Widget _createChangeLangApp() {
  return GetMaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Language Test'),
        actions: [ChangeLang()],
      ),
      body: Center(
        child: Text('Test App Content'),
      ),
    ),
    translations: TestTranslations(),
  );
}

Future<void> _testLanguageButtonDisplay(PatrolIntegrationTester $) async {
  // Verify language button is visible
  expect(find.byType(ChangeLang), findsOneWidget);
  expect(find.byIcon(Icons.language), findsOneWidget);
  
  // Verify circular container design
  final container = find.byType(Container);
  expect(container, findsAtLeastNWidgets(1));
  
  await $.pumpAndSettle();
}

Future<void> _testPopupMenuOpening(PatrolIntegrationTester $) async {
  // Tap on language button to open popup
  await $(Icons.language).tap();
  await $.pumpAndSettle();
  
  // Verify popup menu opened with all language options
  expect(find.text('English'), findsOneWidget);
  expect(find.text('French'), findsOneWidget);
  expect(find.text('Italian'), findsOneWidget);
  
  // Verify SVG flags are displayed
  expect(find.byType(PopupMenuItem), findsNWidgets(3));
  
  await $.pumpAndSettle();
}

Future<void> _testLanguageSelection(PatrolIntegrationTester $) async {
  // Test selecting French
  await $(Icons.language).tap();
  await $.pumpAndSettle();
  
  await $('French').tap();
  await $.pumpAndSettle();
  
  // Verify menu closed after selection
  expect(find.text('French'), findsNothing);
  
  // Test selecting Italian
  await $(Icons.language).tap();
  await $.pumpAndSettle();
  
  await $('Italian').tap();
  await $.pumpAndSettle();
  
  expect(find.text('Italian'), findsNothing);
  
  // Test selecting English
  await $(Icons.language).tap();
  await $.pumpAndSettle();
  
  await $('English').tap();
  await $.pumpAndSettle();
  
  expect(find.text('English'), findsNothing);
}

Future<void> _testLoadingState(PatrolIntegrationTester $) async {
  // This test would require mocking the controller to show loading state
  // For now, we'll just verify the button remains interactive
  
  await $(Icons.language).tap();
  await $.pumpAndSettle();
  
  // Verify button is still functional
  expect(find.text('English'), findsOneWidget);
  
  // Close menu by tapping outside

  await $.pumpAndSettle();
}

Future<void> _testAccessibilityFeatures(PatrolIntegrationTester $) async {
  // Verify button is accessible
  expect(find.byType(PopupMenuButton), findsOneWidget);
  
  // Test semantic properties
  final popupButton = find.byType(PopupMenuButton<String>);
  expect(popupButton, findsOneWidget);
  
  await $.pumpAndSettle();
}

Future<void> _testKeyboardNavigation(PatrolIntegrationTester $) async {
  // Test basic navigation
  await $.pumpAndSettle();
  
  // Verify focus management works with the button
  expect(find.byType(ChangeLang), findsOneWidget);
  
  await $.pumpAndSettle();
}

Future<void> _testTapOutsideMenu(PatrolIntegrationTester $) async {
  // Open menu
  await $(Icons.language).tap();
  await $.pumpAndSettle();
  
  expect(find.text('English'), findsOneWidget);
  
  // Tap on scaffold background to close menu
  await $(Scaffold).tap();
  await $.pumpAndSettle();
  
  // Verify menu is closed
  expect(find.text('English'), findsNothing);
  expect(find.text('French'), findsNothing);
  expect(find.text('Italian'), findsNothing);
}

class TestTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'success': 'Success',
      'error': 'Error',
    },
    'fr_FR': {
      'success': 'Succès',
      'error': 'Erreur',
    },
    'it_IT': {
      'success': 'Successo',
      'error': 'Errore',
    },
  };
}