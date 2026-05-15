import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/material.dart'; // Import necessário para Color e IconData
import '../models/data_models.dart';
import '../screens/notifications_screen.dart'; // Import para o modelo NotificationItem

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _apiKey = 'AIzaSyAnfm5jnl7MnvGqnbJKZt-KHN59xG_dWJk';

  // 1. Envia para a IA e guarda no Firebase
  Future<String> enviarParaVerificacao(String conteudo, String tipo) async {
    String vereditoFinal = "inconclusivo";
    String detalhesFinal = "Não foi possível gerar uma análise clara.";

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final prompt = '''
        És o ETHOS, um sistema rigoroso e imparcial de verificação de factos.
        Analisa o seguinte texto ou afirmação para verificar se é fake news ou verdade.
        
        Responde ESTRITAMENTE neste formato exato (sem formatações extra):
        STATUS: [Escolhe apenas uma destas 3 palavras: Verdadeiro, Falso, Misto]
        RESUMO: [Uma justificação direta de 2 ou 3 frases a explicar o porquê do veredicto.]
        
        Texto a analisar: "$conteudo"
      ''';

      final result = await model.generateContent([Content.text(prompt)]);
      final respostaIA = result.text ?? '';

      final linhas = respostaIA.split('\n');
      for (var linha in linhas) {
        if (linha.trim().toUpperCase().startsWith('STATUS:')) {
          vereditoFinal = linha
              .replaceAll(RegExp('STATUS:', caseSensitive: false), '')
              .replaceAll('*', '')
              .trim()
              .toLowerCase();
        } else if (linha.trim().toUpperCase().startsWith('RESUMO:')) {
          detalhesFinal = linha
              .replaceAll(RegExp('RESUMO:', caseSensitive: false), '')
              .replaceAll('*', '')
              .trim();
        }
      }
    } catch (e) {
      print("Erro na IA: $e");
      vereditoFinal = "erro";
      detalhesFinal = "Falha ao contactar a IA.";
    }

    final docRef = await _db.collection('verificacoes').add({
      'usuario_id': _auth.currentUser?.uid,
      'usuario_email': _auth.currentUser?.email ?? 'Usuário',
      'conteudo': conteudo,
      'tipo': tipo,
      'status': 'pendente', 
      'veredito': vereditoFinal,
      'confianca': 95,
      'detalhes': detalhesFinal,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // 2. Escuta o documento a ser verificado
  Stream<DocumentSnapshot> ouvirResultado(String docId) {
    return _db.collection('verificacoes').doc(docId).snapshots();
  }

  // 3. Buscar APENAS AS RECENTES
  Future<List<VerificationItem>> getRecentVerifications() async {
    final snapshot = await _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => _mapDocToItem(doc)).toList();
  }

  // 4. Buscar HISTÓRICO EM TEMPO REAL
  Stream<List<VerificationItem>> ouvirUserVerifications() {
    return _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _mapDocToItem(doc)).toList());
  }

  // --- NOVO: SISTEMA DE NOTIFICAÇÕES REAIS ---

  Stream<List<NotificationItem>> ouvirNotificacoes() {
    return _db
        .collection('notificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return NotificationItem(
                id: doc.id,
                title: data['titulo'] ?? 'Aviso',
                message: data['mensagem'] ?? '',
                time: _formatTimestamp(data['timestamp']),
                icon: _mapIcon(data['icone_tipo']),
                iconColor: Color(int.parse(data['cor'] ?? '0xFF4CAF50')),
                isRead: data['lida'] ?? false,
                type: data['tipo'] ?? 'Sistema',
              );
            }).toList());
  }

  Future<void> marcarNotificacaoComoLida(String id) async {
    await _db.collection('notificacoes').doc(id).update({'lida': true});
  }

  Future<void> marcarTodasComoLidas() async {
    final batch = _db.batch();
    final notifications = await _db
        .collection('notificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .where('lida', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'lida': true});
    }
    await batch.commit();
  }

  // Auxiliares de Notificação
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Agora';
    DateTime date = (timestamp as Timestamp).toDate();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${date.day}/${date.month}';
  }

  IconData _mapIcon(String? tipo) {
    switch (tipo) {
      case 'verificacao': return Icons.check_circle;
      case 'alerta': return Icons.warning;
      case 'conquista': return Icons.emoji_events;
      default: return Icons.notifications;
    }
  }

  // --- MÉTODOS DE ESTATÍSTICAS E CONVERSÃO MANTIDOS ---

  Future<UserStats> getUserStats() async {
    final snapshot = await _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .get();

    int verified = 0, fakeNews = 0, suspicious = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final confianca = (data['confianca'] ?? 0).toInt();
      if (data['status'] != 'pendente') {
        if (confianca >= 70) verified++;
        else if (confianca <= 30) fakeNews++;
        else suspicious++;
      }
    }
    return UserStats(totalVerifications: snapshot.docs.length, verified: verified, fakeNews: fakeNews, suspicious: suspicious);
  }

  VerificationItem _mapDocToItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final confianca = (data['confianca'] ?? 0).toInt();
    return VerificationItem(
      id: doc.id,
      content: data['conteudo'] ?? '',
      type: data['tipo'] ?? 'texto',
      source: data['usuario_email'] ?? 'Desconhecido',
      status: _internalMapStatus(data['status'], confianca),
      confidence: confianca,
      verifiedAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      details: data['detalhes'],
    );
  }

  VerificationStatus _internalMapStatus(String? status, int confianca) {
    if (status == 'pendente') return VerificationStatus.pending;
    if (confianca >= 70) return VerificationStatus.verified;
    if (confianca <= 30) return VerificationStatus.fakeNews;
    return VerificationStatus.suspicious;
  }
}