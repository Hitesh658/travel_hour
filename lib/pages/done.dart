import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/pages/intro.dart';
import 'package:travel_hour/utils/next_screen.dart';

class DonePage extends StatefulWidget {
  const DonePage({Key key}) : super(key: key);

  @override
  _DonePageState createState() => _DonePageState();
}

class _DonePageState extends State<DonePage> {


  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 2000))
    .then((value) => nextScreenCloseOthers(context, IntroPage()));
    super.initState();
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 150,
          width: 150,
          child: FlareActor(
              'assets/flr/success.flr',
              animation : 'success',
              
              alignment: Alignment.center,
              fit: BoxFit.contain,

            
            
            
            ),
        ),
        
      
    ),
    );
  }
}