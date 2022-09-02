import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tuasty/inventory/product.dart';
import 'package:short_uuids/short_uuids.dart';
import 'package:tuasty/recipes/recipes_page.dart';

import 'package:tuasty/screen/green_screen.dart';
import 'package:tuasty/screen/blue_screen.dart';
import 'package:tuasty/screen/red_screen.dart';
import 'package:tuasty/screen/yellow_screen.dart';
import 'package:tuasty/screen/purple_screen.dart';
import 'package:tuasty/inventory/inventory_page.dart';
import 'package:tuasty/inventory/accueil_page.dart';
import 'package:tuasty/inventory/shopping_list_page.dart';
import 'package:tuasty/parameters/parameters_screen.dart';
import 'package:tuasty/news/news_page.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:tuasty/notifications.dart';

import 'package:tuasty/parameters/constant.dart';


class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{
  final user = FirebaseAuth.instance.currentUser!;

  final currentUser = FirebaseAuth.instance;

  final myUserId = FirebaseAuth.instance.currentUser?.uid;


  var docRef = Map<String,dynamic>();
  var docName='';
  int perished_food = 0;
  int near_perished_food = 0;

  late final prefs;
  late Color appColor;



  late final _bottomNavigationBarItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.newspaper),
        label: 'NEWS',
        backgroundColor: Colors.yellow.shade800),
    BottomNavigationBarItem(icon: Icon(Icons.library_books),
      label: 'RECETTES',
      backgroundColor:  Colors.yellow.shade700,
    ),
    BottomNavigationBarItem(icon: Icon(Icons.home),
      label: 'HOME',
      backgroundColor: Colors.yellow.shade600,
    ),
    BottomNavigationBarItem(icon: Icon(Icons.kitchen),
      label: 'INVENTAIRE',
      backgroundColor: Colors.yellow.shade500,
    ),
    BottomNavigationBarItem(icon: Icon(Icons.note_add),
      label: "LISTE D'ENVIES",
      backgroundColor: Colors.yellow.shade400,
    ),

  ];




  void listenNotifications() =>
      NotificationWidget.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      print("Build Completed");
    });
  }





