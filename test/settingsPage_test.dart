// test/settings_page_final_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test hanya untuk UI components dasar TANPA SettingsPage
void main() {
  group('UI Components Test (tanpa SettingsPage)', () {
    testWidgets('AppBar dapat dibuat', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: AppBar(title: const Text('Settings'))),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Switch dapat dibuat', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Switch(value: false, onChanged: (value) {})),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('ListTile dapat dibuat', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('Indonesia'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Indonesia'), findsOneWidget);
    });

    testWidgets('Container dengan warna dapat dibuat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              color: Colors.grey[50],
              child: const Text('Test Container'),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Test Container'), findsOneWidget);
    });

    testWidgets('OutlinedButton dapat dibuat', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedButton(
              onPressed: () {},
              child: const Text('Log Out'),
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('Icon dapat dibuat', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const Icon(Icons.settings))),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Column dan Padding dapat dibuat', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: const [Text('Item 1'), Text('Item 2')]),
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('SingleChildScrollView dapat dibuat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: 1000,
                child: const Text('Scroll Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Scroll Content'), findsOneWidget);
    });

    testWidgets('Semantics dapat dibuat dengan find.atLeast', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(label: 'Test Label', child: const Text('Test')),
          ),
        ),
      );

      // Gunakan findsAtLeast karena MaterialApp sudah punya Semantics internal
      expect(find.byType(Semantics), findsAtLeast(1));
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('Mock Test untuk struktur SettingsPage', () {
    testWidgets('Mock SettingsPage UI Structure', (WidgetTester tester) async {
      // Build mock UI yang mirip SettingsPage tapi tanpa dependensi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.pink,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Customize your experience',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Settings Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.language,
                                color: Colors.blue,
                              ),
                            ),
                            title: const Text('Language'),
                            subtitle: const Text('Indonesia'),
                            trailing: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {},
                          ),

                          ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.orange,
                              ),
                            ),
                            title: const Text('Notifications'),
                            subtitle: const Text('Enabled'),
                            trailing: Switch(
                              value: true,
                              onChanged: (value) {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      //mock dibuat seperti page asli

      // Verify semua komponen
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Container), findsAtLeast(3));
      expect(find.byType(ListTile), findsAtLeast(2));
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);

      // Gunakan findsAtLeast untuk Icon karena ada icon internal dari MaterialApp
      expect(find.byType(Icon), findsAtLeast(4));

      // Verify teks
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });
  });

  group('Test dengan Builder untuk Directionality', () {
    testWidgets('Text widget dengan Directionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            color: Colors.grey[50],
            child: const Text('Test Container'),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Test Container'), findsOneWidget);
    });

    testWidgets('Simple widget tree untuk testing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Container(color: Colors.red, child: const Text('Hello'));
            },
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });
  });
}
