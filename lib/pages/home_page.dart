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
  bool _isHover = false;

  final supabase = Supabase.instance.client;

  Future<void> _pickAndUploadToPublicBucket() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
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

      setState(() => _publicImageUrl = publicUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Image Upload',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// CARD CONTENT
                Expanded(
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// BUTTON UPLOAD (HOVER)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) => setState(() => _isHover = true),
                            onExit: (_) => setState(() => _isHover = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 50,
                              transform: _isHover
                                  ? (Matrix4.identity())
                                  : Matrix4.identity(),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: _isHover
                                      ? const [
                                          Color(0xFF2575FC),
                                          Color(0xFF6A11CB),
                                        ]
                                      : const [
                                          Color(0xFF6A11CB),
                                          Color(0xFF2575FC),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isUploading
                                    ? null
                                    : _pickAndUploadToPublicBucket,
                                icon: const Icon(Icons.upload, color: Colors.white),
                                label: const Text(
                                  'Pilih & Upload Gambar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (_isUploading)
                            const LinearProgressIndicator(minHeight: 6),

                          const SizedBox(height: 24),

                          const Text(
                            'Preview Gambar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          /// IMAGE PREVIEW
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.grey.shade100,
                              ),
                              child: _publicImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        _publicImageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        'Belum ada gambar',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (_publicImageUrl != null)
                            SelectableText(
                              _publicImageUrl!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
