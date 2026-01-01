import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/firestore_service.dart';

class IzinCutiScreen extends StatefulWidget {
  const IzinCutiScreen({super.key});

  @override
  State<IzinCutiScreen> createState() => _IzinCutiScreenState();
}

class _IzinCutiScreenState extends State<IzinCutiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _npmController = TextEditingController();
  final _alasanController = TextEditingController();
  String _jenis = 'Izin';
  DateTime _mulai = DateTime.now();
  DateTime _akhir = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isMulai) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isMulai ? _mulai : _akhir,
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        if (isMulai)
          _mulai = picked;
        else
          _akhir = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirestoreService.insertIzinCuti(
          name: _nameController.text,
          npm: _npmController.text,
          jenis: _jenis,
          mulai: _mulai,
          akhir: _akhir,
          alasan: _alasanController.text,
        );
        if (mounted) Navigator.pop(context);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izin / Cuti')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama')),
            TextFormField(
                controller: _npmController,
                decoration: const InputDecoration(labelText: 'NPM')),
            DropdownButtonFormField<String>(
              value: _jenis,
              items: ['Izin', 'Cuti', 'Sakit']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _jenis = v!),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text("Mulai: ${DateFormat('dd/MM/yyyy').format(_mulai)}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text("Akhir: ${DateFormat('dd/MM/yyyy').format(_akhir)}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            TextFormField(
                controller: _alasanController,
                decoration: const InputDecoration(labelText: 'Alasan')),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Kirim Pengajuan'),
            )
          ],
        ),
      ),
    );
  }
}
