import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WizPage(),
  ));
}

class WizPage extends StatefulWidget {
  @override
  _WizPageState createState() => _WizPageState();
}

class _WizPageState extends State<WizPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _player = AudioPlayer();
  bool _isWizzing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  Future<void> sendWiz() async {
    if (_isWizzing) return;
    setState(() => _isWizzing = true);
    _controller.repeat();

    // VIBRA FORTE
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }

    // TOCA O SOM (vamos adicionar o arquivo depois)
    // await _player.play(AssetSource('sounds/wiz.mp3'));

    // Tremida + impacto
    for(int i=0; i<5; i++){
      HapticFeedback.heavyImpact();
      await Future.delayed(Duration(milliseconds: 80));
      HapticFeedback.vibrate();
      await Future.delayed(Duration(milliseconds: 80));
    }
    
    await Future.delayed(Duration(milliseconds: 600));
    _controller.stop();
    _controller.reset();
    setState(() => _isWizzing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('WIZ!!! 💜 Você chamou atenção!'), backgroundColor: Color(0xFF8A2BE2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double shake = _controller.isAnimating ? sin(_controller.value * 3.14 * 12) * 15 : 0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black, // FUNDO PRETO OFICIAL
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Z NEON
              Text('Z', style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Color(0xFF8A2BE2), shadows: [Shadow(color: Color(0xFF8A2BE2), blurRadius: 20)])),
              SizedBox(height: 10),
              Text('WIZ', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 5)),
              Text('Chamar Atenção', style: TextStyle(fontSize: 20, color: Colors.grey)),
              SizedBox(height: 60),
              GestureDetector(
                onTap: sendWiz,
                child: Container(
                  width: 220,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _isWizzing ? Colors.red : Color(0xFF8A2BE2),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [BoxShadow(color: Color(0xFF8A2BE2).withOpacity(0.5), blurRadius: 20, offset: Offset(0,5))],
                  ),
                  child: Center(
                    child: Text(
                      _isWizzing ? 'ENVIANDO...' : 'ENVIAR WIZ!',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Vai vibrar + tremer + tocar som', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
