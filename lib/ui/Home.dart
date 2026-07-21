import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../blocs/user/user_bloc.dart';
import 'placeDeatailsScreen/locationDetails.dart';

class home extends StatefulWidget {

  final bool isBackButtonClick;

  const home({required this.isBackButtonClick, Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();

}

class _homeState extends State<home> {

  List<Map<String, dynamic>> attractionList = [];
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    getNearByPlaces();
  }

  late List<Map<String, dynamic>> categorieList = [
    {"photo":"assets/images/hotel.png","name":"Hotel"},
    {"photo":"assets/images/burger.png","name":"Cafes"},
    {"photo":"assets/images/forest.png","name":"Parks"},
    {"photo":"assets/images/flash.png","name":"Attractions"},
    {"photo":"assets/images/gas-pump.png","name":"Gas station"},
  ];

  Future <void> getNearByPlaces ()async{
    final databaseReference = FirebaseDatabase.instance.ref('places');
    final dataSnapshot = await databaseReference.once();
    final data = dataSnapshot.snapshot.value as List<dynamic>;

    List results = data.map((element) {
      if (element['imageUrls'] != null && element['imageUrls'].isNotEmpty) {
        return {
          'name': element['title'],
          'id': element['placeId'],
          'photoRef': element['imageUrls'][0],
          'rating': element['rating'] ?? 3.0,
          'address': element['address'],
          'type': element['categoryName'] ?? 'attraction',
        };
      }
      return null;
    }).where((element) => element != null).toList();

    setState(() {
      attractionList = results.cast<Map<String, dynamic>>();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if(isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ColorfulSafeArea(
      overflowRules: const OverflowRules.all(true),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Greeting
            Padding(
              padding: const EdgeInsets.only(left:13.0,top:30.0,bottom:15.0),
              child: Row(
                children: [
                  FutureBuilder(
                    future: userBlo.getUserDetails(),
                    builder: (BuildContext context, AsyncSnapshot<auth.User?> snapshot) {
                      if(snapshot.hasData){
                        return SizedBox(
                          width:250,
                          child: Text("Hi ${snapshot.data!.displayName}",
                            style: GoogleFonts.nunito(
                              textStyle: const TextStyle(
                                color: Color.fromARGB(255, 27, 27, 27),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              )
                            )
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
            // Categories
            Padding(
              padding: const EdgeInsets.only(left:13.0,right:6),
              child: SizedBox(
                height:45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categorieList.length,
                  itemBuilder: (context, index) {
                    final categorie = categorieList[index];
                    return GestureDetector(
                      onTap:() =>{},
                      child: Card(
                        elevation: 0,
                        color:const Color.fromARGB(255, 240, 238, 238),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        child: SizedBox(
                          width: 101,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(categorie['photo'], width: 23, height:23),
                              Padding(
                                padding: const EdgeInsets.only(left:5.0),
                                child: Text(categorie['name'],
                                  style: GoogleFonts.cabin(
                                    textStyle: const TextStyle(
                                      color: Color.fromARGB(255, 27, 27, 27),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )
                                  )
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
            // Section Title
            Padding(
              padding: const EdgeInsets.only(left:14.0,top:20),
              child: Row(
                children: [
                  Text("Nearby experiences",
                    style: GoogleFonts.cabin(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 27, 27, 27),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                    )
                  ),
                ],
              ),
            ),
            // Attractions List
            Padding(
              padding: const EdgeInsets.only(left:13.0,top:10),
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: attractionList.length,
                  itemBuilder: (context, index) {
                    final item = attractionList[index];
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => locationDetails(
                            placeId: item['id'], searchType: item['type'] == 'locality' ? 'city' : 'attraction'
                          ))
                        );
                      },
                      child: Card(
                        elevation: 0,
                        color:const Color.fromARGB(255, 240, 238, 238),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: SizedBox(
                          width: 230,
                          child: Column(
                            children: [
                              Container(
                                width: 230,
                                height: 130,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(item['photoRef']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cabin(
                                        textStyle: const TextStyle(
                                          color: Color.fromARGB(255, 27, 27, 27),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        )
                                      )
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Image.asset("assets/images/star.png",width:14,height:14),
                                        const SizedBox(width: 4),
                                        Text("${item['rating']}",
                                          style: GoogleFonts.cabin(
                                            textStyle: const TextStyle(
                                              color: Color.fromARGB(255, 27, 27, 27),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            )
                                          )
                                        ),
                                      ],
                                    ),
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
          ],
        ),
      ),
    );
  }
}
