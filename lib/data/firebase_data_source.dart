import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/photo.dart';

class FirebaseDataSource {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Photo> uploadPhoto(Photo file) async {
    try {
      print('Starting photo upload...');
      String fileName = file.path.split('/').last;
      Reference ref = storage.ref().child('photos/$fileName');

      print('Uploading to Firebase Storage...');
      UploadTask uploadTask = ref.putFile(File(file.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Upload successful! URL: $downloadUrl');

      // Save photo metadata to Firestore
      print('Saving to Firestore...');
      DocumentReference docRef = await firestore.collection('photos').add({
        'url': downloadUrl,
        'position': file.location != null
            ? {
                'latitude': file.location!.latitude,
                'longitude': file.location!.longitude,
              }
            : null,
        'timetaken': file.timestamp,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'caption': file.caption ?? '',
      });
      print('Firestore save successful! Doc ID: ${docRef.id}');

      return Photo(
        id: docRef.id,
        url: downloadUrl,
        path: file.path,
        timestamp: DateTime.now(),
        caption: file.caption,
        location: file.location,
      );
    } catch (e, stackTrace) {
      print('Error uploading photo: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> uploadPhotos(List<Photo> photos) async {
    for (var photo in photos) {
      await uploadPhoto(photo);
    }
  }

  // Function that fetches photos from Firestore and downloads them
  Future<List<Photo>> fetchPhotos() async {
    try {
      print('Starting to fetch photos from Firestore...');

      final snapshot = await firestore
          .collection('photos')
          .orderBy('timestamp', descending: true)
          .get();

      print('Fetched ${snapshot.docs.length} photos from Firestore');

      final List<Photo> photos = [];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          print(
            'Processing photo doc ${doc.id}: ${data['caption'] ?? 'no caption'}',
          );

          // Validate required fields
          if (data['url'] == null) {
            print('Warning: Photo ${doc.id} has no URL, skipping');
            continue;
          }

          photos.add(
            Photo(
              id: doc.id,
              url: data['url'],
              path: data['path'] ?? '',
              timestamp: data['timetaken'] != null
                  ? (data['timetaken'] is Timestamp
                        ? (data['timetaken'] as Timestamp).toDate()
                        : DateTime.parse(data['timetaken']))
                  : (data['timestamp'] as Timestamp).toDate(),
              caption: data['caption'] ?? '',
              location: data['position'] != null
                  ? Position(
                      latitude: data['position']['latitude'],
                      longitude: data['position']['longitude'],
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      altitudeAccuracy: 0,
                      heading: 0,
                      headingAccuracy: 0,
                      speed: 0,
                      speedAccuracy: 0,
                    )
                  : null,
            ),
          );
        } catch (e) {
          print('Error processing photo ${doc.id}: $e');
          // Continue processing other photos
        }
      }

      print('Successfully processed ${photos.length} photos');
      return photos;
    } catch (e, stackTrace) {
      print('Error fetching photos from Firestore: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Delete photo from Firestore and Storage
  Future<void> deletePhoto(String photoId, String photoUrl) async {
    // Delete from Firestore
    await firestore.collection('photos').doc(photoId).delete();

    // Delete from Storage
    try {
      final ref = storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file from storage: $e');
      // Continue even if storage deletion fails
    }
  }

  // Update photo caption in Firestore
  Future<void> updatePhotoCaption(String photoId, String caption) async {
    await firestore.collection('photos').doc(photoId).update({
      'caption': caption,
    });
  }
}
