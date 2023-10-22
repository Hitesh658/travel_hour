import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/pages/home.dart';
import 'package:easy_localization/easy_localization.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {


  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            height: h * 0.82,
            child: Carousel(

              dotVerticalPadding: h * 0.00,
              dotColor: Colors.grey,
              dotIncreasedColor: Colors.blueAccent,
              autoplay: false,
              dotBgColor: Colors.transparent,
              dotSize: 6,
              dotSpacing: 15,
              images: [
                IntroView(title: 'intro-title1', description: 'intro-description1', image: Config().introImage1),
                IntroView(title: 'intro-title2', description: 'intro-description2', image: Config().introImage2),
                IntroView(title: 'intro-title3', description: 'intro-description3', image: Config().introImage3),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            height: 45,
            width: w * 0.70,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25),
                ),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Text(
                'get started',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ).tr(),
              onPressed: () {
                nextScreenReplace(context, HomePage());
              },
            ),
          ),
          SizedBox(
            height: 0.15,
          ),
        ],
      ),
    );
  }
  


  

  
}


class IntroView extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  const IntroView({Key key, @required this.title, @required this.description, @required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Container(
            alignment: Alignment.center,
            height: h * 0.38,
            child: Image(
              image: AssetImage(image),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.grey[800]),
            ).tr(),
          ),
          Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    height: 3,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40)),
                  ),
          SizedBox(
            height: 15,
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800]),
            ).tr(),
          ),
        ],
      ),
    );
  }
}
