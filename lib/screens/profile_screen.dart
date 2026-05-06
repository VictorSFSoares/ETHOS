import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart'; // Necessário para formatar a data
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
  int _verificationsCount = 0; // Quantidade de checagens

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final email = UserService().currentUserEmail ?? currentUser?.email;

    if (email != null) {
      final profile = await _dbHelper.getProfile(email);

      // Busca a quantidade de histórico/verificações no banco (se você já tiver essa tabela)
      // Substitua 'history' pelo nome da sua tabela se for diferente
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

  // --- Função para buscar e formatar a data de criação do Firebase ---
  String get _formattedCreationDate {
    if (currentUser?.metadata.creationTime != null) {
      // Formata a data para algo como "15 Abr 2026"
      return DateFormat('dd MMM yyyy')
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
          // ---- ZONA DA FOTO DE PERFIL ----
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

          // ---- PAINEL DE ESTATÍSTICAS (NOVO) ----
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
                Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade800), // Linha divisória
                _buildStatColumn('Membro desde', _formattedCreationDate,
                    Icons.calendar_today),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ---- CAMPOS DE DADOS ----
          _buildTextField('Nome Completo', _nameController, Icons.badge,
              readOnly: false),
          const SizedBox(height: 16),
          _buildTextField('E-mail (Login)', _emailController, Icons.email,
              readOnly: true),

          const SizedBox(height: 32),

          // ---- BOTÃO DE SALVAR ----
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

          // ---- BOTÃO DE SAIR ----
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

  // ---- WIDGET PARA OS CARDS DE ESTATÍSTICA ----
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

  // ---- WIDGET PARA OS CAMPOS DE TEXTO ----
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
