import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../models/place.dart';
import '../../blocs/place/placeList_bloc.dart';
import '../Welcomepage.dart';
import '../placeDeatailsScreen/locationDetails.dart';
import 'editProfile.dart';


class myAccount extends StatefulWidget {
  const myAccount({super.key});

  @override
  State<myAccount> createState() => _myAccountState();
}

class _myAccountState extends State<myAccount> {

  late auth.User user;

  @override
  void initState() {
    super.initState();
     
  }

  Future <void> logOut()async{

    BlocProvider.of<userBloc>(context).add(signOutEvent());

    userBlo.authState.listen((user) {

      if(user == null){

         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  const welcomePage()),
        );

      }

    });



  }

  Future<void> _showFCMTokenDialog() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('FCM Token'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy token này để gửi test notification từ Firebase Console:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  token ?? 'Token not available',
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
              onPressed: () {
                if (token != null) {
                  Clipboard.setData(ClipboardData(text: token));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('FCM Token đã được copy!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy token: $e')),
      );
    }
  }

  Future<void> _showInstallationIdDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Installation ID (FID)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cách lấy FID để test In-App Messaging:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '1. Kết nối thiết bị với máy tính qua USB\n\n'
                  '2. Mở Android Studio → Logcat\n\n'
                  '3. Mở app FTravel này\n\n'
                  '4. Trong Logcat, tìm dòng:\n'
                  '   I/FIAM.Headless: Starting InAppMessaging runtime with Installation ID [YOUR_FID]\n\n'
                  '5. Copy FID (dãy ký tự sau "Installation ID")\n\n'
                  '6. Paste FID vào Firebase Console → In-App Messaging → Test on Device',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'FCM Token (nút bên trên) dùng cho Cloud Messaging\n'
                        'FID (từ Logcat) dùng cho In-App Messaging',
                        style: TextStyle(fontSize: 10, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }


@override
  Widget build(BuildContext context) {
        return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                  Padding(
                    padding: const EdgeInsets.only(top:40,left:13),
                    child: Row(
                      children: [
                        Text("Account",
                          style: GoogleFonts.nunito(
                                      // ignore: prefer_const_constructors
                                      textStyle: TextStyle(
                                      color: const Color.fromARGB(255, 27, 27, 27),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                              
                                      ) 
                                    )
                        
                        ),
                      ],
                    ),
                  ),
                  //account details---------------------------------------------------------
                  FutureBuilder(
                    future: userBlo.getUserDetails(),
                    builder: (context,AsyncSnapshot<auth.User?> snapshot) {
                      
                      if(snapshot.hasData){
                        user=snapshot.data!;
                        return
                         GestureDetector(
                            onTap: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditProfile(user: user,)));
                            },
                            child: Row(
                              children: [
                              Padding(
                                padding: const EdgeInsets.only(left:13,top:10),
                                child: SizedBox(
                                  width: 45,
                                  height: 45,
                                  child:  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:snapshot.data?.photoURL!=null? NetworkImage("${snapshot.data?.photoURL}")
                                    :const NetworkImage("https://cdn-icons-png.flaticon.com/64/3177/3177440.png"),
                                    
                                  ),
                                ),
                              ),
                              
                                Column(
                                  children: [
                            
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top:20),
                                          child: SizedBox(
                                          width:290,
                                            child: Text("${snapshot.data?.displayName}",
                                              style: GoogleFonts.poppins(
                                                  textStyle: const TextStyle(
                                                    color: Color.fromARGB(255, 0, 0, 0),
                                                    fontSize: 18,
                                                                        
                                                    ), 
                                                                                            
                                                                                            
                                              ),
                                                                                    
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left:6),
                                              child: SizedBox(
                                                width:290,
                                                child: Text("${snapshot.data?.email}",
                                                style: GoogleFonts.poppins(
                                                    textStyle: const TextStyle(
                                                      color: Color.fromARGB(255, 0, 0, 0),
                                                      fontSize: 12,
                                                                          
                                                      ), 
                                                                                                
                                                                                                
                                                ),
                                                                                      
                                                ),
                                              ),
                                            ),
                            
                            
                                      ],
                            
                            
                            
                                    )
                                  ],
                                ),  
                              ],
                            
                            ),
                          );
            
                      }else{
            
                        return Container();
            
                      }
                      
                    }
                  ),
                  //preferences------------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.only(left:13,top:34),
                    child: Row(
                      children: [
                        Text("Preferences",
                          style: GoogleFonts.nunito(
                                      // ignore: prefer_const_constructors
                                      textStyle: TextStyle(
                                      color: const Color.fromARGB(255, 27, 27, 27),
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,

                                      )
                                    )

                        ),
                      ],
                    ),
                  ),

                  // FCM Token Button
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 13, right: 13),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _showFCMTokenDialog,
                        icon: const Icon(Icons.notifications_active, size: 20),
                        label: const Text(
                          'Show FCM Token',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 10, 124, 132),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Installation ID Button
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 13, right: 13),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _showInstallationIdDialog,
                        icon: const Icon(Icons.fingerprint, size: 20),
                        label: const Text(
                          'Installation ID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 56, 142, 60),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Recently Used Section
                  Padding(
                    padding: const EdgeInsets.only(left: 13, top: 20),
                    child: Row(
                      children: [
                        Text(
                          'Recently Used',
                          style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 27, 27, 27),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recently Used List
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 13, right: 13),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FutureBuilder<List<Place>>(
                        future: placeBloc.getUserRecentlySearch(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'No recent searches',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          final recentPlaces = snapshot.data!;
                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: recentPlaces.length > 5 ? 5 : recentPlaces.length,
                            itemBuilder: (context, index) {
                              final place = recentPlaces[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.history, size: 20),
                                title: Text(
                                  place.name,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  place.address,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => locationDetails(
                                        placeId: place.id,
                                        searchType: place.type,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top:20),
                    child: SizedBox(
                      width: 200,
                      height: 45,
                      child: TextButton(
                        onPressed: () {

                         logOut();


                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          foregroundColor:const Color.fromARGB(255, 0, 0, 0),
                          side: const BorderSide(
                            width: 2.0,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),

                        ),
                        child: Text('Log out',
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,


                            ),

                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            );

              
          }
       



}
