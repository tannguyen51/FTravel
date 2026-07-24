import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:travelapp/ui/components/shimmer.dart';
import 'package:travelapp/ui/createTrip.dart';
import 'package:travelapp/ui/placeDeatailsScreen/placeCoverImage.dart';
import 'package:travelapp/ui/placeDeatailsScreen/placeDescreption.dart';
import 'package:travelapp/ui/tripDetailsPlan.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/place/placeList_bloc.dart';
import '../../blocs/place/place_event.dart';
import '../../blocs/place/place_state.dart';
import '../../blocs/trip/trip_bloc.dart';
import '../../models/place.dart';
import '../../models/trip.dart';
import '../../repositories/user/userAuth_repo.dart';
import '../../timeAgoSinceDate.dart';
import '../components/shimmerLoading.dart';
import '../components/topButtonIndicator.dart';
import 'placesList.dart';
import 'reviewList.dart';

class locationDetails extends StatefulWidget {
  final placeId;
  final searchType;

  const locationDetails(
      {required this.placeId, required this.searchType, Key? key})
      : super(key: key);

  @override
  State<locationDetails> createState() =>
      _locationDetailsState(placeId, searchType);
}

class _locationDetailsState extends State<locationDetails> {
  final placeId;
  final searchType;
  late List isAddFavorite;
  var favorites = [];
  final reviewTextController = TextEditingController();
  List<bool> isaddAttractionToFavorite = [];
  late final String placeType;
  late Place placeDetails;
  bool isShowReviews = false;
  List currentReviews = [];
  String reviewText = "";
  late String userName;
  late String proPic;
  late String? userId;
  bool isfirstLoading = true;
  bool isLoading = true;

