import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

// Data definitions
final List<Map<String, dynamic>> _attractions = [
  {
    "placeId": "att_001",
    "title": "Vịnh Hạ Long",
    "imageUrls": [
      "https://images.unsplash.com/photo-1528127269322-539801943592?w=400",
      "https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400"
    ],
    "address": "Vịnh Hạ Long, Quảng Ninh, Việt Nam",
    "city": "Hạ Long",
    "searchString": "locality",
    "categoryName": "attraction",
    "phone": "",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 20.9101, "lng": 107.1839},
    "reviews": [],
    "userIds": [],
    "rating": 4.8
  },
  {
    "placeId": "att_002",
    "title": "Phố cổ Hội An",
    "imageUrls": [
      "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400",
      "https://images.unsplash.com/photo-1612372602656-2ab6d0003e9a?w=400"
    ],
    "address": "Hội An, Quảng Nam, Việt Nam",
    "city": "Hội An",
    "searchString": "locality",
    "categoryName": "attraction",
    "phone": "",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 15.8801, "lng": 108.3380},
    "reviews": [],
    "userIds": [],
    "rating": 4.7
  },
  {
    "placeId": "att_003",
    "title": "Landmark 81",
    "imageUrls": [
      "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400"
    ],
    "address": "Bình Thạnh, TP. Hồ Chí Minh",
    "city": "Hồ Chí Minh",
    "searchString": "attraction",
    "categoryName": "attraction",
    "phone": "+84 28 3622 2222",
    "openingHours": [
      {"day": "Mon-Fri", "hours": "09:00-22:00"},
      {"day": "Sat-Sun", "hours": "08:00-23:00"}
    ],
    "location": {"lat": 10.7949, "lng": 106.7225},
    "reviews": [],
    "userIds": [],
    "rating": 4.5
  },
  {
    "placeId": "att_004",
    "title": "Chợ Bến Thành",
    "imageUrls": [
      "https://images.unsplash.com/photo-1583241800699-1bf77c2e3e5d?w=400"
    ],
    "address": "Quận 1, TP. Hồ Chí Minh",
    "city": "Hồ Chí Minh",
    "searchString": "attraction",
    "categoryName": "attraction",
    "phone": "+84 28 3829 9274",
    "openingHours": [
      {"day": "Mon-Sun", "hours": "06:00-18:00"}
    ],
    "location": {"lat": 10.7728, "lng": 106.6980},
    "reviews": [],
    "userIds": [],
    "rating": 4.2
  },
  {
    "placeId": "att_005",
    "title": "Lăng Chủ tịch Hồ Chí Minh",
    "imageUrls": [
      "https://images.unsplash.com/photo-1589894409718-5e3b8e8ebc0b?w=400"
    ],
    "address": "Ba Đình, Hà Nội",
    "city": "Hà Nội",
    "searchString": "attraction",
    "categoryName": "attraction",
    "phone": "+84 24 3845 5128",
    "openingHours": [
      {"day": "Tue-Thu", "hours": "07:30-10:30"},
      {"day": "Sat-Sun", "hours": "07:30-11:00"}
    ],
    "location": {"lat": 21.0369, "lng": 105.8347},
    "reviews": [],
    "userIds": [],
    "rating": 4.6
  },
  {
    "placeId": "att_006",
    "title": "Bà Nà Hills",
    "imageUrls": [
      "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400"
    ],
    "address": "Đà Nẵng",
    "city": "Đà Nẵng",
    "searchString": "attraction",
    "categoryName": "attraction",
    "phone": "",
    "openingHours": [{"day": "Mon-Sun", "hours": "07:00-22:00"}],
    "location": {"lat": 16.0014, "lng": 107.9868},
    "reviews": [],
    "userIds": [],
    "rating": 4.7
  },
  {
    "placeId": "att_007",
    "title": "Nhà thờ Đức Bà",
    "imageUrls": [
      "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400"
    ],
    "address": "Quận 1, TP. Hồ Chí Minh",
    "city": "Hồ Chí Minh",
    "searchString": "attraction",
    "categoryName": "attraction",
    "phone": "",
    "openingHours": [{"day": "Mon-Sun", "hours": "08:00-17:00"}],
    "location": {"lat": 10.7798, "lng": 106.6990},
    "reviews": [],
    "userIds": [],
    "rating": 4.4
  }
];

