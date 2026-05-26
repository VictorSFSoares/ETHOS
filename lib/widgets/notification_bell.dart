import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      // Procura apenas as notificações do utilizador logado que ainda não foram lidas
      stream: FirebaseFirestore.instance
          .collection('notificacoes')
          .where('usuario_id', isEqualTo: currentUser.uid)
          .where('lida', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        int quantidadeNaoLidas = 0;

        if (snapshot.hasData && snapshot.data != null) {
          quantidadeNaoLidas = snapshot.data!.docs.length;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            
            // Só desenha a bolinha vermelha se houver mais de 0 não lidas
            if (quantidadeNaoLidas > 0)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$quantidadeNaoLidas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}