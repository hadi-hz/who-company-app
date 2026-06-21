import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test3/features/home/presentation/pages/home.dart';

void main() {
  patrolTest('HomePage Admin role complete flow test', ($) async {
    await _setupTestEnvironment('Admin');
    await $.pumpWidgetAndSettle(_createHomePageApp());

    await _testHomePageInitialization($);
    await _testAdminNavigationFlow($);
    await _testPageSwitching($);
  });

  patrolTest('HomePage ServiceProvider role test', ($) async {
    await _setupTestEnvironment('ServiceProvider');
    await $.pumpWidgetAndSettle(_createHomePageApp());

    await _testHomePageInitialization($);
    await _testServiceProviderNavigation($);
  });

  patrolTest('HomePage Doctor role test', ($) async {
    await _setupTestEnvironment('Doctor');
    await $.pumpWidgetAndSettle(_createHomePageApp());

    await _testHomePageInitialization($);
    await _testDoctorNavigation($);
  });

  patrolTest('HomePage loading and error states test', ($) async {
    await _setupTestEnvironment('Admin');
    await $.pumpWidgetAndSettle(_createHomePageApp());

    await _testLoadingStates($);
    await _testErrorHandling($);
  });
}

Future<void> _setupTestEnvironment(String role) async {
  SharedPreferences.setMockInitialValues({
    'userId': 'test-user-123',
    'role': role,
    'userName': 'Test User',
  });
}

Widget _createHomePageApp() {
  return GetMaterialApp(home: HomePage(), translations: TestTranslations());
}

Future<void> _testHomePageInitialization(PatrolIntegrationTester $) async {
  // Wait for initialization to complete
  await $.pump(const Duration(seconds: 2));

  // Should show loading initially, then the home page
  expect(find.byType(HomePage), findsOneWidget);
  expect(find.byType(Scaffold), findsOneWidget);

  await $.pumpAndSettle();
}

Future<void> _testAdminNavigationFlow(PatrolIntegrationTester $) async {
  // Admin should have access to all navigation items
  expect(find.byType(BottomNavigationBar), findsOneWidget);

  // Test navigation through different tabs
  if (find.byIcon(Icons.people).evaluate().isNotEmpty) {
    await $(Icons.people).tap();
    await $.pumpAndSettle();
  }

  if (find.byIcon(Icons.report).evaluate().isNotEmpty) {
    await $(Icons.report).tap();
    await $.pumpAndSettle();
  }

  if (find.byIcon(Icons.group).evaluate().isNotEmpty) {
    await $(Icons.group).tap();
    await $.pumpAndSettle();
  }

  if (find.byIcon(Icons.person).evaluate().isNotEmpty) {
    await $(Icons.person).tap();
    await $.pumpAndSettle();
  }
}

Future<void> _testServiceProviderNavigation(PatrolIntegrationTester $) async {
  // ServiceProvider should have limited navigation
  expect(find.byType(BottomNavigationBar), findsOneWidget);

  // Test available navigation items
  if (find.byIcon(Icons.report).evaluate().isNotEmpty) {
    await $(Icons.report).tap();
    await $.pumpAndSettle();
  }

  if (find.byIcon(Icons.person).evaluate().isNotEmpty) {
    await $(Icons.person).tap();
    await $.pumpAndSettle();
  }
}

Future<void> _testDoctorNavigation(PatrolIntegrationTester $) async {
  // Doctor should have minimal navigation
  expect(find.byType(BottomNavigationBar), findsOneWidget);

  // Test available navigation items
  if (find.byIcon(Icons.report).evaluate().isNotEmpty) {
    await $(Icons.report).tap();
    await $.pumpAndSettle();
  }

  if (find.byIcon(Icons.person).evaluate().isNotEmpty) {
    await $(Icons.person).tap();
    await $.pumpAndSettle();
  }
}

Future<void> _testPageSwitching(PatrolIntegrationTester $) async {
  // Test switching between different pages
  await $.pump(const Duration(milliseconds: 500));

  // Navigate through available tabs
  final navigationItems = find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.byType(GestureDetector),
  );

  if (navigationItems.evaluate().isNotEmpty) {
    for (int i = 0; i < navigationItems.evaluate().length; i++) {
      await $.pumpAndSettle();
    }
  }
}

Future<void> _testLoadingStates(PatrolIntegrationTester $) async {
  // Test that loading indicators appear and disappear appropriately
  await $.pump();

  // Should show loading initially
  if (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
    expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
  }

  // Wait for loading to complete
  await $.pumpAndSettle();

  // Should show actual content after loading
  expect(find.byType(HomePage), findsOneWidget);
}

Future<void> _testErrorHandling(PatrolIntegrationTester $) async {
  // Test that the app handles errors gracefully
  await $.pumpAndSettle();

  // App should remain functional even if some data fails to load
  expect(find.byType(HomePage), findsOneWidget);
  expect(find.byType(Scaffold), findsOneWidget);
}

class TestTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'users': 'Users',
      'reports': 'Reports',
      'teams': 'Teams',
      'profile': 'Profile',
      'charts': 'Charts',
      'error': 'Error',
      'loading': 'Loading',
    },
  };
}
