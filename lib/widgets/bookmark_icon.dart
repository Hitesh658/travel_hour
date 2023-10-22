import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/models/icon_data.dart';
import 'package:provider/provider.dart';



  class BuildBookmarkIcon extends StatelessWidget {
    final String collectionName;
    final String uid;
    final String timestamp;

    const BuildBookmarkIcon({
      Key key, 
      @required this.collectionName, 
      @required this.uid,
      @required this.timestamp
      
      }) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      final sb = context.watch<SignInBloc>();
      String _type = collectionName == 'places' ? 'bookmarked places' : 'bookmarked blogs';
      if(sb.isSignedIn == false) return BookmarkIcon().normal;
      return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        if (uid == null) return BookmarkIcon().normal;
        if (!snap.hasData) return BookmarkIcon().normal;
        List d = snap.data[_type];

        if (d.contains(timestamp)) {
          return BookmarkIcon().bold;
        } else {
          return BookmarkIcon().normal;
        }
      },
    );
    }
  }