final List<Map<String, dynamic>> _hotels = [
  {
    "placeId": "hot_001",
    "title": "Vinpearl Luxury Landmark 81",
    "imageUrls": [
      "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400"
    ],
    "address": "Bình Thạnh, TP. Hồ Chí Minh",
    "city": "Hồ Chí Minh",
    "searchString": "hotel",
    "categoryName": "hotel",
    "phone": "+84 28 7108 8888",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 10.7949, "lng": 106.7225},
    "reviews": [],
    "userIds": [],
    "rating": 4.9
  },
  {
    "placeId": "hot_002",
    "title": "Sofitel Legend Metropole Hanoi",
    "imageUrls": [
      "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400"
    ],
    "address": "Hoàn Kiếm, Hà Nội",
    "city": "Hà Nội",
    "searchString": "hotel",
    "categoryName": "hotel",
    "phone": "+84 24 3826 6919",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 21.0285, "lng": 105.8542},
    "reviews": [],
    "userIds": [],
    "rating": 4.8
  },
  {
    "placeId": "hot_003",
    "title": "InterContinental Danang",
    "imageUrls": [
      "https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400"
    ],
    "address": "Sơn Trà, Đà Nẵng",
    "city": "Đà Nẵng",
    "searchString": "hotel",
    "categoryName": "hotel",
    "phone": "+84 236 3938 888",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 16.1197, "lng": 108.2528},
    "reviews": [],
    "userIds": [],
    "rating": 4.9
  }
];

final List<Map<String, dynamic>> _cafes = [
  {
    "placeId": "caf_001",
    "title": "The Coffee House",
    "imageUrls": [
      "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400"
    ],
    "address": "Quận 1, TP. Hồ Chí Minh",
    "city": "Hồ Chí Minh",
    "searchString": "cafe",
    "categoryName": "cafe",
    "phone": "+84 28 7108 1234",
    "openingHours": [{"day": "Mon-Sun", "hours": "07:00-22:00"}],
    "location": {"lat": 10.7769, "lng": 106.7009},
    "reviews": [],
    "userIds": [],
    "rating": 4.5
  },
  {
    "placeId": "caf_002",
    "title": "Highlands Coffee",
    "imageUrls": [
      "https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=400"
    ],
    "address": "Hoàn Kiếm, Hà Nội",
    "city": "Hà Nội",
    "searchString": "cafe",
    "categoryName": "cafe",
    "phone": "+84 24 3936 7890",
    "openingHours": [{"day": "Mon-Sun", "hours": "06:30-22:00"}],
    "location": {"lat": 21.0285, "lng": 105.8542},
    "reviews": [],
    "userIds": [],
    "rating": 4.3
  },
  {
    "placeId": "caf_003",
    "title": "Cong Caphe",
    "imageUrls": [
      "https://images.unsplash.com/photo-1453614512568-c4024d13c075?w=400"
    ],
    "address": "Hải Châu, Đà Nẵng",
    "city": "Đà Nẵng",
    "searchString": "cafe",
    "categoryName": "cafe",
    "phone": "+84 236 3825 567",
    "openingHours": [{"day": "Mon-Sun", "hours": "07:00-22:00"}],
    "location": {"lat": 16.0544, "lng": 108.2022},
    "reviews": [],
    "userIds": [],
    "rating": 4.6
  }
];

