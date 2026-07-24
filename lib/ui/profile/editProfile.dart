import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../models/user.dart';
import '../../repositories/storage/storage_service.dart';

/// Trang chỉnh sửa thông tin cá nhân
/// Cho phép user thay đổi tên và avatar
class EditProfile extends StatefulWidget {
  final auth.User user;

  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState(user);
}

class _EditProfileState extends State<EditProfile> {
  auth.User user;
  _EditProfileState(this.user);

  final TextEditingController _usernameController = TextEditingController();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (user.displayName != null) {
      _usernameController.text = user.displayName!;
    }
  }

  /// Chọn ảnh từ gallery hoặc camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Upload ngay sau khi chọn
        await _uploadAvatar();
      }
    } catch (e) {
      _showErrorDialog('Lỗi chọn ảnh: $e');
    }
  }

  /// Upload avatar lên Firebase Storage
  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final downloadUrl = await _storageService.uploadAvatar(_selectedImage!);

      if (downloadUrl != null && mounted) {
        // Cập nhật user photoURL trong Firebase Auth
        await user.updatePhotoURL(downloadUrl);
        await user.reload();

        setState(() {
          user = auth.FirebaseAuth.instance.currentUser!;
          _isUploading = false;
        });

        _showSuccessSnackBar('Đã cập nhật avatar!');
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorDialog('Lỗi upload ảnh: $e');
    }
  }

  /// Lưu thông tin profile
  Future<void> _saveProfile() async {
    if (_usernameController.text.isEmpty) {
      _showErrorDialog('Vui lòng nhập tên');
      return;
    }

    try {
      User editUser = User(
        uid: user.uid,
        name: _usernameController.text,
        email: user.email.toString(),
        proPicUrl: user.photoURL ?? '',
      );

      // Cập nhật displayName trong Firebase Auth
      await user.updateDisplayName(_usernameController.text);

      // Cập nhật trong Firestore qua Bloc
      if (mounted) {
        BlocProvider.of<userBloc>(context).add(editProfile(editUser));
        _showSuccessSnackBar('Đã lưu thông tin!');

        // Quay lại trang trước
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorDialog('Lỗi lưu thông tin: $e');
    }
  }

  /// Hiển thị dialog chọn nguồn ảnh
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        backgroundColor: const Color.fromARGB(255, 10, 124, 132),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : const NetworkImage(
                                  "https://cdn-icons-png.flaticon.com/64/3177/3177440.png"))
                          as ImageProvider,
                    ),
                  ),
                  if (_isUploading)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 10, 124, 132),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),

              // Username field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Tên hiển thị',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20.0),

              // Email field (read-only)
              TextField(
                controller: TextEditingController(text: user.email),
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 40.0),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 10, 124, 132),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Lưu thông tin',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
