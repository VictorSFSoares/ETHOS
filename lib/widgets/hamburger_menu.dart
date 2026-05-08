import 'package:flutter/material.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tracinho superior (indicador de puxar)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Botão: Sobre nós
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'Sobre nós',
            onTap: () {
              Navigator.pop(context); // Fecha o menu
              Navigator.pushNamed(context, '/about'); // Vai para a tela
            },
          ),
          
          // Botão: Contato
          _buildMenuItem(
            context,
            icon: Icons.headset_mic_outlined,
            title: 'Contato',
            onTap: () {
              Navigator.pop(context);
              _showContactDialog(context);
            },
          ),
          
          // Botão: Termos e Privacidade
          _buildMenuItem(
            context,
            icon: Icons.description_outlined,
            title: 'Termos e Privacidade',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/privacy');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Widget para padronizar os itens do menu
  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 26),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  // Pop-up elegante para o Contato
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic, color: Color(0xFF4CAF50)),
            SizedBox(width: 10),
            Text('Fale Conosco', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Precisa de ajuda? Entre em contato com a nossa equipe de suporte enviando um e-mail para:\n\nsuporte@ethos.com.br',
          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}