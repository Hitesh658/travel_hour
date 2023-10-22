import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/blocs/popular_places_bloc.dart';
import 'package:travel_hour/models/place.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/pages/more_places.dart';
import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';



class PopularPlaces extends StatelessWidget {
  PopularPlaces({Key key}) : super(key: key);

  


  
  @override
  Widget build(BuildContext context) {
    final pb = context.watch<PopularPlacesBloc>();
    
    

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 15, top: 10,),
          child: Row(children: <Widget>[
            Text('popular places', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.grey[800]),).tr(),
            Spacer(),
            IconButton(icon: Icon(Icons.arrow_forward),
              onPressed: () => nextScreen(context, MorePlacesPage(title: 'popular', color: Colors.grey[800],)),            
            )
          ],),
        ),
        

        Container(
          height: 220,
          //color: Colors.green,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 15, right: 15),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: pb.data.isEmpty ? 3 : pb.data.length,
            itemBuilder: (BuildContext context, int index) {
              if(pb.data.isEmpty) return LoadingPopularPlacesCard();
              return ItemList(d: pb.data[index],);
              //return LoadingCard1();
           },
          ),
        )
        
        
      ],
    );
  }
}


class ItemList extends StatelessWidget {
  final Place d;
  const ItemList({Key key, @required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
          child: Container(
                margin: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
                width: MediaQuery.of(context).size.width * 0.36,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)
                  
                ),
                child: Stack(
                   children: [
                     Hero(
                       tag: 'popular${d.timestamp}',
                        child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomCacheImage(imageUrl: d.imageUrl1)
                       ),
                     ),
                     Align(
                       alignment: Alignment.bottomLeft,
                       child: Padding(
                         padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                         child: Text(d.name, 
                         maxLines: 2,
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w500,
                           color: Colors.white
                         ),),
                       ),
                     ),

                     Align(
                       alignment: Alignment.topRight,
                       child: Padding(
                         padding: const EdgeInsets.only(top: 15, right: 15,),
                         child: Container(
                           padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(20),
                             color: Colors.grey[600].withOpacity(0.5),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(LineIcons.heart, size: 16, color: Colors.white),
                               SizedBox(width: 5,),
                               Text(d.loves.toString(), style: TextStyle(
                                 fontSize: 12,
                                 color: Colors.white
                               ),)
                             ],
                           ),
                         )
                       ),
                     )

                   ],
                ),
                
              ),

              onTap: () => nextScreen(context, PlaceDetails(data: d, tag: 'popular${d.timestamp}')),
    );
  }
}


