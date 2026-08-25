import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';

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
      SnackBar(content: Text('WIZ!!! Voce chamou a atencao!'), backgroundColor: Colors.blue),
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
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble, size: 100, color: Colors.blue),
              SizedBox(height: 20),
              Text('WIZ', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blue)),
              Text('Chamar Atencao', style: TextStyle(fontSize: 20, color: Colors.grey)),
              SizedBox(height: 60),
              GestureDetector(
                onTap: sendWiz,
                child: Container(
                  width: 200,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _isWizzing ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,5))],
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
              Text('Vai vibrar e tremer a tela', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
