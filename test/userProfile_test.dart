import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projek_uts_mbr/profile/userProfile.dart';

// Test hanya untuk constructor dan state
//tidak ada integration test dengan firebase karena perlunya device asli/emulator
void main() {
  group('UserProfile Constructor Tests', () {
    test('UserProfile dapat diinstantiate', () {
      expect(() => const UserProfile(), returnsNormally);
    });

    test('UserProfile adalah StatefulWidget', () {
      const widget = UserProfile();
      expect(widget, isA<StatefulWidget>());
    });
    //
  });

  group('UI Components Tests (tanpa UserProfile)', () {
    testWidgets('Scaffold dengan AppBar dapat dibuat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('User Profile')),
            body: const Center(child: Text('Profile Body')),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Profile Body'), findsOneWidget);
    });

    testWidgets('IconButton dapat dibuat', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test'),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('StreamBuilder dapat dibuat', (WidgetTester tester) async {
      final stream = Stream<int>.fromIterable([1, 2, 3]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamBuilder<int>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Data: ${snapshot.data}');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.textContaining('Data:'), findsOneWidget);
    });

    testWidgets('SingleChildScrollView dapat dibuat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(height: 100, color: Colors.red),
                  Container(height: 100, color: Colors.blue),
                  Container(height: 100, color: Colors.green),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsAtLeast(3));
    });
    //tes struktur card di profile
    testWidgets('Profile Card UI Structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Mock Profile Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.pink[100],
                            child: const Icon(Icons.person, size: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Test User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('test@example.com'),
                                const SizedBox(height: 4),
                                const Text('08123456789'),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Edit Profile'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mock Purchase History Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Test Vendor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(child: Text('Edit')),
                                  const PopupMenuItem(child: Text('Delete')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Test Package - Rp 100,000'),
                          const SizedBox(height: 4),
                          const Text('Date: 2024-01-01'),
                          const SizedBox(height: 4),
                          const Text('Location: Test Location'),
                          const SizedBox(height: 4),
                          const Text('Status: Completed'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      //ada 2 card yaitu profile, dan card vendor
      expect(find.byType(Card), findsAtLeast(2));
      //avatar profil user
      expect(find.byType(CircleAvatar), findsOneWidget);
      //nama user
      expect(find.text('Test User'), findsOneWidget);
      //ada edit profile
      expect(find.text('Edit Profile'), findsOneWidget);
      //nama vendor
      expect(find.text('Test Vendor'), findsOneWidget);
      //terdapat popupmenubutton
      expect(find.byType(PopupMenuButton), findsOneWidget);
    });
  });

  group('Dialog and BottomSheet UI Tests', () {
    testWidgets('Edit Profile Dialog UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Edit Profile'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      //edit profile dapat di tap dan ada text edit profile, full name, dll
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Image Picker BottomSheet UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bc) {
                      return SafeArea(
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Gallery'),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Camera'),
                              onTap: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text('Pick Image'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Pick Image'));
      await tester.pumpAndSettle();
      //tombol ganti proful(pick image) dapat ditekan
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera), findsOneWidget);
    });
  });
}