String getBodyNotification(int perished_food, int near_perished_food){

    String debut = "Vous avez : \n";
    String part1 = "";
    String part2 = "";


    if(perished_food == 0){
      part1 = "Aucun aliment périmé";
    }else if (perished_food == 1){
      part1 =  perished_food.toString() + " aliment périmé";
    }else{
      part1 = perished_food.toString() + " aliments périmés";
    }

    if(near_perished_food == 0){
      part2 = "aucun aliment qui va bientôt passer sa date";
    }else if (near_perished_food == 1){
      part2 =  near_perished_food.toString() + " aliment qui va bientôt passer sa date";
    }else{
      part2 = near_perished_food.toString() + " aliments qui vont bientôt passe leurs dates";
    }


    return debut + part1 + " et " + part2 + " !";





}



  Future _getUserData() async {

    var temp_inv = [];

    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()

        .then((value) {
      value.docs.forEach((element) {

        setState(()=> docName = element.id);
        setState(()=> docRef = element.data());
        //print(docName);
        print(docName.toString());
        //print("INV : " + docRef['inventory'][0]);


        temp_inv = docRef['inventory'];




      });
    });





    var perished_item = 0;
    var near_perished_item = 0;

    DateTime compdate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for(int i =0; i < temp_inv.length;i++){
      if(DateTime.parse(temp_inv[i]["date-peremption"]).isBefore(compdate)){
        perished_item ++;
        print("perimé");
        print(temp_inv[i]);
      }
      else if (DateTime.parse(temp_inv[i]["date-peremption"]).isBefore(compdate.add(Duration(days: 3)))){
        near_perished_item ++;
        print("proche périmé");
      }

    }

    print("PERIME BOSS");



    setState((){
      perished_food = perished_item;
      near_perished_food = near_perished_item;
    });


    tz.initializeTimeZones();
    NotificationWidget.init(scheduled: true);
    listenNotifications();

    print("ASTUCE");
    print(NotificationWidget().NotifDays);
    print(NotificationWidget().NotifHours);


    NotificationWidget.showScheduledNotification(
      title : "Voici le bilan de vos aliments",
      //body : "Vous avez : \n" + perished_food.toString() + " aliments périmés et " + near_perished_food.toString() + " aliments qui vont bientôt passer leurs dates !",
      body: getBodyNotification(perished_food, near_perished_food),
      payload: "Pas d'idées",
      scheduleTime: DateTime.now().add(Duration(seconds: 10)),

    );

    prefs = await SharedPreferences.getInstance();











  }

  @override
  void initState() {



    super.initState();

    _getUserData();















  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();

  }


  void removeItem(data, index){
    FirebaseFirestore.instance.collection('users')
        .doc(docName)
        .update({"inventory":FieldValue.arrayRemove([data?["inventory"][index]])});


  }


  void getPerishedAndLimitItemsNumber() {


    var temp_inv = docRef['inventory'];



    var perished_item = 0;
    var near_perished_item = 0;

    DateTime compdate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for(int i =0; temp_inv.length;i++){
      if(DateTime.parse(temp_inv[i]["date-peremption"]).isAfter(compdate)){
        perished_item ++;
      }
      else if (DateTime.parse(temp_inv[i]["date-peremption"]).isAfter(compdate.add(Duration(days: 2)))){
        near_perished_item ++;
      }

    }



    perished_food = perished_item;
    near_perished_food = near_perished_item;

  }









  //final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots();

  int _currentIndex = 2;
  final PageController _pageController = PageController(initialPage: 2);

  /*
  final _bottomNavigationBarItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.newspaper),
        label: 'NEWS',
        backgroundColor: Colors.blue),
    BottomNavigationBarItem(icon: Icon(Icons.library_books),
      label: 'COOKING',
      backgroundColor: Colors.green,
    ),
    BottomNavigationBarItem(icon: Icon(Icons.home),
      label: 'HOME',
      backgroundColor: Colors.yellow,
    ),
    BottomNavigationBarItem(icon: Icon(Icons.kitchen),
      label: 'INVENTORY',
      backgroundColor: Colors.purple,
    ),
    BottomNavigationBarItem(icon: Icon(Icons.note_add),
      label: 'LISTS',
      backgroundColor: Colors.red,
    ),

  ];
  */



  @override
  Widget build(BuildContext context) {
/*
         return Center(
          child: Column(

            children: [

              SizedBox(height:50),

              Text(
                "INVENTORY OF "+docName,
              ),

Text(
  docRef["inventory"][0],
),


/*

              ListView.builder(
                itemCount: docRef['inventory'].length,
                  itemBuilder: (context, index){
                  return Text("1");
                  }
              ),
*/


              SizedBox(height: 20),
              TextButton(onPressed: () {

                final product = {

                  "name":"produitdetest",
                  "code-barre": 0101,
                  "id" : ShortUuid().generate(),
                  "data":"25/25/2525",

    };

    FirebaseFirestore.instance.collection('users')
        .doc(docName)
        .update({"inventory":FieldValue.arrayUnion([product])});





              },
                  child: Text('Add Item to Inventory')
              ),
              SizedBox(height:40),
              TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: Text('SIGN OUT'),
              ),



            ],
          ),


        );

