import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/photo_feed_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  testFirestore();
  runApp(const ProviderScope(child: MyApp()));
}

void testFirestore() async {
  final snapshot = await FirebaseFirestore.instance.collection('photos').get();
  print("Docs fetched: ${snapshot.docs.length}");

  for (var doc in snapshot.docs) {
    print("DOC: ${doc.id} -> ${doc.data()}");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Feed App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PhotoFeedView(),
    );
  }
}
