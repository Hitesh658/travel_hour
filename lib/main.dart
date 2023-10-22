import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/ads_bloc.dart';
import 'package:travel_hour/blocs/blog_bloc.dart';
import 'package:travel_hour/blocs/bookmark_bloc.dart';
import 'package:travel_hour/blocs/comments_bloc.dart';
import 'package:travel_hour/blocs/featured_bloc.dart';
import 'package:travel_hour/blocs/internet_bloc.dart';
import 'package:travel_hour/blocs/notification_bloc.dart';
import 'package:travel_hour/blocs/other_places_bloc.dart';
import 'package:travel_hour/blocs/popular_places_bloc.dart';
import 'package:travel_hour/blocs/recent_places_bloc.dart';
import 'package:travel_hour/blocs/recommanded_places_bloc.dart';
import 'package:travel_hour/blocs/search_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/blocs/sp_state_one.dart';
import 'package:travel_hour/blocs/state_bloc.dart';
import 'package:travel_hour/pages/splash.dart';
import 'blocs/sp_state_two.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      startLocale: Locale('en'),
      useOnlyLangCode: true,
      child: MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BlogBloc>( create: (context) => BlogBloc(),),
        ChangeNotifierProvider<InternetBloc>(create: (context) => InternetBloc(),),
        ChangeNotifierProvider<SignInBloc>(create: (context) => SignInBloc(),),
        ChangeNotifierProvider<CommentsBloc>(create: (context) => CommentsBloc(),),
        ChangeNotifierProvider<BookmarkBloc>(create: (context) => BookmarkBloc(),),
        ChangeNotifierProvider<PopularPlacesBloc>(create: (context) => PopularPlacesBloc(),),
        ChangeNotifierProvider<RecentPlacesBloc>(create: (context) => RecentPlacesBloc(),),
        ChangeNotifierProvider<RecommandedPlacesBloc>(create: (context) => RecommandedPlacesBloc(),),
        ChangeNotifierProvider<FeaturedBloc>(create: (context) => FeaturedBloc(),),
        ChangeNotifierProvider<SearchBloc>(create: (context) => SearchBloc()),
        ChangeNotifierProvider<NotificationBloc>(create: (context) => NotificationBloc()),
        ChangeNotifierProvider<StateBloc>(create: (context) => StateBloc()),
        ChangeNotifierProvider<SpecialStateOneBloc>(create: (context) => SpecialStateOneBloc()),
        ChangeNotifierProvider<SpecialStateTwoBloc>(create: (context) => SpecialStateTwoBloc()),
        ChangeNotifierProvider<OtherPlacesBloc>(create: (context) => OtherPlacesBloc()),
        ChangeNotifierProvider<AdsBloc>(create: (context) => AdsBloc()),
      ],
      child: MaterialApp(
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          locale: context.locale,
          theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: Colors.blueAccent,
              iconTheme: IconThemeData(color: Colors.grey[900]),
              fontFamily: 'Muli',
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: AppBarTheme(
                color: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.grey[800],
                ),
                brightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
                textTheme: TextTheme(
                    headline6: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.grey[900],
                      fontWeight: FontWeight.w500
                    )),
                
              )),
          debugShowCheckedModeBanner: false,
          home: SplashPage()),
    ); 
  }
}

