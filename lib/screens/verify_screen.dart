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

  @override
  void dispose() {
    _controller.dispose(); // Essencial para evitar vazamento de memória
    super.dispose();
  }

  Future<void> _verify() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isVerifying = true;
      _currentDocId = null;
    });

    try {
      final tipo = text.contains('http') ? 'link' : 'text';
      final id = await _verificationService.enviarParaVerificacao(text, tipo);
      
      if (mounted) {
        setState(() {
          _currentDocId = id;
          _isVerifying = false;
        });
        _controller.clear();
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

  @override
  Widget build(BuildContext context) {
    // Usando o tema do app para cores consistentes
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
                  if (snapshot.hasError) {
                    return const Text('Erro ao carregar resultado', style: TextStyle(color: Colors.red));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  
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
            const Text(
              'O que deseja verificar?', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            
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

  VerificationStatus _mapStatus(String status, String veredito) {
    if (status == 'pendente') return VerificationStatus.suspicious;
    if (veredito == 'verdadeiro') return VerificationStatus.verified;
    if (veredito == 'falso') return VerificationStatus.fakeNews;
    return VerificationStatus.suspicious;
  }

  // --- WIDGETS DE INTERFACE ---

  Widget _buildOptionRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left), 
        const SizedBox(width: 12), 
        Expanded(child: right)
      ]
    );
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
          Text(
            subtitle, 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)
          ),
        ],
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
              backgroundColor: primaryColor,
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
              Text(
                result.status.label.toUpperCase(), 
                style: TextStyle(color: result.status.color, fontWeight: FontWeight.bold, letterSpacing: 1.1)
              ),
              const Spacer(),
              Text('${result.confidence}%', style: TextStyle(color: result.status.color, fontSize: 12)),
            ],
          ),
          if (result.details != null && result.details!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Text(
              result.details!, 
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)
            ),
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