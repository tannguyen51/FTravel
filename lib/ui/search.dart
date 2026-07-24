import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../blocs/place/placeList_bloc.dart';
import '../blocs/place/place_event.dart';
import '../models/place.dart';
import 'placeDeatailsScreen/locationDetails.dart';

class search extends StatefulWidget {

  final isTextFieldClicked;
  final searchType;
  final isSelectPlaces;

  const search({required this.isTextFieldClicked,required this.searchType,required this.isSelectPlaces, Key? key}) : super(key: key);

  @override
  State<search> createState() => _searchState(isTextFieldClicked,searchType,isSelectPlaces);
}

 class _searchState extends State<search> {

  var isTextFieldClicked;
  var searchType;
  var isSelectPlaces;
  var isDataReady;
  var data;
  var inputData="";
  var capitalizedString="";
  String keyboardInput='';
  Timer? _timer;
  List selectedIds =[{
      'day':"" ,
      'places':[],
    }];
  bool isOnLongPress = false;
  late List<Place> RecentlySearchList = [];
  
  _searchState( this.isTextFieldClicked,this.searchType,this.isSelectPlaces);

  Future<List> getAllPlaces() async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref('places');
      final event = await databaseReference.once();
      final data = event.snapshot.value as List<dynamic>;

      final results = data.map((element) {
        return {
          'name': element['title'] ?? '',
          'id': element['placeId'],
          'photoRef': element['imageUrls'] != null && element['imageUrls'].isNotEmpty
              ? element['imageUrls'][0]
              : '',
          'rating': element['rating'] ?? 3.0,
          'address': element['address'] ?? '',
          'type': element['categoryName'] ?? 'attraction',
        };
      }).toList();

      inputData = "";
      return results;
    } catch (e) {
      return [];
    }
  }

 
   @override
  void initState() {
    super.initState();
    
    
    setState(() {

      isTextFieldClicked; 
     });
   
     
  }


  
