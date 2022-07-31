import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:geolocator_app/model/user.dart';
import 'package:geolocator_app/pages/signin.dart';
import 'package:geolocator_app/services/authservice.dart';
import 'package:geolocator_app/services/databaseservices.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth.FirebaseAuth auth = FirebaseAuth.FirebaseAuth.instance;

  UserModel currentUser =
      UserModel(id: 'id', email: 'email', name: 'name', role: 'role');

  Completer<GoogleMapController>? _controller;
  BuildContext? parentContext;
  GeoPoint? pinLocationController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  bool pinLocationSelected = false;
  List<String> months = [
    'Januari',
    'Februari',
    'March',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  void inputData() async {
    final FirebaseAuth.User? user = auth.currentUser;
    final result = await DatabaseService().getUserById(user!.uid);
    setState(() {
      currentUser = result;
    });
  }

  void permission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    inputData();
    permission();
    super.initState();
  }

  AuthService authService = AuthService();

  Dialog pinLocation(BuildContext context, BuildContext parent,
      void Function(void Function()) setState) {
    Size size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 370,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text('Pilih Titik',
                  style: TextStyle(
                      color: Color(0xFF3F3F3F),
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder(
                    stream: Geolocator.getPositionStream(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Position> snapshot) {
                      if (snapshot.hasData) {
                        Position position = snapshot.data!;
                        return Container(
                            height: 200,
                            margin: EdgeInsets.only(top: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.8),
                              child: GoogleMap(
                                onTap: (LatLng latlng) {
                                  Marker marker = Marker(
                                      icon: BitmapDescriptor.defaultMarker,
                                      markerId: MarkerId('location'),
                                      position: LatLng(
                                          latlng.latitude, latlng.longitude));
                                  setState(() {
                                    markers.clear();
                                    markers[MarkerId('location')] = marker;
                                    pinLocationSelected = true;
                                  });
                                },
                                markers: Set<Marker>.of(this.markers.values),
                                initialCameraPosition: CameraPosition(
                                    zoom: 11,
                                    target: LatLng(
                                        position.latitude, position.longitude)),
                                mapType: MapType.normal,
                                zoomControlsEnabled: false,
                                onMapCreated: (GoogleMapController controller) {
                                  if (_controller != null) {
                                    _controller!.complete(controller);
                                  }
                                },
                              ),
                            ));
                      } else {
                        return Container(height: 200, color: Colors.white);
                      }
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3),
                    child: Text(
                      'Pilih titik Location dengan menekan map',
                      style: TextStyle(fontSize: 12, color: Color(0xff707070)),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 400),
                    opacity: pinLocationSelected ? 1 : 0.5,
                    child: Container(
                      margin: EdgeInsets.only(top: 16, bottom: 0),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: GestureDetector(
                        onTap: () async {
                          if (pinLocationSelected) {
                            setState(() {
                              pinLocationController = GeoPoint(
                                  markers[MarkerId('location')]!
                                      .position
                                      .latitude,
                                  markers[MarkerId('location')]!
                                      .position
                                      .longitude);
                            });
                            await Future.delayed(Duration(milliseconds: 300),
                                () async {
                              Map<String, dynamic> locationMap = {
                                "location": pinLocationController,
                                "time": DateTime.now().millisecondsSinceEpoch
                              };
                              await DatabaseService().addLocation(locationMap);
                            });
                            Navigator.pop(context);
                            return showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Sukses'),
                                content:
                                    Text('Lokasi Absen Berhasil Ditambahkan'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Ok'),
                                    onPressed: () {
                                      Navigator.pop(parent);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                              color: Color(0xff1C4EFF),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xAD0138FF),
                                    offset: Offset(0, 2),
                                    blurRadius: 10,
                                    spreadRadius: -5)
                              ],
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              "Tambah Lokasi",
                              style: TextStyle(
                                fontSize: 15,
                                height: 1,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "BalooPaaji",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _myListView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('absen').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.length != 0) {
              return ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DateTime absenTime = DateTime.fromMillisecondsSinceEpoch(
                      snapshot.data.docs[index].data()['time']);
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                              'Nama : ${snapshot.data.docs[index].data()['username']}'),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                              'Waktu Hadir : ${DateFormat.yMMMMd().add_Hm().format(absenTime)}'),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              );
            } else {
              return Center(
                child: Text(
                  'Belum ada data absensi',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget masterWidget() {
    return StreamBuilder(
        stream: Geolocator.getPositionStream(),
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (snapshot.hasData) {
            Position currentPosition = snapshot.data!;
            return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('location')
                    .doc('F7zwyLYBwWs0qZSfjPWY')
                    .snapshots(),
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.hasData) {
                    if (dataSnapshot.data!.data() != null) {
                      GeoPoint position =
                          (dataSnapshot.data!.data() as Map)['location'];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 200,
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.all(16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.8),
                              child: GoogleMap(
                                markers: Set<Marker>.of([
                                  Marker(
                                      markerId: MarkerId('pin'),
                                      position: LatLng(position.latitude,
                                          position.longitude))
                                ]),
                                initialCameraPosition: CameraPosition(
                                    zoom: 11,
                                    target: LatLng(
                                        position.latitude, position.longitude)),
                                mapType: MapType.normal,
                                zoomControlsEnabled: false,
                                onMapCreated: (GoogleMapController controller) {
                                  if (_controller != null) {
                                    _controller!.complete(controller);
                                  }
                                },
                              ),
                            ),
                          ),
                          RaisedButton(
                            splashColor: Colors.pinkAccent,
                            color: Colors.black,
                            child: new Text(
                              "Tambah Lokasi",
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            ),
                            onPressed: () async {
                              await Future.delayed(Duration(milliseconds: 300),
                                  () async {
                                await showDialog(
                                    context: parentContext!,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder:
                                            (BuildContext context, setState) {
                                          return pinLocation(context,
                                              parentContext!, setState);
                                        },
                                      );
                                    });
                              });
                            },
                          ),
                          Expanded(child: _myListView(context)),
                        ],
                      );
                    } else {
                      return RaisedButton(
                        splashColor: Colors.pinkAccent,
                        color: Colors.black,
                        child: new Text(
                          "Tambah Lokasi",
                          style: new TextStyle(
                              fontSize: 20.0, color: Colors.white),
                        ),
                        onPressed: () async {
                          await Future.delayed(Duration(milliseconds: 300),
                              () async {
                            await showDialog(
                                context: parentContext!,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context, setState) {
                                      return pinLocation(
                                          context, parentContext!, setState);
                                    },
                                  );
                                });
                          });
                        },
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget attendaceWidget() {
    DateTime? lastAbsenTime;
    return StreamBuilder(
        stream: Geolocator.getPositionStream(),
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (snapshot.hasData) {
            Position currentPosition = snapshot.data!;
            return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('location')
                    .doc('F7zwyLYBwWs0qZSfjPWY')
                    .snapshots(),
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.hasData) {
                    if (dataSnapshot.data!.data() != null) {
                      GeoPoint position =
                          (dataSnapshot.data!.data() as Map)['location'];
                      return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('absen')
                              .doc(currentUser.id + currentUser.name)
                              .snapshots(),
                          builder: (context, absenSnapshot) {
                            if (absenSnapshot.hasData) {
                              if (absenSnapshot.data!.data() != null) {
                                lastAbsenTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (absenSnapshot.data!.data()
                                            as Map)['time']);

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 200,
                                      margin: EdgeInsets.only(top: 5),
                                      padding: EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.8),
                                        child: GoogleMap(
                                          markers: Set<Marker>.of([
                                            Marker(
                                                markerId: MarkerId('pin'),
                                                position: LatLng(
                                                    position.latitude,
                                                    position.longitude))
                                          ]),
                                          initialCameraPosition: CameraPosition(
                                              zoom: 11,
                                              target: LatLng(position.latitude,
                                                  position.longitude)),
                                          mapType: MapType.normal,
                                          zoomControlsEnabled: false,
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            if (_controller != null) {
                                              _controller!.complete(controller);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    RaisedButton(
                                      splashColor: Colors.pinkAccent,
                                      color: Colors.black,
                                      child: new Text(
                                        "Absen",
                                        style: new TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        var _distanceInMeters =
                                            await Geolocator.distanceBetween(
                                          position.latitude,
                                          position.longitude,
                                          currentPosition.latitude,
                                          currentPosition.longitude,
                                        );
                                        if (_distanceInMeters < 50) {
                                          Map<String, dynamic> locationMap = {
                                            "userUID": currentUser.id,
                                            "username": currentUser.name,
                                            "time": DateTime.now()
                                                .millisecondsSinceEpoch,
                                          };
                                          DatabaseService()
                                              .addAbsen(locationMap);
                                          return showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text('Sukses'),
                                              content: Text(
                                                  'Absen Anda Sukses \n Absen : ${DateFormat.yMMMMd().add_Hm().format(DateTime.now())}'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Ok'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text('Gagal'),
                                              content: Text(
                                                  'Absen Anda Gagal Karena Terlalu Jauh Dari Titik Absen'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Ok'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                        'Absen Terakhir : ${DateFormat.yMMMMd().add_Hm().format(lastAbsenTime!)}')
                                  ],
                                );
                              } else {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 200,
                                      margin: EdgeInsets.only(top: 5),
                                      padding: EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.8),
                                        child: GoogleMap(
                                          markers: Set<Marker>.of([
                                            Marker(
                                                markerId: MarkerId('pin'),
                                                position: LatLng(
                                                    position.latitude,
                                                    position.longitude))
                                          ]),
                                          initialCameraPosition: CameraPosition(
                                              zoom: 11,
                                              target: LatLng(position.latitude,
                                                  position.longitude)),
                                          mapType: MapType.normal,
                                          zoomControlsEnabled: false,
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            if (_controller != null) {
                                              _controller!.complete(controller);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    RaisedButton(
                                      splashColor: Colors.pinkAccent,
                                      color: Colors.black,
                                      child: new Text(
                                        "Absen",
                                        style: new TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        var _distanceInMeters =
                                            await Geolocator.distanceBetween(
                                          position.latitude,
                                          position.longitude,
                                          currentPosition.latitude,
                                          currentPosition.longitude,
                                        );
                                        if (_distanceInMeters < 50) {
                                          Map<String, dynamic> locationMap = {
                                            "userUID": currentUser.id,
                                            "username": currentUser.name,
                                            "time": DateTime.now()
                                                .millisecondsSinceEpoch,
                                          };
                                          DatabaseService()
                                              .addAbsen(locationMap);
                                          return showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text('Sukses'),
                                              content: Text(
                                                  'Absen Anda Sukses \n Absen : ${DateFormat.yMMMMd().add_Hm().format(lastAbsenTime!)}'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Ok'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text('Gagal'),
                                              content: Text(
                                                  'Absen Anda Gagal Karena Terlalu Jauh Dari Titik Absen'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Ok'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                        'Absen Terakhir : Anda Belum Melakukan Absen')
                                  ],
                                );
                              }
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          });
                    } else {
                      return RaisedButton(
                        splashColor: Colors.pinkAccent,
                        color: Colors.black,
                        child: new Text(
                          "Absen",
                          style: new TextStyle(
                              fontSize: 20.0, color: Colors.white),
                        ),
                        onPressed: () async {
                          return showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("Belum ada lokasi"),
                              content: Text("Belum ada lokasi ditambahkan"),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    this.parentContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              authService.SignOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignIn()));
            },
          )
        ],
      ),
      body: Center(
        child:
            currentUser.role == 'master' ? masterWidget() : attendaceWidget(),
      ),
    );
  }
}
