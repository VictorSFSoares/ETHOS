import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/data_models.dart';
import '../services/verification_service.dart';

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

  Future<void> _verify() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isVerifying = true;
      _currentDocId = null;
    });

    try {
      final tipo = _controller.text.contains('http') ? 'link' : 'text';
      final id = await _verificationService.enviarParaVerificacao(_controller.text, tipo);
      setState(() {
        _currentDocId = id;
        _isVerifying = false;
      });
      _controller.clear();
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Verificação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchSection(),
            
            // RESULTADO EM TEMPO REAL (Se houver uma busca ativa)
            if (_currentDocId != null) ...[
              const SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: _verificationService.ouvirResultado(_currentDocId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  
                  final itemResult = VerificationItem(
                    id: snapshot.data!.id,
                    content: data['conteudo'] ?? '',
                    type: data['tipo'] ?? 'texto',
                    source: data['usuario_email'] ?? 'Usuário',
                    status: _mapStatus(data['status'] ?? '', data['veredito'] ?? ''),
                    confidence: (data['confianca'] ?? 0).toInt(),
                    verifiedAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    details: data['detalhes'],
                  );
                  return _buildResultCard(itemResult);
                },
              ),
            ],

            const SizedBox(height: 32),
            const Text('O que deseja verificar?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // RESTAURANDO OS CARDS DE OPÇÕES
            _buildOptionRow(
              _buildOptionCard(Icons.link, 'Link', 'Verifique URLs', Colors.blue),
              _buildOptionCard(Icons.text_fields, 'Texto', 'Analise textos', Colors.purple),
            ),
            const SizedBox(height: 12),
            _buildOptionRow(
              _buildOptionCard(Icons.image, 'Imagem', 'Detecte edições', Colors.teal),
              _buildOptionCard(Icons.audiotrack, 'Áudio', 'Geração por IA', Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  // Mapeamento de Status
  VerificationStatus _mapStatus(String status, String veredito) {
    if (status == 'pendente') return VerificationStatus.suspicious;
    if (veredito == 'verdadeiro') return VerificationStatus.verified;
    if (veredito == 'falso') return VerificationStatus.fakeNews;
    return VerificationStatus.suspicious;
  }

  // --- WIDGETS DE INTERFACE ---

  Widget _buildOptionRow(Widget left, Widget right) {
    return Row(children: [Expanded(child: left), const SizedBox(width: 12), Expanded(child: right)]);
  }

  Widget _buildOptionCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
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
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Link ou texto suspeito...'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          onPressed: _isVerifying ? null : _verify,
          icon: _isVerifying ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
        )
      ],
    );
  }

  Widget _buildResultCard(VerificationItem result) {
    return Container(
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
              Text(result.status.label, style: TextStyle(color: result.status.color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(result.details ?? '', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Olá,', style: TextStyle(color: Colors.white, fontSize: 24)),
        Text('O que vamos analisar hoje?', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
      ],
    );
  }
}