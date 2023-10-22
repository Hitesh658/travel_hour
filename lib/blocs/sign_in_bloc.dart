import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInBloc extends ChangeNotifier {

  
  SignInBloc() {
    checkSignIn();
    checkGuestUser();
    initPackageInfo();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = new GoogleSignIn();
  final FacebookLogin _fbLogin = new FacebookLogin();
  final String defaultUserImageUrl = 'https://www.seekpng.com/png/detail/115-1150053_avatar-png-transparent-png-royalty-free-default-user.png';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _guestUser = false;
  bool get guestUser => _guestUser;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorCode;
  String get errorCode => _errorCode;


  String _name;
  String get name => _name;

  String _uid;
  String get uid => _uid;

  String _email;
  String get email => _email;

  String _imageUrl;
  String get imageUrl => _imageUrl;

  String _joiningDate;
  String get joiningDate => _joiningDate;

  String _signInProvider;
  String get signInProvider => _signInProvider;

  String timestamp;

  String _appVersion = '0.0';
  String get appVersion => _appVersion;

  String _packageName = '';
  String get packageName => _packageName;



  void initPackageInfo () async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    _packageName = packageInfo.packageName;
    notifyListeners();
    
  }




  

  Future signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googlSignIn.signIn().catchError((error) => print('error : $error'));
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        User userDetails = (await _firebaseAuth.signInWithCredential(credential)).user;

        this._name = userDetails.displayName;
        this._email = userDetails.email;
        this._imageUrl = userDetails.photoURL;
        this._uid = userDetails.uid;
        this._signInProvider = 'google';

        _hasError = false;
        notifyListeners();
      } catch (e) {
        _hasError = true;
        _errorCode = e.toString();
        notifyListeners();
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }



  Future signInwithFacebook() async {

      User currentUser;
      final FacebookLoginResult facebookLoginResult =  await _fbLogin.logIn(['email', 'public_profile']).catchError((error) => print('error: $error'));
      if(facebookLoginResult.status == FacebookLoginStatus.cancelledByUser){
        _hasError = true;
        _errorCode = 'cancel';
        notifyListeners();
      } else if(facebookLoginResult.status == FacebookLoginStatus.error){
        _hasError = true;
        notifyListeners();
      } else{
        try {
          if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
          FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
          final AuthCredential credential = FacebookAuthProvider.credential(facebookAccessToken.token);
          final User user = (await _firebaseAuth.signInWithCredential(credential)).user;
          assert(user.email != null);
          assert(user.displayName != null);
          assert(!user.isAnonymous);
          assert(await user.getIdToken() != null);
          currentUser = _firebaseAuth.currentUser;
          assert(user.uid == currentUser.uid);

          this._name = user.displayName;
          this._email = user.email;
          this._imageUrl = user.photoURL;
          this._uid = user.uid;
          this._signInProvider = 'facebook';
        
        
          _hasError = false;
          notifyListeners();
      }
    } catch (e) {
        _hasError = true;
        _errorCode = e.toString();
        notifyListeners();
      }
    
    
    }
  }



  Future signInWithApple () async {

    final _firebaseAuth = FirebaseAuth.instance;
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])]);

    if(result.status == AuthorizationStatus.authorized){
      try
      {
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = authResult.user;

        this._uid = firebaseUser.uid;
        this._name = '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
        this._email = appleIdCredential.email;
        this._imageUrl = firebaseUser.photoURL ?? defaultUserImageUrl;
        this._signInProvider = 'apple';

        
        print(firebaseUser);
        _hasError = false;
        notifyListeners();


      }
      catch(e)
      {
        _hasError = true;
        _errorCode = e.toString();
        notifyListeners();
      }
    }
    else if (result.status == AuthorizationStatus.error)
    {
      _hasError = true;
      _errorCode = 'Appple Sign In Error! Please try again';
      notifyListeners();
    }
    else if (result.status == AuthorizationStatus.cancelled)
    {
      _hasError = true;
      _errorCode = 'Sign In Cancelled!';
      notifyListeners();
    }
    
  }



  Future<bool> checkUserExists() async {
    
    DocumentSnapshot snap = await firestore.collection('users').doc(_uid).get();
    if(snap.exists){
      print('User Exists');
      return true;
    }else{
      print('new user');
      return false;
    }
  }


  Future saveToFirebase() async {
    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    var userData = {
      'name': _name,
      'email': _email,
      'uid': _uid,
      'image url': _imageUrl,
      'joining date': _joiningDate,
      'loved blogs': [],
      'loved places': [],
      'bookmarked blogs': [],
      'bookmarked places': []
    };
    await ref.set(userData);
  }





  Future getJoiningDate() async {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd-MM-yyyy').format(now);
    _joiningDate = _date;
    notifyListeners();
  }




  Future saveDataToSP() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    await sp.setString('name', _name);
    await sp.setString('email', _email);
    await sp.setString('image_url', _imageUrl);
    await sp.setString('uid', _uid);
    await sp.setString('joining_date', _joiningDate);
    await sp.setString('sign_in_provider', _signInProvider);
  }



  Future getDataFromSp () async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _name = sp.getString('name');
    _email = sp.getString('email');
    _imageUrl = sp.getString('image_url');
    _uid = sp.getString('uid');
    _joiningDate = sp.getString('joining_date');
    _signInProvider = sp.getString('sign_in_provider');
    notifyListeners();
  }



  Future getUserDatafromFirebase(uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snap) {
      this._uid = snap.data()['uid'];
      this._name = snap.data()['name'];
      this._email = snap.data()['email'];
      this._imageUrl = snap.data()['image url'];
      this._joiningDate = snap.data()['joining date'];
      print(_name);
    });
    notifyListeners();
  }



  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }



  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed_in') ?? false;
    notifyListeners();
  }



  Future userSignout() async {
    if(_signInProvider == 'apple'){
      await _firebaseAuth.signOut();
    }
    else if (_signInProvider == 'facebook'){
      await _firebaseAuth.signOut();
      await _fbLogin.logOut();
    } else{
      await _firebaseAuth.signOut();
      await _googlSignIn.signOut();
    }
    await clearAllData();
    _isSignedIn = false;
    _guestUser = false;
    notifyListeners();
  }



  Future setGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest_user', true);
    _guestUser = true;
    notifyListeners();
  }



  void checkGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _guestUser = sp.getBool('guest_user') ?? false;
    notifyListeners();
  }




  Future clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }





  Future guestSignout() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest_user', false);
    _guestUser = false;
    notifyListeners();
  }




  Future updateUserProfile (String newName, String newImageUrl) async{
    final SharedPreferences sp = await SharedPreferences.getInstance();

    FirebaseFirestore.instance.collection('users').doc(_uid)
    .update({
      'name': newName,
      'image url' : newImageUrl
    });

    sp.setString('name', newName);
    sp.setString('image url', newImageUrl);
    _name = newName;
    _imageUrl = newImageUrl;
    
    notifyListeners();


  }



  Future<int> getTotalUsersCount () async {
    final String fieldName = 'count';
    final DocumentReference ref = firestore.collection('item_count').doc('users_count');
      DocumentSnapshot snap = await ref.get();
      if(snap.exists == true){
        int itemCount = snap[fieldName] ?? 0;
        return itemCount;
      }
      else{
        await ref.set({
          fieldName : 0
        });
        return 0;
      }
  }


  Future increaseUserCount () async {
    await getTotalUsersCount()
    .then((int documentCount)async {
      await firestore.collection('item_count')
      .doc('users_count')
      .update({
        'count' : documentCount + 1
      });
    });
  }


}
