import 'dart:convert';

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tuasty/inventory/product.dart';
import 'package:short_uuids/short_uuids.dart';
import 'package:http/http.dart' as http;

import 'package:tuasty/inventory/product.dart';

import 'package:intl/intl.dart';

import 'package:tuasty/inventory/detail_product.dart';
import 'package:tuasty/inventory/create_product.dart';
import 'package:tuasty/clientuser.dart';

import 'package:timezone/data/latest.dart' as tz;

import '../parameters/constant.dart';
import 'package:tuasty/inventory/delete_product.dart';

class AccueilPage extends StatefulWidget {
  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _firstController = ScrollController();

  final user = FirebaseAuth.instance.currentUser!;
  final currentUser = FirebaseAuth.instance;
  final myUserId = FirebaseAuth.instance.currentUser?.uid;

  late Stream<QuerySnapshot> _innerStream;

  var docRef = Map<String, dynamic>();
  var docName = '';
  var invSize = 0;



  DateTime? _myDateTime;


  final searchBarController = TextEditingController();

  String searching_text = "";

  List<bool> filterList = [true, false, false];
  late final prefs;

  Future _getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() => docName = element.id);
        setState(() => docRef = element.data());
      });
    });

    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _getUserData();

    _innerStream = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .snapshots();

    searchBarController.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    print(searchBarController.text);
  }

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }


  Future<Map<String, dynamic>> init_inventory() async {
    DocumentReference a =
        await FirebaseFirestore.instance.collection('users').doc(docName);
    var b = await a.get().then((value) => value.data());

    b = b as Map<String, dynamic>;

    /* for(var k in b.keys){
      temp_inv.add(k);
    }*/

    return b;
  }

  @override
  Widget build(BuildContext context) {

    /*
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Colors.white,
              Colors.white38,
              Colors.white54,
            ])),
        child: Column(
          children: [
            // SizedBox(height:20),

            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30)),
                border: Border.all(color: Colors.white, width: 1.2),
                gradient: LinearGradient(begin: Alignment.topLeft, colors: [
                  Colors.yellow.shade800,
                  Colors.yellow.shade700,
                  Colors.yellow.shade600,
                  Colors.yellow.shade500
                ], stops: [
                  0.0,
                  0.1,
                  0.4,
                  0.8,
                ]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 20, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 0.7 * MediaQuery.of(context).size.width,
                            height: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: Text(
                                    "Bonjour " + docName + " !",
                                    style: TextStyle(
                                        height: 0.8,
                                        fontSize: 20,
                                        fontFamily: 'Oswald',
                                        //fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                //SizedBox(height: 2,),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      getRandomHomeMessage(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Oswald',
                                          //fontStyle: FontStyle.italic,
                                          color: Colors.grey[900]),
                                    )),
                              ],
                            )),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 50.0,
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),

            StreamBuilder<QuerySnapshot>(
              //stream: _usersStream,
              stream: (searching_text != "" && searching_text != null)
                  /*
                ? FirebaseFirestore.instance
                    .collection('users')
                    .where('email',
                        isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('users')
                    .where('email',
                        isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .snapshots(),

              */
                  ? _innerStream
                  : _innerStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                } else if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!.docs
                        .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          var temp_inv = data['inventory'];
                          var searched_inv = [];
                          var temp_len = 10;

                          if (temp_inv.length <= temp_len) {
                            temp_len = temp_inv.length;
                          }

                          for (int i = 0; i < temp_len; i++) {
                            if (temp_inv[i]['nom']
                                .contains(searchBarController.text)) {
                              if (filterList[0] == true) {
                                searched_inv.add(temp_inv[i]);
                              }
                              if (filterList[1] == true &&
                                  (temp_inv[i]['categories'].indexWhere((e) => [
                                            'dairies',
                                            'Viandes',
                                            'Fromages'
                                          ].contains(e)) >
                                      -1)) {
                                //if(filterList[1] == true && temp_inv[i]['categories'].contains(['dairies','Viandes', 'Fromages'])){
                                searched_inv.add(temp_inv[i]);
                              }
                              if (filterList[2] == true &&
                                  (temp_inv[i]['categories'].indexWhere((e) => [
                                            'groceries',
                                            'Céréales',
                                            'Biscuits'
                                          ].contains(e)) >
                                      -1)) {
                                //if(filterList[2] == true && temp_inv[i]['categories'].contains(['groceries', 'Céréales', 'Biscuits'])){
                                searched_inv.add(temp_inv[i]);
                              }
                            }
                          }

                          searched_inv.sort((a, b) {
                            //sorting in ascending order
                            return DateTime.parse(a['date-peremption'])
                                .compareTo(
                                    DateTime.parse(b['date-peremption']));
                          });

                          if (temp_inv.isEmpty) {
                            return Align(
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Text("Votre inventaire est vide !"),
                                ],
                              ),
                            );
                          } else {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),

                              height: MediaQuery.of(context).size.height / 2,

                              //height : 300,

                              child: RawScrollbar(
                                thumbColor: Colors.grey[350]!,
                                radius: Radius.circular(10),
                                thickness: 2,
                                thumbVisibility: true,
                                controller: _firstController,
                                child: ListView.separated(
                                    controller: _firstController,
                                    scrollDirection: Axis.vertical,
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            Divider(
                                              indent: 20,
                                              endIndent: 20,
                                              color: Colors.blueGrey,
                                            ),
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    itemCount: searched_inv.length,
                                    //itemCount: data['inventory'].length ?? [],
                                    itemBuilder: (context, index) {
                                      return productWidget(
                                          context,
                                          data,
                                          docName,
                                          index,
                                          _myDateTime,
                                          searched_inv);
                                    }),
                              ),
                            );
                          }
                        })
                        .toList()
                        .cast(),
                  );
                } else {
                  return SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),

            //SizedBox(height:20),

            Divider(
              thickness: 3,
              indent: 10,
              endIndent: 10,
              color: Colors.black,
            ),

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "Ajouter un produit",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(height: 10),
                  RawMaterialButton(
                    onPressed: () async {
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => add_aliment());
                    },
                    elevation: 2.0,
                    fillColor: Colors.yellow[600]!,
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.black,
                    ),
                    padding: EdgeInsets.all(15),
                    shape: CircleBorder(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

     */

    return Center(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height/4.5,
              child:Stack(
                children: [
                  Opacity(opacity: 0.5,
                    child: ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        color: Colors.yellow,
                        height: MediaQuery.of(context).size.height/4.5,
                      ),
                    ),),
                  Opacity(opacity: 0.5,
                    child: ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        color: Colors.amber,
                        height:MediaQuery.of(context).size.height/4.5-(MediaQuery.of(context).size.height/50),
                      ),
                    ),
                  ),
                  Row(
                    children:[
                      Column(

                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height/10,
                            width: (75/100)*MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width/14,
                                top: MediaQuery.of(context).size.width/7
                            ),
                            child:Text("Bonjour " + docName + " !",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:  MediaQuery.of(context).size.height/40
                            ),) ,),
                          SizedBox(height: MediaQuery.of(context).size.width/200,),
                          Container(
                            padding: EdgeInsets.only(left:MediaQuery.of(context).size.width/14),
                            height: MediaQuery.of(context).size.height/9,
                            width: (75/100)*MediaQuery.of(context).size.width,
                            color: Colors.transparent,
                            child: Text(
                              getRandomHomeMessage(),
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height/57,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600]
                            ),),
                          )
                        ],),
                      Padding(padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width/10,
                          left: MediaQuery.of(context).size.width/10),
                          child:Icon(Icons.settings,size: MediaQuery.of(context).size.width/10,)
                      ),

                    ],),


                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/40,),

            Align(
                alignment: Alignment.topLeft,
                child:Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/14),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text("Bientôt périmé :",style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width/16
                      ),),
                      SizedBox(height: 3,),
                      Container(
                        height: MediaQuery.of(context).size.height/150,
                        width: MediaQuery.of(context).size.width/3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              colors: [
                                Colors.yellow.shade800,
                                Colors.yellow.shade700,
                                Colors.yellow.shade600,
                                Colors.yellow.shade500
                              ],
                              stops: [
                                0.0,
                                0.1,
                                0.4,
                                0.8,
                              ]
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: MediaQuery.of(context).size.height/500,),




        StreamBuilder<QuerySnapshot>(
          //stream: _usersStream,
          stream: (searching_text != "" && searching_text != null)
          /*
                ? FirebaseFirestore.instance
                    .collection('users')
                    .where('email',
                        isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('users')
                    .where('email',
                        isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .snapshots(),

              */
              ? _innerStream
              : _innerStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            return Stack(
            children: snapshot.data!.docs
        .map((DocumentSnapshot document) {
    Map<String, dynamic> data =
    document.data()! as Map<String, dynamic>;

    var temp_inv = data['inventory'];
    var searched_inv = [];
    var temp_len = 10;

    if (temp_inv.length <= temp_len) {
    temp_len = temp_inv.length;
    }

    for (int i = 0; i < temp_len; i++) {
    if (temp_inv[i]['nom']
        .contains(searchBarController.text)) {
    if (filterList[0] == true) {
    searched_inv.add(temp_inv[i]);
    }
    if (filterList[1] == true &&
    (temp_inv[i]['categories'].indexWhere((e) => [
    'dairies',
    'Viandes',
    'Fromages'
    ].contains(e)) >
    -1)) {
    //if(filterList[1] == true && temp_inv[i]['categories'].contains(['dairies','Viandes', 'Fromages'])){
    searched_inv.add(temp_inv[i]);
    }
    if (filterList[2] == true &&
    (temp_inv[i]['categories'].indexWhere((e) => [
    'groceries',
    'Céréales',
    'Biscuits'
    ].contains(e)) >
    -1)) {
    //if(filterList[2] == true && temp_inv[i]['categories'].contains(['groceries', 'Céréales', 'Biscuits'])){
    searched_inv.add(temp_inv[i]);
    }
    }
    }

    searched_inv.sort((a, b) {
    //sorting in ascending order
    return DateTime.parse(a['date-peremption'])
        .compareTo(
    DateTime.parse(b['date-peremption']));
    });

    if (temp_inv.isEmpty) {
    return Align(
    child: Column(
    children: [
    SizedBox(height: 20),
    Text("Votre inventaire est vide !"),
    ],
    ),
    );
    } else {
    return
      Container(
          height: (48/100)*MediaQuery.of(context).size.height,
        child: RawScrollbar(
          thumbVisibility: true,
          thumbColor: Colors.amber,
          thickness: MediaQuery.of(context).size.width/40,
          radius: Radius.circular(50),
          child: ListView.separated(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              separatorBuilder: (context,index){
                return SizedBox(height: MediaQuery.of(context).size.height/400,);
              },
              shrinkWrap: true,
              itemCount: searched_inv.length,
              itemBuilder: (context,index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width/20,
                      vertical: MediaQuery.of(context).size.height/200),
                  child:Container(
                      height: MediaQuery.of(context).size.height/6.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[100],
                          boxShadow: [BoxShadow(
                              offset: Offset(0, 0),
                              blurRadius: 1.5,
                              spreadRadius: 1.5,
                              color: Colors.black26
                          )
                          ]
                      ),

                      padding: EdgeInsets.all(MediaQuery.of(context).size.width/40),
                      child: Column(
                        children: [

                          Row(
                            children: [
                              Container(
                                width:MediaQuery.of(context).size.height/150,
                                height: MediaQuery.of(context).size.height/50,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.center,
                                        colors: [
                                          Colors.yellow.shade800,
                                          Colors.yellow.shade700,
                                          Colors.yellow.shade600,
                                          Colors.yellow.shade500
                                        ],
                                        stops: [
                                          0.0,
                                          0.1,
                                          0.4,
                                          0.8,
                                        ]
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width/40,),
                              Text("Produit : ",style: TextStyle(
                                  color: Colors.grey[800],
                                  fontStyle: FontStyle.italic
                              ),),
                              Text(searched_inv[index]['nom'],style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),)
                            ],
                          ),
                          Divider(
                            thickness: 2,
                            indent: 10,
                            endIndent: 20,
                          ),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(

                                  searched_inv[index]['image'],
                                  fit: BoxFit.cover,
                                  height: MediaQuery.of(context).size.height/20,
                                  width: MediaQuery.of(context).size.width/3.6,
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width/10,),
                              Column(

                                children: [
                                  Text(searched_inv[index]["date-peremption"],



                                    style: TextStyle(
                                      color : getColorComparingDate(DateTime.parse(searched_inv[index]["date-peremption"]), DateTime.now()),
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width/20
                                    ),),
                                  SizedBox(height: MediaQuery.of(context).size.height/100,),
                                  Text("Date de péremption",style: TextStyle(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                      fontSize: MediaQuery.of(context).size.width/30

                                  ),)
                                ],
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width/25,),
                              IconButton(
                                icon : Icon(Icons.restore_from_trash_outlined),
                                color: Colors.red,
                                iconSize: MediaQuery.of(context).size.width/10,
                              onPressed: () {

                                showDialog<String>(
                                    context: context,
                                    builder : (BuildContext context) => delete_aliment(data: searched_inv,index: index));

                              },

                              ),
                            ],)
                        ],
                      )
                  ),);
              }
          ),
        )
    );
              }})
                  .toList()
                  .cast(),
            );
          },
        ),

