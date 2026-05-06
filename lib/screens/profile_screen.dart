import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- IMPORTANTE: Para carregar o pt-BR
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

  final User? currentUser = FirebaseAuth.instance.currentUser;

  String _avatarPath = '';
  int _verificationsCount = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializa o formato de datas para Português do Brasil
    initializeDateFormatting('pt_BR', null);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final email = UserService().currentUserEmail ?? currentUser?.email;

    if (email != null) {
      final profile = await _dbHelper.getProfile(email);
      final historyCount = await _dbHelper.getHistoryCount(email);

      if (profile != null && mounted) {
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _emailController.text = email;
          _avatarPath = profile['avatar_path'] ?? '';
          _verificationsCount = historyCount;
        });
      } else {
        setState(() {
          _emailController.text = email;
          _verificationsCount = historyCount;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(image.path);
      final String savedPath = p.join(directory.path, fileName);

      final File localImage = await File(image.path).copy(savedPath);

      setState(() {
        _avatarPath = localImage.path;
      });

      _saveProfile(silent: true);
    }
  }

  Future<void> _saveProfile({bool silent = false}) async {
    final email = _emailController.text;
    if (email.isEmpty) return;

    await _dbHelper.updateProfile(email, _nameController.text, _avatarPath);
    UserService().setUser(email, _nameController.text);

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

  // --- Função com a data 100% em pt-BR ---
  String get _formattedCreationDate {
    if (currentUser?.metadata.creationTime != null) {
      // O 'pt_BR' garante que os meses apareçam como abr, mai, jun, etc.
      return DateFormat("dd 'de' MMM 'de' yyyy", 'pt_BR')
          .format(currentUser!.metadata.creationTime!);
    }
    return 'Desconhecida';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                    'Verificações', '$_verificationsCount', Icons.shield),
                Container(width: 1, height: 40, color: Colors.grey.shade800),
                _buildStatColumn('Membro desde', _formattedCreationDate,
                    Icons.calendar_today),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Nome Completo', _nameController, Icons.badge,
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
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Sair da Conta',
                style: TextStyle(color: Colors.redAccent, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
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
        prefixIcon: Icon(icon,
            color: readOnly ? Colors.grey.shade600 : const Color(0xFF4CAF50)),
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
