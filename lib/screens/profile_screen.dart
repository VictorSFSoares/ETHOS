import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart'; // Importante para salvar permanentemente
import 'package:path/path.dart' as p;
import '../services/db_helper.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DBHelper _dbHelper = DBHelper();
  final ImagePicker _picker = ImagePicker();

  String _avatarPath = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Puxa o email de quem fez login
    final email = UserService().currentUserEmail ??
        FirebaseAuth.instance.currentUser?.email;

    if (email != null) {
      final profile = await _dbHelper.getProfile(email);
      if (profile != null && mounted) {
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _emailController.text = email;
          _avatarPath = profile['avatar_path'] ?? '';
        });
      } else {
        setState(() {
          _emailController.text = email;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // 1. Obter a pasta de documentos segura do aplicativo
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(image.path);
      final String savedPath = p.join(directory.path, fileName);

      // 2. Copiar a imagem para o local permanente
      final File localImage = await File(image.path).copy(savedPath);

      setState(() {
        _avatarPath = localImage.path;
      });

      // 3. Salvar o novo caminho permanentemente na base de dados
      _saveProfile(silent: true);
    }
  }

  Future<void> _saveProfile({bool silent = false}) async {
    final email = _emailController.text;
    if (email.isEmpty) return;

    await _dbHelper.updateProfile(email, _nameController.text, _avatarPath);
    UserService().setUser(email, _nameController.text); // Atualiza na memória

    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    UserService().clearUser();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF1A1A1A),
                  backgroundImage:
                      _avatarPath.isNotEmpty && File(_avatarPath).existsSync()
                          ? FileImage(File(_avatarPath))
                          : null,
                  child: _avatarPath.isEmpty || !File(_avatarPath).existsSync()
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Nome Completo', _nameController, Icons.person,
              readOnly: false),
          const SizedBox(height: 16),
          _buildTextField('E-mail (Login)', _emailController, Icons.email,
              readOnly: true),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _saveProfile(),
              child: const Text('Salvar Alterações',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Sair da Conta',
                style: TextStyle(color: Colors.red, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? Colors.grey : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: readOnly ? Colors.transparent : const Color(0xFF4CAF50)),
        ),
      ),
    );
  }
}