  final _shimmerGradient = const LinearGradient(
    colors: [
      Color(0xFFEBEBF4),
      Color(0xFFF4F4F4),
      Color(0xFFEBEBF4),
    ],
    stops: [
      0.1,
      0.3,
      0.4,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );

  _locationDetailsState(this.placeId, this.searchType);

  @override
  void initState() {
    super.initState();
    getplacesDetails();
    initializeData();
  }

  void initializeData() async {
    // Perform asynchronous operations here
    userAuthRep.onAuthStateChanged.listen((user) {
      setState(() {
        userId = user!.uid;
        userName = user.displayName ?? "";
        proPic = user.photoURL ??
            "https://cdn-icons-png.flaticon.com/64/3177/3177440.png";
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    reviewTextController.dispose();
  }

  Future<void> getplacesDetails() async {
    placeDetails = await placeBloc.getPlaceDetailes(placeId, searchType);
    setState(() {
      placeDetails;
      isLoading = false;
    });
  }

  void addReview() {
    if (currentReviews.isEmpty && isfirstLoading == true) {
      currentReviews = placeDetails.reviews;
      isfirstLoading = false;
    }

    var uuid = const Uuid();
    final newReview = {
      "userId": userId,
      "reviewId": uuid.v1(),
      "name": userName,
      "publishAt": DateTime.now(),
      "reviewerPhotoUrl": proPic,
      "text": reviewText,
    };

    setState(() {
      currentReviews.add(newReview);
    });

    BlocProvider.of<placeListBloc>(context)
        .add(addReviewEvent(currentReviews, searchType, placeId, userId!));
  }

  void deleteReview(reviews) {
    if (isfirstLoading == true) {
      currentReviews = reviews;
      isfirstLoading = false;
    }
    BlocProvider.of<placeListBloc>(context)
        .add(deleteReviewEvent(currentReviews, searchType, placeId, userId!));

    if (isfirstLoading == true) {
      currentReviews = reviews;
      isfirstLoading = false;
    }

    setState(() {
      currentReviews;
    });
  }

  bool isValidTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return true;
    } else if (timestamp is String) {
      try {
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  void navigateBack() async {
    setState(() {
      isLoading = true;
    });
    getplacesDetails();
  }

  @override
  Widget build(BuildContext context) {
    return locationDetailsBody(context);
  }

  Widget locationDetailsBody(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<placeListBloc, place_state>(
            listener: (context, state) {
              if (state is placeAddToFavoriteState) {
                if (state.isAdd == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("place is add to the favorites")));
                }
              } else if (state is placeRemoveFromFavoriteState) {
                if (state.isRemove == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Removed place from the favorites")));
                }
              }
            },
          ),
        ],
        child: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, true);
              return true;
            },
            child: Shimmer(
              linearGradient: _shimmerGradient,
              child: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  toolbarHeight: 2,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Color.fromARGB(0, 255, 255, 255),
                    statusBarIconBrightness: Brightness.light,
                  ),
                  elevation: 0,
                  backgroundColor: const Color.fromARGB(0, 20, 12, 12),
                ),
                body: buildBody(),
              ),
            )));
  }

  Widget buildBody() {
    // Return loading widget if data not ready
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: const Color.fromARGB(255, 83, 83, 83),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: 360,
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Stack(children: [
              Column(
                children: [
                  Row(
                    children: [
                      ShimmerLoading(
                          isLoading: isLoading,
                          child: !isLoading
                              ? PlaceCoveImage(
                                  isLoading: isLoading,
                                  placeDetails: placeDetails)
                              : Container(
                                  width: 360,
                                  height: 250,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                  ),
                                )),
                    ],
                  ),
                ],
              ),
              //data container---------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.only(top: 195),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 360,
                            child: Container(
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(27)),
                              child: Column(
                                //mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 16, left: 6),
                                          child: ShimmerLoading(
                                            isLoading: isLoading,
                                            child: !isLoading
                                                ? SizedBox(
                                                    width: 240,
                                                    child: Text(
                                                      placeDetails.name,
                                                      style: GoogleFonts.cabin(
                                                          // ignore: prefer_const_constructors
                                                          textStyle: TextStyle(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 27, 27, 27),
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 150,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        // Weather
                                        searchType == 'city'
                                            ? FutureBuilder<
                                                Map<String, dynamic>>(
                                                future: placeBloc.getWeather(
                                                    placeDetails.latitude,
                                                    placeDetails.longitude),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data!['icon'] !=
                                                          '') {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8, top: 10),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Image.network(
                                                            snapshot.data![
                                                                'iconUrl'],
                                                            width: 35,
                                                            height: 35,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${snapshot.data!['temperature'].toStringAsFixed(0)}°',
                                                            style: GoogleFonts
                                                                .cabin(
                                                              textStyle:
                                                                  const TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        27,
                                                                        27,
                                                                        27),
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox
                                                      .shrink();
                                                },
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),

                                  // ratings------------------------------------------------
                                  Visibility(
                                    visible: searchType != 'city',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, top: 6),
                                      child: Row(
                                        children: [
                                          ShimmerLoading(
                                            isLoading: isLoading,
                                            child: !isLoading
                                                ? RatingBar.builder(
                                                    itemSize: 15,
                                                    initialRating:
                                                        placeDetails.rating,
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 1.0),
                                                    itemBuilder: (context, _) =>
                                                        const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  )
                                                : Container(
                                                    width: 100,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                          ),

                                          ShimmerLoading(
                                            isLoading: isLoading,
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 7),
                                                child: !isLoading
                                                    ? Text(
                                                        '${placeDetails.rating}',
                                                        style: GoogleFonts.cabin(
                                                            // ignore: prefer_const_constructors
                                                            textStyle: TextStyle(
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 27, 27, 27),
                                                          fontSize: 15,
                                                          //fontWeight: FontWeight.bold,
                                                        )))
                                                    : Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                      )),
                                          ),
                                          //----------------------------------------------------------
                                        ],
                                      ),
                                    ),
                                  ),
                                  //place types------------------------------------------------------------
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, top: 4),
                                              child: ShimmerLoading(
                                                  isLoading: isLoading,
                                                  child: !isLoading
                                                      ? SizedBox(
                                                          width: 70,
                                                          height: 25,
                                                          child: Card(
                                                              elevation: 0,
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  240,
                                                                  238,
                                                                  238),
                                                              //clipBehavior: Clip.antiAliasWithSaveLayer,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            17.0),
                                                              ),
                                                              child: Container(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    FittedBox(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                4,
                                                                            right:
                                                                                4),
                                                                        child: Text(
                                                                            placeDetails.type,
                                                                            style: GoogleFonts.cabin(
                                                                                // ignore: prefer_const_constructors
                                                                                textStyle: TextStyle(
                                                                              color: const Color.fromARGB(255, 27, 27, 27),
                                                                              fontSize: 8,
                                                                              fontWeight: FontWeight.bold,
                                                                            ))),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10),
                                                          child: Container(
                                                            width: 70,
                                                            height: 15,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255, 3, 3, 3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                          ),
                                                        ))),
                                        ],
                                      ),
                                    ],
                                  ),

                                  //open times---------------------------------------------------------------------------------
                                  Visibility(
                                    visible: searchType != 'city',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13, top: 5),
                                      child: Column(
                                        children: [
                                          ShimmerLoading(
                                              isLoading: isLoading,
                                              child: !isLoading
                                                  ? Column(
                                                      children:
                                                          placeDetails
                                                              .openingHours
                                                              .map<Widget>(
                                                                  (time) =>
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                4.0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text(
                                                                              time['day'],
                                                                              style: GoogleFonts.cabin(
                                                                                textStyle: const TextStyle(
                                                                                  color: Color.fromARGB(255, 27, 27, 27),
                                                                                  fontSize: 8,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 12),
                                                                              child: Text(
                                                                                time['hours'],
                                                                                style: GoogleFonts.cabin(
                                                                                  textStyle: const TextStyle(
                                                                                    color: Color.fromARGB(255, 27, 27, 27),
                                                                                    fontSize: 8,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ))
                                                              .toList(),
                                                    )
                                                  : SizedBox(
                                                      height: 150,
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount: 7,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom: 7),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                50,
                                                                            height:
                                                                                8,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.black,
                                                                              borderRadius: BorderRadius.circular(16),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 12),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                15,
                                                                            height:
                                                                                8,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.black,
                                                                              borderRadius: BorderRadius.circular(16),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //phone number--------------------------------------------------------------
                                  Visibility(
                                    visible: searchType != 'city',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13, top: 7),
                                      child: Row(
                                        children: [
                                          ShimmerLoading(
                                            isLoading: isLoading,
                                            child: !isLoading
                                                ? Text(
                                                    placeDetails.phone,
                                                    style: GoogleFonts.cabin(
                                                      textStyle:
                                                          const TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      19,
                                                                      148,
                                                                      223),
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 100,
                                                    height: 11,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  // about details on the place----------------------------------------------------
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 13, top: 7),
                                    child: Row(
                                      children: [
                                        ShimmerLoading(
                                          isLoading: isLoading,
                                          child: !isLoading
                                              ? Text(
                                                  "About",
                                                  style: GoogleFonts.cabin(
                                                    textStyle: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              : Container(
                                                  width: 100,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 13,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ShimmerLoading(
                                          isLoading: isLoading,
                                          child: placeDescription(
                                            hasData: !isLoading,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //place address ----------------------------------------------------------
                                  Visibility(
                                    visible: searchType != 'city',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13, top: 7),
                                      child: Row(
                                        children: [
                                          ShimmerLoading(
                                            isLoading: isLoading,
                                            child: !isLoading
                                                ? Text(
                                                    "Address",
                                                    style: GoogleFonts.cabin(
                                                      textStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 100,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: searchType != 'city',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13, top: 5),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 250,
                                            child: ShimmerLoading(
                                              isLoading: isLoading,
                                              child: !isLoading
                                                  ? Text(
                                                      placeDetails.address,
                                                      style: GoogleFonts.cabin(
                                                        textStyle:
                                                            const TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        19,
                                                                        148,
                                                                        223),
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 200,
                                                      height: 11,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  //google map------------------------------------------------------------
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 13, top: 8),
                                    child: Row(
                                      children: [
                                        ShimmerLoading(
                                          isLoading: isLoading,
                                          child: !isLoading
                                              ? Text(
                                                  "How to get there",
                                                  style: GoogleFonts.cabin(
                                                    textStyle: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              : Container(
                                                  width: 220,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                        )
                                      ],
                                    ),
                                  ),
                                  //Attractions in this place-------------------------------------------------------

                                  Visibility(
                                    visible: searchType == 'city',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13, top: 14),
                                      child: Row(
                                        children: [
                                          ShimmerLoading(
                                            isLoading: isLoading,
                                            child: !isLoading
                                                ? Text(
                                                    "Attractions in ${placeDetails.name}",
                                                    style: GoogleFonts.cabin(
                                                      textStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 150,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  //list------------------------------------------------------

                                  Visibility(
                                      visible: searchType == "city",
                                      child: ShimmerLoading(
                                          isLoading: isLoading,
                                          child: placesList(
                                            placeName: !isLoading
                                                ? placeDetails.name
                                                : 'nan',
                                            placeType: 'attraction',
                                            navigateBackState: (val) {
                                              if (val == true) {
                                                navigateBack();
                                              }
                                            },
                                          ))),

                                  //show resturents----------------------------------------------
                                  Visibility(
                                    visible: searchType == 'city',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13, top: 14),
                                      child: Row(
                                        children: [
                                          ShimmerLoading(
                                            isLoading: isLoading,
                                            child: !isLoading
                                                ? Text(
                                                    "Where to stay and eat ",
                                                    style: GoogleFonts.cabin(
                                                      textStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 150,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  //resturents list-------------------------------------------------------------

                                  Visibility(
                                      visible: searchType == "city",
                                      child: ShimmerLoading(
                                          isLoading: isLoading,
                                          child: placesList(
                                            placeName: !isLoading
                                                ? placeDetails.name
                                                : 'nan',
                                            placeType: 'restaurant',
                                            navigateBackState: (val) {
                                              if (val == true) {
                                                navigateBack();
                                              }
                                            },
                                          ))),

                                  //reviews-----------------------------------------------------------------
                                  Visibility(
                                    visible: isLoading,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15, left: 10),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: 340,
                                              height: 150,
                                              decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 240, 238, 238),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  !isLoading &&
                                          placeDetails.reviews.isNotEmpty &&
                                          isfirstLoading
                                      ? Visibility(
                                          visible: searchType != 'city',
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15, left: 10),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      isDismissible: false,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      isScrollControlled: true,
                                                      useSafeArea: true,
                                                      barrierLabel:
                                                          MaterialLocalizations
                                                                  .of(context)
                                                              .modalBarrierDismissLabel,
                                                      barrierColor:
                                                          const Color.fromARGB(
                                                                  137, 0, 0, 0)
                                                              .withOpacity(
                                                                  0.35),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      builder: (context) =>
                                                          reviewList(
                                                        mFPAddReview: addReview,
                                                        currentReviews:
                                                            currentReviews
                                                                    .isNotEmpty
                                                                ? currentReviews
                                                                : placeDetails
                                                                    .reviews,
                                                        reviewText:
                                                            (String val) {
                                                          reviewText = val;
                                                        },
                                                        deleteReviews:
                                                            (List<dynamic>
                                                                val) {
                                                          deleteReview(val);
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                      width: 340,
                                                      decoration: const BoxDecoration(
                                                          color: Color
                                                              .fromARGB(255,
                                                              240, 238, 238),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15))),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 7,
                                                                    left: 10),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  'Reviews',
                                                                  style:
                                                                      GoogleFonts
                                                                          .cabin(
                                                                    textStyle: const TextStyle(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5),
                                                                  child: Text(
                                                                    '${currentReviews.isNotEmpty ? currentReviews.length : placeDetails.reviews.length}',
                                                                    style: GoogleFonts
                                                                        .cabin(
                                                                      textStyle: const TextStyle(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              112,
                                                                              112,
                                                                              112),
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 10,
                                                                    left: 10,
                                                                    bottom: 10),
                                                            child: Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 35,
                                                                  height: 35,
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius: 40,
                                                                    backgroundImage: NetworkImage(currentReviews
                                                                            .isNotEmpty
                                                                        ? currentReviews[currentReviews.length -
                                                                                1]
                                                                            [
                                                                            "reviewerPhotoUrl"]
                                                                        : placeDetails
                                                                            .reviews[placeDetails
                                                                                .reviews.length -
                                                                            1]["reviewerPhotoUrl"]),
                                                                  ),
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          260,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 13),
                                                                            child:
                                                                                SizedBox(
                                                                              child: Text(
                                                                                currentReviews.isNotEmpty ? currentReviews[currentReviews.length - 1]["name"] : placeDetails.reviews[placeDetails.reviews.length - 1]["name"],
                                                                                style: GoogleFonts.cabin(
                                                                                  textStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 13, fontWeight: FontWeight.w600),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 13),
                                                                            child:
                                                                                SizedBox(
                                                                              child: Text(
                                                                                currentReviews.isNotEmpty ? TimeAgoSince.timeAgoSinceDate(currentReviews[currentReviews.length - 1]["publishAt"]) : TimeAgoSince.timeAgoSinceDate(placeDetails.reviews[placeDetails.reviews.length - 1]["publishAt"].toDate()),
                                                                                style: GoogleFonts.cabin(
                                                                                  textStyle: const TextStyle(color: Color.fromARGB(255, 112, 112, 112), fontSize: 12, fontWeight: FontWeight.w300),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              13),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            250,
                                                                        child:
                                                                            Text(
                                                                          currentReviews.isNotEmpty
                                                                              ? currentReviews[currentReviews.length - 1]["text"]
                                                                              : placeDetails.reviews[placeDetails.reviews.length - 1]["text"],
                                                                          style:
                                                                              GoogleFonts.cabin(
                                                                            textStyle: const TextStyle(
                                                                                color: Color.fromARGB(255, 112, 112, 112),
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      : currentReviews.isEmpty
                                          ? Visibility(
                                              visible: searchType != 'city',
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15, left: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 340,
                                                      height: 150,
                                                      decoration: const BoxDecoration(
                                                          color: Color
                                                              .fromARGB(255,
                                                              240, 238, 238),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15))),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 13,
                                                                    left: 10,
                                                                    bottom: 10),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          290,
                                                                      height:
                                                                          45,
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            reviewTextController,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          hintText:
                                                                              "Add first review for this place",
                                                                          filled:
                                                                              true,
                                                                          contentPadding:
                                                                              const EdgeInsets.only(left: 14),
                                                                          fillColor: const Color.fromARGB(
                                                                              255,
                                                                              207,
                                                                              207,
                                                                              207),
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(25.0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              width: 0,
                                                                              style: BorderStyle.none,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          reviewText =
                                                                              reviewTextController.text;
                                                                          addReview();
                                                                          reviewTextController.text =
                                                                              "";
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              34,
                                                                          height:
                                                                              34,
                                                                          child:
                                                                              Image.asset('assets/images/chat-arrow-before.png'),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Visibility(
                                              visible: searchType != 'city',
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15, left: 10),
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        showModalBottomSheet(
                                                          isDismissible: false,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          useSafeArea: true,
                                                          barrierLabel:
                                                              MaterialLocalizations
                                                                      .of(context)
                                                                  .modalBarrierDismissLabel,
                                                          barrierColor:
                                                              const Color
                                                                      .fromARGB(
                                                                      137,
                                                                      0,
                                                                      0,
                                                                      0)
                                                                  .withOpacity(
                                                                      0.35),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          builder: (context) =>
                                                              reviewList(
                                                            mFPAddReview:
                                                                addReview,
                                                            currentReviews:
                                                                currentReviews,
                                                            reviewText:
                                                                (String val) {
                                                              reviewText = val;
                                                            },
                                                            deleteReviews:
                                                                (List<dynamic>
                                                                    val) {
                                                              deleteReview(val);
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                          width: 340,
                                                          decoration: const BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                  255,
                                                                  240,
                                                                  238,
                                                                  238),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          15))),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 7,
                                                                        left:
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Reviews',
                                                                      style: GoogleFonts
                                                                          .cabin(
                                                                        textStyle: const TextStyle(
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        '${currentReviews.isNotEmpty ? currentReviews.length : placeDetails.reviews.length}',
                                                                        style: GoogleFonts
                                                                            .cabin(
                                                                          textStyle: const TextStyle(
                                                                              color: Color.fromARGB(255, 112, 112, 112),
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 35,
                                                                      height:
                                                                          35,
                                                                      child:
                                                                          CircleAvatar(
                                                                        radius:
                                                                            40,
                                                                        backgroundImage: NetworkImage(currentReviews.isNotEmpty
                                                                            ? currentReviews[currentReviews.length -
                                                                                1]["reviewerPhotoUrl"]
                                                                            : placeDetails.reviews[placeDetails.reviews.length - 1]["reviewerPhotoUrl"]),
                                                                      ),
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              260,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 13),
                                                                                child: SizedBox(
                                                                                  child: Text(
                                                                                    currentReviews.isNotEmpty ? currentReviews[currentReviews.length - 1]["name"] : placeDetails.reviews[placeDetails.reviews.length - 1]["name"],
                                                                                    style: GoogleFonts.cabin(
                                                                                      textStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 13, fontWeight: FontWeight.w600),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 18),
                                                                                child: SizedBox(
                                                                                  child: Text(
                                                                                    currentReviews.isNotEmpty ? TimeAgoSince.timeAgoSinceDate(isValidTimestamp(currentReviews[currentReviews.length - 1]["publishAt"]) ? currentReviews[currentReviews.length - 1]["publishAt"].toDate() : currentReviews[currentReviews.length - 1]["publishAt"]) : TimeAgoSince.timeAgoSinceDate(placeDetails.reviews[placeDetails.reviews.length - 1]["publishAt"].toDate()),
                                                                                    style: GoogleFonts.cabin(
                                                                                      textStyle: const TextStyle(color: Color.fromARGB(255, 112, 112, 112), fontSize: 12, fontWeight: FontWeight.w300),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 13),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                250,
                                                                            child:
                                                                                Text(
                                                                              currentReviews.isNotEmpty ? currentReviews[currentReviews.length - 1]["text"] : placeDetails.reviews[placeDetails.reviews.length - 1]["text"],
                                                                              style: GoogleFonts.cabin(
                                                                                textStyle: const TextStyle(color: Color.fromARGB(255, 112, 112, 112), fontSize: 10, fontWeight: FontWeight.w400),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          )),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      onPressed: () {
                                        searchType != 'city'
                                            ? showModalBottomSheet(
                                                context: context,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                                ),
                                                builder:
                                                    (BuildContext context) {
                                                  return SizedBox(
                                                    height: 210,
                                                    child: Column(
                                                      children: [
                                                        const TopButtonIndicator(),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 12,
                                                                  top: 12),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Select trip and day",
                                                                style:
                                                                    GoogleFonts
                                                                        .cabin(
                                                                  textStyle: const TextStyle(
                                                                      color: Color
                                                                          .fromARGB(
                                                                              255,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 12,
                                                                  top: 6),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Choose your best option to go to this place",
                                                                style:
                                                                    GoogleFonts
                                                                        .cabin(
                                                                  textStyle: const TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          112,
                                                                          112,
                                                                          112),
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        //trip list------------------------------------------------
                                                        FutureBuilder(
                                                          future: tripBlo
                                                              .getOnGoingTrips(),
                                                          builder: (BuildContext
                                                                  context,
                                                              AsyncSnapshot<
                                                                      List<
                                                                          Trip>>
                                                                  onGoingTrips) {
                                                            if (onGoingTrips
                                                                .hasData) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 9),
                                                                child: SizedBox(
                                                                  height: 115,
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            ScrollConfiguration(
                                                                          behavior:
                                                                              const ScrollBehavior(),
                                                                          child:
                                                                              GlowingOverscrollIndicator(
                                                                            axisDirection:
                                                                                AxisDirection.down,
                                                                            color: const Color.fromARGB(
                                                                                255,
                                                                                83,
                                                                                83,
                                                                                83),
                                                                            child: ListView.builder(
                                                                                cacheExtent: 9999,
                                                                                itemCount: onGoingTrips.data!.length + 1,
                                                                                scrollDirection: Axis.horizontal,
                                                                                itemBuilder: (context, index) {
                                                                                  if (index == 0) {
                                                                                    return Padding(
                                                                                      padding: const EdgeInsets.only(left: 7, right: 6),
                                                                                      child: Container(
                                                                                          width: 145,
                                                                                          height: 110,
                                                                                          decoration: BoxDecoration(
                                                                                            color: const Color.fromARGB(255, 124, 124, 124),
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                          ),
                                                                                          child: GestureDetector(
                                                                                              onTap: () => {
                                                                                                    //dierect place details page again---------------------
                                                                                                    Navigator.push(
                                                                                                      context,
                                                                                                      MaterialPageRoute(
                                                                                                          builder: (context) => createTrip(
                                                                                                                placeName: '',
                                                                                                                placePhotoUrl: '',
                                                                                                                isEditTrip: false,
                                                                                                                trip: Trip(tripId: '', tripName: '', tripBudget: '', tripLocation: '', tripDuration: '', tripDescription: '', tripCoverPhoto: '', durationCount: 0, startDate: DateTime(00), endDate: DateTime(00), places: {}),
                                                                                                              )),
                                                                                                    ),
                                                                                                  },
                                                                                              child: Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                    children: [
                                                                                                      Image.asset('assets/images/add.png', width: 30, height: 30)
                                                                                                    ],
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.only(top: 6),
                                                                                                    child: Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          "Creat new trip",
                                                                                                          style: GoogleFonts.cabin(
                                                                                                            textStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12, fontWeight: FontWeight.w500),
                                                                                                          ),
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ))),
                                                                                    );
                                                                                  } else {
                                                                                    return Padding(
                                                                                      padding: const EdgeInsets.only(left: 6),
                                                                                      child: GestureDetector(
                                                                                        onTap: () async {
                                                                                          Navigator.push(
                                                                                            context,
                                                                                            MaterialPageRoute(
                                                                                                builder: (context) => tripDetailsPlan(
                                                                                                      isEditPlace: true,
                                                                                                      isAddPlace: true,
                                                                                                      trip: onGoingTrips.data![index - 1],
                                                                                                      place: placeDetails,
                                                                                                    )),
                                                                                          );
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.only(
                                                                                            right: 6,
                                                                                          ),
                                                                                          child: Container(
                                                                                            width: 145,
                                                                                            height: 110,
                                                                                            decoration: BoxDecoration(
                                                                                              color: const Color.fromARGB(255, 216, 99, 99),
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                              image: DecorationImage(image: NetworkImage(onGoingTrips.data![index - 1].tripCoverPhoto), fit: BoxFit.cover),
                                                                                            ),
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(top: 11),
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      SizedBox(
                                                                                                        height: 25,
                                                                                                        width: 50,
                                                                                                        child: Card(
                                                                                                            elevation: 0,
                                                                                                            color: const Color.fromARGB(200, 240, 238, 238),
                                                                                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                                            shape: RoundedRectangleBorder(
                                                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                                                            ),
                                                                                                            child: FittedBox(
                                                                                                              fit: BoxFit.cover,
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.all(7.0),
                                                                                                                child: Text('${onGoingTrips.data?[index - 1].durationCount} days',
                                                                                                                    style: GoogleFonts.cabin(
                                                                                                                        // ignore: prefer_const_constructors
                                                                                                                        textStyle: TextStyle(
                                                                                                                      color: const Color.fromARGB(255, 95, 95, 95),
                                                                                                                      fontSize: 7,
                                                                                                                      fontWeight: FontWeight.bold,
                                                                                                                    ))),
                                                                                                              ),
                                                                                                            )),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.only(top: 10),
                                                                                                    child: Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          '${onGoingTrips.data?[index - 1].tripName}',
                                                                                                          style: GoogleFonts.cabin(
                                                                                                              // ignore: prefer_const_constructors
                                                                                                              textStyle: TextStyle(
                                                                                                            color: const Color.fromARGB(255, 255, 255, 255),
                                                                                                            fontSize: 19,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                          )),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.only(top: 4),
                                                                                                    child: Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          '${onGoingTrips.data?[index - 1].durationCount}',
                                                                                                          style: GoogleFonts.cabin(
                                                                                                              // ignore: prefer_const_constructors
                                                                                                              textStyle: TextStyle(
                                                                                                            color: const Color.fromARGB(255, 255, 255, 255),
                                                                                                            fontSize: 7,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                          )),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                }),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              return LoadingAnimationWidget
                                                                  .waveDots(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    129,
                                                                    129,
                                                                    129),
                                                                size: 35,
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )
                                            :
                                            //derect trip plan page---------------------------------
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        createTrip(
                                                          placeName:
                                                              placeDetails.name,
                                                          placePhotoUrl:
                                                              placeDetails
                                                                  .photoRef,
                                                          isEditTrip: false,
                                                          trip: Trip(
                                                              tripId: '',
                                                              tripName: '',
                                                              tripBudget: '',
                                                              tripLocation: '',
                                                              tripDuration: '',
                                                              tripDescription:
                                                                  '',
                                                              tripCoverPhoto:
                                                                  '',
                                                              durationCount: 0,
                                                              startDate:
                                                                  DateTime(00),
                                                              endDate:
                                                                  DateTime(00),
                                                              places: {}),
                                                        )),
                                              );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        foregroundColor: const Color.fromRGBO(
                                            255, 255, 255, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20), // Set the radius here
                                        ),
                                      ),
                                      child: Text(
                                        searchType != 'city'
                                            ? 'Add to trip'
                                            : 'Plan new trip',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