final List<Map<String, dynamic>> _parks = [
  {
    "placeId": "par_001",
    "title": "Công viên Tao Đàn",
    "imageUrls": [
      "https://images.unsplash.com/photo-1585938389612-a552a28d6914?w=400"
    ],
    "address": "Quận 1, TP. Hồ Chí Minh",
    "city": "Hồ Chí Minh",
    "searchString": "park",
    "categoryName": "park",
    "phone": "",
    "openingHours": [{"day": "Mon-Sun", "hours": "05:00-22:00"}],
    "location": {"lat": 10.7764, "lng": 106.6932},
    "reviews": [],
    "userIds": [],
    "rating": 4.4
  },
  {
    "placeId": "par_002",
    "title": "Công viên Thống Nhất",
    "imageUrls": [
      "https://images.unsplash.com/photo-1519331379826-f10be5d65c4f?w=400"
    ],
    "address": "Hai Bà Trưng, Hà Nội",
    "city": "Hà Nội",
    "searchString": "park",
    "categoryName": "park",
    "phone": "",
    "openingHours": [{"day": "Mon-Sun", "hours": "06:00-22:00"}],
    "location": {"lat": 21.0142, "lng": 105.8456},
    "reviews": [],
    "userIds": [],
    "rating": 4.3
  },
  {
    "placeId": "par_003",
    "title": "Công viên Biển Đông",
    "imageUrls": [
      "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400"
    ],
    "address": "Sơn Trà, Đà Nẵng",
    "city": "Đà Nẵng",
    "searchString": "park",
    "categoryName": "park",
    "phone": "",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 16.1229, "lng": 108.2584},
    "reviews": [],
    "userIds": [],
    "rating": 4.7
  }
];

final List<Map<String, dynamic>> _gasStations = [
  {
    "placeId": "gas_001",
    "title": "Petrolimex Station 1",
    "imageUrls": [
      "https://images.unsplash.com/photo-1545459723-a880be6ef9db?w=400"
    ],
    "address": "Quận 1, TP. Hồ Chí Minh",
    "city": "Hồ Chí Minh",
    "searchString": "gas_station",
    "categoryName": "gas_station",
    "phone": "+84 28 3829 1234",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 10.7769, "lng": 106.7009},
    "reviews": [],
    "userIds": [],
    "rating": 4.2
  },
  {
    "placeId": "gas_002",
    "title": "Petrolimex Station 2",
    "imageUrls": [
      "https://images.unsplash.com/photo-1545459723-a880be6ef9db?w=400"
    ],
    "address": "Đống Đa, Hà Nội",
    "city": "Hà Nội",
    "searchString": "gas_station",
    "categoryName": "gas_station",
    "phone": "+84 24 3852 5678",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 21.0142, "lng": 105.8323},
    "reviews": [],
    "userIds": [],
    "rating": 4.1
  },
  {
    "placeId": "gas_003",
    "title": "Petrolimex Station 3",
    "imageUrls": [
      "https://images.unsplash.com/photo-1545459723-a880be6ef9db?w=400"
    ],
    "address": "Hải Châu, Đà Nẵng",
    "city": "Đà Nẵng",
    "searchString": "gas_station",
    "categoryName": "gas_station",
    "phone": "+84 236 3821 999",
    "openingHours": [{"day": "Mon-Sun", "hours": "00:00-24:00"}],
    "location": {"lat": 16.0544, "lng": 108.2022},
    "reviews": [],
    "userIds": [],
    "rating": 4.3
  }
];

final List<Map<String, dynamic>> _restaurants = [
  {
    "placeId": "res_001",
    "title": "Nhà hàng Ngon",
    "imageUrls": [
      "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400"
    ],
    "address": "Quận 1, TP. Hồ Chí Minh",
    "city": "Hồ Chí Minh",
    "searchString": "restaurant",
    "categoryName": "restaurant",
    "phone": "+84 28 3827 7131",
    "openingHours": [
      {"day": "Mon-Sun", "hours": "07:00-22:00"}
    ],
    "location": {"lat": 10.7756, "lng": 106.6999},
    "reviews": [],
    "userIds": [],
  },
  {
    "placeId": "res_002",
    "title": "Phở 2000",
    "imageUrls": [
      "https://images.unsplash.com/photo-1555126634-323283e090fa?w=400"
    ],
    "address": "Hoàn Kiếm, Hà Nội",
    "city": "Hà Nội",
    "searchString": "restaurant",
    "categoryName": "restaurant",
    "phone": "+84 24 3824 3374",
    "openingHours": [
      {"day": "Mon-Sun", "hours": "06:00-22:00"}
    ],
    "location": {"lat": 21.0305, "lng": 105.8500},
    "reviews": [],
    "userIds": [],
  },
];