/*
            Container(
                height: 330,
                child: RawScrollbar(
                  thumbVisibility: true,
                  thumbColor: Colors.amber,
                  thickness: 8,
                  radius: Radius.circular(50),
                  child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      physics: BouncingScrollPhysics(),
                      separatorBuilder: (context,index){
                        return SizedBox(height: 5,);
                      },
                      shrinkWrap: true,
                      itemCount: 10,
                      itemBuilder: (context,index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                          child:Container(
                              height: 130,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[100],
                                  boxShadow: [BoxShadow(
                                      offset: Offset(0, 0),
                                      blurRadius: 1.5,
                                      spreadRadius: 1.5,
                                      color: Colors.black26
                                  )
                                  ]
                              ),

                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [

                                  Row(
                                    children: [
                                      Container(
                                        width:5,
                                        height: 14,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.center,
                                                colors: [
                                                  Colors.yellow.shade800,
                                                  Colors.yellow.shade700,
                                                  Colors.yellow.shade600,
                                                  Colors.yellow.shade500
                                                ],
                                                stops: [
                                                  0.0,
                                                  0.1,
                                                  0.4,
                                                  0.8,
                                                ]
                                            ),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Text("Produit : ",style: TextStyle(
                                          color: Colors.grey[800],
                                          fontStyle: FontStyle.italic
                                      ),),
                                      Text("Nom du produit",style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),)
                                    ],
                                  ),
                                  Divider(
                                    thickness: 2,
                                    indent: 10,
                                    endIndent: 20,
                                  ),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(

                                          "https://www.aquaportail.com/pictures2001/nourriture-saine-fruits-legumes.jpg",
                                          fit: BoxFit.cover,
                                          height: 78.0,
                                          width: 100.0,
                                        ),
                                      ),
                                      SizedBox(width: 40,),
                                      Column(

                                        children: [
                                          Text("25/02/2022",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20
                                            ),),
                                          SizedBox(height: 10,),
                                          Text("Date de péremption",style: TextStyle(
                                              color: Colors.grey[500],
                                              fontStyle: FontStyle.italic,
                                              fontSize: 13

                                          ),)
                                        ],
                                      ),
                                      SizedBox(width: 30,),
                                      Icon(Icons.restore_from_trash_outlined,color: Colors.red,size: 40,)
                                    ],)
                                ],
                              )
                          ),);
                      }
                  ),
                )
            ),

 */
            SizedBox(height: MediaQuery.of(context).size.height/40,),

                RawMaterialButton(
                  onPressed: () async {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => add_aliment());
                  },
                  elevation: 2.0,
                  fillColor: Colors.yellow[600]!,
                  child: Icon(
                    Icons.add,
                    size: MediaQuery.of(context).size.height/20,
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.all(15),
                  shape: CircleBorder(),
                ),


          ],

        )
    );



    /*
       SingleChildScrollView(child:Container(
         color: Colors.white,
        child:Column(
           children: [
                    Container(
                   height: 150,
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                         bottomLeft: Radius.circular(30)
                       ),
                       border: Border.all(color: Colors.white,width: 1.2),
                       gradient: LinearGradient(
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight,
                         colors:[
                           Colors.yellow[200] as Color,
                           Colors.yellow[500] as Color,
                           Colors.yellow[600] as Color,

                         ]
                       )
                   ),
                   child: Row(
                     children: [
                       Padding(
                           padding: EdgeInsets.only(top: 50,left: 20),
                           child:Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Container(
                                   width: 300,
                                   height: 80,
                                   child:Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                 Expanded(flex: 0,child:Text("Bonjour machin...",style: TextStyle(
                                     fontSize: 25,
                                     fontStyle: FontStyle.italic,
                                   fontWeight: FontWeight.bold
                                 ),),),
                                 SizedBox(height: 10,),
                                 Expanded(flex:1,child:Text("Message inspirant de ouf qu'il faut mettre",style: TextStyle(
                                     fontSize: 19,
                                     fontStyle: FontStyle.italic,
                                     color: Colors.grey[500]
                                 ),)),
                               ],)),

                             ],
                           )
                       ),
                       SizedBox(width: 5,),
                      CircleAvatar(

                             radius: 30,
                             backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"),
                           ),
                     ],
                   ),
                 ),






             SizedBox(height: 20,),
             Container(
               width: 300,
               padding: EdgeInsets.symmetric(horizontal: 30,vertical: 5),
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.only(
                   topLeft: Radius.circular(50),
                   topRight: Radius.circular(50),
                   bottomLeft: Radius.circular(50),
                   bottomRight: Radius.circular(50)
                 ),
                 border: Border.all(color:Colors.white as Color,width: 1.2),
                 color: Colors.yellow
               ),
               child:Text("Aliments",
                 textAlign: TextAlign.center,
                 style: TextStyle(
               fontSize: 40,
               fontStyle: FontStyle.italic,
               fontWeight: FontWeight.bold,
               color: Colors.black
             ),),),
             SizedBox(height: 15,),
             Container(
               width: 390,
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(
                   topRight: Radius.circular(20),
                   topLeft: Radius.circular(20)
                 ),
                 border: Border.all(color: Colors.grey[400] as Color,width: 1.2)
                 //border: Border.all(color: Colors.white,width: 1.5)
               ),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Padding(
                     padding: EdgeInsets.only(top: 20,left: 20,bottom: 10),
                     child:Text("Dates courtes : ",
                       style: TextStyle(
                   fontSize: 25,
                   fontWeight: FontWeight.bold
                 ),)),
                 Divider(
                   thickness: 2,
                 ),
                 SingleChildScrollView(
                   child: Scrollbar(
                     controller: scroll_controller,
                     thumbVisibility: true,
                     radius: Radius.circular(50),
                     thickness: 7,
                     child:Padding(
                     padding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                     child:Container(
                     height: 310,
                     child: ListView.separated(
                       separatorBuilder: (context,index){
                         return Divider(
                           thickness: 1,
                           color: Colors.grey[500],
                         );
                       },
                         itemCount: 10,
                         shrinkWrap: true,
                         itemBuilder: (context,index){
                           return Container(
                             decoration: BoxDecoration(
                               color: Colors.grey[50],
                               borderRadius: BorderRadius.circular(20)
                             ),

                             padding: EdgeInsets.all(5),
                             height: 100,
                             child: IntrinsicHeight(
                               child:
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.start,
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                 child:Image.network("https://media.istockphoto.com/photos/fast-food-items-like-hot-dogs-hamburgers-fries-and-pizza-picture-id180258510?k=20&m=180258510&s=612x612&w=0&h=GCtwnFdBO9WCOvW00g1ccU28yZJtyg0bXpcVHlVoT34=",height: 70,)),
                                 SizedBox(width: 10,),
                                 VerticalDivider(
                                   indent: 18,
                                   endIndent: 18,
                                   thickness: 1.5,
                                 ),
                                 Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                                 child:Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text("Nom du produit"),
                                     SizedBox(height: 10,),
                                     Text("Date de péremption")
                                   ],
                                 )
                                 ),
                               ],
                             ),
                           ),);
                         }),
                   ),),
                 )
                 ),
                 SizedBox(height: 10,),
               ],
               ),
             ),
             SizedBox(height: 30,),
             /*
             Container(
               padding: EdgeInsets.all(10),
               width: 350,
               decoration: BoxDecoration(
                   border: Border.all(color: Colors.grey,width: 1.3),
                 borderRadius: BorderRadius.circular(40),
                 color: Colors.yellow
               ),
                                   child:Row(
                   crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 ButtonTheme(
                   height: 500,
                     child: ElevatedButton(

                       onPressed: (){},
                       child: Icon(Icons.add),
                       style: ElevatedButton.styleFrom(
                         primary: Colors.black
                       ),
                     )),
                 SizedBox(width: 40,),
                 Icon(Icons.arrow_circle_left,size: 30,),
                 SizedBox(width: 10,),
                 Container(
                   width: 150,
                   child: Expanded(
                     child:Text("Ajouter votre produit en 2 clics")
                     ,
                   ),
                 )

               ],
                 ),
             ),
             */
            RawMaterialButton(
                onPressed: (){},
            elevation: 2.0,
            fillColor: Colors.yellowAccent,
            child: Icon(Icons.add,size: 50,color: Colors.black,),
            padding: EdgeInsets.all(15),
            shape: CircleBorder(),),
             SizedBox(height: 40,)

           ],

         ),
       ),
       ),
      */


  }
}

class WaveClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    debugPrint(size.width.toString());
    var path=new Path();
    path.lineTo(0, size.height-30);
    var firstStart=Offset(size.width/6,size.height-0);
    var firstEnd=Offset(size.width/2+10,size.height-0);

    path.quadraticBezierTo(firstStart.dx, firstStart.dy,firstEnd.dx, firstEnd.dy);

    var secondStart=Offset(size.width-60,size.height-0);
    var secondEnd=Offset(size.width,size.height-30);

    path.quadraticBezierTo(secondStart.dx, secondStart.dy,secondEnd.dx, secondEnd.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;

  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }



}
