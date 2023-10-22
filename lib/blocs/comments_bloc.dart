import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CommentsBloc extends ChangeNotifier{

  
  String date;
  String timestamp1;
  
  

  Future saveNewComment(String collectionName, String timestamp, String newComment) async{

    final SharedPreferences sp = await SharedPreferences.getInstance();
    String _name = sp.getString('name');
    String _uid = sp.getString('uid');
    String _imageUrl = sp.getString('image_url');

    await _getDate()
    .then((value) => FirebaseFirestore.instance
       .collection('$collectionName/$timestamp/comments')
       .doc('$_uid$timestamp1').set({
        'name': _name,
        'comment' : newComment,
        'date' : date,
        'image url' : _imageUrl,
        'timestamp': timestamp1,
        'uid' : _uid
       })).then((value){
         if(collectionName == 'places'){
           commentInrement(collectionName, timestamp);
         }
       });
    
    
    notifyListeners();

  }





  Future deleteComment (String collectionName, timestamp, uid, timestamp2, ) async{

    await FirebaseFirestore.instance.collection('$collectionName/$timestamp/comments').doc('$uid$timestamp2').delete()
    .then((value){
      if(collectionName == 'places'){
        commentDecrement(collectionName, timestamp);
      }
    });
    notifyListeners();
  }

  


  Future commentInrement (String collectionName, String timestamp) async {

    final DocumentReference ref = FirebaseFirestore.instance.collection(collectionName).doc(timestamp);
    DocumentSnapshot snap = await ref.get();
    int _commentsAmount = snap['comments count'];
    await ref.update({
      'comments count' : _commentsAmount + 1
    });
  }


  Future commentDecrement (String collectionName, String timestamp) async {

    final DocumentReference ref = FirebaseFirestore.instance.collection(collectionName).doc(timestamp);
    DocumentSnapshot snap = await ref.get();
    int _commentsAmount = snap['comments count'];
    await ref.update({
      'comments count' : _commentsAmount - 1
    });
  }





  Future _getDate() async {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd MMMM yy').format(now);
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    date = _date;
    timestamp1 = _timestamp;
  }


}