final List<Map<String, dynamic>> _cities = [
  {
    "placeId": "city_001",
    "title": "Hà Nội",
    "imageUrls": [
      "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400",
      "https://images.unsplash.com/photo-1528127269322-539801943592?w=400"
    ],
    "address": "Hà Nội, Việt Nam",
    "city": "Hà Nội",
    "searchString": "city",
    "categoryName": "city",
    "phone": "",
    "openingHours": [],
    "location": {"lat": 21.0285, "lng": 105.8542},
    "reviews": [],
    "userIds": [],
    "rating": 4.7
  },
  {
    "placeId": "city_002",
    "title": "Hồ Chí Minh",
    "imageUrls": [
      "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400",
      "https://images.unsplash.com/photo-1583241800699-1bf77c2e3e5d?w=400"
    ],
    "address": "TP. Hồ Chí Minh, Việt Nam",
    "city": "Hồ Chí Minh",
    "searchString": "city",
    "categoryName": "city",
    "phone": "",
    "openingHours": [],
    "location": {"lat": 10.8231, "lng": 106.6297},
    "reviews": [],
    "userIds": [],
    "rating": 4.6
  },
  {
    "placeId": "city_003",
    "title": "Đà Nẵng",
    "imageUrls": [
      "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400",
      "https://images.unsplash.com/photo-1589894409718-5e3b8e8ebc0b?w=400"
    ],
    "address": "Đà Nẵng, Việt Nam",
    "city": "Đà Nẵng",
    "searchString": "city",
    "categoryName": "city",
    "phone": "",
    "openingHours": [],
    "location": {"lat": 16.0544, "lng": 108.2022},
    "reviews": [],
    "userIds": [],
    "rating": 4.8
  },
  {
    "placeId": "city_004",
    "title": "Hội An",
    "imageUrls": [
      "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400",
      "https://images.unsplash.com/photo-1612372602656-2ab6d0003e9a?w=400"
    ],
    "address": "Hội An, Quảng Nam, Việt Nam",
    "city": "Hội An",
    "searchString": "city",
    "categoryName": "city",
    "phone": "",
    "openingHours": [],
    "location": {"lat": 15.8801, "lng": 108.3380},
    "reviews": [],
    "userIds": [],
    "rating": 4.9
  },
  {
    "placeId": "city_005",
    "title": "Hạ Long",
    "imageUrls": [
      "https://images.unsplash.com/photo-1528127269322-539801943592?w=400",
      "https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400"
    ],
    "address": "Hạ Long, Quảng Ninh, Việt Nam",
    "city": "Hạ Long",
    "searchString": "city",
    "categoryName": "city",
    "phone": "",
    "openingHours": [],
    "location": {"lat": 20.9101, "lng": 107.1839},
    "reviews": [],
    "userIds": [],
    "rating": 4.8
  },
];

