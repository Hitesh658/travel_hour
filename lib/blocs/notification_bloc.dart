import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hour/models/notification.dart';
import 'package:travel_hour/pages/notifications.dart';
import 'package:travel_hour/utils/next_screen.dart';




class NotificationBloc extends ChangeNotifier {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  DocumentSnapshot _lastVisible;
  DocumentSnapshot get lastVisible => _lastVisible;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<DocumentSnapshot> _snap = new List<DocumentSnapshot>();

  List<NotificationModel> _data = [];
  List<NotificationModel> get data => _data;

  bool _subscribed;
  bool get subscribed => _subscribed;

  final String subscriptionTopic = 'all';




  Future<Null> getData(mounted) async {
    QuerySnapshot rawData;
    if (_lastVisible == null)
      rawData = await firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    else
      rawData = await firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible['timestamp']])
          .limit(10)
          .get();

    if (rawData != null && rawData.docs.length > 0) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        _isLoading = false;
        _snap.addAll(rawData.docs);
        _data = _snap.map((e) => NotificationModel.fromFirestore(e)).toList();
      }
    } else {
      _isLoading = false;
      print('none');
    }

    notifyListeners();
    return null;
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }




  onRefresh(mounted) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted);
    notifyListeners();
  }

  

  onReload(mounted) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted);
    notifyListeners();
  }



  

  Future initFirebasePushNotification(context) async {
    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((event) {
        print('event: $event');
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }


  handleFcmSubscribtion();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showinAppDialog(context, message['notification']['title'], message['notification']['body']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        nextScreen(context, NotificationsPage());
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    notifyListeners();
  }






  Future handleFcmSubscribtion() async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    bool _getsubcription = sp.getBool('subscribe') ?? true;
    if(_getsubcription == true){
      await sp.setBool('subscribe', true);
      _fcm.subscribeToTopic(subscriptionTopic);
      _subscribed = true;
      print('subscribed');
    }else{
      await sp.setBool('subscribe', false);
      _fcm.unsubscribeFromTopic(subscriptionTopic);
      _subscribed = false;
      print('unsubscribed');
    }
    
    notifyListeners();
  }








  Future fcmSubscribe(bool isSubscribed) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('subscribe', isSubscribed);
    handleFcmSubscribtion();
  }

  







  showinAppDialog(context, title, body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(title),
          subtitle: HtmlWidget(body),
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                nextScreen(context, NotificationsPage());
              }),
        ],
      ),
    );
  }
}