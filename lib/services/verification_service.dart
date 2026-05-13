import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/data_models.dart';

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔴 COLA A TUA API KEY DO GEMINI AQUI ENTRE AS ASPAS:
  // Lembrete: Por segurança, no futuro, mova isso para um arquivo .env!
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
      detalhesFinal =
          "Falha ao contactar a IA. Verifica a tua ligação à internet ou a API Key.";
    }

    final docRef = await _db.collection('verificacoes').add({
      'usuario_id': _auth.currentUser?.uid,
      'usuario_email': _auth.currentUser?.email ?? 'Usuário',
      'conteudo': conteudo,
      'tipo': tipo,
      'status': 'pendente', // Mantido como você enviou
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

  // 3. Buscar APENAS AS RECENTES (Para a Tela Inicial - HOME SCREEN)
  Future<List<VerificationItem>> getRecentVerifications() async {
    final snapshot = await _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => _mapDocToItem(doc)).toList();
  }

  // 4. Buscar TODO O HISTÓRICO (Para a Tela de Histórico - HISTORY SCREEN)
  Future<List<VerificationItem>> getUserVerifications() async {
    final snapshot = await _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => _mapDocToItem(doc)).toList();
  }

  // 4.1. NOVO: Escuta TODO O HISTÓRICO EM TEMPO REAL
  Stream<List<VerificationItem>> ouvirUserVerifications() {
    return _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _mapDocToItem(doc)).toList());
  }

  // 5. Buscar ESTATÍSTICAS do Usuário (Para o Perfil)
  Future<UserStats> getUserStats() async {
    final snapshot = await _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .get();

    int verified = 0, fakeNews = 0, suspicious = 0;

    for (var doc in snapshot.docs) {
      final veredito = doc.data()['veredito'];
      if (veredito == 'verdadeiro') {
        verified++;
      } else if (veredito == 'falso') {
        fakeNews++;
      } else {
        suspicious++;
      }
    }

    return UserStats(
      totalVerifications: snapshot.docs.length,
      verified: verified,
      fakeNews: fakeNews,
      suspicious: suspicious,
    );
  }

  // 6. Helpers de Conversão (Firestore -> App)
  VerificationItem _mapDocToItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VerificationItem(
      id: doc.id,
      content: data['conteudo'] ?? '',
      type: data['tipo'] ?? 'texto',
      source: data['usuario_email'] ?? 'Desconhecido',
      status: _internalMapStatus(data['status'], data['veredito']),
      confidence: data['confianca'] ?? 0,
      verifiedAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      details: data['detalhes'],
    );
  }

  VerificationStatus _internalMapStatus(String? status, String? veredito) {
    if (status == 'pendente') return VerificationStatus.pending;
    if (veredito == 'verdadeiro') return VerificationStatus.verified;
    if (veredito == 'falso') return VerificationStatus.fakeNews; 
    return VerificationStatus.suspicious;
  }
}