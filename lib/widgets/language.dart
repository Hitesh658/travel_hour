import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_hour/config/config.dart';

class LanguagePopup extends StatefulWidget {
  const LanguagePopup({Key key}) : super(key: key);

  @override
  _LanguagePopupState createState() => _LanguagePopupState();
}

class _LanguagePopupState extends State<LanguagePopup> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('select language').tr(),
      ),
      body : ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: Config().languages.length,
        itemBuilder: (BuildContext context, int index) {
         return _itemList(Config().languages[index], index);
       },
      ),
    );
  }

  Widget _itemList (d, index){
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.language),
          title: Text(d),
          onTap: () async{
            if(index == 0){
              context.locale = Locale('en');
            }
            else{
              context.locale = Locale('es');
            }
            Navigator.pop(context);
          },
        ),
        Divider()
      ],
    );
  }
}