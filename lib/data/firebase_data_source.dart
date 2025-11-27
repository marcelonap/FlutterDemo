import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocode/geocode.dart';
import '../models/photo.dart';
import 'weather_api_service.dart';

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

  // Function that relates fetched photos to firestore photo model
  Future<List<Photo>> fetchPhotos() async {
    try {
      print('Fetching photos from Firestore...');
      final snapshot = await firestore
          .collection('photos')
          .orderBy('timestamp', descending: true)
          .get();

      final List<Photo> photos = [];

      print("Found ${snapshot.docs.length} photos in Firestore");

      for (final doc in snapshot.docs) {
        final data = doc.data();
        print(
          "Photo ${doc.id}: url=${data['url']}, caption=${data['caption']}",
        );

        // Convert Firestore Timestamp to DateTime
        DateTime photoTimestamp;
        if (data['timetaken'] != null) {
          final timetaken = data['timetaken'];
          photoTimestamp = timetaken is Timestamp
              ? timetaken.toDate()
              : timetaken as DateTime;
        } else {
          final timestamp = data['timestamp'];
          photoTimestamp = timestamp is Timestamp
              ? timestamp.toDate()
              : timestamp as DateTime;
        }
        Address? address;
        String? weather;
        if (data['position'] != null) {
          final geoCode = GeoCode();
          address = await geoCode.reverseGeocoding(
            latitude: data['position']['latitude'],
            longitude: data['position']['longitude'],
          );
          weather = await WeatherApiService.instance.fetchWeatherWithArguments(
            lat: data['position']['latitude'].toString(),
            lon: data['position']['longitude'].toString(),
            time: photoTimestamp,
          );
        }

        photos.add(
          Photo(
            id: doc.id,
            url: data['url'],
            path: data['path'] ?? '',
            timestamp: photoTimestamp,
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
            address: address,
            weather: weather,
          ),
        );
      }
      print('Successfully fetched ${photos.length} photos from Firebase');
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
