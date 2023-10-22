import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/blog_bloc.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/pages/blog_details.dart';
import 'package:travel_hour/utils/empty.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';


class BlogPage extends StatefulWidget {
  BlogPage({Key key}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> with AutomaticKeepAliveClientMixin {


  ScrollController controller;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _orderBy = 'loves';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0))
    .then((value){
      controller = new ScrollController()..addListener(_scrollListener);
      context.read<BlogBloc>().getData(mounted, _orderBy);
    });

  }


  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }




  void _scrollListener() {
    final db = context.read<BlogBloc>();
    
    if (!db.isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        context.read<BlogBloc>().setLoading(true);
        context.read<BlogBloc>().getData(mounted, _orderBy);

      }
    }
  }

  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bb = context.watch<BlogBloc>();

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text(
            'blogs'
            
          ).tr(),
          elevation: 0,
          actions: <Widget>[
            PopupMenuButton(
                child: Icon(CupertinoIcons.sort_down),
                //initialValue: 'view',
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem>[
                    PopupMenuItem(
                      child: Text('Most Recent'),
                      value: 'recent',
                    ),
                    PopupMenuItem(
                      child: Text('Most Popular'),
                      value: 'popular',
                    )
                  ];
                },
                onSelected: (value) {
                  setState(() {
                    if(value == 'popular'){
                      _orderBy = 'loves';
                    }else{
                      _orderBy = 'timestamp';
                    }
                  });
                  bb.afterPopSelection(value, mounted, _orderBy);
                }),
            IconButton(
              icon: Icon(Feather.rotate_cw, size: 22,),
              onPressed: (){
                context.read<BlogBloc>().onRefresh(mounted, _orderBy);
              },
            )
          ],
        ),

    body: RefreshIndicator(
        child: bb.hasData == false 
        ? ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.35,),
            EmptyPage(icon: Feather.clipboard, message: 'No blogs found', message1: ''),
          ],
          )
        
        : ListView.separated(
          padding: EdgeInsets.all(15),
          controller: controller,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: bb.data.length != 0 ? bb.data.length + 1 : 5,
          separatorBuilder: (BuildContext context, int index) => SizedBox(height: 15,),
          
          //shrinkWrap: true,
          itemBuilder: (_, int index) {

            if (index < bb.data.length) {
              return _ItemList(d: bb.data[index]);
            }
            return Opacity(
                opacity: bb.isLoading ? 1.0 : 0.0,
                child: bb.lastVisible == null
                ? LoadingCard(height: 250)
                
                : Center(
                  child: SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: new CupertinoActivityIndicator()),
                ),
              
            );
          },
        ),
        onRefresh: () async {
          context.read<BlogBloc>().onRefresh(mounted, _orderBy);
          
        },
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}


class _ItemList extends StatelessWidget {
  final Blog d;
  const _ItemList({Key key, @required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
          child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: <BoxShadow> [
            BoxShadow(
              color: Colors.grey[200],
              blurRadius: 10,
              offset: Offset(0, 3)
            )
          ]
        ),
        child: Wrap(
          children: [
            Hero(
              tag: 'blog${d.timestamp}',
                child: Container(
                height: 160,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CustomCacheImage(imageUrl: d.thumbnailImagelUrl)),
              ),
            ),
            Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    d.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600
                    ),),
                    SizedBox(height: 5,),
                    Text(
                          HtmlUnescape().convert(parse(d.description).documentElement.text),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style:TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey[700]
                      )
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.time, size: 16, color: Colors.grey,),
                        SizedBox(width: 3,),
                        Text(d.date, style: TextStyle(
                          fontSize: 12, color: Colors.grey
                        ),),
                        Spacer(),
                        Icon(Icons.favorite, size: 16, color: Colors.grey,),
                        SizedBox(width: 3,),
                        Text(d.loves.toString(), style: TextStyle(
                          fontSize: 12, color: Colors.grey
                        ),)
                      ],
                    )
                    
                    
                  ],
                ),
              ),
          
          ],
        ),
      ),

      onTap: () => nextScreen(context, BlogDetails(blogData: d, tag: 'blog${d.timestamp}'))
    );
  }
}



