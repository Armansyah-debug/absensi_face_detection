import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Lengkap'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4682B4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getAllAbsen(),
        builder: (context, absenSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.getAllIzinCuti(),
            builder: (context, izinSnapshot) {
              if (absenSnapshot.hasError || izinSnapshot.hasError) {
                return Center(child: Text('Error: ${absenSnapshot.error ?? izinSnapshot.error}'));
              }

              if (absenSnapshot.connectionState == ConnectionState.waiting ||
                  izinSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Gabungkan data dari dua koleksi berbeda
              final absenDocs = absenSnapshot.data?.docs ?? [];
              final izinDocs = izinSnapshot.data?.docs ?? [];

              final allDocs = <Map<String, dynamic>>[
                ...absenDocs.map((doc) => {
                      'id': doc.id,
                      'data': doc.data() as Map<String, dynamic>,
                      'type': 'absen',
                    }),
                ...izinDocs.map((doc) => {
                      'id': doc.id,
                      'data': doc.data() as Map<String, dynamic>,
                      'type': 'izin_cuti',
                    }),
              ];

              if (allDocs.isEmpty) {
                return const Center(child: Text('Belum ada data riwayat'));
              }

              // Sort berdasarkan waktu terbaru (Descending)
              allDocs.sort((a, b) {
                final Timestamp? aTime = a['data']['timestamp'] as Timestamp?;
                final Timestamp? bTime = b['data']['timestamp'] as Timestamp?;
                final DateTime aDate = aTime?.toDate() ?? DateTime(1970);
                final DateTime bDate = bTime?.toDate() ?? DateTime(1970);
                return bDate.compareTo(aDate);
              });

              return ListView.builder(
                itemCount: allDocs.length,
                itemBuilder: (context, index) {
                  final item = allDocs[index];
                  final data = item['data'] as Map<String, dynamic>;
                  final String docId = item['id'] as String;
                  final String type = item['type'] as String;
                  final bool isAbsen = type == 'absen';

                  return Dismissible(
                    key: Key(docId),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Hapus Data?"),
                          content: const Text("Data ini akan dihapus permanen dari riwayat."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                    ),
                    onDismissed: (_) async {
                      if (isAbsen) {
                        await FirestoreService.deleteAbsen(docId);
                      } else {
                        await FirestoreService.deleteIzinCuti(docId);
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        // MENAMPILKAN FOTO SELFIE JIKA TYPE ADALAH ABSEN
                        leading: isAbsen 
                          ? Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: data['photo_url'] != null
                                    ? Image.network(data['photo_url'], fit: BoxFit.cover, 
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person))
                                    : const Icon(Icons.person),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.orange[100],
                              radius: 30,
                              child: const Icon(Icons.note_alt, color: Colors.orange),
                            ),
                        title: Text(
                          isAbsen
                              ? '${data['name']} (${data['npm'] ?? '-'})'
                              : '${data['name']} - ${data['jenis']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              data['timestamp'] != null 
                                ? DateFormat('dd MMM yyyy, HH:mm').format((data['timestamp'] as Timestamp).toDate())
                                : '-',
                              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                            ),
                            if (isAbsen) Text('📍 ${data['address'] ?? 'Lokasi...'}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (!isAbsen) Text('📝 Alasan: ${data['alasan']}', maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
