import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../main.dart'; // Importante para localizar o AuthWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isFinished = false;

 @override
  void initState() {
    super.initState();
    
    _controller = VideoPlayerController.asset("assets/videos/reload.mp4")
      ..initialize().then((_) {
        // Velocidade alta para o logo aparecer rápido
        _controller.setPlaybackSpeed(2.0); 
        
        // Remove qualquer atraso de áudio
        _controller.setVolume(0.0); 
        
        if (mounted) {
          setState(() {}); 
          _controller.play();
        }
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration && _controller.value.duration != Duration.zero) {
        _goToNextScreen();
      }
    });
  }

  void _goToNextScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para não dar "flash" branco
      body: SizedBox.expand(
        child: Center(
          child: _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.contain, // Garante que o vídeo não fique cortado
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const SizedBox(), // Tela preta enquanto o vídeo prepara o 1º frame
        ),
      ),
    );
  }
}