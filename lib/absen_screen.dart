import 'package:absensi_face_detection/services/firestore_service.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AbsenScreen extends StatefulWidget {
  const AbsenScreen({super.key});

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();
  late FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
  }

  // --- FUNGSI BARU: CEK & MINTA IZIN LOKASI ---
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('GPS kamu mati. Silakan nyalakan GPS di pengaturan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak. Aplikasi butuh lokasi untuk absen.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak permanen. Tolong aktifkan manual di Settings HP.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    setState(() => _isInitialized = true);
  }

  Future<void> _processAbsen() async {
    if (_nameController.text.isEmpty || _npmController.text.isEmpty) {
      _showMsg('Nama & NPM tidak boleh kosong');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Ambil Lokasi DULU (Biar kalau error izin, proses berhenti di sini)
      Position pos = await _determinePosition();

      // 2. Ambil Foto
      XFile photo = await _cameraController!.takePicture();
      File file = File(photo.path);

      // 3. Cek Wajah
      final inputImage = InputImage.fromFile(file);
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) throw 'Wajah tidak terdeteksi!';

      // 4. Ambil Alamat (Geocoding)
      List<Placemark> pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      String addr = "${pm.first.street}, ${pm.first.locality}";

      // 5. Upload & Simpan
      String url = await FirestoreService.uploadSelfie(file, _npmController.text);
      await FirestoreService.insertAbsen(
        name: _nameController.text,
        npm: _npmController.text,
        location: "${pos.latitude}, ${pos.longitude}",
        address: addr,
        photoUrl: url,
      );

      _showMsg('Absen Berhasil!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showMsg(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showMsg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kamera Absen')),
      body: !_isInitialized 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama')),
                TextField(controller: _npmController, decoration: const InputDecoration(labelText: 'NPM')),
                const SizedBox(height: 20),
                _isProcessing 
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _processAbsen, 
                      child: const Text('Kirim Absen'),
                    ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}
