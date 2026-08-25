import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){ runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Splash())); }

class Splash extends StatefulWidget{ @override _SplashState createState()=> _SplashState(); }
class _SplashState extends State<Splash>{
  @override
  void initState(){ super.initState(); Future.delayed(Duration(seconds: 2), ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> WizApp()))); }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Colors.black, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Z', style: TextStyle(fontSize: 130, fontWeight: FontWeight.bold, color: Color(0xFFA855F7), shadows: [Shadow(color: Color(0xFFA855F7), blurRadius: 30)])),
      Text('WIZ', style: TextStyle(fontSize: 35, letterSpacing: 8, color: Colors.white, fontWeight: FontWeight.bold)),
      SizedBox(height: 20),
      CircularProgressIndicator(color: Color(0xFFA855F7))
    ])));
  }
}

class WizApp extends StatefulWidget{ @override _WizAppState createState()=> _WizAppState(); }

class _WizAppState extends State<WizApp> with SingleTickerProviderStateMixin{
  int tab=0;
  late AnimationController ctrl;
  final AudioPlayer player=AudioPlayer();
  bool isWiz=false;
  List<String> lembretes=[];
  List<String> msgs=["Oi! Eu sou o Wiz 💜","Como posso te ajudar hoje?"];

  @override
  void initState(){
    super.initState();
    ctrl=AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    SharedPreferences.getInstance().then((p){ setState(()=> lembretes=p.getStringList('lembretes')??[]); });
  }

  Future<void> sendWiz() async{
    if(isWiz) return;
    setState(()=> isWiz=true);
    ctrl.repeat();
    if(await Vibration.hasVibrator()??false) Vibration.vibrate(pattern: [0,150,80,150,80,400]);
    for(int i=0;i<5;i++){ HapticFeedback.heavyImpact(); await Future.delayed(Duration(milliseconds: 90)); }
    try{ await player.play(AssetSource('sounds/wiz.mp3')); }catch(e){}
    await Future.delayed(Duration(milliseconds: 900));
    ctrl.stop(); ctrl.reset();
    setState((){ isWiz=false; msgs.add("WIZ!!! BUZZZ!!! 🔔"); });
  }

  @override
  Widget build(BuildContext context){
    return AnimatedBuilder(animation: ctrl, builder: (c, child){
      double s=ctrl.isAnimating? sin(ctrl.value*3.14*10)*15 :0;
      return Transform.translate(offset: Offset(s,0), child: child);
    }, child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Row(children: [Text('Z', style: TextStyle(color: Color(0xFFA855F7), fontSize: 28, fontWeight: FontWeight.bold)), SizedBox(width: 6), Text('WIZ', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold))]), actions: [IconButton(icon: Icon(Icons.bolt, color: Color(0xFFA855F7)), onPressed: sendWiz)]),
      body: [chat(), pageLembretes(), pageCasa()][tab],
      bottomNavigationBar: BottomNavigationBar(backgroundColor: Colors.black, selectedItemColor: Color(0xFFA855F7), unselectedItemColor: Colors.grey, currentIndex: tab, onTap: (i)=> setState(()=> tab=i), items: [BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'), BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Lembretes'), BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Casa')]),
      floatingActionButton: tab==0? FloatingActionButton.extended(backgroundColor: isWiz?Colors.red:Color(0xFFA855F7), onPressed: sendWiz, icon: Icon(Icons.notifications_active), label: Text(isWiz?'ENVIANDO...':'ENVIAR WIZ!')):null,
    ));
  }

  Widget chat(){ return Column(children: [Expanded(child: ListView.builder(padding: EdgeInsets.all(16), itemCount: msgs.length, itemBuilder: (c,i)=> Align(alignment: i%2==0?Alignment.centerLeft:Alignment.centerRight, child: Container(margin: EdgeInsets.symmetric(vertical: 5), padding: EdgeInsets.all(14), decoration: BoxDecoration(color: i%2==0?Color(0xFF1E1E1E):Color(0xFFA855F7), borderRadius: BorderRadius.circular(16)), child: Text(msgs[i], style: TextStyle(color: Colors.white)))))), Padding(padding: EdgeInsets.all(10), child: Text('Toque em ENVIAR WIZ para vibrar + som MSN', style: TextStyle(color: Colors.grey, fontSize: 11))) ]); }

  Widget pageLembretes(){ return Padding(padding: EdgeInsets.all(16), child: Column(children: [Row(children: [Expanded(child: Text('Lembretes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), ElevatedButton.icon(onPressed: (){ var t=TextEditingController(); showDialog(context: context, builder: (c)=> AlertDialog(backgroundColor: Color(0xFF1E1E1E), title: Text('Novo Lembrete', style: TextStyle(color: Colors.white)), content: TextField(controller: t, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Ex: Remédio às 20h', hintStyle: TextStyle(color: Colors.grey))), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: Text('Cancelar')), ElevatedButton(onPressed: (){ if(t.text.isNotEmpty){ setState(()=> lembretes.add(t.text)); SharedPreferences.getInstance().then((p)=> p.setStringList('lembretes', lembretes)); Navigator.pop(c);} }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFA855F7)), child: Text('Salvar'))])); }, icon: Icon(Icons.add), label: Text('Novo'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFA855F7)))]), SizedBox(height: 12), Expanded(child: lembretes.isEmpty?Center(child: Text('Nenhum lembrete. Clique em Novo!', style: TextStyle(color: Colors.grey))):ListView.builder(itemCount: lembretes.length, itemBuilder: (c,i)=> Card(color: Color(0xFF1E1E1E), child: ListTile(leading: Icon(Icons.alarm, color: Color(0xFFA855F7)), title: Text(lembretes[i], style: TextStyle(color: Colors.white)), trailing: IconButton(icon: Icon(Icons.delete, color: Colors.grey), onPressed: (){ setState(()=> lembretes.removeAt(i)); SharedPreferences.getInstance().then((p)=> p.setStringList('lembretes', lembretes)); })))))])); }

  Widget pageCasa(){ return Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Controle da Casa', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 20), GridView.count(crossAxisCount: 2, shrinkWrap: true, crossAxisSpacing: 12, mainAxisSpacing: 12, children: [card(Icons.tv, 'TV Sala', true), card(Icons.lightbulb, 'Luz Quarto', false), card(Icons.ac_unit, 'Ar Cond.', true), card(Icons.lock, 'Porta', false)])])); }
  Widget card(IconData ic, String nome, bool on){ return Container(decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: on?Color(0xFFA855F7):Colors.transparent)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, size: 38, color: on?Color(0xFFA855F7):Colors.grey), SizedBox(height: 8), Text(nome, style: TextStyle(fontWeight: FontWeight.bold)), Text(on?'Ligado':'Desligado', style: TextStyle(color: on?Color(0xFFA855F7):Colors.grey, fontSize: 11))])); }
}
