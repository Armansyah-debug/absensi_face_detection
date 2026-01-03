import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
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
  Future<void>? _initializeControllerFuture;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
  );

  bool _isProcessing = false;
  String _message = 'Memuat kamera...';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(frontCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();

      await _initializeControllerFuture;

      if (mounted) {
        setState(() => _message = 'Arahkan wajah & tekan absen');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Gagal memuat kamera: $e');
      }
    }
  }

  Future<Map<String, String>> _getLocationInfo() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'GPS mati. Nyalakan GPS.';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw 'Izin lokasi ditolak.';
    }
    if (permission == LocationPermission.deniedForever) throw 'Izin lokasi ditolak permanen.';

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if (position.isMocked) throw 'Fake GPS terdeteksi! Absen ditolak.';

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    String address = '${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}'.trim();
    if (address.startsWith(',') || address.endsWith(',')) address = address.replaceAll(',', '').trim();

    return {
      'location': '${position.latitude}, ${position.longitude}',
      'address': address.isEmpty ? 'Lokasi tidak diketahui' : address,
    };
  }

  Future<void> _processImage() async {
    if (_isProcessing || !mounted) return;
    setState(() => _isProcessing = true);

    try {
      final XFile image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) throw 'Wajah tidak terdeteksi. Coba lagi';

      final nameController = TextEditingController();
      final npmController = TextEditingController();

      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Masukkan Data Absen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Nama Lengkap'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: npmController,
                decoration: const InputDecoration(hintText: 'NPM'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final npm = npmController.text.trim();
                if (name.isNotEmpty && npm.isNotEmpty) {
                  Navigator.pop(context, {'name': name, 'npm': npm});
                }
              },
              child: const Text('Absen'),
            ),
          ],
        ),
      );

      if (result == null) {
        setState(() => _message = 'Absen dibatalkan');
        _isProcessing = false;
        return;
      }

      final locationInfo = await _getLocationInfo();
      await FirestoreService.insertAbsen(
        name: result['name']!,
        npm: result['npm']!,
        location: locationInfo['location']!,
        address: locationInfo['address']!,
      );

      setState(() {
        _message = '${result['name']} (${result['npm']}) absen berhasil!\n${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}\nLokasi: ${locationInfo['address']}';
      });
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absen Wajah')),
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
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.black.withOpacity(0.7),
                  child: Text(_message, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(_isProcessing ? 'Memproses...' : 'Absen Sekarang', style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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