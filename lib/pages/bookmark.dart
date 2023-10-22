import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:travel_hour/blocs/bookmark_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/pages/blog_details.dart';
import 'package:travel_hour/utils/empty.dart';
import 'package:travel_hour/utils/list_card.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final SignInBloc sb = context.watch<SignInBloc>();

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('bookmarks').tr(),
          centerTitle: false,
          bottom: TabBar(
              labelPadding: EdgeInsets.all(0),
              indicatorColor: Theme.of(context).primaryColor,
              isScrollable: false,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[500],
              indicatorWeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.w600
              ),
              indicator: MD2Indicator(
                indicatorHeight: 2,
                indicatorSize: MD2IndicatorSize.normal,
                indicatorColor: Theme.of(context).primaryColor,
              ),
              tabs: [
                Tab(
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.centerLeft,
                    child: Text('saved places').tr(),
                  ),
                  //text: 'Saved Places',
                ),
                Tab(
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.centerLeft,
                    child: Text('saved blogs').tr(),
                  ),
                )
              ]),
        ),
        body: TabBarView(children: <Widget>[
          sb.guestUser == true
              ? EmptyPage(
                  icon: Feather.user_plus, 
                  message: 'sign in first'.tr(),
                  message1: "sign in to save your favourite places here".tr(),
                )
              : BookmarkedPlaces(),
          sb.guestUser == true
              ? EmptyPage(
                  icon: Feather.user_plus, 
                  message: 'sign in first'.tr(),
                  message1: "sign in to save your favourite blogs here".tr(),
                )
              : BookmarkedBlogs(),
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}







class BookmarkedPlaces extends StatefulWidget {
  const BookmarkedPlaces({Key key}) : super(key: key);

  @override
  _BookmarkedPlacesState createState() => _BookmarkedPlacesState();
}

class _BookmarkedPlacesState extends State<BookmarkedPlaces>
    with AutomaticKeepAliveClientMixin {
  final String collectionName = 'hotels';
  final String type = 'bookmarked_hotels';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: FutureBuilder(
        future: context.watch<BookmarkBloc>().getPlaceData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0)
              return EmptyPage(
                icon: Feather.bookmark,
                message: 'no places found'.tr(),
                message1: 'save your favourite places here'.tr(),
              );
            else
              return ListView.separated(
                padding: EdgeInsets.all(5),
                itemCount: snapshot.data.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return ListCard(d: snapshot.data[index],tag: "bookmark$index", color: Colors.white,);
                  
                },
              );
          }
          return ListView.separated(
            padding: EdgeInsets.all(15),
            itemCount: 5,
            separatorBuilder: (BuildContext context, int index) => SizedBox(height: 10,),
            itemBuilder: (BuildContext context, int index) {
            return LoadingCard(height: 150);
           },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}







class BookmarkedBlogs extends StatefulWidget {
  const BookmarkedBlogs({Key key}) : super(key: key);

  @override
  _BookmarkedBlogsState createState() => _BookmarkedBlogsState();
}

class _BookmarkedBlogsState extends State<BookmarkedBlogs>
    with AutomaticKeepAliveClientMixin {
  final String collectionName = 'blogs';
  final String type = 'bookmarked_blogs';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: FutureBuilder(
        future: context.watch<BookmarkBloc>().getBlogData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0)
              return EmptyPage(
                icon: Feather.bookmark,
                message: 'no blogs found'.tr(),
                message1: 'save your favourite blogs here'.tr(),
              );
            else return ListView.separated(
                padding: EdgeInsets.all(15),
                itemCount: snapshot.data.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 15,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return _BlogList(data: snapshot.data[index]);
                },
              );
          }
          return ListView.separated(
            padding: EdgeInsets.all(15),
            itemCount: 5,
            separatorBuilder: (BuildContext context, int index) => SizedBox(height: 10,),
            itemBuilder: (BuildContext context, int index) {
            return LoadingCard(height: 120);
           },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}






class _BlogList extends StatelessWidget {
  final Blog data;
  const _BlogList({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(

          color: Colors.white,
          borderRadius: BorderRadius.circular(3)
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Hero(
                  tag: 'bookmark${data.timestamp}',
                  child: Container(
                    width: 140,
                    child: CustomCacheImage(imageUrl: data.thumbnailImagelUrl),
                  )),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 15, top: 15, right: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.time,
                                size: 16, color: Colors.grey),
                            SizedBox(
                              width: 3,
                            ),
                            Text(data.date,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.favorite, size: 16, color: Colors.grey),
                            SizedBox(
                              width: 3,
                            ),
                            Text(data.loves.toString(),
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        nextScreen(context, BlogDetails(blogData: data, tag: 'bookmark${data.timestamp}'));
      },
    );
  }
}