
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/models/place.dart';

class BookmarkBloc extends ChangeNotifier {


  
  
  Future<List> getPlaceData() async {

    String collectionName = 'places';
    String type = 'bookmarked places';
    List<Place> data = [];
    List<DocumentSnapshot> _snap = [];

    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    

    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap[type];

    if(d.isNotEmpty){
      QuerySnapshot rawData = await FirebaseFirestore.instance.collection(collectionName)
      .where('timestamp', whereIn: d)
      .get();
      _snap.addAll(rawData.docs);
      data = _snap.map((e) => Place.fromFirestore(e)).toList();
    }

    
    return data;
  
  }


  Future<List> getBlogData() async {

    String collectionName = 'blogs';
    String type = 'bookmarked blogs';
    List<Blog> data = [];
    List<DocumentSnapshot> _snap = [];
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');

    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap[type];

    if(d.isNotEmpty){
      QuerySnapshot rawData = await FirebaseFirestore.instance.collection(collectionName)
      .where('timestamp', whereIn: d)
      .get();
      _snap.addAll(rawData.docs);
      data = _snap.map((e) => Blog.fromFirestore(e)).toList();
    }
    return data;
  
  }



  Future onBookmarkIconClick(String collectionName, String timestamp) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    String _type = collectionName == 'places' 
      ? 'bookmarked places' 
      : 'bookmarked blogs';
    
    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap[_type];
    

    if (d.contains(timestamp)) {

      List a = [timestamp];
      await ref.update({_type: FieldValue.arrayRemove(a)});
      

    } else {

      d.add(timestamp);
      await ref.update({_type: FieldValue.arrayUnion(d)});
      
      
    }

    notifyListeners();
  }



  Future onLoveIconClick(String collectionName, String timestamp) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');
    String _type = collectionName == 'places' 
      ? 'loved places' 
      : 'loved blogs';


    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    final DocumentReference ref1 = FirebaseFirestore.instance.collection(collectionName).doc(timestamp);

    DocumentSnapshot snap = await ref.get();
    DocumentSnapshot snap1 = await ref1.get();
    List d = snap[_type];
    int _loves = snap1['loves'];

    if (d.contains(timestamp)) {

      List a = [timestamp];
      await ref.update({_type: FieldValue.arrayRemove(a)});
      ref1.update({'loves': _loves - 1});

    } else {

      d.add(timestamp);
      await ref.update({_type: FieldValue.arrayUnion(d)});
      ref1.update({'loves': _loves + 1});

    }
  }







}