String capitalize(String s) =>s.isNotEmpty? s[0].toUpperCase() + s.substring(1):'';
 

  @override
  Widget build(BuildContext context) {
    
    return 
       Scaffold(
        body:Column(
          children: [
            Visibility(
              visible: !isTextFieldClicked,
              child: Padding(
                padding: const EdgeInsets.only(left:13.0,top:40.0,bottom:6.0),
                child: Row(
                  children: [
                    Text("Search",
                          style: GoogleFonts.nunito(
                                      // ignore: prefer_const_constructors
                                      textStyle: TextStyle(
                                      color: const Color.fromARGB(255, 27, 27, 27),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,

                                      )
                                    )

                        ),

                  ]
                ),
              ),
            ),
            Padding(
              padding:isTextFieldClicked? const EdgeInsets.only(top:40):const EdgeInsets.only(top:25),
              child: Row(
            
                children: [
                   Visibility(
                    visible: isTextFieldClicked,
                     child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: const Color.fromARGB(255, 145, 144, 144),
                        iconSize: 26,
                        onPressed: () {
                   
                          setState(() {
                          isTextFieldClicked = false;
                          });       
                   
                          // Handle back button press
                        },
                     ),
                   ),
                   
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        
                       
                        height: 37,
                        
                        child:  TextField(
                          
                          onTap: () {
                            setState(() {
                              isTextFieldClicked = true;
                              //searchResults = [];
                              isOnLongPress = false;
                            });
                          },
                          //get keyboard input value-------------
                          onChanged: (value) {
                             //if text filed is empty do this------------------ 
                            if(value !=''){
                              if (_timer?.isActive ?? false) _timer!.cancel();
                              _timer = Timer(const Duration(milliseconds: 1000), () {

                                setState(() {
                                 inputData=value;
                                 print(inputData);
                                });

                              });
                              isTextFieldClicked = true;
                            }

                          },
                          decoration: InputDecoration(
                          filled: true,
                          fillColor:  const Color.fromARGB(255, 240, 238, 238),
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          hintStyle: GoogleFonts.cabin(
                                        // ignore: prefer_const_constructors
                                        textStyle: TextStyle(
                                        color: const Color.fromARGB(255, 145, 144, 144),
                                        fontSize: 17,
                                        fontWeight:FontWeight.w400,
                                        
                                        ) 
                                      ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(19.0),
                            
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                          ),
                      
                      
                        ),
                      ),
                    ),
                  )

            
                ],
                   
                      
                  
              ),
            ),
            Visibility(
              visible: !isTextFieldClicked,
              child: Padding(
                 padding: const EdgeInsets.only(left:13,top:30),
                child: Row(
              
                  children: [
                    Text("Your recent searches",
                      style: GoogleFonts.cabin(
                            // ignore: prefer_const_constructors
                            textStyle: TextStyle(
                            color: const Color.fromARGB(255, 27, 27, 27),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                    
                            ) 
                          )
                            
                    
                    ),
              
                  ],
              
                ),
              ),
            ),
            //show search results-----------------------------------
              FutureBuilder(
              future: getAllPlaces(),
              builder: (BuildContext context, results) { 
                
                if(results.connectionState==ConnectionState.waiting){
                  return
                  LoadingAnimationWidget.discreteCircle(
                    color: const Color.fromARGB(255, 129, 129, 129), 
                    size: 12,
                  );
                }

                if(results.hasData){

                  return
                    Visibility(
                      visible: isTextFieldClicked,
                      child: Expanded(
                        child:Stack(
                          children:[ 
                            ScrollConfiguration(
                              behavior:const ScrollBehavior(),
                              child: GlowingOverscrollIndicator(
                                axisDirection: AxisDirection.down,
                                color:const Color.fromARGB(255, 100, 100, 100),
                                child: ListView.builder(
                                  itemCount: results.data?.length,
                                  itemBuilder: (context, index) {
                                    final searchRe = results.data?[index];
                                    final name = searchRe?['name'] ?? '';
                                    final photoReference = searchRe?['photoRef'] ?? '';
                                    final placeId = searchRe?['id'] ?? '';
                                    final placeType = searchRe?['type'] ?? 'attraction';
                                    
                                                          
                                    return Column(
                                      children: [
                                        //set bottom border-----------------------------
                                        GestureDetector(
                                          onLongPress: () {
                                                          
                                            // visible only places select------------------- 
                                            if(isSelectPlaces ==true){
                                                          
                                              setState(() {
                                              isOnLongPress = true;
                                            });
                                                          
                                            }
                                            
                                            
                                          },
                                          onTap: () {

                                            if(isOnLongPress!= true){

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) =>  locationDetails(placeId: placeId, searchType: placeType)),
                                              );

                                              // Add to recent searches
                                              try {
                                                BlocProvider.of<placeListBloc>(context).add(
                                                  addUserRecentlySearch(
                                                    id: results.data![index]['id'] ?? '',
                                                    name: results.data![index]['name'] ?? '',
                                                    address: results.data![index]['address'] ?? '',
                                                    openingHours: results.data![index]['openingHours'] ?? [],
                                                    phone: results.data![index]['phone'] ?? '',
                                                    photoRef: results.data![index]['photoRef'] ?? '',
                                                    type: results.data![index]['type'] ?? '',
                                                    latitude: results.data![index]['latitude'] ?? 0.0,
                                                    longitude: results.data![index]['longitude'] ?? 0.0,
                                                  ),
                                                );
                                              } catch (_) {}

                                            }

                                          },
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left:6),
                                                child: Container(
                                                  width: 340,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: const Color.fromARGB(255, 226, 226, 226).withOpacity(0.5), 
                                                        width: 1, 
                                                      ),
                                                    ),
                                                  ),//------------------------
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 9),
                                                          child: SizedBox(
                                                            width:37,
                                                            height:37,
                                                            child: CircleAvatar(
                                                              radius: 40,
                                                              backgroundImage:NetworkImage(photoReference!),
                                                              
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left:6),
                                                          child: Column(
                                                            
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(bottom:4),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width:245,
                                                                      child: Text(name!,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: GoogleFonts.cabin(
                                                                          // ignore: prefer_const_constructors
                                                                          textStyle: TextStyle(
                                                                          color: const Color.fromARGB(255, 27, 27, 27),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w700,
                                                                                                                  
                                                                          ) 
                                                                        )
                                                                      ),
                                                                    ),
                                                                    
                                                                  ],
                                                                ),
                                                              ),
                                                              
                                                            ],
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: isOnLongPress,
                                                          child: InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                        
                                                                if(selectedIds[0]['places'].contains(placeId)){
                                                                selectedIds[0]['places'].remove(placeId);
                                                        
                                                                }else{
                                                                  selectedIds[0]['places'].add(placeId);
                                                        
                                                                }
                                                                
                                                              });
                                                        
                                                                  print(selectedIds);
                                                            },
                                                            child: SizedBox(
                                                              height: 25,
                                                              width: 25,
                                                              child:selectedIds[0]['places'].contains(placeId)?Image.asset("assets/images/correct.png") :Image.asset("assets/images/dry-clean.png")
                                                              
                                                              ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ), 
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        
                                              
                                      ],
                                              
                                    );
                                          
                                  }
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isOnLongPress,
                              child: Positioned(
                                top:565,
                                left:95,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                                width: 155,
                                                height: 45,
                                                child: TextButton(
                                                  onPressed:() async{
                                                    
                                                    // if(isSelectPlaces == true){

                                                    //   BlocProvider.of<tripBloc>(context).add(addTripPalcesEvent(isEditTrip:true, placesIds: selectedIds, tripId: ''));

                                                    //   Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(builder: (context) =>  tripDetailsPlan(isSelectPlaces: true,isEditPlace: true, isAddPlace: false,)));
                                                    // }else{

                                                    //   BlocProvider.of<tripBloc>(context).add(addTripPalcesEvent(isEditTrip:false, placesIds: [], tripId: ''));
                  
                                                    //   Navigator.push(
                                                    //   context,
                                                    //   MaterialPageRoute(builder: (context) =>  tripDetailsPlan(isSelectPlaces: true,isEditPlace: false, isAddPlace: false,)));
                  
                                                    // }  
                                                    
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                                                    foregroundColor:const Color.fromARGB(255, 255, 255, 255),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20), 
                                                      ),
                                                    
                                                  ),
                                                  child: Text('Add to trip',
                                                      style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                          
                                                  
                                                      ),
                                                  
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                                
                              ),
                            )
                          ]
                        )
                        
                        
                      ),
                    );

                }else{

                  return
                    LoadingAnimationWidget.waveDots(
                      color: const Color.fromARGB(255, 129, 129, 129), 
                      size: 35,
                    );

                }

               },
              
            ),
            //------------------------------------------------------
            Visibility(
              visible: !isTextFieldClicked,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<List<Place>>(
                  future:placeBloc.getUserRecentlySearch(),
                  builder: (BuildContext context, AsyncSnapshot<List<Place>> recentlySearch) { 
                    
                    if(recentlySearch.hasData ){
                    
                      RecentlySearchList =recentlySearch.data!;  
                      return
                         SizedBox(height: 300,
                           child: ScrollConfiguration(
                             behavior:const ScrollBehavior(),
                             child: GlowingOverscrollIndicator(
                               axisDirection: AxisDirection.down,
                               color:const Color.fromARGB(255, 0, 0, 0),
                               child: ListView.builder(
                                 shrinkWrap: true,
                                 physics: const ScrollPhysics(),
                                 scrollDirection: Axis.vertical,
                                 itemCount: recentlySearch.data!.length,
                                 itemBuilder: (context, index) {
                                   final place = recentlySearch.data![index];
                                   return Padding(
                                     padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                     child: GestureDetector(
                                       onTap: () {
                                         Navigator.push(
                                           context,
                                           MaterialPageRoute(builder: (context) => locationDetails(placeId: place.id, searchType: place.type)));
                                       },
                                       child: Container(
                                         width: 360,
                                         height: 90,
                                         decoration: BoxDecoration(
                                           color: const Color.fromARGB(255, 240, 238, 238),
                                           borderRadius: BorderRadius.circular(12),
                                         ),
                                         child: Row(
                                           children: [
                                             ClipRRect(
                                               borderRadius: const BorderRadius.only(
                                                 topLeft: Radius.circular(12),
                                                 bottomLeft: Radius.circular(12),
                                               ),
                                               child: Container(
                                                 width: 90,
                                                 height: 90,
                                                 decoration: BoxDecoration(
                                                   image: DecorationImage(
                                                     image: NetworkImage(place.photoRef),
                                                     fit: BoxFit.cover,
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             const SizedBox(width: 10),
                                             Expanded(
                                               child: Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                 children: [
                                                   Text(
                                                     place.name,
                                                     style: GoogleFonts.cabin(
                                                       textStyle: const TextStyle(
                                                         color: Color.fromARGB(255, 27, 27, 27),
                                                         fontSize: 14,
                                                         fontWeight: FontWeight.bold,
                                                       ),
                                                     ),
                                                     overflow: TextOverflow.ellipsis,
                                                   ),
                                                   const SizedBox(height: 4),
                                                   Row(
                                                     children: [
                                                       Image.asset("assets/images/star.png", width: 14, height: 14),
                                                       const SizedBox(width: 4),
                                                       Text(
                                                         "${place.rating}",
                                                         style: GoogleFonts.cabin(
                                                           textStyle: const TextStyle(
                                                             color: Color.fromARGB(255, 95, 95, 95),
                                                             fontSize: 12,
                                                             fontWeight: FontWeight.bold,
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                   if (place.address.isNotEmpty) ...[
                                                     const SizedBox(height: 4),
                                                     Row(
                                                       children: [
                                                         Image.asset('assets/images/location.png', width: 12, height: 12, color: Colors.grey),
                                                         const SizedBox(width: 4),
                                                         Expanded(
                                                           child: Text(
                                                             place.address,
                                                             overflow: TextOverflow.ellipsis,
                                                             style: GoogleFonts.cabin(
                                                               textStyle: const TextStyle(
                                                                 color: Color.fromARGB(255, 94, 94, 94),
                                                                 fontSize: 10,
                                                                 fontWeight: FontWeight.bold,
                                                               ),
                                                             ),
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ],
                                                 ],
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                     ),
                                   );
                                                          
                                  },
                                 
                               ),
                             ),
                           ),
                         );
                    }else{

                      return Container();
                    }

                     

                   },
                  
                ),
              ),
            ),

          ],
        )
         
        );
        
  
  }
}