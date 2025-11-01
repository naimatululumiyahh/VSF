import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  String? _imagePath;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.userType == UserType.individual ? widget.user.fullName : widget.user.organizationName);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _bioCtrl = TextEditingController(text: widget.user.bio ?? '');
    _imagePath = widget.user.profileImagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file != null) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final imagesDir = Directory('${appDir.path}/vsf_images');
          if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          final saved = await File(file.path).copy('${imagesDir.path}/$fileName');
          setState(() {
            _imagePath = saved.path;
          });
        } catch (e) {
          setState(() {
            _imagePath = file.path;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memilih gambar')));
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.user.userType == UserType.individual) {
        widget.user.updateProfile(fullName: name, phone: phone.isEmpty ? null : phone, bio: bio.isEmpty ? null : bio, profileImagePath: _imagePath);
      } else {
        widget.user.updateProfile(organizationName: name, phone: phone.isEmpty ? null : phone, bio: bio.isEmpty ? null : bio, profileImagePath: _imagePath);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil disimpan')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan profil')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrg = widget.user.isOrganization;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.blue[50],
                    backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) as ImageProvider : null,
                    child: _imagePath == null
                        ? Text(
                            widget.user.initials,
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isOrg ? 'Nama Organisasi' : 'Nama Lengkap',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: isOrg ? 'Nama organisasi' : 'Nama lengkap',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Nomor Telepon',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '0812xxxx',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Bio',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Cerita singkat tentang Anda atau organisasi',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 20),

            CustomButton(
              text: 'Simpan',
              isLoading: _isSaving,
              icon: Icons.save,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
