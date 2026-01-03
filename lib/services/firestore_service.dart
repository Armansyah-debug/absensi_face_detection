import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Koleksi
  static CollectionReference get absenCollection => _firestore.collection('absen');
  static CollectionReference get izinCutiCollection => _firestore.collection('izin_cuti');

  // Upload Foto Selfie ke Storage
  static Future<String> uploadSelfie(File imageFile, String npm) async {
    try {
      String fileName = 'selfie_${npm}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('absensi_selfie/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error Upload Selfie: $e");
      return '';  // Kalo error, return empty string
    }
  }

  // Insert Absen (dengan photoUrl)
  static Future<void> insertAbsen({
    required String name,
    required String npm,
    required String location,
    required String address,
    String photoUrl = '',  // Default empty kalo gak ada foto
  }) async {
    await absenCollection.add({
      'name': name,
      'npm': npm,
      'location': location,
      'address': address,
      'photo_url': photoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Insert Izin/Cuti/Sakit
  static Future<void> insertIzinCuti({
    required String name,
    required String npm,
    required String jenis,
    required DateTime mulai,
    required DateTime akhir,
    required String alasan,
  }) async {
    await izinCutiCollection.add({
      'name': name,
      'npm': npm,
      'jenis': jenis,
      'tanggal_mulai': Timestamp.fromDate(mulai),
      'tanggal_akhir': Timestamp.fromDate(akhir),
      'alasan': alasan,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream untuk Riwayat Realtime
  static Stream<QuerySnapshot> getAllAbsen() {
    return absenCollection.orderBy('timestamp', descending: true).snapshots();
  }

  static Stream<QuerySnapshot> getAllIzinCuti() {
    return izinCutiCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Hapus Data
  static Future<void> deleteAbsen(String docId) async {
    await absenCollection.doc(docId).delete();
  }

  static Future<void> deleteIzinCuti(String docId) async {
    await izinCutiCollection.doc(docId).delete();
  }
}