// Auto-seed data if not exists (call from main.dart)
Future<void> autoSeedData() async {
  final firestore = FirebaseFirestore.instance;
  final dbRef = FirebaseDatabase.instance.ref('places');

  // Check if attractions collection is empty
  final attractionsQuery = await firestore.collection('attractions').limit(1).get();
  if (attractionsQuery.docs.isEmpty) {
    // Seed attractions
    for (var att in _attractions) {
      await firestore.collection('attractions').add(att);
    }

    // Seed restaurants
    for (var res in _restaurants) {
      await firestore.collection('restaurants').add(res);
    }

    // Seed cities
    for (var city in _cities) {
      await firestore.collection('cities').add(city);
    }

    // Seed hotels
    for (var hotel in _hotels) {
      await firestore.collection('hotels').add(hotel);
    }

    // Seed cafes
    for (var cafe in _cafes) {
      await firestore.collection('cafes').add(cafe);
    }

    // Seed parks
    for (var park in _parks) {
      await firestore.collection('parks').add(park);
    }

    // Seed gas stations
    for (var gas in _gasStations) {
      await firestore.collection('gas_stations').add(gas);
    }
  }

  // Always check and seed Realtime Database
  final snapshot = await dbRef.get();
  final existingPlaces = snapshot.value as List<dynamic>?;

  // Only seed if Realtime DB is empty or has less than 19 places
  if (existingPlaces == null || existingPlaces.length < 19) {
    List<Map<String, dynamic>> places = [];

    // Add attractions
    for (var att in _attractions) {
      places.add({
        "title": att["title"],
        "imageUrls": att["imageUrls"],
        "placeId": att["placeId"],
        "address": att["address"],
        "city": att["city"],
        "categoryName": att["categoryName"],
        "rating": att["rating"],
      });
    }

    // Add hotels
    for (var hotel in _hotels) {
      places.add({
        "title": hotel["title"],
        "imageUrls": hotel["imageUrls"],
        "placeId": hotel["placeId"],
        "address": hotel["address"],
        "city": hotel["city"],
        "categoryName": hotel["categoryName"],
        "rating": hotel["rating"],
      });
    }

    // Add cafes
    for (var cafe in _cafes) {
      places.add({
        "title": cafe["title"],
        "imageUrls": cafe["imageUrls"],
        "placeId": cafe["placeId"],
        "address": cafe["address"],
        "city": cafe["city"],
        "categoryName": cafe["categoryName"],
        "rating": cafe["rating"],
      });
    }

    // Add parks
    for (var park in _parks) {
      places.add({
        "title": park["title"],
        "imageUrls": park["imageUrls"],
        "placeId": park["placeId"],
        "address": park["address"],
        "city": park["city"],
        "categoryName": park["categoryName"],
        "rating": park["rating"],
      });
    }

    // Add gas stations
    for (var gas in _gasStations) {
      places.add({
        "title": gas["title"],
        "imageUrls": gas["imageUrls"],
        "placeId": gas["placeId"],
        "address": gas["address"],
        "city": gas["city"],
        "categoryName": gas["categoryName"],
        "rating": gas["rating"],
      });
    }

    // Add restaurants
    for (var res in _restaurants) {
      places.add({
        "title": res["title"],
        "imageUrls": res["imageUrls"],
        "placeId": res["placeId"],
        "address": res["address"],
        "city": res["city"],
        "categoryName": res["categoryName"],
        "rating": res["rating"] ?? 4.0,
      });
    }

    await dbRef.set(places);
  }
}

class SeedDataPage extends StatefulWidget {
  const SeedDataPage({super.key});

  @override
  State<SeedDataPage> createState() => _SeedDataPageState();
}

class _SeedDataPageState extends State<SeedDataPage> {
  String _status = 'Ready to seed data.';
  bool _isLoading = false;

  Future<void> _seedFirestore() async {
    final firestore = FirebaseFirestore.instance;
    int added = 0;

    for (var att in _attractions) {
      final query = await firestore
          .collection('attractions')
          .where('placeId', isEqualTo: att['placeId'])
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('attractions').add(att);
        added++;
      }
    }