*/
/*

    return Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: Center(
          child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots(),
              builder: (context, snapshot) {

                if (snapshot.hasData) {

                  var data = snapshot.data?.docs[0];

                  return Center(
                    child: Column(

                      children: [

                        SizedBox(height:50),

                        Text(
                          "INVENTORY OF "+(data?.id).toString(),
                        ),






              ListView.builder(
                shrinkWrap: true,
                itemCount: data?['inventory'].length,
                  itemBuilder: (context, index){
                  return   Card(

                    child: ExpansionTile(
                      title: Text( data?['inventory'][index]['name']),
                      leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child : Text(index.toString()),
                      ),
                      children: <Widget>[
                        ListTile(
                          title: Text("Date : " + data?["inventory"][index]["date"]),



                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {

                              removeItem(data, index);

                            },
                          ),

                        ),
                        TextButton(
                            onPressed: () {


                            },
                            child: Text("MORE INFORMATIONS")
                        ),

                      ],
                    ),

                  );
                  }
              ),



                        SizedBox(height: 20),
                        TextButton(onPressed: () {

                          final product = {

                            "name":"produitdetest",
                            "code-barre": 0101,
                            "id" : ShortUuid().generate(),
                            "date":"25/25/2525",

                          };

                          FirebaseFirestore.instance.collection('users')
                              .doc(docName)
                              .update({"inventory":FieldValue.arrayUnion([product])});





                        },
                            child: Text('Add Item to Inventory')
                        ),
                        SizedBox(height:40),
                        TextButton(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          child: Text('SIGN OUT'),
                        ),



                      ],
                    ),


                  );
                } else {
                 return CircularProgressIndicator();
                }


              }
          ),
        )
    );


    */






    return Scaffold(
     // endDrawer: ParametersScreen(),

      /*
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        automaticallyImplyLeading: true,
        shape: Border(
            bottom: BorderSide(
                color: Colors.black,
                width: 2,
            )
        ),
        elevation: 4,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),

            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
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
      ),

       */

      body: PageView(
        //scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: (index){
          setState((){
            _currentIndex = index;
          });
        },


        children: [
          NewsPage(),
          DebugPage(),
          AccueilPage(),
          InventoryPage(),
          ShoppingListPage(),


        ],

      ),
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _currentIndex,
        onTap: (index) {
        /* _pageController.animateToPage(index,
              duration: Duration(seconds: 2),
              curve: Curves.ease);

         */
          _pageController.jumpToPage(index);
        },
        items: _bottomNavigationBarItems,
        //type: BottomNavigationBarType.fixed,






      ),

    );




/*
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context,i){
              var data = snapshot.data!.docs[i];
              return Column(
                children: [
                  //Text("Name : " + data['name']),
                  SizedBox(height:10),
                  Text("ID : " +snapshot.data!.docs[i].id),
                  SizedBox(height:10),
                  Text('Inventory : '),

                  TextButton(onPressed: () {
                    print(docRef);
                  },
                      child: Text('print inv'),
                  ),













                  SizedBox(height:40),

                  TextButton(
                      onPressed: () async{



                      final product = {
                        'name': 'nametestproduct',
                        'code-barre': 001,
                        "id" : ShortUuid().generate(),
                      };



                      /*


                     await FirebaseFirestore.instance.collection('users')
                          .withConverter(
                          fromFirestore: Product.fromFirestore,
                          toFirestore: (Product obj, options) => obj.toFirestore())
                      .doc(snapshot.data!.docs[i].id+"/inventory").set(obj);


                        FirebaseFirestore.instance.collection('users')
                            .doc(snapshot.data!.docs[i].id).collection("inventory")
                            .add({
                                  "code-barre" : 0001,
                                "name":"test",


                        })
                        */

                      FirebaseFirestore.instance.collection('users')
                          .doc(snapshot.data!.docs[i].id)
                      .update({"inventory":FieldValue.arrayUnion([product])});






                      },
                      child: Text('Add item to inventory')
                  ),

                  TextButton(onPressed: () => FirebaseAuth.instance.signOut(),
                      child: Text('SIGN OUT')),


                ],
            );
      },
    );

        */
  }

}









/*



  @override
  Widget build(BuildContext context){
    return Scaffold(

      appBar: AppBar(
        title: Text('HOME'),
      ),



      body:


      Container(

        child: Column(
          children: [

          Text(
          'Signed in as',
          style :  TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          user.email!,
          style : TextStyle(fontSize: 20),
        ),
        SizedBox(height:40),
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: Text('Logout'),
        ),

            SizedBox(height:40),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text('Add Item'),
            ),


      ],
        ),





      ),

      drawer: Drawer(

        child:Column(

          children: [


           StreamBuilder(
             stream : FirebaseFirestore.instance
                 .collection('users')
                 //.doc(FirebaseAuth.instance.currentUser!.uid)
             .where("uid", isEqualTo: currentUser.currentUser!.uid)
                 .snapshots(),
               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){

        if(snapshot.hasData){
                 return ListView.builder(
                     itemCount: snapshot.data!.docs.length,
                     shrinkWrap: true,
                     itemBuilder: (context,i){
                       var data = snapshot.data!.docs[i];
                   return Column(
                     children: [
                       Text("Name : " + data['name']),
                       Text("ID : " +snapshot.data!.docs[i].id),


                     ],

                   );
                 });

    } else{
                 return CircularProgressIndicator();
               }
    }





           ),

          ],

        ),



      ),
    );


  }
*/
