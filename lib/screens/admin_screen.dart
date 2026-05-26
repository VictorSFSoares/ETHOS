import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função que atualiza o banco e envia a notificação automaticamente
  Future<void> _submeterAnalise({
    required String docId,
    required String usuarioId,
    required String conteudo,
    required String veredito,
    required int confianca,
    required String detalhes,
  }) async {
    final batch = _db.batch();

    // 1. Referência da verificação original para atualizar
    final docRef = _db.collection('verificacoes').doc(docId);
    batch.update(docRef, {
      'status': 'concluido',
      'veredito': veredito,
      'confianca': confianca,
      'detalhes': detalhes,
    });

    // Configurações visuais automáticas da notificação baseado no veredito
    String tituloNotificacao = 'Verificação Concluída';
    String iconeTipo = 'verificacao';
    String corHex = '0xFF4CAF50'; // Verde para verdadeiro

    if (veredito == 'falso') {
      tituloNotificacao = 'Alerta de Fake News';
      iconeTipo = 'alerta';
      corHex = '0xFFE53935'; // Vermelho para falso
    } else if (veredito == 'misto') {
      tituloNotificacao = 'Conteúdo Suspeito';
      iconeTipo = 'alerta';
      corHex = '0xFFFFB300'; // Laranja para misto
    }

    // 2. Referência para criar a nova notificação para o usuário dono do post
    final notificacaoRef = _db.collection('notificacoes').doc();
    batch.set(notificacaoRef, {
      'usuario_id': usuarioId,
      'titulo': tituloNotificacao,
      'mensagem': 'A sua análise sobre "${conteudo.length > 30 ? conteudo.substring(0, 30) + '...' : conteudo}" foi concluída!',
      'tipo': 'Verificações',
      'cor': corHex,
      'icone_tipo': iconeTipo,
      'lida': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Executa as duas operações juntas de forma segura
    await batch.commit();
  }

  // Janela flutuante (Pop-up) para preencher a análise
  void _abrirPainelJulgamento(BuildContext context, String docId, Map<String, dynamic> data) {
    final TextEditingController detalhesController = TextEditingController();
    String vereditoSelecionado = 'verdadeiro';
    double confiancaSelecionada = 90;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24, left: 24, right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Avaliar Conteúdo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Enviado por: ${data['usuario_email']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                
                // Exibe imagem ou texto dependendo do tipo enviado
                if (data['tipo'] == 'imagem')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(data['conteudo'], height: 150, width: double.infinity, fit: BoxFit.cover),
                  )
                else
                  Text('"${data['conteudo']}"', style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                
                const SizedBox(height: 20),
                const Text('Veredito:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                Row(
                  children: [
                    Radio<String>(
                      value: 'verdadeiro', groupValue: vereditoSelecionado, activeColor: Colors.green,
                      onChanged: (val) => setModalState(() => vereditoSelecionado = val!),
                    ),
                    const Text('Verdadeiro', style: TextStyle(color: Colors.white)),
                    Radio<String>(
                      value: 'falso', groupValue: vereditoSelecionado, activeColor: Colors.red,
                      onChanged: (val) => setModalState(() => vereditoSelecionado = val!),
                    ),
                    const Text('Falso', style: TextStyle(color: Colors.white)),
                    Radio<String>(
                      value: 'misto', groupValue: vereditoSelecionado, activeColor: Colors.orange,
                      onChanged: (val) => setModalState(() => vereditoSelecionado = val!),
                    ),
                    const Text('Misto', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Nível de Confiança: ${confiancaSelecionada.toInt()}%', style: const TextStyle(color: Colors.grey)),
                Slider(
                  value: confiancaSelecionada, min: 0, max: 100, divisions: 10,
                  activeColor: const Color(0xFF4CAF50),
                  label: '${confiancaSelecionada.toInt()}%',
                  onChanged: (val) => setModalState(() => confiancaSelecionada = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detalhesController,
                  maxLines: 4, style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Escreva o parecer técnico da equipe...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true, fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                    onPressed: () async {
                      Navigator.pop(context); // Fecha o painel
                      await _submeterAnalise(
                        docId: docId,
                        usuarioId: data['usuario_id'] ?? '',
                        conteudo: data['conteudo'] ?? '',
                        veredito: vereditoSelecionado,
                        confianca: confiancaSelecionada.toInt(),
                        detalhes: detalhesController.text.trim(),
                      );
                    },
                    child: const Text('Enviar Análise', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Fila de Moderação (Admin)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('verificacoes').where('status', isEqualTo: 'pendente').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 48, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  Text('Nenhuma verificação pendente!', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final String conteudo = data['conteudo'] ?? '';
              final String tipo = data['tipo'] ?? 'texto';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(tipo == 'imagem' ? Icons.image : Icons.text_fields, color: Colors.orange, size: 16),
                        const SizedBox(width: 6),
                        Text(tipo.toUpperCase(), style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(data['usuario_email'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (tipo == 'imagem')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(conteudo, height: 100, width: double.infinity, fit: BoxFit.cover),
                      )
                    else
                      Text(conteudo, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(backgroundColor: Colors.orange.withOpacity(0.1)),
                        onPressed: () => _abrirPainelJulgamento(context, docId, data),
                        icon: const Icon(Icons.gavel, color: Colors.orange, size: 16),
                        label: const Text('Avaliar Conteúdo', style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}