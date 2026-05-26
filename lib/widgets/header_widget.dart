import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/profile_screen.dart'; 
import 'hamburger_menu.dart'; 

class HeaderWidget extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const HeaderWidget({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LADO ESQUERDO: Logo e Textos
        Row(
          children: [
            // Quadrado verde com o ícone de Check
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check, color: Colors.black, size: 28),
            ),
            const SizedBox(width: 12),
            // Títulos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ETHOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Portal de verificação',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // LADO DIREITO: Os 3 botões interativos
        Row(
          children: [
            // 1. Botão de Perfil
            _buildHeaderButton(
              icon: Icons.person_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            
            // 2. Botão de Notificações com a Bolinha Vermelha Inteligente
            _buildNotificationButton(context),
            const SizedBox(width: 8),
            
            // 3. Menu Hambúrguer
            _buildHeaderButton(
              icon: Icons.menu,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const HamburgerMenu(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // --- LÓGICA DA BOLINHA VERMELHA INTEGRADA AO DESIGN ---
  Widget _buildNotificationButton(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // Se não estiver logado, mostra o botão normal sem o verificador
    if (currentUser == null) {
      return _buildHeaderButton(
        icon: Icons.notifications_none,
        onTap: () => Navigator.pushNamed(context, '/notifications'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
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
          clipBehavior: Clip.none,
          children: [
            // O botão base mantém o mesmo design original
            _buildHeaderButton(
              icon: Icons.notifications_none,
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            
            // A bolinha vermelha só aparece se houver notificações novas
            if (quantidadeNaoLidas > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    quantidadeNaoLidas > 9 ? '9+' : '$quantidadeNaoLidas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Função base COM animação de clique nativa do Flutter (Mantida intacta)
  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFF1A1A1A), // Cor de fundo do botão
      borderRadius: BorderRadius.circular(10), // Bordas arredondadas
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10), // Garante que o clique respeite a borda
        splashColor: const Color(0xFF4CAF50).withOpacity(0.3), // Efeito verde ao clicar
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}