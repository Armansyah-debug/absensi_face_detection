import 'package:flutter/material.dart';
import 'absen_screen.dart';
import 'izin_cuti_screen.dart';
import 'riwayat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Wajah'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.0,
          children: [
            _menuCard(
              context,
              title: 'Absen\nWajah',
              icon: Icons.camera_alt,
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AbsenScreen())),
            ),
            _menuCard(
              context,
              title: 'Izin / Cuti /\nSakit',
              icon: Icons.note_add,
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IzinCutiScreen())),
            ),
            _menuCard(
              context,
              title: 'Riwayat',
              icon: Icons.history,
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}