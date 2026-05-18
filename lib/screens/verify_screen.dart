import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/verification_service.dart';
import '../models/data_models.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _controller = TextEditingController();
  final VerificationService _verificationService = VerificationService();
  bool _isVerifying = false;
  String? _currentDocId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- LÓGICA DE UPLOAD PARA CLOUDINARY ---
  
  Future<String?> _uploadToCloudinary(File file, String resourceType) async {
    // resourceType deve ser 'image' ou 'video'
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dm9ngsyrx/$resourceType/upload');
    
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'ethos_preset'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonMap = json.decode(responseData);
      return jsonMap['secure_url']; // O link público da imagem/vídeo gerado!
    } else {
      debugPrint('Erro no Cloudinary: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _startMediaUpload(File file, String resourceType, String tipoBanco) async {
    setState(() {
      _isVerifying = true; 
      _currentDocId = null;
    });

    try {
      // 1. Envia para o Cloudinary e pega o link
      final String? linkPublico = await _uploadToCloudinary(file, resourceType);
      
      if (linkPublico != null) {
        // 2. Envia o LINK gerado para o Firebase em vez do arquivo pesado
        await _processVerification(linkPublico, tipoBanco);
      } else {
        throw Exception("Falha ao gerar o link da mídia no servidor.");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar mídia: $e")),
        );
      }
    }
  }

  // --- MANIPULADORES DE CLIQUES NOS CARDS ---

  Future<void> _handleImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      _startMediaUpload(File(image.path), 'image', 'imagem');
    }
  }

  Future<void> _handleVideo() async {
    // Usamos pickVideo pois o pacote atual suporta vídeo nativamente
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    
    if (video != null) {
      _startMediaUpload(File(video.path), 'video', 'video');
    }
  }

  void _showTextInputDialog(String title, String hint, String tipo) {
    final TextEditingController dialogController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: dialogController,
          style: const TextStyle(color: Colors.white),
          maxLines: tipo == 'texto' ? 6 : 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final text = dialogController.text.trim();
              Navigator.pop(context); // Fecha o Pop-up
              if (text.isNotEmpty) {
                _processVerification(text, tipo);
              }
            },
            child: const Text('Verificar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA CENTRAL DE VERIFICAÇÃO ---

  Future<void> _processVerification(String conteudo, String tipo) async {
    setState(() {
      _isVerifying = true;
      _currentDocId = null;
    });

    try {
      final id = await _verificationService.enviarParaVerificacao(conteudo, tipo);

      if (mounted) {
        setState(() {
          _currentDocId = id;
          _isVerifying = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.send, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text("Solicitação enviada com sucesso!")),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro na verificação: $e")),
        );
      }
    }
  }

  Future<void> _verify() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final tipo = text.contains('http') ? 'link' : 'text';
    await _processVerification(text, tipo);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchSection(primaryColor),
            if (_currentDocId != null) ...[
              const SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: _verificationService.ouvirResultado(_currentDocId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Color(0xFF4CAF50)),
                          SizedBox(height: 16),
                          Text('A enviar para os servidores...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text('Erro ao carregar resultado', style: TextStyle(color: Colors.red));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final confianca = (data['confianca'] ?? 0).toInt();

                  if (data['status'] == 'pendente') {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.pending_actions, color: Colors.orange, size: 40),
                          ),
                          const SizedBox(height: 16),
                          const Text('Verificação em Análise', style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            'A sua solicitação foi recebida e entrou em análise pela nossa equipa técnica. Assim que for verificada, receberá uma notificação!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    );
                  }

                  final itemResult = VerificationItem(
                    id: snapshot.data!.id,
                    content: data['conteudo'] ?? '',
                    type: data['tipo'] ?? 'texto',
                    source: data['usuario_email'] ?? 'Usuário',
                    status: _mapStatus(data['status'] ?? '', confianca),
                    confidence: confianca,
                    verifiedAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    details: data['detalhes'],
                  );
                  return _buildResultCard(itemResult);
                },
              ),
            ],
            const SizedBox(height: 32),
            const Text('O que deseja verificar?',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildOptionRow(
              _buildOptionCard(
                  Icons.link, 'Link', 'Verifique URLs', Colors.blue, 
                  () => _showTextInputDialog('Verificar Link', 'Cole o link suspeito aqui...', 'link')),
              _buildOptionCard(
                  Icons.text_fields, 'Texto', 'Analise textos', Colors.purple, 
                  () => _showTextInputDialog('Verificar Texto', 'Cole o texto suspeito aqui...', 'texto')),
            ),
            const SizedBox(height: 12),
            _buildOptionRow(
              _buildOptionCard(
                  Icons.image, 'Imagem', 'Detecte edições', Colors.teal, _handleImage),
              _buildOptionCard(
                  Icons.audiotrack, 'Áudio/Vídeo', 'Geração por IA', Colors.orange, _handleVideo),
            ),
          ],
        ),
      ),
    );
  }

  VerificationStatus _mapStatus(String status, int confianca) {
    if (status == 'pendente') return VerificationStatus.pending;
    if (confianca >= 70) return VerificationStatus.verified;
    if (confianca <= 30) return VerificationStatus.fakeNews;
    return VerificationStatus.suspicious;
  }

  // --- WIDGETS DE INTERFACE ---

  Widget _buildOptionRow(Widget left, Widget right) {
    return Row(children: [
      Expanded(child: left),
      const SizedBox(width: 12),
      Expanded(child: right)
    ]);
  }

  // Adicionado InkWell e parâmetro onTap para tornar clicável
  Widget _buildOptionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Link ou texto suspeito...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 50,
          width: 50,
          child: IconButton(
            onPressed: _isVerifying ? null : _verify,
            icon: _isVerifying
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.search, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildResultCard(VerificationItem result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: result.status.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(result.status.icon, color: result.status.color),
              const SizedBox(width: 12),
              Text(result.status.label.toUpperCase(),
                  style: TextStyle(color: result.status.color, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const Spacer(),
              Text('${result.confidence}%',
                  style: TextStyle(color: result.status.color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          if (result.details != null && result.details!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Text(result.details!, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Olá,', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('O que vamos analisar hoje?', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
      ],
    );
  }
}