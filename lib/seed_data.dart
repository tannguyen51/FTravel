import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class SeedDataPage extends StatefulWidget {
  const SeedDataPage({super.key});

  @override
  State<SeedDataPage> createState() => _SeedDataPageState();
}

class _SeedDataPageState extends State<SeedDataPage> {
  String _status = 'Ready to seed data.';
  bool _isLoading = false;

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
        "https://images.unsplash.com/photo-1589894409718-5e3b8e8ebc0b?w=400"
      ],
      "address": "Đà Nẵng, Việt Nam",
      "city": "Đà Nẵng",
      "searchString": "attraction",
      "categoryName": "attraction",
      "phone": "+84 236 3791 999",
      "openingHours": [
        {"day": "Mon-Sun", "hours": "07:00-22:00"}
      ],
      "location": {"lat": 15.9952, "lng": 108.2608},
      "reviews": [],
      "userIds": [],
      "rating": 4.7
    },
    {
      "placeId": "att_007",
      "title": "Nhà thờ Đức Bà Sài Gòn",
      "imageUrls": [
        "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400"
      ],
      "address": "Quận 1, TP. Hồ Chí Minh",
      "city": "Hồ Chí Minh",
      "searchString": "attraction",
      "categoryName": "attraction",
      "phone": "",
      "openingHours": [
        {"day": "Mon-Sat", "hours": "08:00-17:00"}
      ],
      "location": {"lat": 10.7797, "lng": 106.6990},
      "reviews": [],
      "userIds": [],
      "rating": 4.4
    },
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

  Future<void> _seedFirestore() async {
    final firestore = FirebaseFirestore.instance;

    // Seed attractions
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

    // Seed restaurants
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

    _updateStatus('✅ Đã thêm $added địa điểm vào Firestore!');
  }

  Future<void> _seedRealtimeDB() async {
    final dbRef = FirebaseDatabase.instance.ref('places');

    // Build places array for Realtime DB (used by Home screen)
    List<Map<String, dynamic>> places = [];
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
