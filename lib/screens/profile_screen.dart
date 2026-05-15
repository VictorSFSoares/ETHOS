import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/db_helper.dart';
import '../services/user_service.dart';
import '../services/verification_service.dart'; // <-- Novo Import
import '../models/data_models.dart'; // <-- Novo Import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DBHelper _dbHelper = DBHelper();
  final VerificationService _verificationService = VerificationService(); // <-- Nova instância
  final ImagePicker _picker = ImagePicker();

  final User? currentUser = FirebaseAuth.instance.currentUser;
  StreamSubscription? _statsSubscription;

  String _avatarPath = '';
  UserStats _stats = UserStats(totalVerifications: 0, verified: 0, fakeNews: 0, suspicious: 0);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _loadProfile();
    _startListeningStats();
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Escuta as mudanças no histórico para atualizar os contadores no perfil
  void _startListeningStats() {
    _statsSubscription = _verificationService.ouvirUserVerifications().listen((_) async {
      final updatedStats = await _verificationService.getUserStats();
      if (mounted) {
        setState(() {
          _stats = updatedStats;
        });
      }
    });
  }

  Future<void> _loadProfile() async {
    final email = UserService().currentUserEmail ?? currentUser?.email;

    if (email != null) {
      final profile = await _dbHelper.getProfile(email);
      // Puxa as estatísticas iniciais da nuvem
      final cloudStats = await _verificationService.getUserStats();

      if (mounted) {
        setState(() {
          _nameController.text = profile?['name'] ?? '';
          _emailController.text = email;
          _avatarPath = profile?['avatar_path'] ?? '';
          _stats = cloudStats;
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

  String get _formattedCreationDate {
    if (currentUser?.metadata.creationTime != null) {
      return DateFormat("dd 'de' MMM 'de' yyyy", 'pt_BR')
          .format(currentUser!.metadata.creationTime!);
    }
    return 'Desconhecida';
  }

  @override
  Widget build(BuildContext context) {
    final bool isPushed = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isPushed
          ? AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatarHeader(),
            const SizedBox(height: 24),
            _buildCloudStatsCard(),
            const SizedBox(height: 32),
            _buildTextField('Nome Completo', _nameController, Icons.badge),
            const SizedBox(height: 16),
            _buildTextField('E-mail (Login)', _emailController, Icons.email, readOnly: true),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarHeader() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF1A1A1A),
            backgroundImage: _avatarPath.isNotEmpty && File(_avatarPath).existsSync()
                ? FileImage(File(_avatarPath))
                : null,
            child: _avatarPath.isEmpty || !File(_avatarPath).existsSync()
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Total', _stats.totalVerifications.toString(), Icons.analytics, Colors.blue),
              _buildStatItem('Verdade', _stats.verified.toString(), Icons.check_circle, Colors.green),
              _buildStatItem('Fake', _stats.fakeNews.toString(), Icons.cancel, Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
              const SizedBox(width: 8),
              Text(
                'Membro desde: $_formattedCreationDate',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? Colors.grey : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: readOnly ? Colors.grey.shade600 : const Color(0xFF4CAF50)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _saveProfile(),
            child: const Text('Salvar Alterações', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          label: const Text('Sair da Conta', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }
}