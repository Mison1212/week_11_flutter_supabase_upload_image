import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _publicImageUrl;
  bool _isUploading = false;

  final supabase = Supabase.instance.client;

  Future<void> _pickAndUploadToPublicBucket() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final filePath = 'uploads/$fileName';

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        await supabase.storage.from('bucket_images').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/png'),
        );
      } else {
        final file = File(picked.path);
        await supabase.storage.from('bucket_images').upload(filePath, file);
      }

      final publicUrl =
          supabase.storage.from('bucket_images').getPublicUrl(filePath);
      setState(() {
        _publicImageUrl = publicUrl;
      });
    } catch (e) {
      debugPrint('Error upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Title
            const Text(
              'Upload ke Public Bucket',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Button
            ElevatedButton(
              onPressed: _isUploading ? null : _pickAndUploadToPublicBucket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade200,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Pilih & Upload Gambar',
                style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            // Upload progress
            if (_isUploading) const LinearProgressIndicator(),
            const SizedBox(height: 30),
            // Label
            const Text(
              'Gambar dari Public URL:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            // Image display area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: _publicImageUrl != null
                    ? Image.network(
                        _publicImageUrl!,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text(
                          'Belum ada gambar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // URL display
            if (_publicImageUrl != null) ...[
              SelectableText(
                _publicImageUrl!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
