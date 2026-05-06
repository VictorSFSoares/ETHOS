import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/data_models.dart';

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Envia a petição
  Future<String> enviarParaVerificacao(String conteudo, String tipo) async {
    final docRef = await _db.collection('verificacoes').add({
      'usuario_id': _auth.currentUser?.uid,
      'usuario_email': _auth.currentUser?.email ?? 'Usuário',
      'conteudo': conteudo,
      'tipo': tipo,
      'status': 'pendente',
      'veredito': '',
      'confianca': 0,
      'detalhes': 'Aguardando análise...',
      'timestamp': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Escuta um documento específico (Usado na VerifyScreen)
  Stream<DocumentSnapshot> ouvirResultado(String docId) {
    return _db.collection('verificacoes').doc(docId).snapshots();
  }

  // Métodos para a HomeScreen
  Future<List<VerificationItem>> getRecentVerifications() async {
    final snapshot = await _db
        .collection('verificacoes')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();
    
    return snapshot.docs.map((doc) => _mapDocToItem(doc)).toList();
  }

  // Métodos para a HistoryScreen
  Future<List<VerificationItem>> getUserVerifications() async {
    final snapshot = await _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => _mapDocToItem(doc)).toList();
  }

  Future<UserStats> getUserStats() async {
    final snapshot = await _db
        .collection('verificacoes')
        .where('usuario_id', isEqualTo: _auth.currentUser?.uid)
        .get();

    int verified = 0, fakeNews = 0, suspicious = 0;

    for (var doc in snapshot.docs) {
      final veredito = doc.data()['veredito'];
      if (veredito == 'verdadeiro') verified++;
      else if (veredito == 'falso') fakeNews++;
      else suspicious++;
    }

    return UserStats(
      totalVerifications: snapshot.docs.length,
      verified: verified,
      fakeNews: fakeNews,
      suspicious: suspicious,
    );
  }

  // Helper para converter Firestore Doc em Objeto do App
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

  VerificationStatus _internalMapStatus(String status, String veredito) {
    if (status == 'pendente') return VerificationStatus.suspicious;
    if (veredito == 'verdadeiro') return VerificationStatus.verified;
    if (veredito == 'falso') return VerificationStatus.fakeNews;
    return VerificationStatus.suspicious;
  }
}