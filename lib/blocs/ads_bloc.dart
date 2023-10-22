import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_hour/config/config.dart';

class AdsBloc extends ChangeNotifier {




  int _clickCounter = 0;
  int get clickCounter => _clickCounter;

  bool _adsEnabled = false;
  bool get adsEnabled => _adsEnabled;


  Future checkAdsEnable () async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('admin').doc('ads').get()
      .then((DocumentSnapshot snap) {
      bool _enabled = snap.data()['ads_enabled'];
      _adsEnabled = _enabled;
      
      notifyListeners();
    }).catchError((e){
      print('error : $e');
    });
  }

  void increaseClickCounter(){
    _clickCounter ++;
    print('Clicks : $_clickCounter');
    notifyListeners();
  }


  void enableAds (){
    if(_adsEnabled == true){
      loadAdmobInterstitialAd();  //admob
      //loadFbAd();              //fb
    }
  }


  initiateAds (){
    increaseClickCounter();
    showAdmobInterstitialAd();  //admob
    //showFbAdd();              //fb
  }

  @override
  void dispose() {
    disposeAdmobInterstitialAd();      //admob
    //destroyFbAd();                       //fb
    super.dispose();                     
  }


  //admob Ads -------Start--------

  bool _admobInterstialAdClosed = false;
  bool get admobInterStitialAdClosed => _admobInterstialAdClosed;

  InterstitialAd _admobInterstitialAd;
  InterstitialAd get admobInterstitialAd => _admobInterstitialAd;

  initAdmob (){
    FirebaseAdMob.instance.initialize(appId: Config().admobAppId);
  }

  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(

    childDirected: false,
    nonPersonalizedAds: true,
  );

  InterstitialAd createAdmobInterstitialAd() {
    return InterstitialAd(
      adUnitId: Config().admobInterstitialAdId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
        if (event == MobileAdEvent.closed) {
          loadAdmobInterstitialAd();
          
        } else if (event == MobileAdEvent.failedToLoad) {
          disposeAdmobInterstitialAd().then((_) {
            loadAdmobInterstitialAd();
          });
        }
        notifyListeners();
      },
    );
  }

  Future loadAdmobInterstitialAd() async {
    await _admobInterstitialAd?.dispose();
    _admobInterstitialAd = createAdmobInterstitialAd()..load();
    notifyListeners();
  }

  Future disposeAdmobInterstitialAd() async {
    _admobInterstitialAd?.dispose();
    notifyListeners();
  }

  showAdmobInterstitialAd() {
    if(_clickCounter % Config().userClicksAmountsToShowEachAd == 0){
      _admobInterstitialAd?.show();
    }
    notifyListeners();
  }

  // admob ads --------- end --------










  //fb ads ----------- start ----------

//   bool _fbadloaded = false;
//   bool get fbadloaded => _fbadloaded;


//   Future loadFbAd() async{
//     print('loading');
//     FacebookInterstitialAd.loadInterstitialAd(
//       placementId: 
//       Config().fbInterstitalAdIDAndroid,
//       //Platform.isAndroid ? Config().fbInterstitalAdIDAndroid : Config().fbInterstitalAdIDiOS,
//       listener: (result, value) {
//         print(result);
//         if (result == InterstitialAdResult.LOADED){
//           _fbadloaded = true;
//           print('ads loaded');
//           notifyListeners();
//         }else if(result == InterstitialAdResult.DISMISSED && value["invalidated"] == true){
//           _fbadloaded = false;
//           print('ads dismissed');
//           loadFbAd();
//           notifyListeners();
//         }
          
//       }
//     );
//   }

//   Future showFbAdd() async{
//     if(_clickCounter % Config().userClicksAmountsToShowEachAd == 0){
//       if(_fbadloaded == true){
//         print('showing');
//       await FacebookInterstitialAd.showInterstitialAd();
//       _fbadloaded = false;
//       notifyListeners();
//     }
//     }
//  }

//   Future destroyFbAd() async{
//     if (_fbadloaded == true) {
//       FacebookInterstitialAd.destroyInterstitialAd();
//       _fbadloaded = false;
//       notifyListeners();
//     }
//   }


//   initFbAd () async{
//     await FacebookAudienceNetwork.init();
//   }



  // fb ads --------- end --------

  
}