    for (var res in _restaurants) {
      final query = await firestore
          .collection('restaurants')
          .where('placeId', isEqualTo: res['placeId'])
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('restaurants').add(res);
        added++;
      }
    }

    for (var city in _cities) {
      final query = await firestore
          .collection('cities')
          .where('placeId', isEqualTo: city['placeId'])
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('cities').add(city);
        added++;
      }
    }

    for (var hotel in _hotels) {
      final query = await firestore
          .collection('hotels')
          .where('placeId', isEqualTo: hotel['placeId'])
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('hotels').add(hotel);
        added++;
      }
    }

    for (var cafe in _cafes) {
      final query = await firestore
          .collection('cafes')
          .where('placeId', isEqualTo: cafe['placeId'])
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('cafes').add(cafe);
        added++;
      }
    }

    for (var park in _parks) {
      final query = await firestore
          .collection('parks')
          .where('placeId', isEqualTo: park['placeId'])
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('parks').add(park);
        added++;
      }
    }

    for (var gas in _gasStations) {
      final query = await firestore
          .collection('gas_stations')
          .where('placeId', isEqualTo: gas['placeId'])
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('gas_stations').add(gas);
        added++;
      }
    }

    _updateStatus('✅ Đã thêm $added địa điểm vào Firestore!');
  }

  Future<void> _seedRealtimeDB() async {
    final dbRef = FirebaseDatabase.instance.ref('places');
    List<Map<String, dynamic>> places = [];

    // Add attractions
    for (var att in _attractions) {
      places.add({
        "title": att["title"],
        "imageUrls": att["imageUrls"],
        "placeId": att["placeId"],
        "address": att["address"],
        "city": att["city"],
        "categoryName": att["categoryName"],
        "rating": att["rating"],
      });
    }

    // Add hotels
    for (var hotel in _hotels) {
      places.add({
        "title": hotel["title"],
        "imageUrls": hotel["imageUrls"],
        "placeId": hotel["placeId"],
        "address": hotel["address"],
        "city": hotel["city"],
        "categoryName": hotel["categoryName"],
        "rating": hotel["rating"],
      });
    }

    // Add cafes
    for (var cafe in _cafes) {
      places.add({
        "title": cafe["title"],
        "imageUrls": cafe["imageUrls"],
        "placeId": cafe["placeId"],
        "address": cafe["address"],
        "city": cafe["city"],
        "categoryName": cafe["categoryName"],
        "rating": cafe["rating"],
      });
    }

    // Add parks
    for (var park in _parks) {
      places.add({
        "title": park["title"],
        "imageUrls": park["imageUrls"],
        "placeId": park["placeId"],
        "address": park["address"],
        "city": park["city"],
        "categoryName": park["categoryName"],
        "rating": park["rating"],
      });
    }

    // Add gas stations
    for (var gas in _gasStations) {
      places.add({
        "title": gas["title"],
        "imageUrls": gas["imageUrls"],
        "placeId": gas["placeId"],
        "address": gas["address"],
        "city": gas["city"],
        "categoryName": gas["categoryName"],
        "rating": gas["rating"],
      });
    }

    // Add restaurants
    for (var res in _restaurants) {
      places.add({
        "title": res["title"],
        "imageUrls": res["imageUrls"],
        "placeId": res["placeId"],
        "address": res["address"],
        "city": res["city"],
        "categoryName": res["categoryName"],
        "rating": res["rating"] ?? 4.0,
      });
    }

    await dbRef.set(places);
    _updateStatus('✅ Đã thêm ${places.length} địa điểm vào Realtime Database!');
  }

  Future<void> _seedAll() async {
    setState(() {
      _isLoading = true;
      _status = '⏳ Đang thêm dữ liệu...';
    });

    try {
      await _seedFirestore();
      await _seedRealtimeDB();
      setState(() => _status = '🎉 Hoàn tất! Dữ liệu đã sẵn sàng.');
    } catch (e) {
      setState(() => _status = '❌ Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateStatus(String msg) {
    setState(() => _status = msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Data'),
        backgroundColor: const Color.fromARGB(255, 10, 124, 132),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.storage, size: 64, color: Color.fromARGB(255, 10, 124, 132)),
            const SizedBox(height: 16),
            const Text(
              'Thêm dữ liệu mẫu vào Firebase',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bấm nút bên dưới để thêm các địa điểm du lịch Việt Nam vào Firestore và Realtime Database.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _seedAll,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.upload),
              label: Text(_isLoading ? 'Đang xử lý...' : 'Seed Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 124, 132),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
