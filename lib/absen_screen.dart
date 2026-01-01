import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'services/firestore_service.dart';

class AbsenScreen extends StatefulWidget {
  const AbsenScreen({super.key});

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,
      enableLandmarks: true,
    ),
  );

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();

  bool _isProcessing = false;
  String _message = 'Arahkan wajah ke kamera & tekan Absen';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize().then((_) {
      if (mounted) {
        setState(() => _message = 'Siap absen! Tekan tombol di bawah');
      }
    }).catchError((e) {
      if (mounted) setState(() => _message = 'Error camera: $e');
    });
  }

  Future<Map<String, String>> _getLocationAndAddress() async {
    // Cek GPS nyala
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'GPS mati. Nyalakan GPS di pengaturan HP.';

    // Cek izin
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Izin lokasi ditolak.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak permanen. Aktifkan di Settings.';
    }

    // Ambil posisi
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // ANTI FAKE GPS
    if (position.isMocked) {
      throw 'Fake GPS terdeteksi! Absen ditolak. Matikan aplikasi fake location.';
    }

    // Optional: Tolak kalau akurasi jelek
    if (position.accuracy > 20) {
      throw 'Akurasi lokasi kurang bagus (${position.accuracy.toStringAsFixed(0)}m). Cari sinyal lebih baik.';
    }

    // Geocoding alamat
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];
    String address = [
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return {
      'location': '${position.latitude},${position.longitude}',
      'address': address.isEmpty ? 'Lokasi tidak diketahui' : address,
    };
  }

  Future<void> _processAbsen() async {
    if (_nameController.text.trim().isEmpty || _npmController.text.trim().isEmpty) {
      _showSnackBar('Nama dan NPM wajib diisi!');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Ambil lokasi + anti fake GPS
      final locationData = await _getLocationAndAddress();

      // 2. Ambil foto
      final XFile photo = await _controller!.takePicture();

      // 3. Deteksi wajah
      final inputImage = InputImage.fromFilePath(photo.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) throw 'Wajah tidak terdeteksi! Pastikan wajah terlihat jelas.';

      // 4. Upload foto ke Firebase Storage
      final String photoUrl = await FirestoreService.uploadSelfie(
        File(photo.path),
        _npmController.text.trim(),
      );

      // 5. Simpan data ke Firestore
      await FirestoreService.insertAbsen(
        name: _nameController.text.trim(),
        npm: _npmController.text.trim(),
        location: locationData['location']!,
        address: locationData['address']!,
        photoUrl: photoUrl,
      );

      _showSnackBar('Absen berhasil!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absen Selfie'),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade600, width: 8),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _message,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _npmController,
                        decoration: const InputDecoration(
                          labelText: 'NPM',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processAbsen,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Absen Sekarang', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}