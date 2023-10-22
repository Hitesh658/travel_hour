import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/featured_bloc.dart';
import 'package:travel_hour/blocs/popular_places_bloc.dart';
import 'package:travel_hour/blocs/recent_places_bloc.dart';
import 'package:travel_hour/blocs/recommanded_places_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/blocs/sp_state_one.dart';
import 'package:travel_hour/blocs/sp_state_two.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/pages/profile.dart';
import 'package:travel_hour/pages/search.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/featured_places.dart';
import 'package:travel_hour/widgets/popular_places.dart';
import 'package:travel_hour/widgets/recent_places.dart';
import 'package:travel_hour/widgets/recommended_places.dart';
import 'package:travel_hour/widgets/special_state1.dart';
import 'package:travel_hour/widgets/special_state2.dart';
import 'package:easy_localization/easy_localization.dart';

class Explore extends StatefulWidget {
  Explore({Key key}) : super(key: key);

  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((_) {

      context.read<FeaturedBloc>().getData();
      context.read<PopularPlacesBloc>().getData();
      context.read<RecentPlacesBloc>().getData();
      context.read<SpecialStateOneBloc>().getData();
      context.read<SpecialStateTwoBloc>().getData();
      context.read<RecommandedPlacesBloc>().getData();




    });
  }




  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.white,
          body: SafeArea(
                      child: RefreshIndicator(
              onRefresh: () async{
                context.read<FeaturedBloc>().onRefresh();
                context.read<PopularPlacesBloc>().onRefresh(mounted);
                context.read<RecentPlacesBloc>().onRefresh(mounted);
                context.read<SpecialStateOneBloc>().onRefresh(mounted);
                context.read<SpecialStateTwoBloc>().onRefresh(mounted);
                context.read<RecommandedPlacesBloc>().onRefresh(mounted);
              },
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Header(),
                    Featured(),

                    PopularPlaces(),
                    RecentPlaces(),
                    SpecialStateOne(),
                    SpecialStateTwo(),
                    RecommendedPlaces()
                  ],
                ),
              ),
            ),
          )
    );
  }

  @override
  bool get wantKeepAlive => true;
}




class Header extends StatelessWidget {
  const Header({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = Provider.of<SignInBloc>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Config().appName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[800]),
                  ),
                  Text(
                    'explore country',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600]),
                  ).tr()
                ],
              ),
              Spacer(),
              InkWell(
                child: sb.imageUrl == null || sb.isSignedIn == false
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, size: 28),
                      )
                    : Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(sb.imageUrl),
                                fit: BoxFit.cover)),
                      ),
                onTap: () {
                  nextScreen(context, ProfilePage());
                },
              )
            ],
          ),
          SizedBox(
            height: 25,
          ),
          InkWell(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 5, right: 5),
              padding: EdgeInsets.only(left: 15, right: 15),
              height: 40,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300], width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Feather.search,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'search places',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ).tr(),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchPage()));
            },
          )
        ],
      ),
    );
  }
}



class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.green,
      padding: EdgeInsets.only(top: 10, bottom: 5, left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Config().appName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700]),
              ),
              Text(
                'Explore ${Config().countryName}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600]),
              )
            ],
          ),
          Spacer(),
          IconButton(
              icon: Icon(
                Feather.bell,
                size: 20,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Feather.search,
                size: 20,
              ),
              onPressed: () {})
        ],
      ),
    );
  }
}
