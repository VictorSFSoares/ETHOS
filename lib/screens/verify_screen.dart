import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Função que envia o texto para o Firestore
  Future<void> _verify() async {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      _isVerifying = true;
      _currentDocId = null;
    });

    try {
      final tipo = _controller.text.contains('http') ? 'link' : 'texto';
      // Envia para o serviço que criaste
      final id = await _verificationService.enviarParaVerificacao(_controller.text, tipo);
      
      setState(() {
        _currentDocId = id;
        _isVerifying = false;
      });
      
      _controller.clear();
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    }
  }

  // Define as cores com base no veredicto do Firestore
  Color _getStatusColor(String veredito) {
    if (veredito == 'verdadeiro') return const Color(0xFF4CAF50);
    if (veredito == 'falso') return Colors.redAccent;
    return Colors.orangeAccent; // Para misto ou inconclusivo
  }

  IconData _getStatusIcon(String veredito) {
    if (veredito == 'verdadeiro') return Icons.verified_user;
    if (veredito == 'falso') return Icons.cancel;
    return Icons.warning; // Para misto ou inconclusivo
  }

  String _getStatusTitle(String veredito) {
    if (veredito == 'verdadeiro') return 'Verdadeiro';
    if (veredito == 'falso') return 'Falso';
    return 'Inconclusivo / Misto';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABEÇALHO
          const Text('Verificar Informação', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // CAIXA DE PESQUISA (O tal _buildSearchBox que estava em falta)
          TextField(
            controller: _controller,
            maxLines: 6,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cola aqui a notícia, link ou afirmação suspeita...',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          // BOTÃO ANALISAR
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isVerifying ? null : _verify,
              child: _isVerifying 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Analisar com ETHOS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          const SizedBox(height: 32),
          
          // ZONA DE RESULTADOS (ESPERANDO PELO FIRESTORE)
          if (_currentDocId != null)
            StreamBuilder<DocumentSnapshot>(
              stream: _verificationService.ouvirResultado(_currentDocId!),
              builder: (context, snapshot) {
                // Estado 1: A carregar o Stream
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4CAF50)),
                        SizedBox(height: 16),
                        Text('A contactar os servidores...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // Estado 2: Erro no documento
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('Erro ao carregar o resultado.', style: TextStyle(color: Colors.red));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                
                // Estado 3: O documento existe, mas a IA ainda está a pensar
                if (data['status'] == 'pendente') {
                   return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4CAF50)),
                        SizedBox(height: 16),
                        Text('A aguardar processamento na nuvem da IA...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // Estado 4: A IA respondeu! (O status mudou para 'concluido' e o 'veredito' foi preenchido)
                final vereditoRaw = data['veredito']?.toString().toLowerCase() ?? '';
                final Color cardColor = _getStatusColor(vereditoRaw);
                final IconData cardIcon = _getStatusIcon(vereditoRaw);
                final String cardTitle = _getStatusTitle(vereditoRaw);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(cardIcon, color: cardColor),
                          const SizedBox(width: 12),
                          Text(cardTitle, style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const Divider(color: Colors.grey, height: 24),
                      Text(data['detalhes'] ?? 'Sem detalhes adicionais.', style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 15)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}