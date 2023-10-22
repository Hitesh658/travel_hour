import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geo/geo.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:travel_hour/blocs/ads_bloc.dart';
import 'package:travel_hour/models/colors.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/models/place.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_hour/utils/convert_map_icon.dart';
import 'package:travel_hour/utils/map_util.dart';
import 'package:provider/provider.dart';





class GuidePage extends StatefulWidget {

  final Place d;
  GuidePage({Key key,@required this.d}) : super(key: key);

  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {

  GoogleMapController mapController;

  
  List<Marker> _markers = [];
  Map data = {};
  String distance  = 'O km';

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  Uint8List _sourceIcon;
  Uint8List _destinationIcon;
  


  Future getData() async {
   await FirebaseFirestore.instance.collection('places')
   .doc(widget.d.timestamp)
   .collection('travel guide')
   .doc(widget.d.timestamp)
   .get().then((DocumentSnapshot snap) {
      setState(() {
        data = snap.data();
      });
      
    });
  }



  _setMarkerIcons () async{
    _sourceIcon = await getBytesFromAsset(Config().drivingMarkerIcon, 110);
    _destinationIcon = await getBytesFromAsset(Config().destinationMarkerIcon, 110);
  }







  Future addMarker() async {
    List m = [
      Marker(
      markerId: MarkerId(data['startpoint name']),
      position: LatLng(data['startpoint lat'], data['startpoint lng']),
      infoWindow: InfoWindow(title: data['startpoint name']),
      icon: BitmapDescriptor.fromBytes(_sourceIcon)
      
      ),
      Marker(
      markerId: MarkerId(data['endpoint name']),
      position: LatLng(data['endpoint lat'], data['endpoint lng']),
      infoWindow: InfoWindow(title: data['endpoint name']),
      icon: BitmapDescriptor.fromBytes(_destinationIcon)
      )
    ];
    setState(() {
      m.forEach((element) {
        _markers.add(element);
      });
    });

    
  }




 Future computeDistance() async{
  var p1 = geo.LatLng(data['startpoint lat'], data['startpoint lng']);
  var p2 = geo.LatLng(data['endpoint lat'], data['endpoint lng']);
  double _distance = geo.computeDistanceBetween(p1, p2)/1000;
  setState(() {
    distance = '${_distance.toStringAsFixed(2)} km';
  });
  
}

  

  Future _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Config().mapAPIKey,
        PointLatLng(data['startpoint lat'], data['startpoint lng']),
        PointLatLng(data['endpoint lat'], data['endpoint lng']),
        travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }



  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id, 
      color: Color.fromARGB(255, 40, 122, 198), 
      points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }


  


  void animateCamera() {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(data['startpoint lat'], data['startpoint lng']),
        zoom: 8,
        bearing: 120
        
      )));
  }



  void onMapCreated(controller) {
    controller.setMapStyle(MapUtils.mapStyles);
    setState(() {
      mapController = controller;
    });
  }

  


  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(milliseconds: 0))
    .then((value) async{
      context.read<AdsBloc>().initiateAds();
    });
    _setMarkerIcons();
    getData().then((value) => addMarker().then((value){
      _getPolyline();
      computeDistance();
      animateCamera();
    }));
    
  }



  Widget panelUI() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "travel guide",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ).tr(),
          ],
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.normal),
            text: 'estimated cost = '.tr(),
            children: <TextSpan>[
              TextSpan(
                style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold),
                text: data['price']
              )
            ]
          )),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.normal),
            text: 'distance = '.tr(),
            children: <TextSpan>[
              TextSpan(
                style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold),
                text: distance
              )
            ]
          )),
        
        
        Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: 170,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40)),
                  ),

        Container(
          padding: EdgeInsets.all(15),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Text('steps', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),).tr(),
            Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40)),
                  ),
          ],)
        ),
        Expanded(
          child: data.isEmpty ? Center(child: CircularProgressIndicator(),) :
          ListView.separated(
            padding: EdgeInsets.only(bottom: 10),
            itemCount: data['paths'].length,

            itemBuilder: (BuildContext context, int index) {

              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(radius: 15, child: Text('${index + 1}', style: TextStyle(color: Colors.white),),backgroundColor: ColorList().guideColors[index]),
                        Container(
                          height: 90,
                          width: 2,
                          color: Colors.black12,
                        )

                      ],
                    ),
                    SizedBox(width: 15,),
                    Container(
                      child: Expanded(
                    child: Text(
                    data['paths'][index],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
                  ),
                      ),
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox();
            },
          ),
        ),
      ],
    );
  }



  Widget panelBodyUI(h, w) {
    return Container(
      width: w,
      child: GoogleMap(
        
        initialCameraPosition: Config().initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) => onMapCreated(controller),
        markers: Set.from(_markers),
        polylines: Set<Polyline>.of(polylines.values),
        compassEnabled: false,
        myLocationEnabled: false,
        zoomGesturesEnabled: true,
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return new Scaffold(
        body: SafeArea(
      child: Stack(children: <Widget>[
      SlidingUpPanel(
            minHeight: 125,
            maxHeight: MediaQuery.of(context).size.height * 0.80,
             backdropEnabled: true,
             backdropOpacity: 0.2,
             backdropTapClosesPanel: true,
             isDraggable: true,
             
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey[400], blurRadius: 4, offset: Offset(1, 0))
            ],
            
            padding: EdgeInsets.only(top: 15, left: 10, bottom: 0, right: 10),
            panel: panelUI(),
            body: panelBodyUI(h, w)),
      
      
      
      
      Positioned(
          top: 15,
          left: 10,
          child: Container(
            
            child: Row(
              children: <Widget>[
                InkWell(
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey[300],
                              blurRadius: 10,
                              offset: Offset(3, 3))
                        ]),
                    child: Icon(Icons.keyboard_backspace),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                data.isEmpty 
                ? Container() 
                : Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey, width: 0.5)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15, top: 10, bottom: 10, right: 15),
                    child: Text(
                        '${data['startpoint name']} - ${data['endpoint name']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    
                  ),
                ),
              ],
            ),
          ),
      ),

      data.isEmpty && polylines.isEmpty
          ? Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),) 
          : Container()
    ]),
        ));
  }
}
